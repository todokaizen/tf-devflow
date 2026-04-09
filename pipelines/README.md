# Pipeline Configs (Version-Controlled)

This directory is the source of truth for pipeline YAML configs. VentureLead
agents read configs from `~/.paperclip/pipelines/`, so changes here must be
synced to take effect.

## Sync to runtime

```bash
./paperclip-uaw/sync-pipelines.sh
```

Copies all `.yaml` files from this directory to `~/.paperclip/pipelines/`.
Changes take effect on the next VentureLead heartbeat — no restart needed.

## Adding a new pipeline

1. Copy an existing config: `cp pipelines/galileos-circle.yaml pipelines/{project-slug}.yaml`
2. Update `role_assignments` with the correct agent display names for the company
3. Commit the new file
4. Run `./paperclip-uaw/sync-pipelines.sh`

## Schema

See `design/RUNBOOK.md` → Pipeline Config Reference for full documentation.
