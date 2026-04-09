# Paperclip-UAW v1

Paperclip-specific integration layer built on top of UAW v3 (Unambiguous Agentic Workflow).

## Relationship to UAW v3

UAW v3 is the base protocol — a lightweight operating system for a solo developer
working with AI agents. It defines file structure, session protocols, authority order,
and verification rules.

Paperclip-UAW v1 extends UAW v3 with three amendments for multi-agent pipeline
orchestration (see `amendments.md`). The templates in `templates/` include these
amendments baked into the CLAUDE.md contract.

The original UAW v3 source documents are preserved in `upstream/` for reference.

## What's Here

```
paperclip-uaw/
  README.md              ← this file
  amendments.md          ← three multi-agent amendments to UAW v3
  templates/             ← ready-to-copy project templates (UAW v3 + amendments)
    CLAUDE.md            ← UAW operating contract with pipeline rules
    resume.md            ← project state template
    decisions.md         ← append-only decisions template
    specs/               ← spec file templates
    archive/             ← session archive directory
  upstream/              ← original UAW v3 source documents
    Unambiguous-Agentic-Workflow-v3.docx
    UAW-os-templates.zip
```

## Usage

Install UAW into any project directory:

```bash
./paperclip-uaw/install.sh /path/to/project "Project Name"
```

This copies all template files, creates the `specs/` and `archive/` directories,
and replaces `{{PROJECT_NAME}}` placeholders. If the project name is omitted,
the directory basename is used.

Then fill in `resume.md` with the project state. Agents read `CLAUDE.md` on
startup and follow the UAW protocol autonomously.

To update templates across projects, edit the files in `templates/` and re-run
the installer (it will prompt before overwriting existing files).

## Amendments (v1)

1. **Multi-Agent Session Handoff** — sequential agents complete shutdown before
   the next starts; incoming agent reads resume.md as starting context
2. **Role Scoping** — agents operate within their assigned role boundary
   (spec_writer, executor, reviewer, etc.)
3. **Externally Assigned Phase** — phase comes from the task creator, not the agent

## Version History

- **v1 (2026-03-31)** — Initial Paperclip-UAW integration. Three amendments for
  multi-agent orchestration. Based on UAW v3 (March 2026).
