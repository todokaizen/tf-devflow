# Architecture Quick Reference

Date: 2026-04-08
Status: current
Version: 1.0
Supersedes: none

Visual reference for the Paperclip + UAW governance framework. For full design rationale, see `design/specs/2026-04-02-paperclip-uaw-governance-design-Phase-1.md`.

---

## Five-Layer Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│  LAYER 1: Paperclip (orchestration)                             │
│                                                                 │
│  Task routing, scheduling, approvals, audit logs, budgets.      │
│  VentureLead and CEO agents live here.                          │
│                                                                 │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐        │
│  │ TodoFoco │  │ TFLabs   │  │ NHN      │  │ WebSites │        │
│  │ (CEO)    │  │ (venture)│  │ (venture)│  │ (venture)│        │
│  └──────────┘  └──────────┘  └──────────┘  └──────────┘        │
│       ↑              ↑             ↑             ↑              │
│   advisory      orchestrates  orchestrates  orchestrates        │
│   (manual)      (automated)  (automated)  (automated)          │
├─────────────────────────────────────────────────────────────────┤
│  LAYER 2: Paperclip-UAW v1 (workflow manifest, in each repo)   │
│                                                                 │
│  CLAUDE.md + AGENTS.md define: authority order, session         │
│  protocol, decision classification, governance rules.           │
│  Agents read these on startup and follow autonomously.          │
│                                                                 │
│  Files: CLAUDE.md, AGENTS.md, resume.md, decisions.md, specs/  │
├─────────────────────────────────────────────────────────────────┤
│  LAYER 3: Execution (workflow-stage agents)                     │
│                                                                 │
│  Separate runs, separate contexts, separate models.             │
│  Stateless, non-authoritative — functions, not agents.          │
│                                                                 │
│  ┌────────────┐  ┌──────────────┐  ┌───────────┐  ┌─────────┐ │
│  │ spec-writer│  │ implementor  │  │ validator │  │ debugger│ │
│  │ (codex)    │  │ (claude      │  │ (codex)   │  │ (claude │ │
│  │            │  │  sonnet)     │  │           │  │  opus)  │ │
│  └────────────┘  └──────────────┘  └───────────┘  └─────────┘ │
├─────────────────────────────────────────────────────────────────┤
│  LAYER 4: Validation (outside Paperclip)                        │
│                                                                 │
│  Tests, lint, typecheck, schema validation, eval pipelines.     │
│  Correctness is decided HERE — never in Paperclip.              │
├─────────────────────────────────────────────────────────────────┤
│  LAYER 5: Output sinks                                          │
│                                                                 │
│  GitHub (code), CMS (NHN), datasets (TFLabs), Open Brain.      │
└─────────────────────────────────────────────────────────────────┘
```

---

## Company Structure

```
TodoFoco (strategy layer)
  └── CEO agent (opus) — advisory only, cannot touch ventures
        You carry decisions across ventures manually.

TFLabs (venture)                    NHN (venture)
  ├── VentureLead (sonnet)            ├── VentureLead (sonnet)
  ├── SpecWriter (codex)              ├── SpecWriter (codex)
  ├── Implementor (sonnet)            ├── Implementor (sonnet)
  ├── Validator (codex)               ├── Validator (codex)
  ├── Debugger (opus)                 ├── Debugger (opus)
  │                                   │
  ├── tflabs-poc                      └── nine-human-needs
  └── tflabs-edu-fe

WebSites (venture)
  ├── VentureLead (sonnet)
  ├── SpecWriter (codex)
  ├── Implementor (sonnet)
  ├── Validator (codex)
  ├── Debugger (opus)
  │
  ├── todofoco          ├── galileos-circle
  ├── galileo-curie     ├── tfeval-ui
  ├── todofoco-edu      └── tflabs-web
