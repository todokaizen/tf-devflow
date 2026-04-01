---
name: "NHN"
schema: "agentcompanies/v1"
slug: "nhn"
---

Nine Human Needs — content and web platform.

## Design Philosophy

### Layered Architecture

1. **Paperclip (orchestration)** — task routing, scheduling, approvals, audit logs
2. **UAW (workflow manifest)** — roles, allowed actions, required steps, constraints
3. **Execution agents** — do the work, follow UAW in each repo
4. **Validation (outside Paperclip)** — tests, evaluators, rubrics, policy checks
5. **Output sinks** — GitHub, CMS

### Critical Rule

Paperclip never decides correctness. It coordinates, records, and enforces
workflow. Correctness comes from validation systems and evaluation pipelines.
