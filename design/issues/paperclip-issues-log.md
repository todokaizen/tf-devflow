# Paperclip Issues Log

Issues discovered during TodoFoco governance framework implementation. Tracked for potential upstream reporting.

---

## Issue 1: Agents cannot read env vars via bash expansion

**Date:** 2026-04-03
**Severity:** High (cost impact)
**Component:** claude_local / codex_local adapters + Claude Code sandbox

**Problem:** Paperclip correctly injects `PAPERCLIP_API_URL`, `PAPERCLIP_API_KEY`, `PAPERCLIP_AGENT_ID`, `PAPERCLIP_COMPANY_ID`, `PAPERCLIP_RUN_ID` into the agent process environment. However, Claude Code's sandbox blocks `$VAR` expansion in bash ("Contains simple_expansion"), blocks `printenv`/`env`/`set` (requires approval), and blocks `/proc/self/environ`. The agent cannot read its own credentials.

**Impact:** SpecWriter spent ~3M input tokens reading Paperclip source code, server logs, and SQL backups trying to discover how to authenticate. VentureLead had similar (shorter) discovery loop.

**Workaround found by agents:** `X-Local-Agent-Id` header in local_trusted mode. Also `node -e "console.log(process.env.PAPERCLIP_API_URL)"` works in some contexts.

**Root cause:** Claude Code security policy blocks shell variable expansion even when `dangerouslySkipPermissions: true`. The Paperclip skill docs assume agents can read env vars but Claude Code makes this difficult.

**Suggested upstream fix:** Add env var reading instructions to the Paperclip skill doc — a single Node.js one-liner to dump all PAPERCLIP_* vars.

**Our local fix:** Added to agent instructions (see below).

---

## Issue 2: Checkout conflict when executionRunId is pre-set by heartbeat

**Date:** 2026-04-03
**Severity:** Medium (delays, wasted tokens)
**Component:** Issue checkout API + heartbeat execution locking

**Problem:** When the heartbeat wakes an agent, it pre-sets `executionRunId` and `executionLockedAt` on the issue. When the agent then calls `POST /api/issues/{id}/checkout` (as the Paperclip skill instructs), it gets a 409 Conflict because the execution lock is already held.

**Impact:** VentureLead spent multiple turns trying to checkout before discovering it could skip checkout and PATCH status directly.

**Root cause:** The heartbeat system and checkout API have overlapping locking semantics. The skill docs say "If already checked out by you, returns normally" but this only applies when `checkoutRunId` is set, not when only `executionRunId` is set.

**Suggested upstream fix:** Either (a) have the heartbeat set `checkoutRunId` alongside `executionRunId`, or (b) have the checkout endpoint recognize an existing `executionRunId` from the same agent as equivalent to a successful checkout.

**Our local fix:** Agent instructions note that if executionRunId matches current run, checkout is implicit — proceed directly.

---

## Issue 3: Company import doesn't attach project workspaces

**Date:** 2026-04-03
**Severity:** Medium (setup friction)
**Component:** Company portability import

**Problem:** When importing a company package with projects defined in `.paperclip.yaml` (including workspace configs with `cwd` paths), the projects are created but the workspaces are not attached. Agents run in a default Paperclip workspace directory instead of the configured repo path.

**Impact:** VentureLead reported empty workspace. Had to manually create workspace via API after import.

**Suggested upstream fix:** Company import should create project workspaces from `.paperclip.yaml` project definitions.

**Our local fix:** Post-import manual workspace creation via API or UI.

---

## Issue 4: Company deletion returns 500 error via CLI

**Date:** 2026-04-02
**Severity:** Low (workaround exists)
**Component:** CLI `company delete` command

**Problem:** `pnpm paperclipai company delete <id> --yes --confirm <id>` returns API error 500 for all companies. Likely a cascade constraint in the database.

**Impact:** Could not clean up duplicate companies from repeated imports. Had to use DB reset as workaround.

**Suggested upstream fix:** Company deletion should handle cascade constraints gracefully, or the error message should indicate which constraint is blocking.

**Our local fix:** Reset DB (`rm -rf ~/.paperclip/instances/default/db`) when clean slate needed.

---

## Issue 5: Codex agent fails in non-git directories

**Date:** 2026-04-03
**Severity:** Low (expected behavior, but confusing in context)
**Component:** codex_local adapter

**Problem:** Codex requires a git repo. Running SpecWriter (codex_local) in a directory without `.git` fails with "Not inside a trusted directory and --skip-git-repo-check was not specified."

**Impact:** Had to `git init` the project directory before the agent could run.

**Suggested upstream fix:** Either document this requirement clearly in adapter docs, or add `--skip-git-repo-check` as a configurable option in the codex_local adapter config.

**Our local fix:** Ensure all project directories are git repos before agent work begins (added to onboarding flow).
