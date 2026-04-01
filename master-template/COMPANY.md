---
name: "Agent Template"
schema: "agentcompanies/v1"
slug: "agent-template"
---

Master template for creating AI agent companies. Import this once per company,
activating only the agents each company needs.

## Companies

| Company | Focus | Key Agents |
|---------|-------|------------|
| TFLabs | AI/LangGraph platform | python, fe, devops, research, coordinator |
| TFEdu | Education platforms | python, content, research, coordinator |
| NHN | Nine Human Needs (content/web) | fe, content, coordinator |
| TFTrading | Crypto trading | python, crypto, coordinator |
| TFOpenBrain | Open research platform | python, devops, research, coordinator |

## Agent Activation Matrix

| Agent | TFLabs | TFEdu | NHN | TFTrading | TFOpenBrain |
|-------|--------|-------|-----|-----------|-------------|
| coordinator | yes | yes | yes | yes | yes |
| python | yes | yes | - | yes | yes |
| fe | yes | - | yes | - | - |
| devops | yes | - | - | - | yes |
| content | - | yes | yes | - | - |
| research | yes | yes | - | - | yes |
| crypto | - | - | - | yes | - |

## Design Philosophy

### Layered Architecture

1. **Paperclip (orchestration)** — task routing, scheduling, approvals, audit logs
2. **UAW (workflow manifest)** — roles, allowed actions, required steps, constraints
3. **Execution agents** — do the work, follow UAW in each repo
4. **Validation (outside Paperclip)** — tests, evaluators, rubrics, policy checks
5. **Output sinks** — GitHub, CMS, datasets, Open Brain

### Critical Rule

Paperclip never decides correctness. It coordinates, records, and enforces
workflow. Correctness comes from validation systems, evaluation pipelines,
and policy rules — all outside Paperclip.
