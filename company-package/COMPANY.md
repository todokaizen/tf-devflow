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

## Design Philosophy

### Layered Architecture

1. **Paperclip (orchestration)** — task routing, scheduling, approvals, audit logs
2. **UAW (workflow manifest)** — roles, allowed actions, required steps, constraints
3. **Execution agents** — Claude, Codex, AntiGravity, Gemini, others
4. **Validation (outside Paperclip)** — tests, evaluators, rubrics, policy checks
5. **Output sinks** — GitHub, CMS, datasets, Open Brain

### Critical Rule

Paperclip never decides correctness. It coordinates, records, and enforces
workflow. Correctness comes from validation systems, evaluation pipelines,
and policy rules — all outside Paperclip.

## How It Works

1. Each project repo contains UAW v3 files (CLAUDE.md, resume.md, decisions.md, specs/)
2. You create a task in Paperclip and assign it to the project's coordinator
3. The coordinator reads the pipeline config and creates sub-tasks per stage
4. Paperclip auto-wakes each assigned agent via heartbeat
5. Agents follow the UAW contract autonomously — Paperclip tracks status and budget
6. The coordinator pauses at approval gates for your review
7. You approve or intervene — the coordinator never makes judgment calls

## Agents

### Coordinator (per project)
Pipeline state machine. Routes tasks, creates sub-tasks, pauses at gates.
Never judges correctness.

### Execution Agents (role-agnostic)
Any agent can fill any role. Role assignment is per-project config.
- **Claude** — claude_local adapter
- **Codex** — codex_local adapter
- **AntiGravity** — process adapter
- **Gemini** — gemini_local adapter

## Pipeline Roles

Assigned per-project in `~/.paperclip/pipelines/{project}.yaml`:
- **spec_writer** — writes spec files from task descriptions
- **spec_validator** — reviews specs for ambiguity, consistency, feasibility
- **executor** — implements the work following the spec
- **reviewer** — validates the result against the spec and done condition
