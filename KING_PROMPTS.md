# KING_PROMPTS.md — paste at the start of every monorepo app sub-chat

Pick the scenario that matches your repo state, fill in the fields, paste as your first message in a fresh sub-chat in this Claude.ai project.

If every field is filled, the kickoff is satisfied and Claude proceeds straight to the next action — preparing the START_NEW.md prompt for Claude Code (Scenario A) or auditing repo state (Scenario B/C).

---

## Scenario A — Brand New Monorepo App

**Pre-flight in your terminal — do these BEFORE pasting:**

1. Empty GitHub repo created (Initialize OFF) and cloned locally
2. `cd` into the cloned repo
3. `npx degit s-411/monorepo-kit --force` — pulls the kit
4. Convex project exists in dashboard ([dashboard.convex.dev](https://dashboard.convex.dev))
5. Clerk app exists with the auth providers you want enabled, AND a JWT template named `convex` configured ([dashboard.clerk.com](https://dashboard.clerk.com))
6. `./bin/setup-secrets.sh` — interactive, ~3 min, writes `.env.kit` at repo root
7. Nanobanana MCP verified connected in Claude Code (`claude mcp list | grep nanobanana`)

**Then paste this in a fresh Claude.ai sub-chat:**

```
New monorepo app sub-chat. Before doing anything else, run the kickoff
interview using KING_PROMPTS.md and START_NEW.md as reference.

- App name / working slug:
- Purpose:
- Convex team slug:
- Convex project name:
- Stack: Convex + Clerk (kit baseline)
- Current stage: 0 → 1
- Repo: brand new, kit pulled via degit, .env.kit populated
- Notes:
```

**Action implied:**
- Confirm pre-flight is complete; ask if any of the 7 items is unclear
- Customise the START_NEW.md king prompt for this specific app (substitute slug/purpose/notes into the prompt's REQUIRED block)
- Hand it back to me as a clean code block — I paste that into **Claude Code** in the repo, which executes Phases 1–10
- I report status back here for debugging or next-stage planning

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
- `./bin/boot-gate.sh` (do all three services still boot?)

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
