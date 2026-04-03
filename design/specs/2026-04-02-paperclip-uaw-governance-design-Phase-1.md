# Design: Paperclip + UAW v3 Integration with Governance Framework - Pase 1

Date: 2026-04-02
Status: draft
Supersedes: 2026-03-30-paperclip-uaw-integration-design.md

## Objective

Orchestrate AI agent workflows across multiple ventures using Paperclip as the control plane, Paperclip-UAW v1 as the in-repo workflow contract, and the TodoFoco Governance Framework for decision classification and escalation. Everything is portable — if Paperclip is replaced, only who kicks off jobs changes.

---

## System-Wide Invariant

> **No workflow stage may introduce behavior not explicitly defined in the spec or validated outputs.**

This constrains every stage: the spec-writer defines scope, the implementor builds only what's specified, the validator catches anything unauthorized. Silent feature creep is a system violation, not a judgment call.

---

## Design Philosophy

### Layered Architecture

```
Layer 1: Paperclip (orchestration)
  Task routing, scheduling, approvals, audit logs.
  VentureLead agents live here. TodoFoco CEO lives here.

Layer 2: Paperclip-UAW v1 (workflow manifest, in each repo)
  CLAUDE.md + AGENTS.md define: authority order, session protocol,
  decision classification, governance rules, phase verification.
  Agents read these on startup and follow them autonomously.

Layer 3: Execution (workflow-stage functions)
  Spec Writer, Implementor, Validator passes.
  Separate runs, separate contexts, separate models.
  Stateless, non-authoritative — functions, not agents.

Layer 4: Validation (outside Paperclip)
  Tests, lint, typecheck, schema validation, eval pipelines.
  Correctness is decided here — never in Paperclip.

Layer 5: Output sinks
  GitHub (code), CMS (NHN), datasets (TFLabs), Open Brain.
```

### Critical Design Rules

1. **Paperclip never decides correctness.** It coordinates, records, and enforces workflow. Correctness comes from validation systems (Layer 4) and human judgment at approval gates.

2. **Complexity must be earned by failure, not anticipated by design.** Phase 1 is deliberately minimal. Components are added only when specific failures justify them.

3. **All configs are portable.** Agent definitions, pipeline configs, UAW templates, and governance rules live as files you own. Paperclip imports them. Nothing is lost if Paperclip is replaced.

4. **Context independence between workflow stages.** The Spec Writer, Implementor, and Validator must run in separate contexts. Same context = same blind spots = no real separation.

---

## Governance Framework

Based on: TodoFoco AI Governance Framework (Phase 1 — Simplified)

### Decision Classification (3 Types)

**Routine**

- Reversible, low cost, single venture, high confidence
- Action: Log only (issue comment)

**Significant**

- Affects direction within a venture, moderate cost/time, some uncertainty
- Action: Notify operator (non-blocking issue comment)

**Critical**

- Irreversible OR cross-venture OR external-facing OR low confidence + high impact
- Action: Block — create Paperclip approval request, wait for human review

### Self-Check Requirement

Every decision must include:

```json
{
  "classification": "routine | significant | critical",
  "confidence": 0.0,
  "why_not_critical": "justification"
}
```

If justification is weak or missing → treat as Critical.

### Decision Record

Every decision must produce (as a structured issue comment):

```json
{
  "decision": "what was decided",
  "origin_decision": "...",
  "classification": "routine | significant | critical",
  "confidence": 0.0,
  "scope": "venture | portfolio",
  "timestamp": "ISO-8601",
  "escalated": true/false
}
```

100% logging required. No filtering.

### Escalation Rules

Only Critical decisions trigger human involvement. Triggers:

- Irreversible actions
- Cross-venture impact
- External exposure
- Low confidence + high impact

---

## Company Structure

Each business entity is a separate Paperclip company — fully isolated agents, budgets, and projects. TodoFoco is the parent company for strategic oversight.

