# Operating Contract — Paperclip-UAW v1

You are operating inside the Paperclip-UAW workflow (based on UAW v3).

Written files are authoritative. Conversation is secondary.
If conflict exists, written files win.

## System-Wide Invariant

> No workflow stage may introduce behavior not explicitly defined in the spec or validated outputs.

---

## Authority Order

1. Spec file — authority of intent and scope
2. decisions.md — authority of durable architectural decisions
3. resume.md — authority of current project and session state
4. Paperclip — authority of task status and issue backlog
5. Conversation — lowest authority

---

## Session Start — Do This First

Before any implementation:

1. Read `resume.md`
2. Read `decisions.md`
3. Read the active spec referenced in resume.md (if any)
4. Check Paperclip for new issues or priority changes
5. Report current project state and active task
6. Begin at the Next Action stated in resume.md

If resume.md has no Resume Point yet, ask what to work on.

---

## During Execution

- Operate only on the stated task
- Update `resume.md` incrementally as you work
- Record decisions in `decisions.md` immediately when architecture changes
- Update Paperclip task status at each transition
- Do not broaden task scope beyond what is written
- Do not silently refactor unrelated files
- Do not change dependencies without recording a decision

---

## Session End — Do This Before Stopping

1. Ensure Paperclip is updated with current task state
2. Copy current `resume.md` to `archive/resume-YYYY-MM-DD.md`
3. Write fresh `resume.md` with current project state and resume point
4. Update `decisions.md` if any decisions were made during this session

---

## Task Statuses (Paperclip)

IDEA → SPEC → TODO → IN PROGRESS → BLOCKED → REVIEW → DONE

- Do not begin execution before a task is IN PROGRESS
- Do not mark REVIEW without proof (test output, screenshot, CLI result, or review pass)
- Do not mark DONE without completing the session end steps above
- If blocked, record why in resume.md and Paperclip, then stop

---

## Spec Rule

Every task that is not exploratory must have a spec in `specs/` before execution begins.
Exploratory tasks may skip the SPEC status.

---

## Phase Classification

| Phase | Spec Required | Verification Depth |
|-------|--------------|-------------------|
| Exploratory | No | Plausible enough to continue |
| Structural | Short spec | Internally coherent |
| Production | Full spec | Must survive real use |
| Durable Knowledge | Full spec | Source traceability |

---

## File Structure

```
project-root/
  CLAUDE.md            ← this file
  AGENTS.md            ← pointer for Codex/non-Claude agents
  resume.md            ← current state — read first on every session
  decisions.md         ← append-only decisions — read second
  specs/               ← spec files for non-exploratory work
  archive/             ← dated resume.md copies from prior sessions
```

---

## When Uncertain

Stop and ask. Specify:
- which file
- which boundary
- which expected output

Never guess hidden intent.
Prefer narrower scope, explicit uncertainty, and reversible progress.

---

## Multi-Agent Pipeline Rules

When operating as part of a multi-agent pipeline orchestrated by Paperclip or
another coordinator:

### Session Handoff
When multiple agents work a task sequentially, each agent completes the full
shutdown protocol before the next agent starts. The incoming agent reads
`resume.md` written by the previous agent as its starting context.

### Role Scoping
When you receive a scoped role assignment, operate only within that role's
boundaries. A spec-writer produces the spec and completes shutdown. An
implementor implements. A validator validates. No role exceeds its boundary.

### Externally Assigned Phase
Phase is assigned by the task creator, not derived by you. You receive phase
in the kickoff context and apply the corresponding verification depth from
the Phase Classification table above.

---

## Governance — Decision Classification

Every decision you make must be classified before acting. This applies to all
agents in all roles.

### Classification Types

**Routine**
- Reversible, low cost, single venture, high confidence
- Action: Log only (post decision record as issue comment)

**Significant**
- Affects direction within a venture, moderate cost/time, some uncertainty
- Action: Notify operator (post decision record as issue comment, non-blocking)

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
  "origin_decision": "upstream decision or goal that triggered this",
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
