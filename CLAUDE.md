# CLAUDE.md — TF-Devflow overlay

This repo is a fork of [`paperclipai/paperclip`](https://github.com/paperclipai/paperclip) with the **TF-Devflow overlay** (UAW workflow configs, company templates, pipeline tooling). See `TF-DEVFLOW.md` for the full description. `AGENTS.md` is upstream Paperclip guidance — read it for engine-level context.

## Overlay boundary

TF-Devflow-specific (safe to edit without upstream concerns):

- `companies/` — company packages
- `master-template/` — scaffolding template
- `pipelines/` — pipeline configs + tooling
- `paperclip-uaw/` — UAW workflow scripts (install, sync, healthcheck, recover)
- `design/` — architecture, runbooks, decisions, issues, proposals
- `TF-DEVFLOW.md`, `CLAUDE.md` — this overlay's identity files

Everything else is upstream Paperclip. Touching it invites merge conflicts on every `upstream/master` pull.

## Rename discipline (hard rules)

Do **not** rename any of these — they are the merge boundary:

- `PAPERCLIP_*` env vars (runtime contract)
- `schema: paperclip/v1` schema IDs (validated by `server/src/services/company-portability.ts`)
- `@paperclipai/*` package scope (`package.json`, workspaces)
- `paperclip-uaw/` directory name
- Any occurrence of `paperclip` inside upstream-tracked files (`server/`, `ui/`, `cli/`, `packages/`, `doc/`, `releases/`, root `README.md`, `package.json`, etc.)

Do rename / name freshly:

- New overlay files and docs — prefer `tf-devflow` in the name
- Overlay-internal identifiers that have no upstream counterpart

## Remotes

```
origin    git@github.com:todokaizen/tf-devflow.git
upstream  git@github.com:paperclipai/paperclip.git
```

Pull upstream updates with `git fetch upstream && git merge upstream/master`.
