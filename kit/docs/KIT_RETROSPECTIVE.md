# KIT_RETROSPECTIVE.md

> Real failures from the Stage 1 monorepo bootstrap of the celebrity-fitness app
> (May 2026). This is the design spec for `monorepo-kit` — every item here is a
> defensive measure the kit must bake in. Read this before changing any template
> file or shell script in the kit.

---

## A. pnpm-specific issues

### A1. `pnpm pkg set` doesn't exist

`pnpm --filter mobile pkg set "expo.install.exclude[0]=react-native"` failed —
pnpm interpreted `pkg` as a script name and errored with `None of the selected
packages has a "pkg" script`. `pkg` is npm-only.

**Kit fix:** scaffold the `expo.install.exclude` field directly into the
`apps/mobile/package.json` template. Don't use `pnpm pkg` anywhere in
instructions or scripts.

### A2. Zsh glob-expands `workspace:*` specs

`pnpm --filter web add convex @move-club/backend@workspace:*` failed with
`no matches found: @move-club/backend@workspace:*` because zsh tried to expand
the `*`. Single-quoting fixes it: `'@move-club/backend@workspace:*'`.

**Kit fix:** standardise on `workspace:^` (no `*`) in all instructions. Same
workspace behaviour, no glob risk, no quoting required.

### A3. `packageManager: pnpm@9.0.0` pin caused corepack to silently downgrade

User had pnpm 11.0.8 installed; corepack honoured the pinned 9.0.0 and
downloaded it. Worked but cost ~5 seconds and made `pnpm --version` confusing.

**Kit fix:** drop the `packageManager` field from the template root
`package.json`, OR detect the installed pnpm at setup time and pin to that.

---

## B. Expo monorepo issues (the big category)

### B1. `pnpm add <expo-package>` installs the wrong version

`pnpm add @clerk/clerk-expo expo-secure-store` grabbed `expo-secure-store@55.0.13`
(latest npm) but Expo SDK 54 expects `~15.0.8`. Must use `expo install` for any
Expo-prefixed package — it picks the SDK-aligned version.

**Kit fix:** put a single rule at the top of the kit: "All `expo-*` packages:
use `pnpm --filter mobile exec expo install <pkg>`. Never `pnpm add`."

### B2. `expo install --fix` updates package.json but doesn't materialise node_modules

After `expo install --fix` bumped `expo-secure-store` to `^15.0.8`, the actual
`node_modules/expo-secure-store/package.json` was still `55.0.13`. Required a
follow-up `pnpm install` to actually swap.

**Kit fix:** document and script the two-step ritual:
`expo install --fix && pnpm install`.

### B3. `expo/AppEntry.js` trap when running `expo start` from the wrong directory

The worst gotcha. If you `cd <workspace-root> && npx expo start`, Expo can't
find the right entry, falls back to legacy `expo/AppEntry.js`, which does
`import App from '../../App'`, which resolves to `<workspace-root>/App.tsx` —
which doesn't exist → cryptic error. The fix is just "run from `apps/mobile/`"
but the error gives no hint.

**Kit fix (multi-layer defence):**
- Add a root `Makefile` or `kit/bin/dev-mobile.sh` that always `cd apps/mobile`
- Document: "Never `expo start` from the repo root in a monorepo"
- Add `node-linker=hoisted` to `.npmrc` (Expo's official monorepo recommendation)
  so the legacy entry path works defensively
- Optionally drop a stub `App.tsx` at workspace root that re-exports from
  `expo-router/entry` so the legacy fallback succeeds

### B4. Expo template doesn't ship a `dev` script — Turbo silently does nothing

`turbo run dev --filter=mobile` returned `WARNING: No tasks were executed` and
exit 0. Looked like success, was actually a no-op. Had to add `"dev": "expo start"`
to `apps/mobile/package.json` manually.

**Kit fix:** the kit's `apps/mobile/package.json` template MUST include
`"dev": "expo start"` explicitly.

### B5. Metro config changes require `--clear` on next start

Adding the SVG transformer to `metro.config.js` served stale config until
`expo start --clear`. 10 minutes of debugging.

**Kit fix:** every kit instruction that modifies `metro.config.js` ends with
"restart Metro with `--clear`". Add a `kit/bin/dev-mobile.sh` flag for it.

### B6. Port collisions — Expo's interactive prompt fails in background processes

When another project held 8081 and Metro started in the background, Expo errored
with `Input is required, but 'npx expo' is in non-interactive mode`.

**Kit fix:** the kit's mobile dev script explicitly passes `--port <N>` (chosen
once and pinned per repo). Document the multi-project port-conflict pattern.

