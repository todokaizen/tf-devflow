# Runbook: Paperclip + UAW Governance Operations

Date: 2026-04-08
Status: current
Version: 1.0
Supersedes: none

Runtime guide for developers and operators working with the Paperclip + UAW governance framework. Covers project setup, issue management, execution control, and troubleshooting.

For architecture and design rationale, see `design/specs/2026-04-02-paperclip-uaw-governance-design-Phase-1.md`.

---

## Prerequisites

Before using this runbook:

1. **Paperclip is running** — `pnpm dev` from the paperclip repo, server at http://localhost:3100
2. **Company is imported** — `pnpm paperclipai company import companies/{name} --yes`
3. **Project repo exists** — a git-initialized directory with your project code
4. **API keys set** — `ANTHROPIC_API_KEY` and/or `OPENAI_API_KEY` in your environment

---

## Setting Up a New Project

### Step 1: Install UAW templates in the project repo

```bash
./paperclip-uaw/install.sh /path/to/project "Project Name"
```

This creates the UAW contract files:
- `CLAUDE.md` — operating contract (agents read this first)
- `AGENTS.md` — pointer for non-Claude agents
- `resume.md` — project state (fill this in after install)
- `decisions.md` — append-only decision log
- `specs/` — spec files for non-exploratory work
- `archive/` — dated resume copies from prior sessions

### Step 2: Ensure the project directory is a git repo

Codex agents (spec-writer, validator) require a git repo. If the project isn't one:

```bash
cd /path/to/project && git init
```

### Step 3: Attach workspace in Paperclip

After company import, workspaces don't auto-attach (known Issue 3). Attach manually:

- **Via UI:** Open the project at http://localhost:3100/{COMPANY_SLUG}/projects/{project} → Settings → Add workspace → point to the local repo path
- **Via API:**
  ```bash
  curl -X POST http://localhost:3100/api/companies/{companyId}/projects/{projectId}/workspaces \
    -H "Content-Type: application/json" \
    -d '{"name": "primary", "isPrimary": true, "sourceType": "local_path", "cwd": "/path/to/project"}'
  ```

### Step 4: Create pipeline config

Copy the template and customize for your project:

```bash
cp ~/.paperclip/pipelines/galileos-circle.yaml ~/.paperclip/pipelines/{project-slug}.yaml
```

Edit the file — update `role_assignments` with your company's agent names. See Pipeline Config Reference below.

### Step 5: Fill in resume.md

Open `resume.md` in the project and fill in:
- Phase (exploratory / structural / production)
- Objective
- Active specs (or "none")
- What remains before the project goal is met

### Step 6: Create first task

In Paperclip UI, create an issue in the project and assign it to the VentureLead agent. Include:
- Clear task description
- Phase classification (exploratory/structural/production)
- Any constraints or references

The VentureLead takes it from there.

### Step 7: Run health check

Verify everything is in place:

```bash
./paperclip-uaw/healthcheck.sh /path/to/project {project-slug}
```

This checks UAW files, git repo, pipeline config, API keys, and Paperclip server status. It writes `.uaw-healthcheck.json` to the project directory — agents read this on session start and will flag any warnings in their first issue comment.

Re-run after making changes to confirm gaps are resolved.

---

## Creating and Assigning Issues

### Issue structure

Every issue assigned to VentureLead should include:

```
Title: [phase] Brief description
  e.g., [structural] Add user authentication

Body:
  Goal: what this achieves
  Constraints: boundaries, dependencies, deadlines
  Phase: exploratory | structural | production | durable_knowledge
  References: links to related specs, PRs, external docs
```

The phase tells VentureLead which pipeline stages to invoke (see Phase Classification below).

### Phase classification

| Phase | Spec Required | Pipeline Stages | When to Use |
|-------|--------------|-----------------|-------------|
| Exploratory | No | executor only | Prototyping, research, spikes |
| Structural | Short spec | spec_writer → executor | Internal tools, refactors |
| Production | Full spec | spec_writer → validator → executor → reviewer | User-facing features |
| Durable Knowledge | Full spec | spec_writer → validator → executor → reviewer | Documentation, datasets, reference material |

