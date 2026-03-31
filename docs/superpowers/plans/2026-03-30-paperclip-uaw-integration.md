# Paperclip + UAW v3 Integration Plan (Configuration Only)

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Configure Paperclip to orchestrate UAW v3 agent workflows across multiple projects using only config files, company packages, and UAW templates — no Paperclip core code changes.

**Architecture:** A Paperclip company package defines the company, per-project agents, and project workspaces. UAW v3 templates (with amendments) live in each target repo. The role map is documented config that guides manual task assignment until Paperclip gains native pipeline routing.

**Tech Stack:** Markdown, YAML (.paperclip.yaml), UAW v3 templates

---

## File Structure

```
New/modified files (all in the paperclip repo, not core code):

  UAW-v3/amendments.md                            — Three multi-agent amendments
  UAW-v3/uaw-templates/                            — Extracted & amended templates ready to copy
    CLAUDE.md                                      — Updated UAW operating contract
    resume.md                                      — Resume template
    decisions.md                                   — Decisions template
    specs/spec-template.md                         — Spec template
    archive/                                       — Empty archive dir
    pipeline-config.yaml                           — Role map & phase rules template
  company-package/                                 — Importable Paperclip company package
    COMPANY.md                                     — Company definition
    agents/
      claude-executor/AGENTS.md                    — Claude agent template (per-project)
      codex-spec-writer/AGENTS.md                  — Codex agent template (per-project)
      antigravity-reviewer/AGENTS.md               — AntiGravity agent template (per-project)
      gemini-executor/AGENTS.md                    — Gemini agent template (per-project)
    .paperclip.yaml                                — Adapter configs & env inputs
    README.md                                      — Setup instructions
```

---

### Task 1: UAW v3 Amendments

**Files:**
- Create: `UAW-v3/amendments.md`

- [ ] **Step 1: Create the amendments file**

Create `UAW-v3/amendments.md`:

```markdown
# UAW v3 Amendments for Multi-Agent Orchestration

Date: 2026-03-31
Status: accepted

These amendments extend the UAW v3 spec to support orchestrated multi-agent
pipelines where different agents handle different stages of a task (spec writing,
validation, execution, review).

---

## Amendment 1: Multi-Agent Session Handoff

**Add to Section 10 (Session Protocol):**

> When multiple agents work a task sequentially, each agent completes the full
> shutdown protocol before the next agent starts. The incoming agent reads
> `resume.md` written by the previous agent as its starting context.

---

## Amendment 2: Role Scoping

**Add to Section 12 (Operating Rules):**

> When an agent receives a scoped role assignment, it operates only within that
> role's boundaries. A spec_writer produces the spec and completes shutdown. An
> executor implements. A reviewer validates. No role exceeds its boundary.

---

## Amendment 3: Externally Assigned Phase

**Add to Section 4 (Phase Classification):**

> Phase is assigned by the task creator, not derived by the agent. The agent
> receives phase in the kickoff context and applies the corresponding
> verification depth.
```

- [ ] **Step 2: Commit**

```bash
git add UAW-v3/amendments.md
git commit -m "docs: add UAW v3 amendments for multi-agent orchestration"
```

---

### Task 2: Extract and Update UAW v3 Templates

**Files:**
- Create: `UAW-v3/uaw-templates/` (full directory)

The current templates are locked in a .zip file. Extract them, apply the amendments inline, and make them ready to copy into any project repo.

- [ ] **Step 1: Extract templates from zip**

```bash
cd UAW-v3 && unzip -o UAW-os-templates.zip -d . && mv uaw-templates/* uaw-templates-tmp/ 2>/dev/null; rm -rf uaw-templates; mv uaw-templates-tmp uaw-templates
```

Verify the extracted structure:
```
UAW-v3/uaw-templates/
  CLAUDE.md
  resume.md
  decisions.md
  specs/spec-template.md
  archive/
  README.md
```

- [ ] **Step 2: Update CLAUDE.md with amendments**

Add the three amendments to `UAW-v3/uaw-templates/CLAUDE.md`. After the `## When Uncertain` section, add:

