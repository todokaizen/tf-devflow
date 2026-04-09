# Paperclip + UAW Governance Integration — Decisions

Append-only. Never edit old entries. Supersede with a new entry if a decision changes.
Review this file after every agent run to check for spec drift.

---

## 2026-03-30: Use Paperclip + UAW v3 as the orchestration stack

Context: Needed a system to coordinate AI agents across multiple ventures (TFLabs, NHN, WebSites). Evaluated building custom orchestration vs. using existing tools.
Decision: Use Paperclip as the control plane (task routing, scheduling, approvals, audit) and UAW v3 as the in-repo workflow contract (session protocol, authority order, phase classification).
Rationale: Paperclip handles the "who, when, how much" while UAW handles the "what and how." Both are replaceable independently.
Consequence: Two-layer system. Paperclip can be swapped without touching repo-level workflow. UAW contract travels with the repo.

---

## 2026-03-30: Layered architecture with 5 layers

Context: Needed clear separation of concerns to prevent agents from overstepping boundaries.
Decision: Five layers, each with one job: (1) Paperclip orchestration, (2) UAW workflow manifest in each repo, (3) Execution agents, (4) Validation systems outside Paperclip, (5) Output sinks.
Rationale: Layers do not reach into each other's responsibilities. Correctness is decided by Layer 4 (tests, lint, typecheck), never by Paperclip.
Consequence: All architectural decisions must specify which layer they affect. Cross-layer coupling is a design violation.

---

## 2026-03-30: Config-only approach — no Paperclip core code changes (SUPERSEDED)

Context: Initial design proposed code changes to Paperclip (Zod validators, Drizzle schema, pipeline service). First implementation plan had 9 tasks and 1170 lines of proposed code.
Decision: Rewrite plan as config-only — company packages, adapter configs, UAW templates, and pipeline YAML. Zero Paperclip core code changes.
Rationale: If Paperclip is replaced, only the kickoff mechanism changes, not the workflow contract. Portability over convenience.
Consequence: Plan shrunk from 9 code tasks to 7 config tasks. No database schema changes, no new server routes. Everything is importable files.
Superseded by: 2026-03-31: Add coordinator agent (VentureLead) — extended config-only approach with coordinator.

---

## 2026-03-30: UAW v3 amendments for multi-agent orchestration

Context: UAW v3 was designed for single-agent workflows. Paperclip dispatches multiple agents per task in sequence.
Decision: Three amendments: (1) Session Handoff — each agent completes full shutdown before next starts, incoming agent reads resume.md; (2) Role Scoping — agents operate only within assigned role boundaries; (3) Externally Assigned Phase — phase is set by task creator, not derived by agent.
Rationale: These amendments preserve UAW's session protocol while enabling multi-agent pipelines without breaking the contract.
Consequence: CLAUDE.md template updated with multi-agent pipeline rules section. All agents follow same contract.

---

## 2026-03-31: Role-agnostic agent definitions in company package

Context: First company package draft needed to define agents that could be assigned to different roles dynamically.
Decision: Generic agent definitions (claude, codex, antigravity, gemini) that can be assigned to any workflow stage via task assignment rather than baked-in specialization.
Rationale: Keeps the package flexible — same agents can be spec-writers or implementors depending on the task.
Consequence: Company package uses adapter type as the primary differentiator, not workflow role.
Superseded by: 2026-03-31: Stack-specialized agents, then again by 2026-04-02: Governance-driven role-based agents.

---

## 2026-03-31: Add coordinator agent (VentureLead) for pipeline orchestration

Context: Manual task assignment to workflow-stage agents doesn't scale. Need automated dispatch.
Decision: Each venture company gets a VentureLead agent (claude_local, sonnet) that reads pipeline config from ~/.paperclip/pipelines/{project}.yaml and creates sub-tasks per phase rules. VentureLead is a state machine — it orchestrates, classifies, and escalates, but never decides correctness.
Rationale: Coordinator is a state machine, not a decision-maker. Keeps Paperclip as dumb orchestrator while enabling automated pipeline flow.
Consequence: Pipeline config moved from UAW templates (Layer 2) to ~/.paperclip/pipelines/ (Layer 1). VentureLead added to all company packages. company-package/ renamed to kers-lab/, then later to master-template/.

