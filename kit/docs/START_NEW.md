# START_NEW.md — manual / fallback mode

> **For most apps, use `BOOTSTRAP_PROMPT.md` instead** — that's the
> agent-driven flow where Claude Code does everything (pulls the kit,
> creates Convex project, collects creds in chat, scaffolds). You answer
> ~3 questions in chat and watch.
>
> **Use this file (`START_NEW.md`) when:**
> - You want manual control over each step (debugging, custom flow)
> - You don't have Claude Code available
> - You're rebuilding after a failed `BOOTSTRAP_PROMPT.md` run and need to
>   intervene phase-by-phase
>
> **What this is:** the older single prompt to paste into Claude Code that
> takes a kit-prepared repo from `setup-secrets.sh` complete to all three
> services confirmed running on real targets.
>
> **When NOT to use:** existing monorepo that already has apps scaffolded —
> for those, see `BOOTSTRAP.md` (Phase 2).

---

## Pre-flight (your manual work, ~10 min — do these BEFORE pasting the prompt)

These pauses cost the most momentum if Claude Code hits them mid-flight. Knock them out first.

1. **Empty GitHub repo created.** Via GitHub Desktop with "Initialize this repository with a README" UNCHECKED. Open it in Cursor / VS Code.

2. **Kit pulled into the repo:**
   ```bash
   cd your-empty-repo
   npx degit s-411/monorepo-kit --force
   ```