```markdown
---

## Multi-Agent Pipeline Rules

When operating as part of a multi-agent pipeline orchestrated by Paperclip or
another coordinator:

### Session Handoff
When multiple agents work a task sequentially, each agent completes the full
shutdown protocol before the next agent starts. The incoming agent reads
`resume.md` written by the previous agent as its starting context.

### Role Scoping
When you receive a scoped role assignment, operate only within that role's
boundaries. A spec_writer produces the spec and completes shutdown. An executor
implements. A reviewer validates. No role exceeds its boundary.

### Externally Assigned Phase
Phase is assigned by the task creator, not derived by you. You receive phase
in the kickoff context and apply the corresponding verification depth from
the Phase Classification table above.
```

- [ ] **Step 3: Create pipeline-config.yaml template**

Create `UAW-v3/uaw-templates/pipeline-config.yaml`:

```yaml
# Pipeline Configuration — Role Map & Phase Rules
# Copy this into your project repo alongside the UAW files.
# This file is read by the human operator (you) to guide task assignment.
# When Paperclip gains native pipeline routing, this becomes machine-readable config.

project_name: "{{PROJECT_NAME}}"

# Phase rules: which pipeline stages run for each phase.
# Stages execute in order. Each stage maps to a role.
phase_rules:
  exploratory:
    - executor
  structural:
    - spec_writer
    - executor
  production:
    - spec_writer
    - spec_validator
    - executor
    - reviewer
  durable_knowledge:
    - spec_writer
    - spec_validator
    - executor
    - reviewer

# Role assignments: which Paperclip agent fills each role.
# Use the agent name as registered in Paperclip.
# For fan-out (competing outputs), list multiple agents.
role_assignments:
  spec_writer: "{{CODEX_AGENT_NAME}}"
  spec_validator: "{{CLAUDE_AGENT_NAME}}"
  executor: "{{CLAUDE_AGENT_NAME}}"
  reviewer: "{{ANTIGRAVITY_AGENT_NAME}}"

# Approval gates: where you (the operator) review before proceeding.
# These are the stages where the pipeline pauses for your sign-off.
approval_gates:
  - after: spec_writer      # Review the spec before execution begins
  - after: reviewer          # Review the final result before marking done
```

- [ ] **Step 4: Update the README.md with pipeline setup instructions**

Replace `UAW-v3/uaw-templates/README.md` with:

```markdown
# UAW-os Project Templates

## Setup

To initialize a new project under the Universal Agentic Workflow:

1. Copy this folder into your project root:
   ```
   cp -r UAW-v3/uaw-templates/ your-project/
   ```

2. Your project will have:
   ```
   your-project/
     CLAUDE.md            ← UAW operating contract (agents read this first)
     resume.md            ← current state — the one file to read on return
     decisions.md         ← append-only architectural decisions
     specs/               ← spec files for non-exploratory work
       spec-template.md   ← copy and rename per spec
     archive/             ← dated resume.md copies from prior sessions
     pipeline-config.yaml ← role map and phase rules for this project
   ```

3. Fill in `resume.md` — project name, phase, objective.

4. Fill in `pipeline-config.yaml` — replace placeholders with your Paperclip agent names.

## Paperclip Integration

This project uses Paperclip as the orchestration layer. Paperclip assigns agents
to tasks; agents follow the UAW contract in CLAUDE.md autonomously.

**Separation of concerns:**
- Paperclip manages: who runs, when, budget, approvals, audit trail
- UAW manages: what files to read, authority order, status transitions, proof, shutdown

**If Paperclip is removed,** nothing changes except who kicks off the job.

## Agent Read Order

On every session start, the agent reads:
1. `CLAUDE.md` (this contract)
2. `resume.md`
3. `decisions.md`
4. Active spec (if referenced in resume)

## Session End

On every session end, the agent:
1. Copies `resume.md` to `archive/resume-YYYY-MM-DD.md`
2. Writes fresh `resume.md` with current state
3. Updates `decisions.md` if any decisions were made
```

- [ ] **Step 5: Commit**

```bash
git add UAW-v3/uaw-templates/
git commit -m "docs: extract and update UAW v3 templates with pipeline amendments"
```

---

### Task 3: Create Paperclip Company Package — Company & Agent Definitions