### B7. Multiple stale Metros on different ports caused Expo Go to hit the wrong server

Three Metros running across 8081/8082/8083 at one point; Expo Go cached
connections to dead ones. Scanning a fresh QR doesn't always evict the cache.

**Kit fix:** include `kit/bin/kill-metros.sh` (`pkill -f "expo start"`). Document
that force-quitting Expo Go on the device is sometimes required.

---

## C. Convex setup issues

### C1. `convex dev --configure new` requires interactive team selection

When the user has multiple Convex teams, the CLI uses an arrow-key TUI which
breaks under piped stdin: `Cannot prompt for input in non-interactive terminals`.

**Kit fix:** the kit asks for the Convex team slug upfront as a setup variable,
then uses `--team <slug> --project <name> --configure existing
--dev-deployment cloud` — fully non-interactive.

### C2. `--configure new` vs `--configure existing` ambiguity

If the project already exists in the Convex dashboard, `--configure new` either
errors or duplicates.

**Kit fix:** default to `--configure existing` and document that the user
creates the Convex project via the dashboard UI first (30 seconds). Use
`--configure new` only on truly fresh setups.

### C3. Convex `auth.config.ts` JWT issuer is manual

Required pulling the Issuer URL from Clerk Dashboard → JWT Templates → "Convex"
template. No automation. Easy to skip and only discover the breakage later when
auth tokens don't validate.

**Kit fix:** include a checklist line in `START_NEW.md`: "after creating Clerk
app, go to JWT Templates, create a 'Convex' template, copy Issuer URL → write
to `packages/backend/convex/auth.config.ts`." Ship a template file with a
single `<CLERK_ISSUER_URL>` placeholder.

---

## D. Clerk + Expo issues

### D1. Missing peer dep `expo-crypto` — runtime crash on first device boot

Installed `@clerk/clerk-expo`; the peer-dep warning for `expo-crypto` was buried
in install output. The boot test passed (bundle compiled fine). The phone
crashed with `Cannot find native module 'ExpoCryptoAES'` only when the JS
actually executed on device.

**Kit fix:** the kit's Clerk install step always installs the full peer set:

```bash
pnpm --filter mobile exec expo install \
  @clerk/clerk-expo \
  expo-crypto \
  expo-secure-store \
  expo-web-browser \
  expo-auth-session
```

### D2. Clerk's React peer range is grumpy in monorepos

`@clerk/react` wants `~19.0.3 || ~19.1.4 || ~19.2.3`; Expo SDK 54 ships React
19.1.0. Result: pnpm prints peer-dep warnings on every install. Non-blocking
but spammy.

**Kit fix:** document that these warnings are expected and harmless. Optionally
include a `.pnpmfile.cjs` snippet to silence them.

---

## E. Verification gaps

### E1. The "boot gate" curl test was misleading

Curling `/node_modules/expo-router/entry.bundle?...` returned HTTP 200 + 17.6 MB
and Stage 1 was declared done. But that only proves the bundle TRANSFORMS — it
doesn't prove the bundle RUNS. Native module errors (D1) only manifest at JS
execution time on a device.

**Kit fix:** the boot gate must require an actual device load (Expo Go or
simulator) and a "Hello World" rendered visibly, not just a successful bundle
compile. `kit/bin/boot-gate.sh` waits for explicit user confirmation that the app
appeared on a device before exiting 0.

---

## F. Kit-as-process issues

### F1. The existing drop-in kits assume single-app structure

