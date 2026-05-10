# How to use this Claude.ai project

This project is the **strategic command center** for building monorepo apps with `monorepo-kit` (Next.js + Expo + Convex + Clerk on pnpm workspaces + Turborepo).

It is NOT where code is executed. Code lives in your repo, executed via Claude Code. This project is where you talk to Claude.ai to plan, debug, and orchestrate.

---

## The two-tool pattern

| Tool | Role | What you paste here |
|---|---|---|
| **Claude.ai (this project)** | Strategic brain — planning, debugging, prompt engineering, decisions | King prompts from `KING_PROMPTS.md` |
| **Claude Code (in your repo)** | Hands — file edits, command execution, scaffolding | The customised `START_NEW.md` block (or stage prompt) that Claude.ai prepares for you |

You DON'T paste `START_NEW.md` here. You paste the **king prompt** here. Claude.ai then prepares the customised `START_NEW.md` block for you to paste into **Claude Code**.

---

## The systematic build flow

For each new monorepo app, the flow is:

### 1. Pre-build setup (your terminal, ~10 min)

```bash
# Empty GitHub repo, Initialize OFF, cloned locally
cd your-empty-repo
npx degit s-411/monorepo-kit --force
./bin/setup-secrets.sh   # collects all creds → .env.kit
```

Plus: confirm Convex project + Clerk app exist, JWT template named `convex` is set up, Nanobanana MCP is connected. Full pre-flight checklist is in `KING_PROMPTS.md` Scenario A.

### 2. Strategic kickoff (this Claude.ai project, fresh sub-chat)

- Open a **new chat** in this project
- Paste `KING_PROMPTS.md` Scenario A with the fields filled in
- Claude.ai confirms plan, asks any clarifying questions, and prepares the `START_NEW.md` king prompt customised for your app

### 3. Execution (Claude Code in your repo)

- Open Claude Code in the cloned repo
- Paste the prompt Claude.ai prepared for you
- Claude Code runs Phases 1–10 from `START_NEW.md`
- Watch each phase complete; if anything fails, Claude Code stops and surfaces the error
- Bring the error back to the Claude.ai chat for debugging

### 4. Subsequent stages (back to Claude.ai)

- Stage 2+ work happens chat-by-chat in this Claude.ai project
- For each stage, Claude.ai prepares the prompt for Claude Code based on the app's specifics, the kit's process docs, and any Figma / design / API references you've attached to the chat
- Iterate until the app ships

---

## What's in this project's knowledge

| File | Purpose |
|---|---|
| `README.md` | 5-min orientation to the kit |
| `KIT_RETROSPECTIVE.md` | Design spec — 20 real failures the kit defends against. Read this when something weird happens; the answer is probably here |
| `START_NEW.md` | The king prompt for **Claude Code**. Used in Stage 1 only |
| `KING_PROMPTS.md` | Paste-ready Claude.ai kickoff prompts. **This is the doc you reach for at the start of every new sub-chat** |
| `HOW_TO_USE_THIS_PROJECT.md` | This file |
| `bin/setup-secrets.sh` | Reference — Claude can answer "what does setup-secrets collect?" |
| `bin/boot-gate.sh` | Reference — Claude can answer "what does boot-gate verify?" |
| `templates/apps/mobile/metro.config.js` | Reference — Claude can debug Metro issues |
| `packages/backend/convex/auth.config.ts.template` | Reference — Claude understands the Clerk JWT issuer pattern |

The actual filesystem files (configs, scripts, templates) are referenced here so Claude.ai can answer questions without needing to inspect your repo. Real content lives in your app's repo after `degit` pulls it.

---

## Per-app context (don't put it in project knowledge)

Each app's specific context — `PRODUCT_OVERVIEW.md`, Figma exports, API schemas, etc. — does NOT belong in this project's knowledge. Project knowledge stays kit-focused.

Instead, attach app-specific files at the **chat level**:
- Drop `PRODUCT_OVERVIEW.md` into the sub-chat as an attachment
- Paste Figma frame links into the chat
- Reference repo files Claude Code touches by path

