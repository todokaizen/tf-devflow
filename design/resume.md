# Paperclip + UAW Governance Integration

## Project State

Phase: structural
Objective: Orchestrate AI agent workflows across multiple ventures using Paperclip as control plane, UAW v1 as in-repo workflow contract, and TodoFoco Governance Framework for decision classification and escalation. All config-only — no Paperclip core code changes.
Active Specs: design/specs/2026-04-02-paperclip-uaw-governance-design-Phase-1.md
Completion: Core config done and verified against spec. Fresh DB on v2026.403.0. UAW workflow files bootstrapped. Remaining: workspace attachments, pipeline configs, UAW template deployment to project repos.

---

## Resume Point

Updated: 2026-04-08

### Active Task

Post-upgrade setup — attach workspaces, deploy remaining pipeline configs, deploy UAW templates to project repos.

### Stopped At

Completed fresh start on v2026.403.0:
- Merged upstream v2026.403.0 (242 files, 4 new DB migrations 0045-0048)
- Normalized headers on all 7 design documents (Date, Status, Version, Supersedes)
- Fixed spec title typo ("Pase 1" → "Phase 1")
- Verified all 4 company .paperclip.yaml configs match governance spec
- Deleted DB, re-imported all 4 companies (TodoFoco, TFLabs, NHN, WebSites)
- Workspace attachments failed on import (known Issue 3)
- Created design/resume.md, design/decisions.md, 4 archived resume snapshots
- Backfilled decisions.md with 17 decisions extracted from git history

### Open Decision

Docker sandboxing approach for agent execution — Approach B (sidecar containers) was recommended for always-on agents but design is paused. Resume when core workflow is validated.

### Head State

- 4 companies imported, 16 agents created, 9 projects created — all on fresh v2026.403.0
- Workspace attachments still broken on import (Issue 3) — must attach manually
- Only 1 pipeline config deployed (galileos-circle.yaml) — need configs for all projects
- UAW templates (CLAUDE.md, resume.md, decisions.md, specs/) not yet deployed to any project repo
- 6 known issues documented in design/issues/paperclip-issues-log.md
- Docker sandboxing design paused at "Approach B: sidecar containers for always-on agents"
- pnpm itself has major update available (9.15.4 → 10.33.0) but project pins 9.15.4

### Next Action

Attach workspaces to all 9 imported projects via Paperclip UI (http://localhost:3100) or CLI API calls.