`drop-in-kit` and `nextjs-kit` PROCESS_GUIDE.md, file paths (`src/theme/theme.ts`),
and conventions all assume `apps/mobile/`-style isn't a thing. Worked OK because
they were placed in `_kit/` as reference, but anywhere they prescribe a path,
manual translation was required.

**Kit fix:** keep both existing kits unchanged (they serve non-monorepo
projects). Build `monorepo-kit` as the third kit with monorepo-aware paths
throughout. Optionally include a `MONOREPO_OVERLAY.md` that maps every
single-app convention to its monorepo equivalent for cross-reference.

### F2. Credentials collected ad-hoc, not upfront

Stage 1 paused twice for credentials (Convex team, Clerk keys). Each pause cost
momentum.

**Kit fix:** ship `kit/bin/setup-secrets.sh` that prompts for ALL required
credentials at the start (Convex team slug, Clerk publishable + secret,
optionally Stripe/Resend/RevenueCat/Sentry/PostHog keys for later stages) and
writes them to the right `.env*` files in one pass.

### F3. Default `.gitignore` was too narrow

`.env`, `.env.local`, `.env.*.local` didn't catch `.env.steve` (personal scratch
file). Could have leaked secrets if `git add -A` was run blindly.

**Kit fix:** default `.gitignore` is broader:

```
.env*
!.env.example
.vscode/
.DS_Store
```

### F4. SVG asset processing was ad-hoc

Every Figma SVG export had `var(--fill-X, #color)` CSS-var fills that
`react-native-svg` doesn't parse. Required `sed` per asset.

**Kit fix:** include `kit/bin/process-figma-svgs.sh` — a one-shot script that scans
`apps/mobile/assets/` for SVGs and inlines all `var(--fill-X, #...)` references.

### F5. Kit material cluttered the consumer's repo root

Original kit shipped 5 docs (`README.md`, `KING_PROMPTS.md`, `START_NEW.md`,
`KIT_RETROSPECTIVE.md`, `HOW_TO_USE_THIS_PROJECT.md`) plus `bin/` and
`templates/` folders directly at repo root. After `npx degit`, the consumer's
working tree was visually dominated by kit reference material rather than
their own code, with seven kit-related items at root competing with `apps/`,
`packages/`, and any product-specific folders the consumer added.

The two `bin/` shell scripts also resolved `REPO_ROOT="$SCRIPT_DIR/.."` —
hardcoding the assumption that the script lives one level deep from root.
Moving them anywhere broke pathing; the assumption was the constraint.

**Kit fix:** consolidate kit material under a single `kit/` folder
(`kit/docs/`, `kit/bin/`, `kit/templates/`). Root keeps only what pnpm and
Turbo require there: the four root configs, `.gitignore`, `.npmrc`,
`packages/`, and the eventual `apps/`. Bin scripts use
`REPO_ROOT="$SCRIPT_DIR/../.."` (two levels up) so they work from
`kit/bin/`. Root README is replaced with a project placeholder pointing at
`kit/docs/` for kit orientation; the kit's own README lives at
`kit/docs/README.md`.

---

## Proposed kit structure (expanded from this retrospective)