```

Companies are fully isolated in Paperclip — agents, budgets, and projects do not cross boundaries.

---

## Task Pipeline Flow

```
                    ┌──────────────┐
                    │  YOU create   │
                    │  task + phase │
                    └──────┬───────┘
                           │
                    ┌──────▼───────┐
                    │ VentureLead  │
                    │ classifies:  │
                    │ routine /    │
                    │ significant /│
                    │ critical     │
                    └──────┬───────┘
                           │
              ┌────────────▼────────────┐
              │ Reads pipeline config   │
              │ for this project's phase│
              └────────────┬────────────┘
                           │
                ┌──────────▼──────────┐
                │    spec-writer      │
                │    (codex)          │
                └──────────┬──────────┘
                           │
              ╔════════════▼════════════╗
              ║   HUMAN REVIEW GATE    ║
              ║   3-check protocol     ║
              ╚════════════╬════════════╝
                           │
                ┌──────────▼──────────┐
                │    implementor      │
                │    (claude sonnet)  │
                └──────────┬──────────┘
                           │
                ┌──────────▼──────────┐
                │     validator       │◄──── fail: retry implementor
                │     (codex)         │      (up to 3x)
                └──────────┬──────────┘
                           │               ┌──────────┐
                     fail + exhausted ────►│ debugger  │
                           │               │ (opus)    │
                           │               │ diagnoses │
                           │               └──────────┘
              ╔════════════▼════════════╗
              ║   HUMAN REVIEW GATE    ║
              ║   final sign-off       ║
              ╚════════════╬════════════╝
                           │
                    ┌──────▼───────┐
                    │    DONE      │
                    └──────────────┘
```

Note: Exploratory tasks skip spec-writer and validator. Structural tasks skip validator. See phase classification table in `design/RUNBOOK.md`.

---

## Data Flow

```
Pipeline config                    UAW contract files
~/.paperclip/pipelines/            project-repo/
  {project}.yaml ──read by──►       CLAUDE.md ──read by──► all agents
  (Layer 1)        VentureLead       resume.md ◄──written by── all agents
                                     decisions.md ◄──appended by── all agents
                                     specs/ ◄──written by── spec-writer
                                     archive/ ◄──session copies

Paperclip DB                       Git repo
  issues, runs, approvals            code, tests, specs, decisions
  (Layer 1 state)                    (Layer 2-5 artifacts)
```

---

## Governance Decision Flow

```
Agent makes decision
        │
        ▼
┌───────────────┐     ┌───────────────┐     ┌───────────────┐
│   ROUTINE     │     │  SIGNIFICANT  │     │   CRITICAL    │
│               │     │               │     │               │
│ Log as issue  │     │ Notify via    │     │ BLOCK — create│
│ comment       │     │ issue comment │     │ approval      │
│               │     │ (non-blocking)│     │ request       │
│ Proceed       │     │ Proceed       │     │ WAIT for human│
└───────────────┘     └───────────────┘     └───────────────┘

Every decision includes:
  classification + confidence + why_not_critical
```

---

## Key Design Rules

1. **Paperclip never decides correctness** — it coordinates, records, enforces
2. **Context independence between stages** — separate agent = separate session = separate blind spots
3. **Complexity earned by failure** — Phase 1 is minimal; add components only when failures justify them
4. **Configs are portable** — all definitions are files you own; nothing is lost if Paperclip is replaced
5. **Human review at spec stage** — highest-leverage checkpoint; breaks the LLM agreement loop

---

## File Locations

| What | Where | Who reads it |
|------|-------|-------------|
| Design spec | `design/specs/2026-04-02-*-Phase-1.md` | You (architecture reference) |
| Decisions log | `design/decisions.md` | You + agents (via project decisions.md) |
| Resume | `design/resume.md` | You + agents (via project resume.md) |
| Issues log | `design/issues/paperclip-issues-log.md` | You (troubleshooting) |
| Runbook | `design/RUNBOOK.md` | You (daily operations) |
| UAW templates | `paperclip-uaw/templates/` | Copied to project repos |
| UAW installer | `paperclip-uaw/install.sh` | You (setup new projects) |
| Company configs | `companies/*/.paperclip.yaml` | Paperclip (import) |
| Master template | `master-template/` | You (scaffold new ventures) |
| Pipeline configs | `~/.paperclip/pipelines/*.yaml` | VentureLead agents |
| Agent instructions | `companies/*/agents/*/AGENTS.md` | Paperclip agents |
