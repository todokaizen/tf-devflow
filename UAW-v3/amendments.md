# UAW v3 Amendments for Multi-Agent Orchestration

Date: 2026-03-31
Status: accepted

These amendments extend the UAW v3 spec to support orchestrated multi-agent
pipelines where different agents handle different stages of a task (spec writing,
validation, execution, review).

---

## Amendment 1: Multi-Agent Session Handoff

**Add to Section 10 (Session Protocol):**

> When multiple agents work a task sequentially, each agent completes the full
> shutdown protocol before the next agent starts. The incoming agent reads
> `resume.md` written by the previous agent as its starting context.

---

## Amendment 2: Role Scoping

**Add to Section 12 (Operating Rules):**

> When an agent receives a scoped role assignment, it operates only within that
> role's boundaries. A spec_writer produces the spec and completes shutdown. An
> executor implements. A reviewer validates. No role exceeds its boundary.

---

## Amendment 3: Externally Assigned Phase

**Add to Section 4 (Phase Classification):**

> Phase is assigned by the task creator, not derived by the agent. The agent
> receives phase in the kickoff context and applies the corresponding
> verification depth.