```
TodoFoco (Paperclip company — strategy layer)
  └── todofoco-CEO (agent with persistent memory)
        Strategic advisor, cross-venture planning.
        Cannot directly touch venture companies (Paperclip isolation).
        You consult it; you carry decisions across ventures.

TFLabs (Paperclip company — venture)
  ├── ventureLead-tflabs (standing agent — orchestrates, governs)
  ├── spec-writer-tflabs (workflow stage — codex_local)
  ├── implementor-tflabs (workflow stage — claude_local)
  ├── validator-tflabs (workflow stage — codex_local)
  └── debugger-tflabs (diagnosis — claude_local opus)
  Projects: tflabs-poc, tflabs-edu-fe

NHN (Paperclip company — venture)
  ├── ventureLead-nhn
  ├── spec-writer-nhn, implementor-nhn, validator-nhn, debugger-nhn
  Projects: nine-human-needs

WebSites (Paperclip company — venture)
  ├── ventureLead-websites
  ├── spec-writer-websites, implementor-websites, validator-websites, debugger-websites
  Projects: todofoco, galileo-curie, galileos-circle, tfeval-ui, todofoco-edu, tflabs-web
```

---

## Agent Model

### Standing Agents (governance + orchestration)

**todofoco-CEO** (TodoFoco company only)

- Role: CEO with persistent memory (PARA)
- Adapter: claude_local (opus)
- Responsibilities: strategic thinking, cross-venture planning, portfolio decisions
- Does NOT directly manage venture work

**ventureLead** (one per venture company)

- Role: PM — the accountable owner of all work in the venture
- Adapter: claude_local
- Responsibilities:
  - Receives tasks, classifies decisions per governance framework
  - Dispatches workflow stages (spec-writer, implementor, validator) as sub-tasks
  - Manages task lifecycle per pipeline config
  - Pauses at approval gates for human review
- Does NOT do implementation work itself
- Follows the VentureLead state machine (see Pipeline section)

### Workflow-Stage Agents (ephemeral execution contexts)

These are Paperclip agents the ventureLead dispatches to. They have distinct contexts (guaranteed by being separate agent runs), distinct models, and no governance authority. They are functions, not decision-makers.

**spec-writer**

- Adapter: codex_local
- Input: goal + constraints + repo context
- Output: spec file in specs/
- Reads CLAUDE.md/AGENTS.md on startup, follows UAW session protocol

**implementor**

- Adapter: claude_local
- Input: spec only + repo/tools
- Output: code changes, commits, test results
- Reads CLAUDE.md on startup, follows UAW session protocol

**validator**

- Adapter: codex_local
- Input: spec + diff/output + test results
- Output: structured validation record (see below) + escalation recommendation
- Must consume objective artifacts (tests, lint, typecheck) — not just LLM review
- Reads AGENTS.md on startup, follows UAW protocol
- Required output format:

```json
{
  "spec_fulfilled": true/false,
  "spec_violations": ["list of spec requirements NOT satisfied"],
  "extra_behavior_detected": ["behavior implemented that spec did NOT authorize"]
}
```

The `extra_behavior_detected` field is critical — this is where subtle bugs and unauthorized feature creep live.

If validator returns fail:
- Issues are returned to the implementor as a new sub-task with violations attached
- Implementor retries (up to N times, same as debugger escalation threshold)
- If retries exhausted → debugger escalation

**debugger**

- Adapter: claude_local (opus — stronger model, fresh perspective)
- Input: original task + failure history + repo state
- Output: diagnosis report (root cause, recommended approach)
- Diagnoses only, does not fix. Different model for different blind spots.

### Agent Naming Convention

Stack-first with company suffix: `ventureLead-tflabs`, `spec-writer-nhn`, `implementor-websites`.

Agents can be renamed or new specialized variants created at any time (e.g., `implementor-tflabs-langchain`).

---

## Task Pipeline

### How a Task Flows

