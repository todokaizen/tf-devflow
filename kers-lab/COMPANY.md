---
name: "Ker's Lab"
schema: "agentcompanies/v1"
slug: "kers-lab"
---

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
