# Solo Operator Advice: Running TF-Devflow Across Multiple Ventures

Date: 2026-04-11
Status: advisory (not authoritative)
Author: Keith + Claude (conversation)
Related: design/specs/2026-04-02-paperclip-uaw-governance-design-Phase-1.md, design/RUNBOOK.md

## Context

Keith is the sole developer running TF-Devflow across multiple ventures (TFLabs, NHN, WebSites, and eventually others). His stated concern: the Paperclip + UAW + Governance framework feels heavy for one person, but project and code drift across simultaneous ventures would be more costly than the ceremony overhead.

This document captures the analysis and recommendations from that conversation, plus a specific adaptation Keith has decided on regarding spec authorship.

## The Core Framing

The right question is not "bureaucracy vs drift." The right question is whether the framework will be run with discipline, or whether steps will be skipped under pressure and the system will quietly degrade without anyone noticing. That second failure mode — governance theater — is what kills heavy frameworks in solo operator hands, and it matters more than the per-task overhead.

Keith's instinct that drift is the larger cost for multi-project solo work is correct, and it is the right strategic call. Most solo developers fail at multi-project work specifically because of drift — losing context on Project A while working on Project B, re-deciding settled questions, or accumulating inconsistencies that compound into rewrite cost. TF-Devflow is designed to survive exactly this pattern.

## Why the Framework Fits a Solo Multi-Project Operator

The drift-prevention benefit is real, but the larger and less-obvious win for a solo operator is cognitive offload. The `resume.md` / `decisions.md` / `specs/` contract means project state lives in files rather than in Keith's head. He can leave TFLabs for two weeks to work on NHN and return without relearning his own context. He does not have to remember why he rejected approach X three months ago, because it is in decisions.md. The VentureLead-per-venture isolation prevents mental model collapse across ventures.

Without this infrastructure, multi-project solo work is unsustainable because the operator spends more time reconstructing state than doing work. The framework's overhead is real, but much of it is overhead Keith would pay anyway — just informally, inconsistently, and without the ability to recover from it.

## Where the Framework Is Heavier Than It Needs to Be

The biggest lever for reducing ceremony without losing the drift-prevention value is aggressive phase classification. The Phase 1 design explicitly says exploratory = executor only, no spec, no gates. This should be used liberally. Prototypes, spikes, research tasks, one-off scripts, and anything where the cost of being wrong is low should go through the exploratory pipeline.

If Keith finds himself running the full production pipeline (spec_writer → spec_validator → executor → reviewer) for tasks that should have been exploratory, he will burn out on the ceremony within a month and conclude the framework is too heavy. The actual problem in that scenario is miscalibration, not framework design. A good early signal: if approval gates are consuming more than roughly 15-20% of total project time, something is miscalibrated and phase assignments should be revisited.

## The Non-Negotiable: Spec Review Discipline

The three-check spec review protocol (most likely failure / what is not specified / solving the right problem) is the highest-leverage checkpoint in the entire pipeline. It exists specifically to break the LLM → LLM → LLM agreement loop where errors in initial framing propagate downstream unchallenged. If Keith is going to skip anything under pressure, he should skip volume (do fewer tasks) rather than skip this. "Looks good" is not a review.

This matters more in the solo-operator case, not less, because there is no second reviewer to catch a weak gate pass. The design document's guidance that Keith must identify at least one concrete risk or explicitly state "none found after adversarial review" should be treated as a hard rule, not a soft norm.

## Adaptation: Operator-Written Specs

Keith has decided that for involved projects he will write specs himself, in collaboration with an agent, and deliver the finished spec directly to the VentureLead or implementor. This replaces the spec-writer agent for those projects. This is a reasonable adaptation and in some ways produces a better initial spec, because the operator knows the intent and constraints more deeply than any agent can infer. It also avoids the specific failure mode of a spec-writer agent misunderstanding the problem and producing a polished-looking document that encodes the wrong assumptions.

However, this adaptation has a subtle cost that must be explicitly compensated for. The Phase 1 design's spec review gate was written assuming a different party wrote the spec. When the operator is both the author and the reviewer, adversarial thinking about the spec becomes much harder — the same blind spots that shaped the writing also shape the review. Self-review is not equivalent to cross-party review.

There are three ways to restore the adversarial check, and at least one should be used for any production-phase work:

The first and simplest is time separation. Write the spec, sleep on it, and review it fresh the next day using the three-check protocol. The overnight gap is enough to partially reset the blind spots that shaped the writing. This is the lowest-overhead option and fits well with a solo operator who is already context-switching between ventures.

The second is role reversal for the validator. Instead of only validating implementations against the spec, the validator (codex_local, different model than the spec was written with) performs an adversarial pass on the spec itself before implementation begins. This adds a stage but produces a meaningfully stronger spec because a different model with no context exposure runs the three checks. This is the most rigorous option and the one recommended for critical or irreversible work.

