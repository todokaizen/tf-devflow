# Design: Paperclip + UAW v3 Integration

Date: 2026-03-30
Status: draft

## Objective

Set up Paperclip as the orchestration layer for managing AI agent workflows across multiple projects, using UAW v3 (Unambiguous Agentic Workflow) as the in-repo contract that agents follow. Paperclip is replaceable — removing it changes only who kicks off a job, not how the job runs.

## Design Principle

**Paperclip owns the _who_, _when_, and _how much_. UAW owns the _what_ and _how_.**

### Paperclip manages:
- When a workflow starts
- Which agent runs it
- Budget and time
- Approvals
- Job audit trail

### UAW defines:
- What files to read
- What order of authority to use
- What status transitions mean
- What proof is required
- What shutdown must write

They touch at exactly one point: Paperclip launches an agent on a task in a workspace, and the agent picks up UAW from there.

---

## Architecture

### Company Structure

One Paperclip company represents the entire operation. Each active project (TFLabs, OpenBrain, GalileosCircle, NineHumanNeeds, and future projects) is a Paperclip project within that company. Each project has a workspace pointing to its repo on disk.

```
Company: "Ker's Lab"
  ├── Project: TFLabs         → workspace: /path/to/tflabs
  ├── Project: OpenBrain      → workspace: /path/to/openbrain
  ├── Project: GalileosCircle → workspace: /path/to/galileos
  └── Project: NineHumanNeeds → workspace: /path/to/nhn
```

UAW v3 files live in each repo and are self-sufficient:
```
project-root/
  CLAUDE.md        ← UAW operating contract
  resume.md        ← current state (read first on every session)
  decisions.md     ← append-only architectural decisions
  specs/           ← spec files for non-exploratory work
  archive/         ← dated resume.md copies from prior sessions
```

### Agent Model

Agents are registered per-project, not shared. Each project gets its own agent instances because projects differ in:
- Stack and CLAUDE.md instructions (Python, Next.js, document workflows)
- Budget limits
- Kickoff prompts

Example:
```
Project: TFLabs (Python)
  ├── Claude-TFLabs      (claude_local, Python-tuned instructions, budget: $X)
  ├── Codex-TFLabs       (codex_local, Python-tuned kickoff, budget: $Y)
  └── AntiGrav-TFLabs    (process adapter, Python validation)

Project: OpenBrain (Next.js)
  ├── Claude-OpenBrain    (claude_local, Next.js instructions, budget: $X)
  ├── Codex-OpenBrain     (codex_local, Next.js kickoff, budget: $Y)
  └── AntiGrav-OpenBrain  (process adapter, Next.js validation)
```

Available agent adapters: `claude_local`, `codex_local`, `gemini_local`, `cursor_local`, `process` (for AntiGravity and similar CLI tools).

---

## Task Pipeline

### Status Mapping

| UAW v3 Status | Paperclip Status | Notes |
|---|---|---|
| IDEA | `backlog` | You create the issue |
| SPEC | `backlog` | Spec-writing sub-task assigned to spec_writer |
| TODO | `todo` | After you approve the spec |
| IN PROGRESS | `in_progress` | Agent checks out the issue |
| BLOCKED | `blocked` | Agent records reason in resume.md + issue comment |
| REVIEW | `in_review` | Agent finishes with proof |
| DONE | `done` | After you review and approve |

### Phase Classification

Phase is assigned by you when creating the task. It determines pipeline depth and verification rigor. Paperclip uses it for routing; the agent receives it in the kickoff and applies UAW's corresponding verification rules.

| Phase | Spec Required | Pipeline |
|---|---|---|
| Exploratory | No | executor only |
| Structural | Short spec | spec_writer → executor |
| Production | Full spec | spec_writer → spec_validator → executor → reviewer |
| Durable Knowledge | Full spec | spec_writer → spec_validator → executor → reviewer |

### Configurable Role Map

Each project has a role map that controls which agent fills which role, and what pipeline each phase triggers. Roles are configurable — you can swap agents at any time without changing the UAW contract.

```
Project: TFLabs
  phase_rules:
    exploratory:       [executor]
    structural:        [spec_writer, executor]
    production:        [spec_writer, spec_validator, executor, reviewer]
    durable_knowledge: [spec_writer, spec_validator, executor, reviewer]

  role_assignments:
    spec_writer:    Codex-TFLabs
    spec_validator: Claude-TFLabs
    executor:       Claude-TFLabs
    reviewer:       AntiGrav-TFLabs
```

When a role maps to a list of agents (e.g., `spec_writer: [Codex-TFLabs, Claude-TFLabs, AntiGrav-TFLabs]`), Paperclip creates parallel sub-tasks — one per agent. You compare outputs on the board and pick the best. This is the fan-out pattern for competing specs or competing implementations.

### The Kickoff Handoff

The kickoff prompt is the single integration point between Paperclip and UAW. Paperclip sends exactly this:

```
Project: {project_name}
Workspace: {repo_path}
Task: {issue_title}
Task Description: {issue_description}
Phase: {exploratory | structural | production | durable_knowledge}
Role: {spec_writer | spec_validator | executor | reviewer}
```

Paperclip does NOT send:
- Instructions about what files to read (UAW handles this)
- Budget limits (Paperclip enforces externally)
- Status transition rules (UAW handles this)
- Other agents' work (no cross-agent context leaking)

