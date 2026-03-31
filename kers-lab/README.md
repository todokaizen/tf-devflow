# Ker's Lab — Paperclip Company Package

## Design Philosophy

### Layered Architecture

```
Layer 1: Paperclip        — coordinates, records, enforces workflow
Layer 2: UAW v3           — defines roles, steps, constraints (in each repo)
Layer 3: Execution agents — do the work, follow UAW
Layer 4: Validation       — tests, evaluators, rubrics (outside Paperclip)
Layer 5: Output sinks     — GitHub, CMS, datasets
```

**Critical rule:** Paperclip never decides correctness. The coordinator is a
state machine — it routes tasks, it does not judge them.

## Prerequisites

1. Paperclip server running (`paperclipai run`)
2. UAW v3 templates copied into each project repo (see `UAW-v3/uaw-templates/`)

## Quick Setup

### 1. Import the company

```bash
paperclipai company import ./kers-lab --new-company-name "Ker's Lab"
```

This creates the company with template agents.

### 2. For each project, create per-project agents

Agents are registered per-project. Example for TFLabs:

```bash
# Create project with workspace
# POST /api/companies/{companyId}/projects
# {
#   "name": "TFLabs",
#   "workspace": {
#     "sourceType": "local_path",
#     "cwd": "/path/to/tflabs",
#     "isPrimary": true
#   }
# }

# Create coordinator
# POST /api/companies/{companyId}/agents
# { "name": "Coordinator-TFLabs", "role": "pm", "adapterType": "claude_local",
#   "adapterConfig": { "cwd": "/path/to/tflabs", "model": "claude-sonnet-4-6" },
#   "budgetMonthlyCents": 1000 }

# Create execution agents
# { "name": "Claude-TFLabs", "role": "engineer", "adapterType": "claude_local",
#   "adapterConfig": { "cwd": "/path/to/tflabs", "model": "claude-sonnet-4-6" },
#   "budgetMonthlyCents": 5000 }

# { "name": "Codex-TFLabs", "role": "engineer", "adapterType": "codex_local",
#   "adapterConfig": { "cwd": "/path/to/tflabs" },
#   "budgetMonthlyCents": 3000 }

# Repeat for AntiGrav-TFLabs, Gemini-TFLabs as needed
```

### 3. Create pipeline config

```bash
cp kers-lab/pipelines/template.yaml ~/.paperclip/pipelines/tflabs.yaml
```

Edit `~/.paperclip/pipelines/tflabs.yaml` — replace agent name placeholders
with the names you registered (e.g., `Claude-TFLabs`, `Codex-TFLabs`).

### 4. Copy UAW templates into the project repo

```bash
cp -r UAW-v3/uaw-templates/ /path/to/tflabs/
```

Edit `resume.md` with the project state.

### 5. Create your first task

Create a Paperclip issue:
- Title: "Implement feature X" (or reference a spec: "See specs/feature-x.md")
- Phase: production (or exploratory, structural, durable_knowledge)
- Assign to: Coordinator-TFLabs

The coordinator reads the pipeline config, creates sub-tasks for each stage,
assigns agents, and pauses at approval gates for your review.

## How the Pipeline Runs

```
You create task → assign to Coordinator-TFLabs → set phase

Coordinator reads ~/.paperclip/pipelines/tflabs.yaml
For production phase:

  [spec_writer] → Codex-TFLabs writes the spec
     ↓ approval gate — you review the spec
  [spec_validator] → Claude-TFLabs validates the spec
     ↓
  [executor] → Claude-TFLabs implements
     ↓
  [reviewer] → AntiGrav-TFLabs validates result
     ↓ approval gate — you review the result

  Parent task → in_review → you do final sign-off → done
```

For exploratory: coordinator assigns executor only, you review when done.
For structural: spec_writer → executor, you review when done.

## Role Map

Any agent can fill any role. The pipeline config decides:

| Role | What it does |
|------|-------------|
| spec_writer | Write specs from task descriptions |
| spec_validator | Review specs for quality and feasibility |
| executor | Implement the work |
| reviewer | Validate against done condition |

Change assignments anytime by editing `~/.paperclip/pipelines/{project}.yaml`.

## Onboarding a New Project

1. Copy UAW templates into the repo
2. Create the Paperclip project with workspace
3. Register per-project agents (coordinator + execution agents)
4. Create pipeline config at `~/.paperclip/pipelines/{project}.yaml`
5. Create first task and assign to coordinator