```
You create a task → assign to ventureLead-{company}

VentureLead classifies the task decision:
  routine → logs, proceeds
  significant → notifies you, proceeds
  critical → blocks, waits for your approval

VentureLead reads ~/.paperclip/pipelines/{project}.yaml
VentureLead creates sub-tasks per phase_rules[phase]:

  [spec-writer] → separate Codex run, writes spec
     ↓ HUMAN REVIEW GATE (see Spec Review Protocol below)
  [implementor] → separate Claude Code run, implements from spec
     ↓
  [validator] → separate Codex run, validates against spec + hard checks
     ↓ if fail → issues returned to implementor → retry (up to 3x)
     ↓ if retries exhausted → [debugger] diagnoses → you review → retry
     ↓ if pass → approval gate — you review the result

  Parent task → in_review → your final sign-off → done
```

### Pipeline Config

Lives at `~/.paperclip/pipelines/{project}.yaml` — Paperclip-managed, outside repos.

```yaml
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

role_assignments:
  spec_writer: "spec-writer-COMPANYNAME"
  spec_validator: "validator-COMPANYNAME"
  executor: "implementor-COMPANYNAME"
  reviewer: "validator-COMPANYNAME"
  debugger: "debugger-COMPANYNAME"

approval_gates:
  - after: spec_writer
  - after: reviewer

failure_escalation:
  executor_retries_before_debugger: 3
```

### Phase Classification

| Phase             | Spec Required | Pipeline                                           |
| ----------------- | ------------- | -------------------------------------------------- |
| Exploratory       | No            | executor only                                      |
| Structural        | Short spec    | spec_writer → executor                             |
| Production        | Full spec     | spec_writer → spec_validator → executor → reviewer |
| Durable Knowledge | Full spec     | spec_writer → spec_validator → executor → reviewer |

---

## Spec Review Protocol

The human review gate after spec-writer is the highest-leverage checkpoint in the pipeline. It breaks the "LLM → LLM → LLM agreement loop" where spec anchoring errors propagate downstream unchallenged.

**Review specs as if they are wrong, not as if they are probably correct.**

### Three Checks (answer explicitly before approving)

1. **What is the most likely failure?**
   - Missing edge case? Wrong assumption? Hidden dependency?

2. **What is NOT specified that should be?**
   - Inputs? Outputs? Constraints? Success criteria?

3. **Is this solving the right problem?**
   - Scope creep? Misaligned with original goal? Unnecessary complexity?

If you cannot answer these clearly → do not approve.

You must identify at least one concrete risk or missing element, or explicitly state "none found after adversarial review." Default to finding something — "looks good" is not a review.

### Review Record

Log your review as a structured issue comment:

```json
{
  "review_passed": true,
  "identified_risks": ["..."],
  "missing_elements": ["none" or "..."],
  "solving_right_problem": true
}
```

This creates accountability, traceability, and a learning signal for refining spec-writer prompts over time.

### Failure Mode to Watch

The risk shifts from "bad spec propagates" to "spec approved too quickly without adversarial thinking." The three checks above are the minimum — do not reduce them to a checkbox habit.

---

## Enhanced Spec Template

The spec template in `paperclip-uaw/templates/specs/spec-template.md` must include these sections to force the spec-writer to surface uncertainty:

```markdown
# Spec: {Name}
Date: {YYYY-MM-DD}
Status: {draft / accepted / superseded}

## Objective
{what this work achieves}

## Scope
### Included
- {what is in scope}

### Excluded
- {what is explicitly out of scope}

## Assumptions
- {what the spec takes for granted — surface these}

## Failure Modes
- {what could go wrong — be specific}

## Constraints
- {technical, time, or resource boundaries}

## Done Condition
{how to know this work is complete — be specific and verifiable}
```

The Assumptions and Failure Modes sections are new. Combined with Scope/Excluded, they force the spec-writer to:
- Surface uncertainty (assumptions)
- Constrain scope (excluded)
- Expose weak points (failure modes)

These sections give the human reviewer concrete material to evaluate rather than having to discover gaps in a polished-looking document.

---

## Paperclip-UAW v1 Contract (in each repo)

Each project repo contains:

```
project-root/
  CLAUDE.md      ← Paperclip-UAW operating contract (Claude Code reads this)
  AGENTS.md      ← UAW pointer for Codex compatibility
  resume.md      ← current project and session state
  decisions.md   ← append-only architectural decisions
  specs/         ← spec files for non-exploratory work
  archive/       ← dated resume.md copies from prior sessions
```