The agent lands in the workspace, finds CLAUDE.md (the UAW contract), and follows its session startup protocol.

### Full Pipeline Sequence

**Your part:**
1. Evaluate the project, decide what needs doing
2. Create a Paperclip issue: title, description, phase
3. Approve the spec (when spec_writer finishes)
4. Review the result (when reviewer finishes)

**Paperclip's part:**
1. Look up role map → find the right agent for the current pipeline stage
2. Send kickoff prompt to agent in the project workspace
3. Track agent execution (budget, heartbeat, status)
4. When agent finishes, update issue status
5. If next stage in pipeline exists, kick off the next agent
6. At approval gates, wait for your sign-off

**Approval gates:** You sit between spec completion and execution, and between review and done. These are the two points where your judgment matters. Everything else Paperclip chains automatically.

---

## Autonomy Model

Start semi-autonomous (level B): you assign specific tasks, agents execute and hand back, you decide what's next. Graduate to full autonomy (level A) for simple-to-medium complexity jobs as trust builds. Results will tell when to expand.

The role map and phase rules make this graduation mechanical — no architectural changes needed, just configuration:
- Level B: You trigger each pipeline stage manually
- Level A: Paperclip chains stages automatically based on the role map

---

## UAW v3 Amendments

Three amendments to the UAW v3 spec to support multi-agent orchestration:

### Amendment 1: Multi-Agent Session Handoff

Add to Section 10 (Session Protocol):

> When multiple agents work a task sequentially, each agent completes the full shutdown protocol before the next agent starts. The incoming agent reads `resume.md` written by the previous agent as its starting context.

### Amendment 2: Role Scoping

Add to Section 12 (Operating Rules):

> When an agent receives a scoped role assignment, it operates only within that role's boundaries. A spec_writer produces the spec and completes shutdown. An executor implements. A reviewer validates. No role exceeds its boundary.

### Amendment 3: Externally Assigned Phase

Add to Section 4 (Phase Classification):

> Phase is assigned by the task creator, not derived by the agent. The agent receives phase in the kickoff context and applies the corresponding verification depth.

No other UAW v3 changes are needed. The file structure, authority order, status meanings, proof requirements, and shutdown protocol all remain as-is.

---

## Project Onboarding Flow

Repeatable steps for bringing a new project into the Paperclip + UAW setup:

**Step 1: Prepare the repo.** Copy UAW v3 templates into the project repo (`CLAUDE.md`, `resume.md`, `decisions.md`, `specs/`, `archive/`). Fill in the project state section of `resume.md`.

**Step 2: Create the Paperclip project.** Project name, workspace pointing to repo path, linked to a company goal.

**Step 3: Register project agents.** Create agent instances with project-specific adapter config, instructions, kickoff prompts, and budget limits.

**Step 4: Configure the role map.** Set phase-based pipeline rules and role-to-agent assignments.

**Step 5: Create your first task.** Evaluate the project, create an issue with title, description, and phase. Paperclip takes it from there.

---

## Key Design Decisions

1. **One company, per-repo projects** — cross-project visibility with project-level isolation
2. **Per-project agent instances** — different configs, budgets, kickoff prompts per project
3. **Paperclip is replaceable** — removing it changes only who kicks off jobs, not how jobs run
4. **Phase is a routing tag** — Paperclip uses it for pipeline selection, UAW uses it for verification depth, neither interprets the other's usage
5. **Configurable role map** — swap agents, add fan-out, change pipelines without touching UAW
6. **Semi-autonomous start, graduate to full** — configuration change, not architecture change
7. **No execution workspaces initially** — agents work directly in the project repo, one task at a time per project. Enable later for parallel agent work (would require UAW amendment for multi-agent resume handling).
8. **Board (you) checks the board for fan-in** — no automatic "wait for all children" mechanism needed

## Implementation Notes

The following concepts from this design are **new to Paperclip** and would need to be built:

- **Role map** (phase_rules + role_assignments per project) — does not exist today. Could be stored as project metadata (jsonb) or as a new schema table.
- **Phase-based pipeline routing** — the logic that looks up the role map, creates sub-tasks for each pipeline stage, and chains them. This is new orchestration logic.
- **Automatic stage chaining** — when one pipeline stage completes, kicking off the next. Could be implemented as a post-completion hook on issue status transitions.
- **Kickoff prompt templating** — assembling the handoff prompt from issue + project + role data and passing it to the agent adapter.

Everything else (companies, projects, agents, issues, sub-tasks, workspaces, budgets, approvals, work products, activity logging) exists today.

## Open Questions

None — all questions resolved during brainstorming.

## Scope

### Included
- Paperclip company and project setup
- Agent registration and adapter configuration per project
- Role map and phase-based pipeline configuration
- Kickoff prompt format and handoff protocol
- UAW v3 amendments for multi-agent support
- Project onboarding template/flow

### Excluded
- Automatic fan-in (notify when all sub-tasks complete) — check the board manually
- Execution workspace isolation (parallel agents on same project) — future enhancement
- Analyst role (agent evaluates codebase and proposes tasks) — future enhancement
- AntiGravity adapter implementation — depends on how AntiGravity runs (CLI, web service, etc.)