### What happens after assignment

1. VentureLead wakes on next heartbeat (default: 30s)
2. Reads resume.md + decisions.md + pipeline config
3. Classifies the task decision (routine/significant/critical)
4. Creates sub-tasks per pipeline stages, assigned to the appropriate agents
5. Each agent wakes independently, reads CLAUDE.md, executes its role

---

## Controlling Execution

### Approval gates

The pipeline pauses at two points for your review:

1. **After spec-writer** — you review the spec using the 3-check protocol:
   - What is the most likely failure?
   - What is NOT specified that should be?
   - Is this solving the right problem?

2. **After reviewer (validator)** — you review the final result before marking done

Approve or reject in Paperclip UI. Rejection sends the task back with your feedback.

### Pausing agents

- **Disable heartbeat** on an agent: Agent detail page → toggle heartbeat off
- **Remove assignment** from issue: unassign the agent
- **Emergency stop**: the agent detail page shows active runs with a stop button

### Governance decisions

Agents classify every decision before acting:

- **Routine** (reversible, low cost, high confidence) — agent logs and proceeds
- **Significant** (moderate cost, some uncertainty) — agent notifies you via issue comment, proceeds
- **Critical** (irreversible, cross-venture, external, low confidence) — agent blocks and creates approval request

You only need to act on Critical decisions. Routine and Significant are logged for audit.

---

## Pipeline Config Reference

Location: `~/.paperclip/pipelines/{project-slug}.yaml`

This file is read by the VentureLead agent (not by Paperclip itself). It's our custom schema — Paperclip has no awareness of it.

### Full schema

```yaml
# Which pipeline stages run for each phase
phase_rules:
  exploratory:
    - executor                    # just run it
  structural:
    - spec_writer                 # write a spec first
    - executor                    # then implement
  production:
    - spec_writer                 # write full spec
    - spec_validator              # validate spec completeness
    - executor                    # implement from spec
    - reviewer                    # validate implementation
  durable_knowledge:
    - spec_writer
    - spec_validator
    - executor
    - reviewer

# Map pipeline roles to Paperclip agent names in this company
role_assignments:
  spec_writer: "SpecWriter"       # Paperclip display name of the spec-writer agent
  spec_validator: "Validator"     # same agent validates spec and reviews implementation
  executor: "Implementor"         # the implementing agent
  reviewer: "Validator"           # reuses validator for final review
  debugger: "Debugger"            # escalation target for repeated failures

# Where the pipeline pauses for human review
approval_gates:
  - after: spec_writer            # review spec before implementation begins
  - after: reviewer               # review result before marking done

# When to escalate to the debugger agent
failure_escalation:
  executor_retries_before_debugger: 3   # after 3 failed implementor attempts
```

### Key points

- `role_assignments` maps abstract roles to your company's actual Paperclip agent display names
- `approval_gates` define human review checkpoints — the pipeline blocks here
- `failure_escalation` controls how many implementor retries before debugger is dispatched
- The debugger diagnoses only — it does not fix. Different model (opus) provides fresh perspective

### Creating a new pipeline config

1. Copy an existing config: `cp ~/.paperclip/pipelines/galileos-circle.yaml ~/.paperclip/pipelines/new-project.yaml`
2. Update `role_assignments` with your company's agent display names (visible in Paperclip UI)
3. Adjust `phase_rules` if your project needs a different stage sequence
4. Adjust `failure_escalation` threshold if needed (default: 3 retries)

---

## Session Protocol (What Agents Do)

### Agent session start (automated)

Every agent, on every wake:
1. Reads `resume.md`
2. Reads `decisions.md`
3. Reads the active spec (if any)
4. Checks Paperclip for task status and priority changes
5. Reports current state
6. Begins at the Next Action in resume.md

### Agent session end (automated)

