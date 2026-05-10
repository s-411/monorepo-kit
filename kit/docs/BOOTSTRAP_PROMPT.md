# BOOTSTRAP_PROMPT.md — paste into Claude Code in an empty folder

> **What this is:** the single prompt for fully agent-driven monorepo bootstrap.
> The user opens Claude Code in an empty folder and pastes the entire body of
> this file (everything below the horizontal rule). Claude Code does the rest,
> asking ~3 questions in chat.
>
> **Replaces** the old manual-mode flow in `START_NEW.md`. Use this for every
> new monorepo unless you specifically need manual control (debugging,
> non-standard setup, etc.) — `START_NEW.md` is kept around as the fallback.

---

## Pre-conditions (one-time per machine, not per app)

These are the only things you need to install/log-into before the prompt
will work. The agent will check each one in Phase 1 and pause if any are
missing.

1. **pnpm** installed: `pnpm --version` should print a version.
2. **Node.js** ≥ 20 installed: `node --version` should print v20.x or higher.
3. **Convex account exists** at https://dashboard.convex.dev (sign-up is free).
4. **Convex CLI authed**: run `npx convex login` once. Pops a browser; sign in
   with your Convex account; closes itself when done.
5. **Clerk account exists** at https://dashboard.clerk.com (sign-up is free).
6. **(Optional) `gh` CLI authed** if you want the agent to create the GitHub
   repo and push for you. Run `gh auth status` to check; `gh auth login` if
   not authed. If you don't have `gh`, the agent will skip the GitHub step
   and you can push manually later.

That's it. Do those once and they cover all future apps.

---

## How to use

1. **Create an empty folder** anywhere on your machine. Naming convention is
   up to you — `~/Documents/GitHub/<slug>/`, `~/Documents/GitHub/monorepo-apps/<slug>/`,
   `~/code/<slug>/`, all fine.
2. **(Optional) Place a `handoff/` folder at the root** if you have product
   spec / reference material (e.g., the seven-doc handoff bundle PhotoMaxxing
   uses). Leave it out if you don't.
3. **Open Claude Code in that folder** and paste the entire body below
   (everything after the horizontal rule), with the REQUIRED fields filled in
   at the top.

The agent will:
- Verify pre-conditions
- Pull the kit
- Create a Convex project automatically (no dashboard visit)
- Walk you through ~3 minutes of Clerk dashboard setup, then collect the
  keys in chat
- Write `.env.kit` itself
- Run all scaffolding (Next.js, Expo, Convex CLI, Clerk peer set, Metro
  config, providers wiring)
- Boot-gate (asks you to confirm web + mobile rendering on real targets)
- (If `gh` is authed) Create the GitHub repo and push

---

````
BOOTSTRAP NEW MONOREPO — Next.js + Expo + Convex + Clerk

REQUIRED FIELDS — replace each <bracketed> placeholder before pasting:

- App slug: <photomaxxing>
  (lowercase, letters/digits/hyphens only; becomes the workspace name AND
   the GitHub repo name AND the Convex project name; pick something short
   and unambiguous)
- Purpose: <one-liner about the app — what it does, who it's for>
- Stack overlays beyond baseline: <none | stripe | resend | revenuecat | sentry | posthog | combinations>
  (the baseline is Convex + Clerk; overlays ship as Phase-N work, not Stage 1)
