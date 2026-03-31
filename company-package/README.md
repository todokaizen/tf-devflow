# Ker's Lab — Paperclip Company Package

## Prerequisites

1. Paperclip server running (`paperclipai run`)
2. UAW v3 templates copied into each project repo (see `UAW-v3/uaw-templates/`)

## Quick Setup

### 1. Import the company

```bash
paperclipai company import ./company-package --new-company-name "Ker's Lab"
```

This creates the company with template agents. The agents need per-project
configuration before they can work.

### 2. For each project, create project-specific agents

Agents are registered per-project with project-specific configs. Use the
Paperclip API or CLI.

Example for TFLabs (Python project):

```bash
# Create the project with workspace
# POST /api/companies/{companyId}/projects
# {
#   "name": "TFLabs",
#   "description": "Python AI/LangGraph platform",
#   "workspace": {
#     "sourceType": "local_path",
#     "cwd": "/path/to/tflabs",
#     "isPrimary": true
#   }
# }

# Create per-project agent instances
# POST /api/companies/{companyId}/agents
# {
#   "name": "Claude-TFLabs",
#   "role": "engineer",
#   "adapterType": "claude_local",
#   "adapterConfig": {
#     "cwd": "/path/to/tflabs",
#     "model": "claude-sonnet-4-6"
#   },
#   "budgetMonthlyCents": 5000
# }

# Repeat for Codex-TFLabs, AntiGrav-TFLabs, Gemini-TFLabs as needed
```

### 3. Copy UAW templates into each project repo

```bash
cp -r UAW-v3/uaw-templates/ /path/to/project/
```

Edit `resume.md` with the project state and `pipeline-config.yaml` with
the agent names you registered (e.g., `Claude-TFLabs`, `Codex-TFLabs`).

### 4. Create your first task

In the Paperclip UI or CLI, create an issue assigned to the appropriate
agent based on the project's pipeline-config.yaml role map.

## Pipeline Workflow (Manual)

Until Paperclip gains native pipeline routing, follow this process:

1. **You** evaluate the project and decide what to do
2. **You** create a Paperclip issue with title, description
3. **You** check the project's `pipeline-config.yaml` for phase rules
4. **For production/durable phases:**
   a. Assign to the spec_writer agent — wait for completion
   b. (Optional) Assign to spec_validator agent — wait for review
   c. Review and approve the spec yourself
   d. Assign to the executor agent — wait for completion
   e. Assign to the reviewer agent — wait for validation
   f. Review and approve the result
5. **For exploratory phases:**
   a. Assign directly to executor agent — review when done
6. **For structural phases:**
   a. Assign to spec_writer — approve spec — assign to executor — review

## Role Map Reference

Each project's `pipeline-config.yaml` is the authoritative source for role
assignments. Any agent can fill any role — the config decides.

Default roles from the template:

| Role | What it does |
|------|-------------|
| spec_writer | Write specs from task descriptions |
| spec_validator | Review specs for quality and feasibility |
| executor | Implement the work |
| reviewer | Validate against done condition |

Example pipeline-config.yaml assignment:
```yaml
role_assignments:
  spec_writer: "Codex-TFLabs"
  spec_validator: "Claude-TFLabs"
  executor: "Claude-TFLabs"
  reviewer: "AntiGrav-TFLabs"
```

You can assign any agent to any role. Claude can be the spec_writer on one
project and the reviewer on another.

## Graduating to Automation

When Paperclip adds native pipeline routing:
1. The `pipeline-config.yaml` format becomes machine-readable project config
2. Paperclip auto-creates sub-tasks per pipeline stage
3. Paperclip auto-assigns agents based on the role map
4. You only intervene at approval gates