---

## 2026-03-31: Pipeline config is Layer 1 (Paperclip), not Layer 2 (repo) (SUPERSEDED)

Context: Initial design had pipeline-config.yaml inside UAW templates (repo-side). But pipeline routing is an orchestration concern.
Decision: Remove pipeline-config.yaml from UAW templates. Pipeline config lives at ~/.paperclip/pipelines/{project}.yaml — managed by Paperclip, outside repos.
Rationale: Wrong layer. Pipeline config is about who runs when (Layer 1), not how agents work (Layer 2). Repos should not need to know about Paperclip's scheduling decisions.
Consequence: UAW templates are pure workflow contract. Pipeline config is a separate Paperclip-layer concern.
Superseded by: 2026-04-02: Governance-driven model — pipeline config retained at Layer 1 but phase rules simplified.

---

## 2026-03-31: Reformat company package to match Paperclip import schema

Context: Initial company package used freeform AGENTS.md files with embedded adapter config. Paperclip import expects specific .paperclip.yaml structure.
Decision: Strip agent AGENTS.md files to minimal content (instructions only). Move all adapter config (role, model, permissions, sidebar) to .paperclip.yaml. Add slug field to COMPANY.md frontmatter.
Rationale: Paperclip import reads .paperclip.yaml for machine config and AGENTS.md for agent instructions. Mixing config into markdown breaks import.
Consequence: Clean separation: .paperclip.yaml = machine-readable config, AGENTS.md = human/agent-readable instructions.

---

## 2026-03-31: Stack-specialized agents per venture (SUPERSEDED)

Context: Generic agents lacked domain expertise. Different projects need different tooling knowledge.
Decision: Replace generic agents with stack-specialized agents: python, fe, devops, content, research, crypto — plus coordinator per venture.
Rationale: Agents with stack-specific instructions produce better output for their domain.
Consequence: master-template updated with 6 specialized agents + coordinator. Three venture companies (tflabs, nhn, websites) created with stack-appropriate agents.
Superseded by: 2026-04-02: Governance-driven model replaces stack-specialized agents.

---

## 2026-04-01: Add debugger agent for failure escalation

Context: When implementor fails repeatedly, there's no mechanism for fresh-perspective diagnosis.
Decision: Add debugger agent (claude_local, opus) to all company packages. After N implementor retries, debugger is dispatched. Debugger diagnoses only — does not fix. Different model (opus vs sonnet) ensures different blind spots.
Rationale: Diagnosis and implementation are different skills. Using a stronger model with fresh context avoids the "same context, same blind spots" problem.
Consequence: Pipeline config updated with failure_escalation.executor_retries_before_debugger: 3. Debugger added to master template and all venture companies.

---

## 2026-04-02: Rename UAW-v3/ to paperclip-uaw/, reorganize design docs

Context: Directory naming was confusing. "UAW-v3" suggests it IS UAW v3, but it's actually UAW v3 + Paperclip-specific amendments. Design docs were mixed into docs/superpowers/.
Decision: Rename to paperclip-uaw/ (reflects the hybrid nature). Track original UAW v3 source in upstream/ subdirectory. Move all design docs from docs/superpowers/ to design/ with subdirectories: specs/, plans/, archive/.
Rationale: Clear provenance — paperclip-uaw = UAW v3 + our amendments. Design docs are our work, not Paperclip's public docs.
Consequence: File structure: paperclip-uaw/{templates/, amendments.md, upstream/, README.md}. Design docs: design/{specs/, plans/, archive/, issues/, proposals/}.

---

## 2026-04-02: Governance-driven model replaces stack-specialized agents

