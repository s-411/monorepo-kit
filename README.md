# Your project

> Replace this README with your project's own description after pulling the kit.

This monorepo was bootstrapped from [s-411/monorepo-kit](https://github.com/s-411/monorepo-kit) — a drop-in kit for **Next.js + Expo + Convex + Clerk** monorepos on pnpm workspaces and Turborepo.

## Repo layout

```
.
├── apps/                 (created during Stage 1)
│   ├── web/              Next.js 16
│   └── mobile/           Expo SDK 54+
├── packages/
│   ├── backend/          Convex deployment (schema, functions, auth)
│   ├── theme/            Shared design tokens
│   └── shared/           Shared business logic, types
├── kit/                  Kit material (docs, scripts, templates)
│   ├── docs/             README, KING_PROMPTS, START_NEW, KIT_RETROSPECTIVE, etc.
│   ├── bin/              setup-secrets, boot-gate, etc.
│   └── templates/        Drop-in config files (metro, etc.)
├── package.json          (root)
├── pnpm-workspace.yaml
├── turbo.json
├── .npmrc
└── .gitignore
```

## Where to start

- **Bootstrapping a new app from this kit:** [`kit/docs/README.md`](./kit/docs/README.md), then [`kit/docs/HOW_TO_USE_THIS_PROJECT.md`](./kit/docs/HOW_TO_USE_THIS_PROJECT.md).
- **The king prompt for Claude Code:** [`kit/docs/START_NEW.md`](./kit/docs/START_NEW.md).
- **Why the kit looks the way it does:** [`kit/docs/KIT_RETROSPECTIVE.md`](./kit/docs/KIT_RETROSPECTIVE.md) — 20 real failures the kit defends against.

## Browsing this on GitHub?

This repo serves a dual purpose: it IS the kit (browsable here on GitHub) AND it's what gets dropped into a fresh repo via `npx degit s-411/monorepo-kit --force`. When that happens, this README is what the consumer sees first — they're expected to overwrite it with their own project README. Kit-level orientation lives in [`kit/docs/`](./kit/docs/).
