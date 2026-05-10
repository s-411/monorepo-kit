# monorepo-kit

A drop-in kit for spinning up production-ready monorepos: **Next.js + Expo + Convex + Clerk**, on pnpm workspaces and Turborepo.

Use this when you need:
- Two frontend apps (web + mobile) sharing one backend
- Shared design tokens and business logic across both
- A defensive setup that survives the 20 real failures documented in `KIT_RETROSPECTIVE.md`

Don't use this for:
- Single-app projects → use [`drop-in-kit`](https://github.com/s-411/drop-in-kit) (RN/Expo) or [`nextjs-kit`](https://github.com/s-411/nextjs-kit) (Next.js)
- Monorepos without Convex or Clerk — the kit assumes both as the auth/data spine

---

## What you get

```
your-app/
├── apps/
│   ├── web/                Next.js 16 (App Router, proxy.ts middleware)
│   └── mobile/             Expo SDK 54+ (expo-router, monorepo-aware Metro)
├── packages/
│   ├── backend/            Convex + auth.config.ts wired to Clerk
│   ├── theme/              Shared design tokens (web Tailwind + mobile NativeWind)
│   └── shared/             Cross-platform business logic, types
├── kit/
│   ├── docs/               README, KING_PROMPTS, START_NEW, KIT_RETROSPECTIVE, etc.
│   ├── bin/
│   │   ├── setup-secrets.sh    Collects all creds upfront, writes .env.kit
│   │   └── boot-gate.sh        Real device-load gate, not just bundle compile
│   └── templates/          Drop-in config files (metro, etc.)
└── (root configs: package.json, pnpm-workspace.yaml, turbo.json, .gitignore, .npmrc)
```

The `kit/` folder collects all kit material in one place so the consumer's repo root stays clean. Root configs (`package.json`, `pnpm-workspace.yaml`, `turbo.json`, `.npmrc`, `.gitignore`) and `packages/` MUST stay at root because pnpm and Turbo expect them there.

---

## Quick start

In an empty folder anywhere on your machine (no naming convention required):

1. **One-time setup per machine** (skip if already done):
   - Install pnpm: `npm install -g pnpm`
   - Sign up for Convex (free): https://dashboard.convex.dev
   - Authenticate Convex CLI: `npx convex login`
   - Sign up for Clerk (free): https://dashboard.clerk.com
   - (Optional) Authenticate `gh` CLI for auto-push: `gh auth login`

2. **Open Claude Code in your empty folder** and paste the body of
   `kit/docs/BOOTSTRAP_PROMPT.md` (with the REQUIRED fields filled in
   at the top — slug, purpose, stack, etc.).

3. **Answer ~3 questions in chat:**
   - Your Convex team slug (one-liner)
   - Three Clerk credentials in one batch (after a 3-min dashboard visit)

That's it. The agent pulls the kit, creates the Convex project, walks you
through Clerk setup, scaffolds Next.js + Expo, wires Clerk + Convex on
both, and boot-gates all three services on real targets.

For manual / debug control, `kit/docs/START_NEW.md` is the older "you do
all the pre-flight by hand" prompt. Use it if you want to drive each step
yourself.

---

## Stack

| Layer | Choice |
|---|---|
| Monorepo | pnpm workspaces + Turborepo |
| Web | Next.js 16 (App Router) |
| Mobile | Expo SDK 54+ (expo-router) |
| Backend | Convex (single deployment, both apps consume) |
| Auth | Clerk (`@clerk/nextjs` + `@clerk/clerk-expo`, single publishable key) |
| Bridge | `ConvexProviderWithClerk` on both apps |
| Deploy | Vercel (web), EAS (mobile) |

Stripe is **not** in the baseline. It ships as a Phase-N overlay when you need payments.

---

## Why the design looks the way it does

Every non-obvious decision in this kit was made because something failed in the first real monorepo bootstrap. Read `KIT_RETROSPECTIVE.md` before changing any template file or shell script — the 20 entries there are the kit's design spec.

Highlights:
- `.npmrc` uses `node-linker=hoisted` because Expo's monorepo support assumes it (defends against the `expo/AppEntry.js` trap from the repo root)
- `apps/mobile/package.json` ships with `"dev": "expo start"` already in scripts (without it, `turbo run dev` silently no-ops)
- `kit/bin/setup-secrets.sh` collects every credential up front so the build doesn't pause for input mid-flight
- `kit/bin/boot-gate.sh` requires explicit operator confirmation that the app rendered on a device — bundle compile success is not enough
- All workspace dep specs use `workspace:^` (zsh glob-expands `workspace:*`)
- All Expo packages installed via `expo install`, never `pnpm add` (latest-on-npm ≠ SDK-aligned)
- Kit material lives under `kit/` so the consumer's repo root stays uncluttered (their root has only configs, `packages/`, `apps/`, `kit/`, and whatever they add)

---

## See also

- `BOOTSTRAP_PROMPT.md` — the agent-driven king prompt (new default flow)
- `START_NEW.md` — manual-mode king prompt (fallback / debugging)
- `KIT_RETROSPECTIVE.md` — the 20+ real failures that shaped this kit's defensive design
- `BOOTSTRAP.md` — verification checklist (Phase 2)
- `PROCESS_GUIDE.md` — full 16-stage pipeline (Phase 3)
- `CHEATSHEET.md` — the 20 gotchas distilled for at-a-glance (Phase 3)
