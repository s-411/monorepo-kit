# CHEATSHEET.md

> One-line gotchas distilled from KIT_RETROSPECTIVE.md. Scan when something
> behaves oddly; if it matches an entry, the kit already has a defence — the
> retrospective entry tells you which file or script holds the fix.
>
> Format: **ID. Symptom** → fix or defence.

---

## pnpm

- **A1.** `pnpm pkg set` fails with "no pkg script" → use `npm pkg set` or edit `package.json` directly. `pkg` is npm-only.
- **A2.** `workspace:*` errors with "no matches found" → use `workspace:^` everywhere (zsh glob-expands `*`).
- **A3.** `pnpm --version` shows older pnpm than installed → no `packageManager` field in root `package.json`; corepack honours pins.
- **G1.** `pnpm create *` aborts with `ERR_PNPM_IGNORED_BUILDS` → root `pnpm-workspace.yaml` `allowBuilds:` must be populated with real `true` booleans.
- **G1b.** "Aborting installation" after a scaffold failure → check `ls apps/<scaffolded>/` before re-running; scaffold likely partially succeeded.
- **G1c.** New placeholder entries appear in `pnpm-workspace.yaml` after `pnpm add` → run `kit/bin/fix-allowbuilds.sh`. pnpm 11 auto-appends.

## Expo monorepo

- **B1.** Expo packages installed at wrong version → always `pnpm --filter mobile exec expo install <pkg>`, never `pnpm add`.
- **B2.** After `expo install --fix`, `node_modules` still has old version → follow with `pnpm install`. Or use `kit/bin/install-deps.sh`.
- **B3.** Cryptic `App.tsx` resolution error → never `expo start` from repo root. Use `kit/bin/dev-mobile.sh` or `cd apps/mobile && expo start`.
- **B4.** `turbo run dev --filter=mobile` no-ops with "No tasks executed" → `apps/mobile/package.json` must have `"dev": "expo start"`. Kit template ships with it.
- **B5.** `metro.config.js` edits don't take effect → restart Metro with `--clear`: `kit/bin/dev-mobile.sh --clear`.
- **B6.** Port collision; `expo start` "in non-interactive mode" → pin a port: `expo start --port <N>`. `dev-mobile.sh` supports `--port` pass-through.
- **B7.** Expo Go connects to a dead Metro on another port → `kit/bin/kill-metros.sh`. Force-quit Expo Go on device if cache persists.

## Convex

- **C1.** `convex dev --configure new` hangs on team selection → use non-interactive flags: `--team <slug> --project <name> --configure existing --dev-deployment cloud`.
- **C2.** `--configure new` errors when project already exists → default to `--configure existing`. Create the Convex project via dashboard first.
- **C3.** Auth tokens don't validate against Convex → `packages/backend/convex/auth.config.ts` needs the Clerk JWT issuer URL (Clerk Dashboard → JWT Templates → "convex" → Issuer URL).

## Clerk + Expo

- **D1.** `Cannot find native module 'ExpoCryptoAES'` on device boot → missing peer dep. Install the full Clerk peer set via `expo install @clerk/clerk-expo expo-crypto expo-secure-store expo-web-browser expo-auth-session`.

## Verification

- **E1.** Bundle compile success ≠ app boots on device → use `kit/bin/boot-gate.sh`. Requires explicit operator confirmation of device load, not just bundle HTTP 200.

## Kit-as-process

- **F1.** Drop-in kits assume single-app structure → use `monorepo-kit` instead. Don't retrofit single-app kits.
- **F2.** Build pauses for credentials mid-flight → run `kit/bin/setup-secrets.sh` first. Collects everything upfront.
- **F3.** `.env.steve` (or similar personal scratch file) snuck into a commit → kit's `.gitignore` uses broad `.env*` + `!.env.example`.
- **F4.** Figma SVGs render blank in `react-native-svg` → `kit/bin/process-figma-svgs.sh` inlines `var(--fill-X, #color)` references.

## Scaffolders + ai-files

- **G2.** Stray `pnpm-workspace.yaml` or `pnpm-lock.yaml` inside `apps/web` or `apps/mobile` → `START_NEW.md` Phases 3 and 4 each `rm -f` the strays. Only root should have these.
- **G3.** Referenced `kit/bin/<script>.sh` doesn't exist → all four previously-aspirational scripts (`install-deps`, `kill-metros`, `dev-mobile`, `process-figma-svgs`) plus `fix-allowbuilds` now ship.
- **P6.** `boot-gate.sh` asks "Is Convex rendering on its target?" → Convex doesn't render. Wording now points to log signals: `functions ready`, no schema/auth errors.
- **P7.** `convex/`, `AGENTS.md`, `.agents/`, `.claude/skills/` appear at repo root → don't run `npx convex ai-files install` from repo root in a monorepo. Run from `packages/backend/`. Kit's `.gitignore` ignores `.agents/` and `.claude/skills/` defensively.

---

## Benign warnings (expected — no action needed)

- **D2.** pnpm prints peer-dep warnings for Clerk's React range → expected. `@clerk/react` wants `~19.0.3 || ~19.1.4 || ~19.2.3`; Expo SDK 54 ships React 19.1.0 which satisfies it. Warnings are cosmetic.
- **P9.** `tsc` warns "Unused @ts-expect-error directive" in `apps/mobile/components/ExternalLink.tsx` → expected. Upstream Expo tabs template ships this; newer TypeScript no longer requires the directive. Not a kit issue.
- **P10.** `expo-doctor` warns about `watchFolders` + `resolver.unstable_enableSymlinks` mismatch in `apps/mobile/metro.config.js` → expected. This is the kit's intentional B3 defence per Expo's official monorepo guide. Benign.

---

## When in doubt

Read the full entry in `kit/docs/KIT_RETROSPECTIVE.md` — it has "Observed / Why it's a kit gap / Kit fix" structure with more context than fits in a one-liner here.