**Files:**
- Create: `company-package/COMPANY.md`
- Create: `company-package/agents/claude-executor/AGENTS.md`
- Create: `company-package/agents/codex-spec-writer/AGENTS.md`
- Create: `company-package/agents/antigravity-reviewer/AGENTS.md`
- Create: `company-package/agents/gemini-executor/AGENTS.md`

- [ ] **Step 1: Create COMPANY.md**

Create `company-package/COMPANY.md`:

```markdown
---
schema: agentcompanies/v1
name: "Ker's Lab"
description: >
  Solo developer operation managing multiple AI agent workflows across projects.
  Uses UAW v3 as the in-repo contract and Paperclip as the replaceable orchestrator.
---

# Ker's Lab

A one-person AI-augmented development operation. Each project gets its own set of
agent instances configured for that project's stack, budget, and workflow needs.

## How It Works

1. Each project repo contains UAW v3 files (CLAUDE.md, resume.md, decisions.md, specs/)
2. Agents are registered per-project in Paperclip with stack-specific configs
3. The operator creates tasks in Paperclip, sets the phase, and assigns agents
4. Agents follow the UAW contract autonomously — Paperclip tracks status and budget
5. The operator reviews at approval gates (after spec, after review)

## Agent Roles

- **spec_writer** — Writes spec files from task descriptions
- **spec_validator** — Reviews specs for ambiguity, consistency, feasibility
- **executor** — Implements the work following the spec
- **reviewer** — Validates the result against the spec and done condition
```

- [ ] **Step 2: Create Claude executor agent**

Create `company-package/agents/claude-executor/AGENTS.md`:

```markdown
---
name: Claude Executor
role: engineer
title: "Implementation & Planning Agent"
icon: code
capabilities: >
  Primary execution agent. Reads UAW contract, follows specs, writes code,
  updates resume.md and decisions.md. Also serves as spec validator when
  assigned that role.
---

# Claude Executor

Implementation and planning agent powered by Claude Code (claude_local adapter).

## Responsibilities
- Execute implementation tasks following UAW v3 specs
- Validate specs for ambiguity and feasibility (when assigned spec_validator role)
- Plan implementation approaches from specs
- Follow UAW session protocol (startup: read resume/decisions/spec, shutdown: archive and update)

## Per-Project Configuration

When registering this agent for a project, configure:
- `cwd`: Path to the project repo
- `model`: Claude model to use (default: claude-sonnet-4-6 for execution, claude-opus-4-6 for planning)
- Budget: Set per-project based on expected work volume

## Naming Convention

Register as `Claude-{ProjectName}` (e.g., `Claude-TFLabs`, `Claude-OpenBrain`).
```

- [ ] **Step 3: Create Codex spec writer agent**

Create `company-package/agents/codex-spec-writer/AGENTS.md`:

```markdown
---
name: Codex Spec Writer
role: engineer
title: "Specification Writer"
icon: file-code
capabilities: >
  Writes detailed spec files from task descriptions. Analyzes codebase context,
  defines objectives, scope, constraints, and done conditions following UAW v3
  spec template format.
---

# Codex Spec Writer

Specification writing agent powered by Codex (codex_local adapter).

## Responsibilities
- Write spec files in `specs/` following the UAW v3 spec template
- Analyze the codebase to understand context before writing specs
- Define clear objectives, scope boundaries, constraints, and verifiable done conditions
- Follow UAW session protocol

## Per-Project Configuration

When registering this agent for a project, configure:
- `cwd`: Path to the project repo
- Budget: Lower than executor (spec writing is cheaper)

## Naming Convention

Register as `Codex-{ProjectName}` (e.g., `Codex-TFLabs`, `Codex-OpenBrain`).
```

- [ ] **Step 4: Create AntiGravity reviewer agent**

Create `company-package/agents/antigravity-reviewer/AGENTS.md`:

```markdown
---
name: AntiGravity Reviewer
role: qa
title: "Validation & Review Agent"
icon: search
capabilities: >
  Validates implementation against specs. Checks done conditions, runs tests,
  reviews code quality. Produces proof artifacts before marking review complete.
---

# AntiGravity Reviewer

Validation agent powered by AntiGravity (process adapter).

## Responsibilities
- Validate that implementation satisfies the spec's done condition
- Run tests and verify code quality
- Produce proof (test output, review notes) before marking review complete
- Follow UAW session protocol

## Per-Project Configuration

When registering this agent for a project, configure:
- `command`: AntiGravity CLI invocation command
- `cwd`: Path to the project repo
- Budget: Set based on review complexity

## Naming Convention

Register as `AntiGrav-{ProjectName}` (e.g., `AntiGrav-TFLabs`, `AntiGrav-OpenBrain`).
```

- [ ] **Step 5: Create Gemini executor agent**

Create `company-package/agents/gemini-executor/AGENTS.md`:

```markdown
---
name: Gemini Executor
role: engineer
title: "Backup Execution Agent"
icon: zap
capabilities: >
  Backup execution agent. Same responsibilities as Claude Executor but powered
  by Gemini CLI. Used when Claude is unavailable or for workload distribution.
---

# Gemini Executor

Backup execution agent powered by Gemini CLI (gemini_local adapter).

## Responsibilities
- Same as Claude Executor — implement tasks following UAW v3 specs
- Follow UAW session protocol
- Available as alternate executor in role assignments

## Per-Project Configuration

When registering this agent for a project, configure:
- `cwd`: Path to the project repo
- Budget: Set per-project

## Naming Convention

Register as `Gemini-{ProjectName}` (e.g., `Gemini-TFLabs`, `Gemini-OpenBrain`).
```

- [ ] **Step 6: Commit**

```bash
git add company-package/
git commit -m "docs: create Paperclip company package with agent definitions"
```

---

### Task 4: Create .paperclip.yaml Adapter Configs

**Files:**
- Create: `company-package/.paperclip.yaml`

- [ ] **Step 1: Create the vendor extension file**

Create `company-package/.paperclip.yaml`:

```yaml
schema: paperclip/v1

# Agent adapter configurations.
# These are TEMPLATES — when importing for a specific project, update:
#   - cwd paths to point to the actual project repo
#   - budget values for the project
#   - model choices if needed
#
# To create per-project agents, import this company package once,
# then use the Paperclip API/CLI to create project-specific agent
# instances with the correct cwd and config overrides.

agents:
  claude-executor:
    adapter:
      type: claude_local
      config:
        cwd: "{{PROJECT_REPO_PATH}}"
        model: claude-sonnet-4-6
        maxTurnsPerRun: 300
        dangerouslySkipPermissions: false

  codex-spec-writer:
    adapter:
      type: codex_local
      config:
        cwd: "{{PROJECT_REPO_PATH}}"
        dangerouslyBypassApprovalsAndSandbox: false

  antigravity-reviewer:
    adapter:
      type: process
      config:
        command: "antigravity"
        cwd: "{{PROJECT_REPO_PATH}}"
        timeoutSec: 300

  gemini-executor:
    adapter:
      type: gemini_local
      config:
        cwd: "{{PROJECT_REPO_PATH}}"
```

- [ ] **Step 2: Commit**

```bash
git add company-package/.paperclip.yaml
git commit -m "docs: add .paperclip.yaml adapter configs for company package"
```

---

### Task 5: Create Company Package README (Setup Guide)

**Files:**
- Create: `company-package/README.md`

- [ ] **Step 1: Create the setup guide**

Create `company-package/README.md`:

```markdown
# Ker's Lab — Paperclip Company Package

## Prerequisites

1. Paperclip server running (`paperclipai run`)
2. UAW v3 templates copied into each project repo (see `UAW-v3/uaw-templates/`)

## Quick Setup

### 1. Import the company

```bash
paperclipai company import ./company-package --new-company-name "Ker's Lab"
```

This creates the company with template agents. The agents won't work yet —
they need per-project configuration.

### 2. For each project, create project-specific agents

Use the Paperclip API or CLI to create agents with the correct repo path.

Example for TFLabs (Python project):

```bash
# Create the project with workspace
paperclipai issue create --title "Setup TFLabs project" --status done