Before stopping:
1. Updates Paperclip task status
2. Copies current `resume.md` to `archive/resume-YYYY-MM-DD.md`
3. Writes fresh `resume.md` with current state and resume point
4. Updates `decisions.md` if any decisions were made

### What you do as operator

- **At spec review gate:** Read the spec, answer the 3 review questions, log your review, approve or reject
- **At final review gate:** Check the implementation against the spec, approve or send back
- **Between sessions:** Read `resume.md` to see where things stand without opening Paperclip

---

## Common Operations

### Add a new agent to a company

Edit `companies/{name}/.paperclip.yaml` — add the agent under `agents:`. Then re-import:

```bash
pnpm paperclipai company import companies/{name} --target existing --collision skip --yes
```

### Change an agent's model

Edit `companies/{name}/.paperclip.yaml` — change `model` under the agent's `adapter.config`. Re-import with `--collision update`:

```bash
pnpm paperclipai company import companies/{name} --target existing --collision update --yes
```

### Check agent status

- **UI:** http://localhost:3100/{COMPANY_SLUG}/agents — shows all agents, heartbeat status, last run
- **CLI:** `pnpm paperclipai agent list --company {slug}`

### View run logs

Agent detail page → Runs tab → click a run to see full stdout/stderr, token usage, and cost.

### Update a pipeline config

Edit the config in `pipelines/{project}.yaml` (version-controlled), then sync:

```bash
./paperclip-uaw/sync-pipelines.sh
```

Changes take effect on the next VentureLead wake — no restart needed.

### Add a new venture company

1. Copy master template: `cp -r master-template companies/{new-name}`
2. Edit `companies/{new-name}/COMPANY.md` — update name and description
3. Edit `companies/{new-name}/.paperclip.yaml` — update project definitions and workspace paths
4. Import: `pnpm paperclipai company import companies/{new-name} --yes`
5. Attach workspaces (see Step 3 above)
6. Create pipeline config for each project
7. Install UAW templates in each project repo

---

## Recovery (if ~/.paperclip is erased)

Everything needed to rebuild is version-controlled in this repo. Run:

```bash
./paperclip-uaw/recover.sh
```

This automatically:
1. Starts Paperclip (fresh DB, all migrations)
2. Imports all company packages from `companies/`
3. Syncs pipeline configs from `pipelines/` to `~/.paperclip/pipelines/`

After recovery, manually:
- Attach workspaces for each project (see Step 3 above)
- Run healthcheck on each project

**What is NOT recoverable:** run history (logs, token usage, costs), issue state (tasks, comments, approvals), and workspace attachments. Project state survives in the repos via `resume.md` and `decisions.md` — agents can resume from where they left off.

---

## Known Issues & Workarounds

Quick reference indexed by symptom. Full details in `design/issues/paperclip-issues-log.md`.

| Symptom | Issue | Fix |
|---------|-------|-----|
| Agent can't authenticate to Paperclip API / burns tokens trying to find credentials | Issue 1: env var access blocked by Claude Code sandbox | `dangerouslySkipPermissions: true` in adapter config (already set). Agent uses `X-Local-Agent-Id` header or `node -e "console.log(process.env.PAPERCLIP_API_URL)"` |
| Agent gets 409 Conflict on checkout | Issue 2: heartbeat pre-sets executionRunId | Skip explicit checkout — if executionRunId matches current run, checkout is implicit |
| Imported project has no workspace / agents run in wrong directory | Issue 3: company import doesn't attach workspaces | Attach manually via UI or API after import (see Step 3 above) |
| Company deletion returns 500 error | Issue 4: missing table in cascade delete | Don't delete — reimport with `--target existing --collision skip`. Or DB reset: `rm -rf ~/.paperclip/instances/default/db` |
| Codex agent fails with "Not inside a trusted directory" | Issue 5: codex requires git repo | `git init` in the project directory |
| Agent token usage is ~200k higher than expected per heartbeat | Issue 6: superpowers plugin injects full skill text | Patch session-start hook to skip when `PAPERCLIP_RUN_ID` is set. Re-apply after superpowers updates |
