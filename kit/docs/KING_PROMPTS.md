# KING_PROMPTS.md — paste at the start of every monorepo app sub-chat

Pick the scenario that matches your repo state, fill in the fields, paste as your first message in a fresh sub-chat in this Claude.ai project.

> **Note on the two paths in Scenario A:** the kit now supports a fully
> agent-driven bootstrap (BOOTSTRAP_PROMPT.md) where Claude Code drives
> everything. You don't need this Claude.ai project for that path — you
> can go directly to Claude Code. Use this Claude.ai sub-chat path when
> you want strategic input on the bootstrap (custom stack, debugging,
> cross-app planning, etc.) before pasting into Claude Code.

---

## Scenario A — Brand New Monorepo App

### Path A1 — Direct to Claude Code (recommended default)

Skip Claude.ai. The agent does everything.

**Pre-conditions (one-time per machine):**
1. pnpm installed (`npm install -g pnpm`)
2. Node 20+ installed
3. Convex account exists + CLI authed (`npx convex login`)
4. Clerk account exists
5. (Optional) `gh` CLI authed for auto-push

**To bootstrap a new app:**
1. Create an empty folder anywhere on your machine
2. Open Claude Code in it
3. Paste the body of `kit/docs/BOOTSTRAP_PROMPT.md` with REQUIRED fields
   filled in at the top (slug, purpose, stack overlays, handoff y/n,
   GitHub-create y/n)
4. Answer ~3 questions in chat (Convex team slug; then three Clerk creds
   in one batch after a 3-min dashboard visit)

That's the whole interaction. The agent pulls the kit, creates the Convex
project, walks you through Clerk setup, scaffolds, and boot-gates.

### Path A2 — Strategic kickoff in Claude.ai (when needed)

Use when you want this project's brain involved before bootstrap (e.g.,
non-baseline stack, you want strategic input on the choices, debugging
a previous failed bootstrap, etc.).

**Paste this in a fresh Claude.ai sub-chat:**

```
New monorepo app sub-chat. I want to bootstrap with the agent-driven flow
(BOOTSTRAP_PROMPT.md), but discuss strategy here first.

- App name / working slug:
- Purpose:
- Stack overlays beyond baseline (Stripe / Resend / RevenueCat / Sentry / PostHog):
- Handoff folder content / product spec attached:
- Notes / open questions:
```

**Action implied:** confirm strategy, customise the BOOTSTRAP_PROMPT REQUIRED
block, hand back as a clean code block. You paste that into Claude Code.

---

## Scenario B — Resuming a Paused Monorepo App

```
Monorepo app sub-chat — resuming. Run kickoff against the repo state.

- App name / working slug:
- Purpose:
- Convex team slug:
- Convex project name:
- Current stage:
- Repo: existing, last worked on (date):
- Notes:
```

**Action implied:** run `BOOTSTRAP.md` (Phase 2 of kit) first to verify kit state — especially if the gap since last work is more than a few days, since the kit may have been refreshed at `s-411/monorepo-kit`. Then resume from the listed stage.

If `BOOTSTRAP.md` doesn't exist yet (Phase 2 not shipped), run a manual audit:
- `cat .env.kit` (does it still have all required vars?)
- `pnpm install` (does the workspace still resolve?)
- `./kit/bin/boot-gate.sh` (do all three services still boot?)

---

## Scenario C — Active Build (state is fresh)

```
Monorepo app sub-chat — active build, recent work.

- App name / working slug:
- Current stage:
- Repo: existing, worked on recently
- Notes (what was just shipped, what's next):
```

**Action implied:** skip BOOTSTRAP, go straight to the next prompt for the current stage. Reach for `PROMPTS.md` (Phase 3 of kit) when it ships, or improvise from the stage's goal.

---

## Field reference

- **Working slug** — lowercase-hyphenated. Used for the GitHub repo name. Don't agonise; renaming a GitHub repo is one click.
- **Convex team / project** — what `setup-secrets.sh` collected. Should be in `.env.kit` if pre-flight ran.
- **Stack** — kit baseline is **Convex + Clerk**. Stripe / RevenueCat / Resend / Sentry / PostHog are Phase-N overlays. If any are in scope, list them in `Notes:` so Claude knows.
- **Current stage** — `0` through `16` per `PROCESS_GUIDE.md` (Phase 3 of kit, not yet shipped). Stage 1 = monorepo bootstrap, covered by `START_NEW.md`. Stage 2+ TBD per app.
- **Notes** — anything non-default: payments wired? Sentry already in? Tight timeline? Anything weird about repo state? Specific Figma file or design references attached?

---

## Rule of thumb for which scenario

- Repo doesn't exist on disk yet → **Scenario A**
- Repo exists, last touched a week+ ago → **Scenario B**
- Repo exists, you were just in it yesterday → **Scenario C**

When in doubt, **Scenario B** is safe — it just adds a verification step.