# Via API:
# POST /api/companies/{companyId}/projects
# {
#   "name": "TFLabs",
#   "description": "Python AI/LangGraph platform",
#   "workspace": {
#     "sourceType": "local_path",
#     "cwd": "/Users/ker/_Projects/Active/MentorMesh/TFLabs",
#     "isPrimary": true
#   }
# }
#
# POST /api/companies/{companyId}/agents
# {
#   "name": "Claude-TFLabs",
#   "role": "engineer",
#   "title": "TFLabs Implementation Agent",
#   "icon": "code",
#   "capabilities": "Executes implementation tasks for TFLabs (Python/LangGraph)",
#   "adapterType": "claude_local",
#   "adapterConfig": {
#     "cwd": "/Users/ker/_Projects/Active/MentorMesh/TFLabs",
#     "model": "claude-sonnet-4-6"
#   },
#   "budgetMonthlyCents": 5000
# }
```

Repeat for each agent type (Codex-TFLabs, AntiGrav-TFLabs) and each project.

### 3. Copy UAW templates into each project repo

```bash
cp -r UAW-v3/uaw-templates/ /path/to/project/
```

Edit `resume.md` and `pipeline-config.yaml` with project-specific values.

### 4. Create your first task

In the Paperclip UI or CLI, create an issue:
- Set the project
- Set the title and description
- Assign to the appropriate agent based on the pipeline-config.yaml role map

## Pipeline Workflow (Manual)

Until Paperclip gains native pipeline routing, follow this process:

1. **You** evaluate the project and decide what to do
2. **You** create a Paperclip issue with title, description
3. **You** check `pipeline-config.yaml` for the project's phase rules
4. **For production/durable phases:**
   a. Assign to spec_writer agent → wait for completion
   b. (Optional) Assign spec_validator agent → wait for review
   c. Review and approve the spec yourself
   d. Assign to executor agent → wait for completion
   e. Assign to reviewer agent → wait for validation
   f. Review and approve the result
5. **For exploratory phases:**
   a. Assign directly to executor agent → review when done
6. **For structural phases:**
   a. Assign to spec_writer → approve spec → assign to executor → review

## Role Map Reference

See each project's `pipeline-config.yaml` for the authoritative role assignments.
The default template is:

| Role | Default Agent | Responsibility |
|------|--------------|----------------|
| spec_writer | Codex-{Project} | Write specs from task descriptions |
| spec_validator | Claude-{Project} | Review specs for quality |
| executor | Claude-{Project} | Implement the work |
| reviewer | AntiGrav-{Project} | Validate against done condition |

## Graduating to Automation

When Paperclip adds native pipeline routing:
1. The `pipeline-config.yaml` format becomes machine-readable project config
2. Paperclip auto-creates sub-tasks per pipeline stage
3. Paperclip auto-assigns agents based on the role map
4. You only intervene at approval gates
```

- [ ] **Step 2: Commit**

```bash
git add company-package/README.md
git commit -m "docs: add company package setup guide with manual pipeline workflow"
```

---

### Task 6: Verify Package Structure and Final Cleanup

**Files:** None created — verification only

- [ ] **Step 1: Verify the complete file structure**

```bash
find UAW-v3/uaw-templates company-package -type f | sort
```

Expected output:
```
UAW-v3/uaw-templates/CLAUDE.md
UAW-v3/uaw-templates/README.md
UAW-v3/uaw-templates/decisions.md
UAW-v3/uaw-templates/pipeline-config.yaml
UAW-v3/uaw-templates/resume.md
UAW-v3/uaw-templates/specs/spec-template.md
company-package/.paperclip.yaml
company-package/COMPANY.md
company-package/README.md
company-package/agents/antigravity-reviewer/AGENTS.md
company-package/agents/claude-executor/AGENTS.md
company-package/agents/codex-spec-writer/AGENTS.md
company-package/agents/gemini-executor/AGENTS.md
```

- [ ] **Step 2: Verify the company package can be previewed by Paperclip**

```bash
paperclipai company import ./company-package --dry-run
```

Expected: Preview output showing company, agents, no errors.

- [ ] **Step 3: Remove the old code-change plan if it was committed**

The old plan at `docs/superpowers/plans/2026-03-30-paperclip-uaw-integration.md` described core code changes. Update it to note it's been superseded by this configuration-only approach.

- [ ] **Step 4: Final commit**

```bash
git add -A
git commit -m "docs: finalize Paperclip + UAW v3 integration package (config only)"
```