3. **Convex project exists in dashboard.** Sign into [dashboard.convex.dev](https://dashboard.convex.dev), create a project, name it whatever you want. Note the team slug and project name from the URL: `dashboard.convex.dev/t/<TEAM>/<PROJECT>`.

4. **Clerk app exists with the auth flavour you want.** [dashboard.clerk.com](https://dashboard.clerk.com) → create an application. Default to email + 6-digit code (no password) for viral-launch apps; toggle whatever else you need.

5. **Clerk JWT template named "convex" configured.** In Clerk dashboard → JWT Templates → New template → choose "Convex" from the preset list. Save it. Then copy the **Issuer URL** field — you'll need it in the next step.

6. **Run `./kit/bin/setup-secrets.sh`** in the repo root. Interactive, ~3 minutes, collects every credential the king prompt will need and writes them to `.env.kit`.

7. **Verify Nanobanana MCP is connected** (used at later stages for in-app imagery and screenshots):
   ```bash
   claude mcp list | grep nanobanana
   ```
   If not connected, see installation in `kit/bin/setup-secrets.sh`'s output or the existing kit's `START_NEW.md` step 3a.

When all seven are done, paste the king prompt below.

---

## The king prompt

Paste the entire block below as your first message to Claude Code in this repo.

````
START NEW MONOREPO — Next.js + Expo + Convex + Clerk

Pre-flight by the user is complete:
- Repo is empty except for the kit (npx degit s-411/monorepo-kit --force has run)
- .env.kit exists at repo root, populated by ./kit/bin/setup-secrets.sh
- Convex project exists in dashboard
- Clerk app exists with JWT template "convex" configured
- Nanobanana MCP is connected

KIT-WIDE RULES (do NOT deviate, every one is a real-failure defence — see
KIT_RETROSPECTIVE.md):

R1. All Expo packages installed via `pnpm --filter mobile exec expo install`,
    never `pnpm add` (latest-on-npm ≠ SDK-aligned).
R2. All workspace dep specs use `workspace:^`, never `workspace:*` (zsh
    glob-expands the asterisk).
R3. Never `expo start` from the repo root. Always `cd apps/mobile` first or
    use `pnpm --filter mobile exec expo start --port <N>`.
R4. After `expo install --fix`, ALWAYS follow with `pnpm install` to
    materialise node_modules.
R5. Never `pnpm pkg set` — `pkg` is npm-only. Use `npm pkg set` if scripting,
    or edit package.json directly.
R6. Convex CLI is run non-interactively with explicit
    `--team --project --configure existing --dev-deployment cloud` flags.
R7. Clerk on Expo requires the FULL peer set installed via `expo install`:
    @clerk/clerk-expo expo-crypto expo-secure-store expo-web-browser
    expo-auth-session. Missing expo-crypto causes runtime crash on first
    device boot (passes bundle compile).

EXECUTE IN PHASES. After each phase, briefly confirm what happened. STOP and
ask me if anything fails or seems off — do not improvise fixes silently.

────────────────────────────────────────────────────────────────────────
PHASE 1 — Verify state, source creds
────────────────────────────────────────────────────────────────────────
- Print pwd. Confirm folder name reasonably matches a slug.
- Run `ls`. Confirm these all exist: package.json, pnpm-workspace.yaml,
  turbo.json, .npmrc, .gitignore, README.md, .env.kit, kit/, packages/.
  Inside kit/, confirm kit/docs/, kit/bin/, kit/templates/ exist.
- Source .env.kit and confirm WORKING_SLUG, CONVEX_TEAM, CONVEX_PROJECT,
  NEXT_PUBLIC_CLERK_PUBLISHABLE_KEY, CLERK_SECRET_KEY,
  EXPO_PUBLIC_CLERK_PUBLISHABLE_KEY, CLERK_JWT_ISSUER_URL are all set
  (echo names + first 8 chars of each value, never log the secret in full).
- Run `pnpm --version`. If pnpm is missing, STOP.

────────────────────────────────────────────────────────────────────────
PHASE 2 — Set workspace name + install root deps
────────────────────────────────────────────────────────────────────────
- Source .env.kit, then update root package.json name field:
    npm pkg set name="$WORKING_SLUG"
- Run `pnpm install` at repo root. Should complete cleanly (the @kit/*
  workspace packages from packages/ resolve as workspace members).

────────────────────────────────────────────────────────────────────────
PHASE 3 — Scaffold apps/web (Next.js 16)
────────────────────────────────────────────────────────────────────────
- mkdir -p apps && cd apps
- pnpm create next-app@latest web \
    --ts --tailwind --eslint --app --src-dir \
    --import-alias "@/*" --use-pnpm --no-turbopack
- cd ..
- Verify: apps/web/package.json, apps/web/src/app/page.tsx exist.
- IMPORTANT: Next 16 renamed middleware.ts → proxy.ts. Anywhere that says
  "middleware" in this prompt or kit docs, the actual file is proxy.ts in
  apps/web/src/. Note this in apps/web/AGENTS.md (create if absent).

────────────────────────────────────────────────────────────────────────
PHASE 4 — Scaffold apps/mobile (Expo + expo-router)
────────────────────────────────────────────────────────────────────────
- cd apps
- pnpm create expo-app mobile --template tabs --yes
- cd ..
- Verify: apps/mobile/app.json, apps/mobile/app/_layout.tsx,
  apps/mobile/package.json exist.
- Apply the kit's monorepo-aware Metro config:
    cp kit/templates/apps/mobile/metro.config.js apps/mobile/metro.config.js
- Add the dev script to apps/mobile/package.json (this is the fix for B4 —
  without it `turbo run dev --filter=mobile` silently no-ops):
    cd apps/mobile && npm pkg set scripts.dev="expo start" && cd ../..
- Optional but recommended: pin a port to avoid 8081 collisions with other
  Expo projects. Edit apps/mobile/package.json scripts.dev to:
    "expo start --port 8082"
  (or whatever port is free for this user).

────────────────────────────────────────────────────────────────────────
PHASE 5 — Install Clerk + Convex deps on both apps (R1, R2, R7)
────────────────────────────────────────────────────────────────────────
Web (uses pnpm add — these are NOT expo packages):
    pnpm --filter web add convex @clerk/nextjs '@kit/backend@workspace:^' \
      '@kit/theme@workspace:^' '@kit/shared@workspace:^'

Mobile (uses expo install for the Clerk peer set per R7, then pnpm add for
non-expo packages):
    pnpm --filter mobile exec expo install \
      @clerk/clerk-expo expo-crypto expo-secure-store expo-web-browser \
      expo-auth-session
    pnpm --filter mobile add convex '@kit/backend@workspace:^' \
      '@kit/theme@workspace:^' '@kit/shared@workspace:^'

Note the SINGLE QUOTES around workspace specs (R2). Without them, zsh
glob-expands and the install fails.

After both apps are done, run the install ritual (R4):
    pnpm --filter mobile exec expo install --fix
    pnpm install

────────────────────────────────────────────────────────────────────────
PHASE 6 — Initialise Convex (R6) and wire auth.config.ts (C3)
────────────────────────────────────────────────────────────────────────
- cd packages/backend
- Source .env.kit values and run NON-INTERACTIVELY:
    npx convex dev --once \
      --team "$CONVEX_TEAM" \
      --project "$CONVEX_PROJECT" \
      --configure existing \
      --dev-deployment cloud
- This populates packages/backend/.env.local with CONVEX_DEPLOYMENT and the
  deployment URL. Capture the URL — it looks like
  https://<random-name>.convex.cloud.
- cd ../..
- Substitute the Clerk JWT issuer into auth.config.ts. The kit ships with
  packages/backend/convex/auth.config.ts.template containing the placeholder
  <CLERK_JWT_ISSUER_URL>. Generate the live file:
    sed "s|<CLERK_JWT_ISSUER_URL>|$CLERK_JWT_ISSUER_URL|g" \
      packages/backend/convex/auth.config.ts.template \
      > packages/backend/convex/auth.config.ts
- Run convex dev once more so the new auth config is pushed:
    cd packages/backend && npx convex dev --once && cd ../..

────────────────────────────────────────────────────────────────────────
PHASE 7 — Distribute env vars to apps
────────────────────────────────────────────────────────────────────────
Read the Convex deployment URL from packages/backend/.env.local (the
CONVEX_URL variable; if absent, run `npx convex info` from packages/backend).

Write apps/web/.env.local:
    NEXT_PUBLIC_CONVEX_URL=<the convex.cloud URL>
    NEXT_PUBLIC_CLERK_PUBLISHABLE_KEY=<from .env.kit>
    CLERK_SECRET_KEY=<from .env.kit>

Write apps/mobile/.env:
    EXPO_PUBLIC_CONVEX_URL=<the convex.cloud URL>
    EXPO_PUBLIC_CLERK_PUBLISHABLE_KEY=<from .env.kit>

────────────────────────────────────────────────────────────────────────
PHASE 8 — Wire ClerkProvider + ConvexProviderWithClerk on both apps
────────────────────────────────────────────────────────────────────────
Web — apps/web/src/app/layout.tsx:
- Wrap the existing root layout's children in <ClerkProvider> from
  @clerk/nextjs and <ConvexProviderWithClerk> from convex/react-clerk.
- Use the official patterns from:
    https://clerk.com/docs/quickstarts/nextjs
    https://docs.convex.dev/auth/clerk

Web — apps/web/src/proxy.ts (NOT middleware.ts in Next 16):
- Add clerkMiddleware() per Clerk's Next 16 docs. If proxy.ts doesn't exist
  yet, create it.

Mobile — apps/mobile/app/_layout.tsx:
- Wrap with <ClerkProvider tokenCache={tokenCache} publishableKey={...}>
  and <ConvexProviderWithClerk>.
- tokenCache uses expo-secure-store per Clerk's official Expo quickstart:
    https://clerk.com/docs/quickstarts/expo

Do NOT implement sign-in or sign-up screens yet. The goal of this phase is
that the providers compile and don't throw at boot. Sign-in UI ships in a
later stage.

────────────────────────────────────────────────────────────────────────
PHASE 9 — Boot gate (E1: real device-load, not just bundle compile)
────────────────────────────────────────────────────────────────────────
Run:
    ./kit/bin/boot-gate.sh

This script:
- Starts `convex dev` (packages/backend), `next dev` (apps/web), and
  `expo start` (apps/mobile) in parallel
- Waits for all three to spin up
- Asks the operator to confirm each service is actually rendering on its
  target before exiting 0
- Convex: log shows schema sync, no errors
- Web: open http://localhost:3000 in browser, page renders, no console errors
- Mobile: scan QR with Expo Go on a REAL DEVICE, app renders the default
  tabs template

If the mobile boot fails with `Cannot find native module 'ExpoCryptoAES'`,
that's the missing-peer-dep crash from D1 — re-run Phase 5's Clerk peer
install. Do NOT continue past Phase 9 without all three confirmed.

────────────────────────────────────────────────────────────────────────
PHASE 10 — Initial commit
────────────────────────────────────────────────────────────────────────
    git add .
    git commit -m "Stage 1 complete: monorepo bootstrap (web + mobile + Convex + Clerk)"

────────────────────────────────────────────────────────────────────────
END OF STAGE 1 — REPORT BACK
────────────────────────────────────────────────────────────────────────
Confirm:
- ✓ pnpm + turborepo monorepo initialised
- ✓ apps/web (Next.js 16) scaffolded, ClerkProvider + ConvexProviderWithClerk wired
- ✓ apps/mobile (Expo SDK X) scaffolded, full Clerk peer set installed,
   metro.config.js monorepo-ready, "dev": "expo start" added to scripts
- ✓ packages/backend Convex initialised, auth.config.ts wired with Clerk
   issuer, deployment URL captured
- ✓ packages/theme + packages/shared placeholders in place
- ✓ Env vars distributed to both apps
- ✓ Boot gate confirmed all three services on real targets
- ✓ Initial commit landed (hash + branch)

Then STOP and wait for the next-stage prompt.
````

---

## Things to watch during execution

**The Convex non-interactive incantation matters.** If `--configure existing` errors with "project not found", the user skipped pre-flight #3 (create the project in the dashboard). Have them do that, then re-run Phase 6.

**`pnpm install` peer-warnings on Clerk's React range are harmless.** Clerk wants `~19.0.3 || ~19.1.4 || ~19.2.3`; Expo SDK 54 ships React 19.1.0 which satisfies the range. The warning print is cosmetic (D2).

**The boot gate is the gate.** Don't let it slip — bundle compile success is not boot success. The fail mode in D1 (missing `expo-crypto`) only shows up when JS executes on a device.

**If anything in Phase 5 looks like it's installing the wrong version for Expo packages**, abort and verify the install used `expo install` not `pnpm add`. That's R1.
