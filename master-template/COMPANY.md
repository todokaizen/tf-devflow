---
name: "Venture Template"
schema: "agentcompanies/v1"
slug: "venture-template"
---

Master template for creating venture companies. Import once per venture, rename agents with company suffix.

## Agents

| Agent | Role | Adapter | Purpose |
|-------|------|---------|---------|
| venture-lead | PM | claude_local | Orchestrates workflow, classifies decisions, manages lifecycle |
| spec-writer | Engineer | codex_local | Writes specs from goals and constraints |
| implementor | Engineer | claude_local | Implements from specs |
| validator | QA | codex_local | Validates against spec + objective artifacts |
| debugger | QA | claude_local (opus) | Diagnoses repeated failures |

## Governance

3-type decision classification (routine/significant/critical) with self-check and escalation. See CLAUDE.md in each project repo for the full contract.

## Pipeline

VentureLead dispatches workflow stages as sub-tasks. Each stage runs in a separate context with a separate model. Human reviews spec before implementation and result after validation.