CLAUDE.md contains:

- Authority order (spec > decisions.md > resume.md > Paperclip > conversation)
- Session start/end protocol
- Governance classification rules (the full framework)
- Phase classification and verification depth
- Multi-agent pipeline rules (session handoff, role scoping, externally assigned phase)

AGENTS.md points Codex to CLAUDE.md so all agents follow the same contract.

---

## Kickoff and Context Independence

When the ventureLead creates a sub-task for a workflow stage:

- The sub-task is assigned to a different Paperclip agent (separate adapter, separate session)
- Paperclip auto-wakes the agent via heartbeat
- The agent lands in the project workspace, reads CLAUDE.md/AGENTS.md
- The agent has NO access to the ventureLead's context or other stages' context
- Context independence is guaranteed by Paperclip's agent isolation

The ventureLead includes the role in the sub-task title (e.g., `[spec-writer] Build auth system`) so the agent knows its scope.

---

## TodoFoco CEO

The CEO agent lives in the TodoFoco company. It cannot directly see or touch venture companies (Paperclip isolation). The operating model:

- You consult the CEO for portfolio-level strategy, priority decisions, cross-venture trade-offs
- The CEO produces strategy docs and decisions
- You carry those decisions to the relevant venture companies
- The CEO has persistent memory (PARA) for accumulated strategic context
- The CEO classifies its own decisions per the governance framework

The CEO is an advisor, not an orchestrator.

**Constraint:** CEO outputs must be translated into venture-level tasks before execution. Abstract strategy does not flow directly to agents — you create concrete tasks in the relevant venture company based on CEO recommendations.

---

## Phase 1 Deliberate Exclusions

Per the governance framework's operating principle ("complexity earned by failure"):

- No validator agents beyond the workflow-stage validator
- No opsLead or taskOrchestrator layers
- No complex ACL systems
- No multi-agent debate
- No advanced memory systems (except CEO)

### Phase 2 Triggers

| Failure                              | Add                                 |
| ------------------------------------ | ----------------------------------- |
| Misclassification / silent errors    | Standalone validator agent          |
| Task coordination breakdown          | opsLead role                        |
| High task concurrency chaos          | taskOrchestrator                    |
| Cross-venture interference           | Stricter ACLs                       |
| Self-review consistently misses bugs | Separate reviewer agent per venture |

---

## Project Onboarding Flow

1. **Prepare the repo.** Copy Paperclip-UAW templates (`CLAUDE.md`, `AGENTS.md`, `resume.md`, `decisions.md`, `specs/`, `archive/`). Fill in resume.md.
2. **Create the Paperclip project.** Project name, workspace pointing to repo path.
3. **Import the company.** `pnpm paperclipai company import ./companies/{company} --new-company-name "{Name}"`
4. **Rename agents.** Add company suffix: `venture-lead` → `ventureLead-tflabs`, etc.
5. **Create pipeline config.** Copy template to `~/.paperclip/pipelines/{project}.yaml`, fill in agent names.
6. **Create first task.** Assign to the ventureLead. It takes it from there.

---

## Key Design Decisions

1. **Layered architecture** — five layers, each with one job
2. **Paperclip never decides correctness** — coordinates, records, enforces
3. **Governance classification** — 3-type decision model with self-check and routing
4. **VentureLead is the accountable owner** — orchestrates but does not execute
5. **Workflow stages are separate contexts** — spec-writer/implementor/validator run in isolated sessions with different models
6. **Context independence is non-negotiable** — same context = same blind spots = no real separation
7. **Separate companies per business entity** — fully isolated in Paperclip
8. **TodoFoco CEO is an advisor** — strategic thinking, cannot directly touch ventures
9. **Configs are portable** — all definitions are files you own
10. **Complexity earned by failure** — Phase 1 is minimal, add only when failures justify
11. **Human review gate before implementation** — spec review with 3 explicit checks; highest-leverage checkpoint in the pipeline
12. **Specs must surface uncertainty** — Assumptions, Failure Modes, Out of Scope sections are required