The third is using the spec-writer agent as a second-opinion consultant after Keith has written his version. Feed the same goal and constraints to the spec-writer agent and compare what it produces to what Keith wrote. Disagreements are signal — places where either Keith missed something or the agent misunderstood. This is useful when Keith is uncertain about his own spec but does not want to delay implementation by waiting for a full validator pass.

For exploratory and structural work, time separation alone is probably sufficient. For production and durable-knowledge work, role reversal is worth the cost. The operator-written spec path should not mean skipping review entirely — it should mean substituting one form of review for another.

## Bidirectional Spec Authorship: Picking a Direction Per Task

The operator-written spec path should not be treated as a fixed rule. The more useful framing is that spec authorship has two possible directions, each with different strengths, and the right choice is task-specific. Committing to one direction for all work gives up a calibration lever that matters.

Operator-writes-first (agent reviews) is stronger when the work has unusual intent, deep domain context, or when the operator already knows an agent would likely frame the problem wrong. This front-loads the thinking where operator judgment is the scarce resource. The agent reviewer's value in this direction is not domain expertise; it is the fact that the agent has to read the spec cold, with no context, exactly the way the implementor will. If the reviewing agent cannot execute from the spec without ambiguity, neither can the implementor. The agent reviewer is effectively a proxy for implementor comprehension, which is a meaningful check even though it is not a deep adversarial one.

Agent-writes-first (operator reviews) is stronger when the work is patterned enough that an agent can produce a reasonable first draft, or when the operator has thought about the problem so much they have lost the ability to see it freshly. The agent's first draft provides something concrete to react to, which is often faster than authoring from a blank page. The operator's adversarial review then brings the domain knowledge and the three checks. This is also the right direction when the operator is tired — reviewing is lower-effort than authoring, and the Phase 1 design protocol was tuned for exactly this case.

A simple heuristic: if the operator can describe the spec in one paragraph without hesitation, write it first and have the agent review. If the operator finds themselves drafting the same paragraph three different ways, let the agent draft first and review the output. The direction that creates less friction on a given task is usually the right one for that task.

One discipline to protect: whichever direction is chosen, commit to it before starting. The worst pattern is starting to write, getting stuck, asking the agent to help mid-flow, and ending up with a spec that neither party fully owns. When ownership is ambiguous, blind spots compound instead of catching each other. Pick a direction, run it, and if it fails, throw out the draft and switch directions rather than trying to stitch a hybrid together.

## The Real Risk: Governance Theater

In month two or three, when Keith is tired, he will be tempted to classify Significant decisions as Routine to skip the notification overhead, or approve specs without honestly running the three checks. The governance framework has no enforcement mechanism. It relies entirely on operator discipline.

The moment this pattern is noticed, the correct response is either to actually recalibrate (perhaps a class of decisions really is Routine and the classification rules should be updated to reflect that) or to reduce task volume until the ceremony can be run honestly. What must not happen is continuing to run the framework while quietly degrading it, because then the cost of the ceremony is paid without the quality floor it is supposed to buy.

The validator's `extra_behavior_detected` field and the system-wide invariant ("no stage may introduce behavior not in the spec") are specifically designed to do drift-prevention work without requiring operator attention. Trust those mechanisms. The operator's job at the final review gate is to confirm the spec was fulfilled, not to re-audit every line of code. Solo operators who try to do validator work on top of operator work burn out fast, and the framework is designed to prevent exactly this.

## Concrete Rollout Recommendation

The advice here is to resist the temptation to onboard all ventures at once. Pick the one where drift is most painful today — probably TFLabs, given it is the highest-complexity codebase and the AI platform. Run TF-Devflow on that project for two or three weeks with the full framework, honestly. Track how time actually splits between gates, execution oversight, and pure execution.

Use that calibration data to answer three questions before onboarding a second venture. Is gate time under 20% of total project time? Is the three-check spec review being run honestly on every production task? Is the resume.md / decisions.md pattern actually capturing enough state that context recovery works after a few days away? If any of those answers is no, fix the calibration before adding more ventures. If all three are yes, onboard the second venture and re-measure.

Beyond the rollout, lean on the todofoco-CEO agent more than instinct suggests. A strategic advisor that can be consulted across ventures without directly touching them is exactly what a solo multi-project operator needs. It is not an executor — it is the thing that helps decide which venture should get attention this week, what cross-venture priorities matter, and when to say no.

## Summary

The framework is appropriate for Keith's situation. The thing that will determine success is not the framework design but whether two solo-operator failure modes are avoided. The first is miscalibrating most work as production when it should be exploratory. The second is quietly degrading the three-check spec review when tired. Get those two right and the overhead is worth it. Get them wrong and the bureaucracy will get blamed when the real problem was discipline.

The operator-written spec adaptation is defensible for involved projects but requires substituting one form of adversarial review for another — either time separation, validator role reversal, or agent second-opinion. Self-review without substitution is the trap to avoid.

One project first. Measure. Calibrate. Then expand.
