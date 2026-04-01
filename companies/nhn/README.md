# NHN — Paperclip Company Package

Nine Human Needs — content and web platform.

## Import

```bash
paperclipai company import ./companies/nhn --new-company-name "NHN"
```

## Agents

| Agent | Expertise |
|-------|-----------|
| coordinator | Pipeline state machine |
| fe | Next.js, React, TypeScript, Tailwind |
| content | Technical writing, docs, educational content |

## Projects

| Project | Path | Stack |
|---------|------|-------|
| nine-human-needs | /Users/ker/_Projects/Active/9HumanNeeds/nine-human-needs | Content/Web |

## Post-Import

1. Rename agents: `fe` → `fe-nhn`, `content` → `content-nhn`, `coordinator` → `coordinator-nhn`
2. Create pipeline config at `~/.paperclip/pipelines/nine-human-needs.yaml`
3. Copy UAW templates into the project repo
