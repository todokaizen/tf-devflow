# TF-Devflow Decision Rubric

Date: 2026-04-11
Status: living reference

Decision aids for the recurring judgment calls in TF-Devflow operation. Use this as a quick reference when classifying work, picking spec authorship direction, evaluating spec quality at the review gate, or checking whether the framework is drifting into theater.

---

## 1. Phase Classification Rubric

Pick the phase before creating the task. Wrong phase classification is the single biggest source of unnecessary ceremony. When in doubt, classify one tier lower than instinct says — the next tier up can always be reached by escalation if the work turns out to be more serious than expected.

| Phase | Use when | Avoid when |
|---|---|---|
| **Exploratory** | Prototyping, research spikes, one-off scripts, proving a concept, investigating a library, ad-hoc data exploration. The cost of being wrong is low and the work is likely disposable. | The output will be committed and maintained. Anyone else will depend on it. It touches production code paths. |
| **Structural** | Internal tools, refactors, non-user-facing changes, developer ergonomics work, internal APIs. Failure is recoverable and scope is limited to a single venture. | The change has external visibility. Failure affects users or data. The scope crosses ventures. |
| **Production** | User-facing features, anything touching payments or auth, public APIs, content that will be published, anything that would require a rollback if wrong. | The work is throwaway or a spike. The cost of the full pipeline exceeds the cost of getting it wrong. |
| **Durable Knowledge** | Documentation intended to be authoritative, datasets, reference material, specs that future agents will read, anything meant to outlive the current sprint. | The material is ephemeral or for immediate use only. |

**Calibration signal:** If approval gates are consuming more than 15-20% of total project time, phases are likely over-classified. Re-examine whether structural tasks are being run as production.

---

## 2. Spec Authorship Direction Rubric

For any task beyond exploratory, decide who writes the spec first and who reviews. Commit to the direction before starting.

| Signal | Direction |
|---|---|
| I can describe the spec in one clear paragraph without hesitation | **Operator writes, agent reviews.** Front-load your judgment. The agent reads the spec cold and acts as a proxy for implementor comprehension — if it cannot execute without ambiguity, neither can the implementor. |
| I find myself drafting the same paragraph three different ways | **Agent writes, operator reviews.** Reviewing is lower-friction than authoring. Let the agent produce a concrete draft to react to, then apply domain knowledge and the three checks. |
| The work has unusual intent, deep domain context, or strong constraints the agent is unlikely to infer | **Operator writes, agent reviews.** |
| The work is patterned and resembles previous specs | **Agent writes, operator reviews.** |
| I am tired or context-depleted | **Agent writes, operator reviews.** Authoring while depleted produces weak specs; reviewing is more forgiving. |
| The work is critical or irreversible | **Operator writes, agent reviews, then validator performs adversarial pass before implementation.** Two reviews, not one. |

**Commitment rule:** If the chosen direction is failing (stuck mid-draft, ambiguous ownership, hybrid patchwork emerging), throw out the draft and restart in the other direction. Do not stitch a hybrid.

---

## 3. Spec Review Gate Rubric

Answer all three checks before approving any spec. If any answer is unclear, fuzzy, or reduces to "looks good," the spec is not approved.

| Check | Approve when | Reject when |
|---|---|---|
| **Most likely failure** | I can name a concrete failure mode (missing edge case, wrong assumption, hidden dependency) OR I have explicitly stated "none found after adversarial review." | I shrugged and moved on. "Probably fine" is a reject. |
| **What is not specified that should be** | Inputs, outputs, constraints, and success criteria are all either present or explicitly marked as out-of-scope. | Any of those are implicit or absent without acknowledgment. |
| **Solving the right problem** | The spec maps clearly to the original goal and does not drift into adjacent scope. | The spec has grown beyond the original goal or solves a different problem than intended. |

**Log format (required):**

```json
{
  "review_passed": true,
  "identified_risks": ["..."],
  "missing_elements": ["none" or "..."],
  "solving_right_problem": true
}
```

**Hard rule:** I must identify at least one concrete risk OR explicitly state "none found after adversarial review." Empty `identified_risks` with no adversarial statement is not a valid review.

---

## 4. Decision Classification Rubric

From the Phase 1 governance framework, summarized for quick reference.

| Class | Criteria | Action |
|---|---|---|
| **Routine** | Reversible AND low cost AND single venture AND high confidence | Log the decision as a structured issue comment. Proceed. |
| **Significant** | Moderate cost OR some uncertainty OR affects direction within a venture | Notify operator via non-blocking issue comment. Proceed. |
| **Critical** | Irreversible OR cross-venture OR external-facing OR (low confidence AND high impact) | Block. Create Paperclip approval request. Wait for human review. |

**Self-check requirement:** Every decision must include a classification, confidence score, and `why_not_critical` justification. If the justification is weak or missing, treat as Critical by default.

**Hard rule:** I never reclassify Significant as Routine to save time. If I notice myself wanting to, I update my classification rules honestly or reduce my task volume instead.

---

## 5. Governance Theater Self-Check

Use this weekly, or whenever the framework starts to feel heavy. If more than one signal is present, stop and recalibrate before continuing.

| Signal | What it means | Response |
|---|---|---|
| I approved a spec this week without naming at least one concrete risk | Three-check protocol is degrading into rubber-stamp | Stop. Reduce task volume until the review can be run honestly. |
| I reclassified a task from Production to Structural mid-flow to skip a gate | Phase classification is being gamed under pressure | Stop. Complete the original phase or restart the task. Never game phase mid-flow. |
| I have not read `resume.md` before resuming a venture | Cognitive offload benefit is not being captured | Read resume files first. Always. |
| I am doing validator work during the final review gate (reading code line by line) | Operator role is collapsing into executor role | Trust the validator. Review against the spec only. |
| More than 20% of my project time is going to approval gates | Phase calibration is wrong | Re-examine recent tasks. Likely over-classifying structural as production. |
| I have onboarded a second venture without measuring the first | Expansion is outrunning calibration | Stop new onboarding. Measure the first venture for another week before expanding. |
| I caught myself writing "looks good" in a review comment | Discipline has degraded | Stop. Redo the review honestly. Log what changed. |

---

Related:
- design/proposals/2026-04-11-solo-operator-advice.md — the analysis behind these rubrics
- design/proposals/2026-04-11-tf-devflow-manifesto.md — the commitments these rubrics operationalize
- design/specs/2026-04-02-paperclip-uaw-governance-design-Phase-1.md — the architectural framework
- design/RUNBOOK.md — operational procedures
