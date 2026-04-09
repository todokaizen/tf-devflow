# Task Lifecycle Walkthrough

Date: 2026-04-08
Status: current
Version: 1.0
Supersedes: none

A traced example of a single task flowing through the full pipeline. This shows what actually happens at each step — who does what, what files change, and where the pipeline pauses for human review.

---

## The Task

**Company:** TFLabs
**Project:** tflabs-poc
**Task:** "Add keyword search to the mentor matching API"
**Phase:** structural (short spec required)

---

## Step 1: Operator creates the issue

In Paperclip UI (http://localhost:3100/TFL/projects/tflabs-poc), create a new issue:

```
Title: [structural] Add keyword search to mentor matching API

Body:
  Goal: Users can search mentors by keyword (name, skills, bio).
  Constraints: Must use existing PostgreSQL full-text search, no Elasticsearch.
  Phase: structural
  References: Current matching logic in server/src/matching.ts
```

Assign to: **VentureLead**

---

## Step 2: VentureLead wakes (heartbeat)

Within 30 seconds, Paperclip's heartbeat wakes the VentureLead agent. The agent:

1. **Reads project state:**
   - `resume.md` — current project phase and active work
   - `decisions.md` — prior architectural decisions
   - Checks Paperclip for the new issue

2. **Classifies the decision:**
   ```json
   {
     "classification": "routine",
     "confidence": 0.9,
     "why_not_critical": "Single-venture, reversible (can revert search endpoint), no external exposure, high confidence in approach"
   }
   ```
   Action: logs classification as issue comment, proceeds.

3. **Reads pipeline config** (`~/.paperclip/pipelines/tflabs-poc.yaml`):
   ```yaml
   phase_rules:
     structural:
       - spec_writer
       - executor
   ```

4. **Creates sub-tasks:**
   - Sub-task 1: `[spec-writer] Add keyword search to mentor matching API` → assigned to **SpecWriter**
   - Sets parent task to IN_PROGRESS

5. **Updates resume.md** with current orchestration state, then shuts down.

---

## Step 3: SpecWriter runs (Codex)

SpecWriter (codex_local) wakes on next heartbeat. It:

1. Reads `CLAUDE.md` → knows it's a spec-writer role
2. Reads `resume.md` and `decisions.md`
3. Reads the parent task description for goal and constraints
4. Explores the codebase (`server/src/matching.ts`, database schema)
5. Writes a spec file:

```markdown
# Spec: Keyword Search for Mentor Matching

Date: 2026-04-09
Status: draft

## Objective
Add full-text keyword search to the mentor matching API endpoint.

## Scope
### Included
- New query parameter `?q=keyword` on GET /api/mentors/match
- PostgreSQL tsvector index on mentors.name, mentors.skills, mentors.bio
- Combined ranking: existing match score + text relevance score

### Excluded
- Fuzzy/typo-tolerant search (Phase 2 if needed)
- Search suggestions/autocomplete
- Search analytics

## Assumptions
- mentors table has <100k rows (full-text search performant without partitioning)
- Existing match scoring can be linearly combined with text relevance

## Failure Modes
- tsvector index migration on existing data could be slow if table is large
- Text relevance ranking may not align well with existing match scoring

## Constraints
- PostgreSQL only, no external search service
- Must not break existing matching API contract (additive query param only)

## Done Condition
- GET /api/mentors/match?q=python returns mentors with "python" in name, skills, or bio
- Existing calls without ?q= return identical results to current behavior
- Migration runs in <30 seconds on current dataset
- Tests cover: keyword match, no keyword (backwards compat), empty results
```

6. Sets sub-task to REVIEW
7. Updates `resume.md`, archives previous copy, shuts down

---

## Step 4: HUMAN REVIEW GATE — Spec Review

**The pipeline pauses here.** You see the spec in the issue's sub-task.

Apply the 3-check protocol:

1. **Most likely failure?** "tsvector index creation could lock the table during migration. Need to use CREATE INDEX CONCURRENTLY."

2. **What's NOT specified?** "How should relevance ranking combine with existing match scores? Weighted sum? Separate sort option?"

3. **Right problem?** "Yes — users need to find specific mentors, keyword search is the right first step."

Log your review:
```json
{
  "review_passed": false,
  "identified_risks": ["Index creation could lock table — spec should require CONCURRENTLY"],
  "missing_elements": ["Ranking combination method not specified"],
  "solving_right_problem": true
}
```

**Result: Rejected.** Add feedback comment: "Use CREATE INDEX CONCURRENTLY. Specify ranking method — suggest weighted sum with configurable weights."

Sub-task returns to SpecWriter with your feedback.

---

## Step 5: SpecWriter revises

SpecWriter wakes again, reads your feedback, updates the spec:
- Adds "CREATE INDEX CONCURRENTLY" to Constraints
- Adds "Weighted sum: 0.7 * match_score + 0.3 * text_relevance" to Scope/Included
- Sets sub-task to REVIEW again

---

## Step 6: HUMAN REVIEW GATE — Spec Approved

You review the revised spec. All 3 checks pass. Approve.

VentureLead wakes, sees spec approved, creates next sub-task:
- Sub-task 2: `[implementor] Add keyword search to mentor matching API` → assigned to **Implementor**

The sub-task description references the approved spec file path.

---

## Step 7: Implementor runs (Claude Code)

Implementor (claude_local, sonnet) wakes. It:

1. Reads `CLAUDE.md` → knows it's an implementor role, reads from spec only
2. Reads the approved spec in `specs/`
3. Implements:
   - Adds tsvector column + GIN index migration (CONCURRENTLY)
   - Adds `?q=` query parameter handling to matching endpoint
   - Adds weighted ranking combination
   - Writes tests
4. Commits changes, runs tests
5. Sets sub-task to REVIEW
6. Updates `resume.md`, shuts down

---

## Step 8: VentureLead dispatches validator (structural phase)

For structural phase, the pipeline config has only `spec_writer` and `executor` — no explicit validator stage. VentureLead checks the implementor's result.

If this were **production** phase, VentureLead would create:
- Sub-task 3: `[validator] Validate keyword search implementation` → assigned to **Validator**

The Validator would produce:
```json
{
  "spec_fulfilled": true,
  "spec_violations": [],
  "extra_behavior_detected": []
}
```

---

## Step 9: HUMAN REVIEW GATE — Final Result

**The pipeline pauses again.** You review:
- Code diff (does it match the spec?)
- Test results (do they pass?)
- Migration (is it CONCURRENTLY as specified?)

If satisfied: approve. VentureLead marks the parent task DONE.

If not: reject with feedback → implementor retries (up to 3x before debugger escalation).

---

## Step 10: Task complete

VentureLead:
1. Marks parent task DONE in Paperclip
2. Updates `resume.md` with completion note
3. Updates `decisions.md` if any architectural decisions were made
4. Shuts down

**Total pipeline:**
```
Operator creates task                          [you]
  → VentureLead classifies + dispatches        [auto, ~1 heartbeat]
  → SpecWriter writes spec                     [auto, ~1-3 heartbeats]
  → HUMAN REVIEW (spec)                        [you, minutes to hours]
  → SpecWriter revises (if rejected)           [auto]
  → HUMAN REVIEW (revised spec)                [you]
  → Implementor builds from spec               [auto, ~1-5 heartbeats]
  → HUMAN REVIEW (result)                      [you, minutes to hours]
  → Task marked DONE                           [auto]
```

---

## What the Files Look Like After

### resume.md (in project repo)

```markdown
# tflabs-poc

## Project State
Phase: structural
Objective: AI-powered mentor matching platform
Active Specs: specs/keyword-search.md (accepted)
Completion: Keyword search done. Next: mentor profile filtering.

## Resume Point
Updated: 2026-04-09

### Active Task
none (last task completed)

### Next Action
Await next task assignment from operator.
```

### decisions.md (in project repo)

```markdown
## 2026-04-09: Use weighted sum for keyword + match score ranking

Context: Adding keyword search to mentor matching. Need to combine text relevance with existing match score.
Decision: Weighted sum — 0.7 * match_score + 0.3 * text_relevance. Weights configurable in environment.
Rationale: Simple, transparent, tunable without code change. Operator feedback during spec review specified this approach.
Consequence: Search results blend match quality with keyword relevance. Can adjust weights without redeployment.
```