Context: Had stack-specialized agents (python, fe, devops, content, research, crypto) per venture. Realized governance matters more than tech stack for agent coordination. Stack specialization added complexity without proportional value — agents can read docs for stack-specific guidance.
Decision: Replace stack agents with 5 role-based agents: venture-lead (PM), spec-writer (codex), implementor (claude sonnet), validator (codex), debugger (claude opus). Add TodoFoco CEO company as strategic oversight layer. Add 3-type decision classification (routine/significant/critical) with mandatory self-check and 100% decision logging.
Rationale: Role separation ensures context independence between workflow stages. Governance framework makes escalation explicit, auditable, and portable. Stack knowledge can be injected via project-level instructions without multiplying agent definitions.
Consequence: All company packages restructured from 6+ stack agents to 5 role agents. TodoFoco CEO company added. Master template rewritten. Governance rules added to CLAUDE.md template. Spec review protocol added with 3 explicit checks.

---

## 2026-04-02: Agent naming uses kebab-case in config, camelCase in spec display

Context: Spec document uses camelCase (ventureLead-tflabs), YAML config uses kebab-case (venture-lead). Both are company-scoped in Paperclip.
Decision: Keep kebab-case in .paperclip.yaml keys (YAML-idiomatic). Spec display names are for human reference only.
Rationale: Consistency within each format. Paperclip disambiguates by company namespace regardless of key style.
Consequence: No config changes needed. Spec uses ventureLead-tflabs for readability; config uses venture-lead within each company scope.

---

## 2026-04-02: Separate companies per business entity, not one mega-company

Context: Could have put all ventures under one Paperclip company. Decided against it.
Decision: Each business entity (TodoFoco, TFLabs, NHN, WebSites) is a separate Paperclip company with fully isolated agents, budgets, and projects. TodoFoco is the parent company for strategic oversight only — it cannot directly touch venture companies.
Rationale: Isolation prevents cross-venture contamination. Budget tracking per venture. CEO consults but you carry decisions across ventures manually (intentional human-in-the-loop for cross-venture coordination).
Consequence: 4 company packages. Cross-venture decisions require manual operator mediation, not automated agent-to-agent communication.

---

## 2026-04-03: Enable dangerouslySkipPermissions for all claude_local agents

Context: Claude Code sandbox blocks env var access ($VAR expansion, printenv, /proc/self/environ). Agents couldn't read PAPERCLIP_API_URL and other injected credentials. SpecWriter burned ~3M input tokens trying to discover how to authenticate.
Decision: Set dangerouslySkipPermissions: true on all claude_local adapter configs across all company packages.
Rationale: Without this, agents cannot read their own environment variables. The sandbox blocks legitimate operational needs. This is a workaround for Issue 1 (env var access).
Consequence: All claude_local agents (venture-lead, implementor, debugger, ceo) now have dangerouslySkipPermissions: true. Codex agents unaffected (different sandbox model).

---

## 2026-04-08: Fresh start on v2026.403.0 — keep repo, reset DB

Context: 37 local commits with 3 major pivots. Question was whether to re-clone from upstream or keep current state. Upgrading from v2026.325.0 to v2026.403.0.
Decision: Keep current repo (working tree is clean despite messy git history). Delete DB and re-import company packages on v2026.403.0.
Rationale: File state is coherent — abandoned approaches were removed, superseded docs archived properly. Re-cloning would risk losing config nuance for no gain.
Consequence: Fresh DB with all 48 migrations. All 4 companies re-imported. Workspace attachments need manual setup (known Issue 3).

---

## 2026-04-08: Adopt UAW workflow for this repo (design/ as project root)

Context: No persistent task tracking existed outside of git commits and ephemeral conversation context. UAW contract defines resume.md + decisions.md for exactly this purpose.
Decision: Create design/resume.md and design/decisions.md following UAW templates. Use design/ as the project root for UAW state files (specs/, archive/, resume.md, decisions.md already colocated there).
Rationale: Follow our own contract. If we're building a UAW-based system, this repo should use the same session protocol.
Consequence: Future sessions start by reading design/resume.md → design/decisions.md → active spec. Session end protocol applies.
