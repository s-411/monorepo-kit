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

For each new monorepo app, the flow is now **agent-driven by default** —
Claude Code does everything, you answer ~3 questions in chat. The Claude.ai
project (this one) becomes a strategic backstop you reach for when the
default flow doesn't fit.

### Path 1 — Default: agent-driven bootstrap (~95% of apps)

1. **Confirm one-time pre-conditions** (skip if already done on this machine):
   - pnpm + node 20+ installed
   - Convex account exists + CLI authed (`npx convex login`)
   - Clerk account exists
   - (Optional) `gh` CLI authed for auto-push

2. **Create an empty folder** anywhere on your machine. Naming convention is up to you.

3. **(Optional) Place a `handoff/` folder at the root** if the app has product spec / reference material. Skip if it doesn't.

4. **Open Claude Code in the empty folder**.

5. **Paste the body of `kit/docs/BOOTSTRAP_PROMPT.md`** with the REQUIRED fields filled in at the top (slug, purpose, stack overlays, handoff y/n, GitHub-create y/n).

6. **Answer ~3 questions in chat** as Claude Code drives:
   - Convex team slug (one line)
   - Three Clerk credentials in one batch (after a 3-min Clerk dashboard visit)

7. **Confirm the boot gate** when it asks (web rendering at localhost:3000, mobile rendering on a real device via Expo Go).

That's the whole interaction. The agent handles every other step.

### Path 2 — Strategic kickoff via this Claude.ai project (when needed)

Use this when:
- You're using a non-baseline stack (Stripe, Resend, RevenueCat, etc.) and want to plan Phase-N overlays before bootstrapping
- A previous bootstrap failed and you need debugging help before retrying
- You want strategic input on naming, repo placement, branch strategy, etc.
- You want Claude.ai to customise the BOOTSTRAP_PROMPT REQUIRED block for you instead of filling it in by hand

Steps:

1. **Open a new chat** in this Claude.ai project.
2. **Paste `KING_PROMPTS.md` Scenario A → Path A2** with the fields filled in.
3. **Claude.ai prepares a customised BOOTSTRAP_PROMPT** for you to paste into Claude Code.
4. **Continue from step 4 of Path 1** above.

### Path 3 — Manual mode (debugging / fallback)

When Path 1's agent-driven flow has issues you can't easily debug, fall back to `kit/docs/START_NEW.md` — the older, more verbose prompt where YOU drive the pre-flight (degit, setup-secrets.sh, dashboards) and Claude Code only handles the scaffolding phases. Slower but more transparent.

### Subsequent stages (Stage 2+, back to this Claude.ai project)

- Stage 2+ work happens chat-by-chat in this Claude.ai project (per-app, not in the kit)
- For each stage, Claude.ai prepares the prompt for Claude Code based on the app's specifics, the kit's process docs, and any Figma / design / API references you've attached to the chat
- Iterate until the app ships

---

## What's in this project's knowledge

| File | Purpose |
|---|---|
| `README.md` | 5-min orientation to the kit |
| `BOOTSTRAP_PROMPT.md` | The agent-driven king prompt — **default flow for new apps**. User pastes this in Claude Code and answers ~3 questions; Claude does the rest |
| `START_NEW.md` | Manual-mode king prompt — fallback when you want to drive each step yourself, or for debugging |
| `KING_PROMPTS.md` | Paste-ready Claude.ai kickoff prompts. Reach for this when you want strategic input before going to Claude Code |
| `KIT_RETROSPECTIVE.md` | Design spec — 20+ real failures the kit defends against. Read this when something weird happens; the answer is probably here |
| `HOW_TO_USE_THIS_PROJECT.md` | This file |
| `bin/setup-secrets.sh` | Reference — Claude can answer "what does setup-secrets collect?" (lives at `kit/bin/setup-secrets.sh` in the consumer's repo). FALLBACK ONLY — agent-driven flow writes `.env.kit` directly without this script |
| `bin/boot-gate.sh` | Reference — Claude can answer "what does boot-gate verify?" (lives at `kit/bin/boot-gate.sh` in the consumer's repo) |
| `templates/apps/mobile/metro.config.js` | Reference — Claude can debug Metro issues (lives at `kit/templates/apps/mobile/metro.config.js` in the consumer's repo) |
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
| **Phase 1 — Bootstrap** | ✅ Shipped | README, START_NEW, KIT_RETROSPECTIVE, KING_PROMPTS, this file (all under `kit/docs/`), root configs (`package.json`, `pnpm-workspace.yaml`, `turbo.json`, `.gitignore`, `.npmrc`), `kit/bin/setup-secrets.sh`, `kit/bin/boot-gate.sh`, monorepo-aware `kit/templates/apps/mobile/metro.config.js`, package skeletons for `theme`, `shared`, `backend` |
| **Phase 2 — Hardening** | 🔄 Pending first-run feedback | `kit/bin/install-deps.sh`, `kit/bin/kill-metros.sh`, `kit/bin/dev-mobile.sh`, `kit/bin/process-figma-svgs.sh`, `kit/docs/BOOTSTRAP.md`, `AGENTS.md` template |
| **Phase 3 — Process docs** | 🔄 Pending | `kit/docs/STACK_PROFILES.md`, `kit/docs/PROCESS_GUIDE.md` (16-stage pipeline), `kit/docs/PROMPTS.md` (per-stage prompts), `kit/docs/CHEATSHEET.md` (the 20 gotchas distilled) |
| **Phase 4 — Reference** | 🔄 Pending | `kit/docs/CREDENTIALS.md`, `kit/docs/REF_DOCS_INDEX.md`, `kit/docs/TESTFLIGHT.md`, `kit/legal/privacy.template.md`, `kit/legal/terms.template.md` |

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
./kit/bin/setup-secrets.sh
```

```bash
# Real boot gate — never trust bundle compile alone (KIT_RETROSPECTIVE E1)
./kit/bin/boot-gate.sh
```

---

## Worked example: starting a new app called "movie-club"

1. **Empty folder:**
   ```bash
   mkdir -p ~/Documents/GitHub/movie-club
   cd ~/Documents/GitHub/movie-club
   ```
   (No GitHub repo yet — the agent can create it via `gh` in Phase 14, or you can do it manually later.)

2. **Open Claude Code in that folder.** Paste the body of `kit/docs/BOOTSTRAP_PROMPT.md` (you'd have a copy locally from a previous app, or download from `s-411/monorepo-kit` GitHub) with the REQUIRED fields filled in:

   ```
   - App slug: movie-club
   - Purpose: Letterboxd for friend-group film watch parties
   - Stack overlays beyond baseline: none
   - Handoff folder at repo root: no
   - Create GitHub repo and push: yes-public
   ```

3. **Claude Code drives:** pulls the kit, asks "what's your Convex team slug?" → you answer `steven-harris` → it creates the Convex project automatically. Then "do 3-min Clerk setup, paste the three values" → you do it, paste them in chat.

4. **Scaffolding runs.** Next.js, Expo, Clerk peer set, providers wiring — all automatic.

5. **Boot gate confirms** all three services running on real targets (you confirm web rendering at localhost:3000, mobile rendering on a real device).

6. **`gh repo create movie-club --public` runs**, initial commit lands, `git push` lands.

Total interaction: ~3 questions answered in chat, ~3 minutes in the Clerk dashboard, ~5 minutes confirming boot gate. No terminal commands typed by hand.

Back to this Claude.ai project for Stage 2 planning when you're ready to start building features.
