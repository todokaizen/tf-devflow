# TF-Devflow

This repository is **not stock Paperclip**. It is a fork of [`paperclipai/paperclip`](https://github.com/paperclipai/paperclip) with the TF-Devflow overlay — configuration, company templates, and tooling that enable the **UAW (Unified Agent Workflow)** on top of the Paperclip runtime.

See `README.md` for the underlying Paperclip project.

## What the overlay adds

These top-level directories are TF-Devflow-specific. Everything else is upstream Paperclip.

| Path | Purpose |
|------|---------|
| `companies/` | Company packages (`nhn`, `tflabs`, `todofoco`, `websites`) that run on this Paperclip instance |
| `master-template/` | Reference template used to scaffold new companies and agents |
| `pipelines/` | Pipeline configs (version-controlled) with sync and recovery tooling |
| `paperclip-uaw/` | UAW workflow scripts: `install.sh`, `sync-pipelines.sh`, `healthcheck.sh`, `recover.sh` |
| `design/` | Architecture, runbooks, decision logs, issue tracking, design proposals |

## Upstream relationship

- `origin` → `git@github.com:todokaizen/tf-devflow.git` (this fork)
- `upstream` → `git@github.com:paperclipai/paperclip.git` (Paperclip core)

Pull upstream updates with:

```sh
git fetch upstream
git merge upstream/master
```

## Rename discipline

TF-Devflow is a **configuration layer**, not a rebrand. The Paperclip system keeps its identity inside the repo so that upstream merges stay conflict-free.

**Stays `paperclip` / `@paperclipai` / `PAPERCLIP_*`:**
- All upstream files (`server/`, `ui/`, `cli/`, `packages/`, `doc/`, `releases/`, root `README.md`, `package.json`, etc.)
- Env vars (`PAPERCLIP_*`) — runtime contract
- Schema IDs (`schema: paperclip/v1`) — validated by `server/src/services/company-portability.ts`
- The `@paperclipai/*` monorepo scope
- The `paperclip-uaw/` directory name (stable path for scripts)

**TF-Devflow-named:**
- This file and `CLAUDE.md`
- Overlay-specific documents whose names already include `tf-devflow`

When adding new overlay content, name it after TF-Devflow; when editing upstream code, leave Paperclip references alone.
