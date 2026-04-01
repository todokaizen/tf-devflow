# Agent Template — Paperclip Company Package

Master template for creating AI agent companies. Each company gets its own
isolated Paperclip instance with stack-specialized agents.

## Design Philosophy

```
Layer 1: Paperclip        — coordinates, records, enforces workflow
Layer 2: UAW v3           — defines roles, steps, constraints (in each repo)
Layer 3: Execution agents — do the work, follow UAW
Layer 4: Validation       — tests, evaluators, rubrics (outside Paperclip)
Layer 5: Output sinks     — GitHub, CMS, datasets
```

**Critical rule:** Paperclip never decides correctness. The coordinator is a
state machine — it routes tasks, it does not judge them.

## Creating a Company

### 1. Import the template

```bash
paperclipai company import ./master-template --new-company-name "TFLabs"
```

This creates a new Paperclip company with all 7 agent types. Deactivate
(pause/terminate) the ones this company doesn't need.

### 2. Rename agents with company suffix

After import, rename agents to follow the naming convention:

```
python       → python-tflabs
fe           → fe-tflabs
coordinator  → coordinator-tflabs
devops       → devops-tflabs
```

Use the Paperclip UI (Agent Detail → edit name) or API.

### 3. Configure per-project workspaces

For each project repo, create a Paperclip project with a workspace:

```bash
# Via API:
# POST /api/companies/{companyId}/projects
# {
#   "name": "TFLabs-poc",
#   "workspace": {
#     "sourceType": "local_path",
#     "cwd": "/path/to/tflabs-poc",
#     "isPrimary": true
#   }
# }
```

### 4. Create pipeline config

```bash
mkdir -p ~/.paperclip/pipelines
cp master-template/pipelines/template.yaml ~/.paperclip/pipelines/tflabs-poc.yaml
```

Edit the pipeline config — set agent names to match your renamed agents:

```yaml
role_assignments:
  spec_writer: "python-tflabs"
  spec_validator: "python-tflabs"
  executor: "python-tflabs"
  reviewer: "devops-tflabs"
```

### 5. Copy UAW templates into the project repo

```bash
cp -r UAW-v3/uaw-templates/ /path/to/tflabs-poc/
```

Edit `resume.md` with the project state.

### 6. Create your first task

Create a Paperclip issue:
- Title: "Implement feature X"
- Assign to: `coordinator-tflabs`

The coordinator reads the pipeline config, creates sub-tasks for each stage,
assigns agents, and pauses at approval gates for your review.

## Agent Types

All agents are role-agnostic — any can serve as spec_writer, spec_validator,
executor, or reviewer. The pipeline config decides.

| Agent | Expertise |
|-------|-----------|
| coordinator | Pipeline state machine. Routes tasks, never judges. |
| python | Python, LangGraph, FastAPI, agent frameworks, data pipelines |
| fe | Next.js, React, TypeScript, Tailwind, component libraries |
| devops | Docker, CI/CD, GitHub Actions, infrastructure |
| content | Technical writing, docs, educational content |
| research | Literature review, analysis, evaluation, datasets |
| crypto | Cryptocurrency markets, trading, blockchain, DeFi |

## Companies and Projects

| Company | Projects |
|---------|----------|
| TFLabs | TFLabs-poc, TFLabs-FE, TFLabs-Evals |
| TFEdu | TFChem, TFBio, Galileo-Circle, Galileo-Curie |
| NHN | (TBD) |
| TFTrading | (TBD) |
| TFOpenBrain | (TBD) |

## How the Pipeline Runs

```
You create task → assign to coordinator → set phase

Coordinator reads ~/.paperclip/pipelines/{project}.yaml
For production phase:

  [spec_writer] → writes the spec
     ↓ approval gate — you review
  [spec_validator] → validates the spec
     ↓
  [executor] → implements
     ↓
  [reviewer] → validates result
     ↓ approval gate — you review

  Parent task → in_review → final sign-off → done
```

## Future Home

These configs will move to a dedicated vault repo (TFLabs-Projects-Vault)
once Obsidian + git coexistence is sorted out. The paperclip repo is temporary.