```
monorepo-kit/
  README.md                        — minimal project README placeholder
                                     (consumer overwrites with their own)
  package.json                     — root configs, must stay at root for
  pnpm-workspace.yaml                pnpm/Turbo to find them
  turbo.json
  .npmrc                           — node-linker=hoisted (defensive for Expo)
  .gitignore                       — broad .env* + .vscode/

  packages/                        — workspace packages, must stay at root
    theme/                         — placeholder tokens
    backend/
      package.json                 — exposes convex/_generated
      convex/auth.config.ts.template — Clerk JWT issuer placeholder
    shared/

  kit/                             — all kit material consolidated under here
                                     so the consumer's repo root stays clean
    docs/
      README.md                    — 5-minute setup story
      KIT_RETROSPECTIVE.md         — this file
      BOOTSTRAP.md                 — verification checklist
      STACK_PROFILES.md            — Convex+Clerk | Convex+Clerk+Stripe
      PROCESS_GUIDE.md             — 16 stages, monorepo-aware paths
      CHEATSHEET.md                — the 20 gotchas distilled for at-a-glance
      AGENTS.md                    — Next 16 proxy.ts, monorepo gotchas, etc.
      PROMPTS.md                   — per-stage prompts (only stages that DIFFER
                                     from existing kits)
      CREDENTIALS.md               — one-time external setup
      REF_DOCS_INDEX.md            — pointers to ~/Documents/GitHub/ref-docs

    templates/
      apps/mobile/
        package.json               — INCLUDES "dev": "expo start" by default
        metro.config.js            — monorepo-ready (workspaceRoot watch + symlinks)
        svg.d.ts                   — for react-native-svg-transformer
        app.json                   — usesNonExemptEncryption: false baked in
      apps/web/
        …                          — Next 16 ready, with proxy.ts (NOT middleware.ts)

    bin/
      setup-secrets.sh             — interactive: collects all creds, writes .env files
      install-deps.sh              — pnpm install + expo install --fix sequence
      process-figma-svgs.sh        — inlines var(--fill-X) references
      kill-metros.sh               — pkill -f "expo start"
      boot-gate.sh                 — runs convex:dev + dev:mobile + dev:web AND
                                     waits for user confirmation of device load
      dev-mobile.sh                — always cds to apps/mobile, supports --clear

    legal/
      privacy.template.md
      terms.template.md
```

**Why this layout (the `kit/` folder pattern, F5 fix):** when `npx degit s-411/monorepo-kit --force` lands in a consumer's empty repo, kit material drops into a single `kit/` subfolder rather than scattering 5+ docs and 2+ folders at the repo root. The consumer's working tree stays focused on `apps/`, `packages/`, and their own files; kit reference material is one click away under `kit/`. Root configs and `packages/` MUST stay at root because pnpm-workspace.yaml looks for `packages/` there and pnpm/Turbo read the root configs from root.

---

## Cross-reference: every issue → fix surface

| # | Issue | Fix lives in |
|---|-------|--------------|
| A1 | `pnpm pkg set` not real | `kit/templates/apps/mobile/package.json` |
| A2 | zsh glob `workspace:*` | All docs use `workspace:^` |
| A3 | `packageManager` pin | `kit/templates/package.json` (omitted) |
| B1 | `pnpm add` for expo pkgs | `START_NEW.md` rule, `kit/bin/install-deps.sh` |
| B2 | `expo install --fix` ritual | `kit/bin/install-deps.sh` |
| B3 | wrong-cwd `expo start` trap | `kit/bin/dev-mobile.sh`, `.npmrc`, `START_NEW.md` |
| B4 | missing `dev` script | `kit/templates/apps/mobile/package.json` |
| B5 | metro `--clear` | `kit/bin/dev-mobile.sh --clear` flag |
| B6 | port collision interactive | `kit/bin/dev-mobile.sh --port` flag |
| B7 | stale Metros / Go cache | `kit/bin/kill-metros.sh` |
| C1 | Convex non-interactive | `kit/bin/setup-secrets.sh`, `START_NEW.md` |
| C2 | configure new vs existing | `START_NEW.md` defaults to `existing` |
| C3 | JWT issuer manual | `auth.config.ts.template` + `START_NEW.md` checklist |
| D1 | expo-crypto runtime crash | `START_NEW.md` Clerk install step (full peer set) |
| D2 | React peer warnings | `CHEATSHEET.md` "expected" entry |
| E1 | boot gate too lax | `kit/bin/boot-gate.sh` waits for device confirm |
| F1 | single-app assumptions | new kit, `MONOREPO_OVERLAY.md` |
| F2 | creds ad-hoc | `kit/bin/setup-secrets.sh` |
| F3 | narrow `.gitignore` | `kit/templates/.gitignore` |
| F4 | SVG var fills | `kit/bin/process-figma-svgs.sh` |
| F5 | kit clutters repo root + scripts hardcode `SCRIPT_DIR/..` | move all kit material under `kit/`, scripts use `SCRIPT_DIR/../..`, ship project-placeholder root README |