This keeps the project useful across many apps without Claude getting confused about which app you're talking about.

---

## When the kit improves

Every real-world failure that wasn't caught by the kit gets logged to `KIT_RETROSPECTIVE.md` as item 21+. The drill:

1. Add the failure to `KIT_RETROSPECTIVE.md` in the GitHub kit repo (`s-411/monorepo-kit`)
2. Update affected templates / scripts / docs
3. Push to GitHub
4. **Re-upload `KIT_RETROSPECTIVE.md` (and any other changed docs) in this project's knowledge** so Claude.ai stays current
5. Existing apps don't auto-update — they pulled an older snapshot. Refresh with `npx degit s-411/monorepo-kit --force` and resolve any conflicts manually

---

## Phase status (where the kit is right now)

| Phase | Status | What's in it |
|---|---|---|
| **Phase 1 — Bootstrap** | ✅ Shipped | README, START_NEW, KIT_RETROSPECTIVE, KING_PROMPTS, this file, root configs (`package.json`, `pnpm-workspace.yaml`, `turbo.json`, `.gitignore`, `.npmrc`), `bin/setup-secrets.sh`, `bin/boot-gate.sh`, monorepo-aware `metro.config.js`, package skeletons for `theme`, `shared`, `backend` |
| **Phase 2 — Hardening** | 🔄 Pending first-run feedback | `bin/install-deps.sh`, `bin/kill-metros.sh`, `bin/dev-mobile.sh`, `bin/process-figma-svgs.sh`, `BOOTSTRAP.md`, `AGENTS.md` template |
| **Phase 3 — Process docs** | 🔄 Pending | `STACK_PROFILES.md`, `PROCESS_GUIDE.md` (16-stage pipeline), `PROMPTS.md` (per-stage prompts), `CHEATSHEET.md` (the 20 gotchas distilled) |
| **Phase 4 — Reference** | 🔄 Pending | `CREDENTIALS.md`, `REF_DOCS_INDEX.md`, `TESTFLIGHT.md`, `legal/privacy.template.md`, `legal/terms.template.md` |

Phase 2 trigger is real-world feedback from running Phase 1 against a fresh repo. New retrospective items inform Phase 2 hardening priorities.

---

## Quick commands you'll reach for

```bash
# Refresh the kit in an existing app to latest s-411/monorepo-kit
cd your-app-repo
npx degit s-411/monorepo-kit --force
git diff   # see what changed
```

```bash
# Cancel and clean Metro processes (when ports get tangled — KIT_RETROSPECTIVE B7)
pkill -f "expo start"
```

```bash
# Re-run setup-secrets to update .env.kit (e.g. rotated Clerk keys)
./bin/setup-secrets.sh
```

```bash
# Real boot gate — never trust bundle compile alone (KIT_RETROSPECTIVE E1)
./bin/boot-gate.sh
```

---

## Worked example: starting a new app called "movie-club"

1. **Terminal:**
   ```bash
   gh repo create s-411/movie-club --public --description "..."
   gh repo clone s-411/movie-club
   cd movie-club
   npx degit s-411/monorepo-kit --force
   ./bin/setup-secrets.sh
   # (interactive — provide slug, Convex team/project, Clerk keys, JWT issuer)
   ```

2. **This Claude.ai project:** New chat, paste:
   ```
   New monorepo app sub-chat. Before doing anything else, run the kickoff
   interview using KING_PROMPTS.md and START_NEW.md as reference.

   - App name / working slug: movie-club
   - Purpose: Letterboxd for friend-group film watch parties
   - Convex team slug: steven-harris
   - Convex project name: movie-club
   - Stack: Convex + Clerk
   - Current stage: 0 → 1
   - Repo: brand new, kit pulled, .env.kit populated
   - Notes: solo developer, want shadcn for charts
   ```

3. **Claude.ai responds:** confirms plan, prepares the customised START_NEW.md prompt block

4. **Claude Code in `~/Documents/GitHub/movie-club`:** paste that block, Phases 1–10 execute

5. **Boot gate confirms** all three services running on real targets — Stage 1 done. Back to Claude.ai for Stage 2 planning.
