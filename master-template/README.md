# Venture Template — Paperclip Company Package

Master template for creating venture companies with the governance framework.

## Import

```bash
pnpm paperclipai company import ./master-template --new-company-name "CompanyName"
```

Then rename agents with company suffix: `venture-lead` → `ventureLead-tflabs`, etc.

## Agents

| Agent | Adapter | Purpose |
|-------|---------|---------|
| venture-lead | claude_local | Orchestrates workflow stages, classifies decisions |
| spec-writer | codex_local | Writes specs from goals |
| implementor | claude_local | Implements from specs |
| validator | codex_local | Validates against spec + hard checks |
| debugger | claude_local (opus) | Diagnoses repeated failures |

## Pipeline Flow

```
Task → VentureLead → reads pipeline config

  [spec-writer] → writes spec
     ↓ HUMAN REVIEW GATE (3 checks)
  [implementor] → implements from spec
     ↓ if validator fails → retry up to 3x → debugger
  [validator] → validates against spec + artifacts
     ↓ HUMAN REVIEW GATE (result)
  Done
```