- Handoff folder at repo root: <yes | no>
  (if "yes", agent leaves /handoff/ alone — it's product reference for later)
- Create GitHub repo and push: <yes-public | yes-private | no>
  (requires `gh` CLI authed; agent will check)

Any field still in <brackets>: STOP and ask the operator to fill it in.

You are the agent driving a fully automated monorepo bootstrap. The user has
opened Claude Code in an empty folder and pasted this prompt. They will
answer ~3 questions in chat (Convex team slug, then Clerk credentials in one
batch); everything else you do yourself.

KIT-WIDE RULES (do NOT deviate, every one is a real-failure defence — see
kit/docs/KIT_RETROSPECTIVE.md after Phase 1 completes):

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
    `--team --project --configure (new|existing) --dev-deployment cloud` flags.
R7. Clerk on Expo requires the FULL peer set installed via `expo install`:
    @clerk/clerk-expo expo-crypto expo-secure-store expo-web-browser
    expo-auth-session. Missing expo-crypto causes runtime crash on first
    device boot (passes bundle compile).

EXECUTE IN PHASES. After each phase, briefly confirm what happened. STOP and
ask if anything fails — do not improvise fixes silently.

────────────────────────────────────────────────────────────────────────
PHASE 1 — Verify pre-conditions and folder state
────────────────────────────────────────────────────────────────────────
Run these checks. STOP after the first failure with a clear message about
what the operator needs to do.

- `pwd` — confirm you're in the right folder; folder name should reasonably
  match the app slug (warn if wildly different, but don't block).
- `ls -A` — folder should contain only `.git/` and optionally `handoff/`.
  Anything else: STOP and ask if it's safe to proceed.
- `pnpm --version` — must print a version. If missing, STOP with install
  instructions: `npm install -g pnpm`.
- `node --version` — must be v20+. If older, STOP and tell the operator to
  upgrade Node.
- `npx convex whoami` — should print the operator's Convex email. If errors
  ("not logged in"), STOP and tell them to run `npx convex login` (pops a
  browser).
- `gh auth status 2>&1` — only check if user said yes-public/yes-private for
  GitHub repo creation. If not authed, downgrade silently to "skip GitHub
  step" and proceed; tell the operator at the end how to push manually.

────────────────────────────────────────────────────────────────────────
PHASE 2 — Pull the kit
────────────────────────────────────────────────────────────────────────
- Run: `npx degit s-411/monorepo-kit --force`
- Verify root now has: README.md, package.json, pnpm-workspace.yaml,
  turbo.json, .npmrc, .gitignore, kit/, packages/. Plus handoff/ if user
  said yes for that.
- Verify kit/ contains: kit/docs/, kit/bin/, kit/templates/.

────────────────────────────────────────────────────────────────────────
PHASE 3 — Convex project (no dashboard visit needed)
────────────────────────────────────────────────────────────────────────
Ask the operator:

  "I need your Convex team slug. Open https://dashboard.convex.dev and
  look at any URL there — it's the part right after `/t/`. For example,
  in `dashboard.convex.dev/t/steven-harris/some-project`, the team slug
  is `steven-harris`. Just paste the slug (no slashes, no full URL)."

WAIT for response. Validate response matches `^[a-z0-9-]+$`. If not, ask
again — patiently. Common mistakes:
  - Pasted full URL → extract the part after /t/
  - Capital letters → reject, slugs are lowercase
  - Spaces → reject

Once valid, store as $CONVEX_TEAM. Use the app slug as $CONVEX_PROJECT.

Run from the repo root (NOT from packages/backend — convex CLI handles cwd):
  cd packages/backend && \
    npx convex dev --once \
      --configure new \
      --team "$CONVEX_TEAM" \
      --project "$APP_SLUG" \
      --dev-deployment cloud && \
    cd ../..

This creates the Convex project AND a dev deployment. NO DASHBOARD VISIT.

If `--configure new` errors with "project already exists", that means the
operator did pre-create one (or this slug was used before). Re-run with
`--configure existing` instead. Don't fail — just retry once.

Read packages/backend/.env.local to capture CONVEX_DEPLOYMENT and the
deployment URL (the https://<random-name>.convex.cloud). Store as
$CONVEX_URL for Phase 5.

────────────────────────────────────────────────────────────────────────
PHASE 4 — Clerk dashboard work (one focused 3-min interruption)
────────────────────────────────────────────────────────────────────────
Tell the operator EXACTLY this (verbatim — it's calibrated to be the
minimum interruption):

  "Now I need 3 minutes of focused setup in the Clerk dashboard. Please:
  
   1. Open https://dashboard.clerk.com and sign in.
   2. Click '+ Create application'. Name it `<APP_SLUG>` (or whatever).
      Pick auth providers — email + 6-digit code is the simplest default;
      you can always add more later.
   3. Once the app is created, in the left sidebar click 'API Keys'. Copy
      both:
        - Publishable key (starts with `pk_test_`)
        - Secret key (starts with `sk_test_`)
   4. In the left sidebar click 'JWT Templates' → 'New template' →
      choose 'Convex' from the preset list → Save. Copy the 'Issuer URL'
      field (looks like `https://<random>.clerk.accounts.dev`).
   
   Paste all three values back here in any order — I'll figure out which
   is which from their format. No need to label them."

WAIT for response. Parse the response:
  - Find the publishable key: regex `pk_(test|live)_[a-zA-Z0-9_-]+`
  - Find the secret key: regex `sk_(test|live)_[a-zA-Z0-9_-]+`
  - Find the issuer URL: regex `https://[a-zA-Z0-9.-]+\.clerk\.accounts\.dev`

If any of the three are missing or malformed, ask again with specific
guidance (e.g., "I see the publishable and secret keys, but I don't see
a Clerk issuer URL. It's the URL field in the JWT template you created.").

Once all three are valid, write .env.kit at the repo root with EXACTLY this
content (substituting values):

    # .env.kit — generated by Claude Code via BOOTSTRAP_PROMPT
    # Read by Phase 5+; distributed to subapp .env files there.
    # DO NOT COMMIT (covered by .gitignore via .env*).
    
    WORKING_SLUG=<APP_SLUG>
    
    CONVEX_TEAM=<CONVEX_TEAM>
    CONVEX_PROJECT=<APP_SLUG>
    
    NEXT_PUBLIC_CLERK_PUBLISHABLE_KEY=<pk>
    EXPO_PUBLIC_CLERK_PUBLISHABLE_KEY=<pk>
    CLERK_SECRET_KEY=<sk>
    
    CLERK_JWT_ISSUER_URL=<issuer>

Then `chmod 600 .env.kit` so it's owner-only readable.

────────────────────────────────────────────────────────────────────────
PHASE 5 — Set workspace name, install root deps
────────────────────────────────────────────────────────────────────────
- npm pkg set name="$APP_SLUG"
- pnpm install
  Should complete cleanly — workspace packages from packages/ resolve as
  workspace members.

────────────────────────────────────────────────────────────────────────
PHASE 6 — Scaffold apps/web (Next.js 16)
────────────────────────────────────────────────────────────────────────
- mkdir -p apps && cd apps
- pnpm create next-app@latest web \
    --ts --tailwind --eslint --app --src-dir \
    --import-alias "@/*" --use-pnpm --no-turbopack
- cd ..
- Verify: apps/web/package.json, apps/web/src/app/page.tsx exist.
- Note: Next 16 renamed middleware.ts → proxy.ts.

────────────────────────────────────────────────────────────────────────
PHASE 7 — Scaffold apps/mobile (Expo + expo-router)
────────────────────────────────────────────────────────────────────────
- cd apps && pnpm create expo-app mobile --template tabs --yes && cd ..
- Verify: apps/mobile/app.json, apps/mobile/app/_layout.tsx,
  apps/mobile/package.json exist.
- Apply the kit's monorepo-aware Metro config:
    cp kit/templates/apps/mobile/metro.config.js apps/mobile/metro.config.js
- Add the dev script (B4 fix):
    cd apps/mobile && npm pkg set scripts.dev="expo start --port 8082" && cd ../..

────────────────────────────────────────────────────────────────────────
PHASE 8 — Install Clerk + Convex deps on both apps (R1, R2, R7)
────────────────────────────────────────────────────────────────────────
Web:
    pnpm --filter web add convex @clerk/nextjs '@kit/backend@workspace:^' \
      '@kit/theme@workspace:^' '@kit/shared@workspace:^'

Mobile:
    pnpm --filter mobile exec expo install \
      @clerk/clerk-expo expo-crypto expo-secure-store expo-web-browser \
      expo-auth-session
    pnpm --filter mobile add convex '@kit/backend@workspace:^' \
      '@kit/theme@workspace:^' '@kit/shared@workspace:^'

SINGLE QUOTES around workspace specs (R2). After both apps:
    pnpm --filter mobile exec expo install --fix
    pnpm install

────────────────────────────────────────────────────────────────────────
PHASE 9 — Wire auth.config.ts (Convex side of Clerk integration)
────────────────────────────────────────────────────────────────────────
Substitute the JWT issuer into the template that ships in the kit:
    sed "s|<CLERK_JWT_ISSUER_URL>|<issuer>|g" \
      packages/backend/convex/auth.config.ts.template \
      > packages/backend/convex/auth.config.ts

Push the new auth config:
    cd packages/backend && npx convex dev --once && cd ../..

────────────────────────────────────────────────────────────────────────
PHASE 10 — Distribute env vars to apps
────────────────────────────────────────────────────────────────────────
Write apps/web/.env.local:
    NEXT_PUBLIC_CONVEX_URL=<CONVEX_URL>
    NEXT_PUBLIC_CLERK_PUBLISHABLE_KEY=<pk>
    CLERK_SECRET_KEY=<sk>

Write apps/mobile/.env:
    EXPO_PUBLIC_CONVEX_URL=<CONVEX_URL>
    EXPO_PUBLIC_CLERK_PUBLISHABLE_KEY=<pk>

────────────────────────────────────────────────────────────────────────
PHASE 11 — Wire ClerkProvider + ConvexProviderWithClerk on both apps
────────────────────────────────────────────────────────────────────────
Web — apps/web/src/app/layout.tsx:
- Wrap children in <ClerkProvider> (from @clerk/nextjs) and
  <ConvexProviderWithClerk> (from convex/react-clerk).
- Reference: https://clerk.com/docs/quickstarts/nextjs and
  https://docs.convex.dev/auth/clerk

Web — apps/web/src/proxy.ts (NOT middleware.ts in Next 16):
- Add clerkMiddleware() per Clerk's Next 16 docs. Create the file if absent.

Mobile — apps/mobile/app/_layout.tsx:
- Wrap with <ClerkProvider tokenCache={tokenCache} publishableKey={...}>
  and <ConvexProviderWithClerk>. tokenCache uses expo-secure-store per
  https://clerk.com/docs/quickstarts/expo

DO NOT implement sign-in/sign-up screens. Goal of this phase: providers
compile and don't throw at boot.

────────────────────────────────────────────────────────────────────────
PHASE 12 — Replace root README with project placeholder
────────────────────────────────────────────────────────────────────────
The kit ships a generic placeholder README at the repo root. Replace it
with a minimal app-specific one. Overwrite README.md with:

    # <APP_SLUG>
    
    <Purpose line — copy from REQUIRED FIELDS>
    
    ## Repo layout
    
    - `apps/web/` — Next.js 16 web app
    - `apps/mobile/` — Expo SDK 54+ mobile app
    - `packages/backend/` — Convex deployment (schema, functions, auth)
    - `packages/theme/`, `packages/shared/` — shared design tokens and code
    - `handoff/` — product reference (if applicable)
    - `kit/` — `s-411/monorepo-kit` snapshot (docs, scripts, templates)

────────────────────────────────────────────────────────────────────────
PHASE 13 — Boot gate (E1: real device-load, not just bundle compile)
────────────────────────────────────────────────────────────────────────
Run: ./kit/bin/boot-gate.sh

It starts convex dev + next dev + expo start in parallel and prompts the
operator to confirm each service rendering on its target. The OPERATOR
confirms — you watch the script's output and surface any errors that
appear in the .boot-gate-logs/.

If mobile boots fail with `Cannot find native module 'ExpoCryptoAES'`,
that's the missing-peer-dep crash from D1 — re-run Phase 8's Clerk peer
install. Do NOT continue past Phase 13 without all three confirmed.

────────────────────────────────────────────────────────────────────────
PHASE 14 — GitHub repo + push (only if "yes" in REQUIRED FIELDS)
────────────────────────────────────────────────────────────────────────
Skip this phase if user said "no" or `gh` wasn't authed in Phase 1.

If yes-public:
    gh repo create "$APP_SLUG" --public --source=. --remote=origin
If yes-private:
    gh repo create "$APP_SLUG" --private --source=. --remote=origin

Then push:
    git add .
    git commit -m "Stage 1 complete: monorepo bootstrap (web + mobile + Convex + Clerk) on $APP_SLUG"
    git push --set-upstream origin main

If `gh repo create` fails because the remote already exists, that's fine —
just commit and push to whatever remote is configured.

────────────────────────────────────────────────────────────────────────
PHASE 15 — Initial commit (only if Phase 14 was skipped)
────────────────────────────────────────────────────────────────────────
Skip this if Phase 14 ran (already committed).

    git add .
    git commit -m "Stage 1 complete: monorepo bootstrap (web + mobile + Convex + Clerk) on $APP_SLUG"

Tell the operator how to add a remote later:
    "When you're ready to push to GitHub, create the repo (any way you
    like — GitHub Desktop, web UI, gh CLI), then:
       git remote add origin <repo-url>
       git push --set-upstream origin main"

────────────────────────────────────────────────────────────────────────
END OF STAGE 1 — REPORT BACK
────────────────────────────────────────────────────────────────────────
Confirm to the operator:
- ✓ Pre-conditions met (pnpm, node, convex login, [optionally gh])
- ✓ Kit pulled from s-411/monorepo-kit (kit/ folder structure intact)
- ✓ Convex project "$APP_SLUG" created on team "$CONVEX_TEAM" with dev
   deployment, URL: <CONVEX_URL>
- ✓ Clerk credentials collected, .env.kit written + chmod'd 600
- ✓ apps/web (Next.js 16) scaffolded, ClerkProvider + ConvexProviderWithClerk
   wired
- ✓ apps/mobile (Expo SDK X) scaffolded, full Clerk peer set installed,
   monorepo Metro config copied, "dev": "expo start --port 8082" added
- ✓ packages/backend Convex initialised with auth.config.ts
- ✓ Env vars distributed to both apps
- ✓ Root README replaced with project placeholder
- ✓ Boot gate confirmed all three services on real targets
- ✓ Initial commit landed [+ pushed to GitHub if Phase 14 ran]

Then STOP and wait for the next-stage prompt. Stage 2 onwards is
app-specific (e.g., for PhotoMaxxing it's porting handoff/PORT/ files per
handoff/06_BUILD_ORDER.md).
````

---

## Things that can go wrong + recovery

**`npx convex login` errors with "could not open browser":** the operator is
on a headless box or the browser isn't available. They can authenticate
manually via `npx convex login --device` and follow the prompt. Pause the
prompt's Phase 1 until that's done.

**Clerk JWT template's Issuer URL field is empty:** the operator forgot to
hit Save on the template. Tell them to go back, save, then copy.

**Convex `--configure new` says "project already exists":** the slug was
previously used. Either pick a new slug, or use `--configure existing`. Don't
silently nuke their existing project.

**`gh repo create` says "name already exists":** the operator already created
the repo via dashboard. Skip creation, just configure the remote:
    `git remote add origin https://github.com/<user>/<slug>.git`
then push.

**Boot gate fails on mobile with native module errors:** classic D1 — peer
dep missing. Re-run Phase 8's Clerk peer install. Don't try to debug deeper.

**Operator gets impatient and closes the chat mid-build:** state is on disk.
They can re-paste this prompt later; the agent should detect existing files
and skip already-done phases (e.g., if `apps/web/package.json` exists, skip
Phase 6).
