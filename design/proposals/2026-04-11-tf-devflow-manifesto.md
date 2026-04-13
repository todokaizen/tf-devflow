# TF-Devflow Operating Manifesto

Date: 2026-04-11
Status: living commitment

## Preamble

This is what I commit to when running TF-Devflow across multiple ventures as a solo operator. These are not rules imposed on me by the framework — they are the principles that make the framework worth its overhead. If I am not running these, the framework is costing me more than it is buying, and the honest response is to either recalibrate or reduce my task volume. Not to quietly degrade the protocol.

## Commitments

**Drift is the enemy, not bureaucracy.** I chose this framework because losing coherence across simultaneous ventures costs more than the ceremony it demands. When the ceremony feels heavy, I remember what I was protecting against and either accept the cost or fix my calibration. I do not blame the framework for a problem that is actually discipline.

**I run the three-check spec review honestly, every time.** "Looks good" is not a review. At every spec gate I identify the most likely failure, what is not specified that should be, and whether this is solving the right problem. I name at least one concrete risk, or I explicitly state "none found after adversarial review." If I cannot answer the three checks clearly, I do not approve. This is the one discipline I will not skip when I am tired.

**I calibrate phase aggressively.** Exploratory means executor only, no spec, no gates. Not everything is production. If I find myself running full pipelines for prototypes and spikes, the problem is my classification, not the framework overhead. I correct my calibration before I complain about ceremony.

**I trust the validator to do validator work.** The `extra_behavior_detected` field and the system-wide invariant are doing drift-prevention for me without my attention. My job at the final review gate is to confirm the spec was fulfilled, not to re-audit every line of code. Solo operators who try to do validator work on top of operator work burn out, and the framework is designed to prevent exactly that.

**I pick a spec authorship direction per task and commit to it.** If I can describe the spec cleanly in one paragraph, I write it first and the agent reviews. If I find myself drafting the same paragraph three different ways, the agent writes first and I review. I do not stitch hybrid specs together when ownership gets ambiguous mid-draft. If a direction is failing, I throw out the draft and restart in the other direction rather than patching.

**I notice governance theater and stop it.** If I catch myself classifying Significant decisions as Routine to save time, or approving specs without honestly running the three checks, I either update my classification rules to reflect reality or reduce my task volume. I never continue running the framework while quietly degrading it, because then I pay the cost of ceremony without the quality floor it is supposed to buy.

**I onboard one project at a time.** I run TF-Devflow on one venture fully for two to three weeks, measure where my time actually goes, and only then expand. I resist the temptation to migrate all ventures at once, because I cannot calibrate what I have not measured.

**I consult the CEO for portfolio decisions, not execution decisions.** The todofoco-CEO is my strategic advisor for which venture gets attention this week and what cross-venture priorities matter. It does not touch ventures directly. Strategy flows through me as concrete venture tasks, not as abstract direction passed to executors.

**I resume from files, not from memory.** `resume.md` and `decisions.md` are the state. When I come back to a venture after being away, I read those first. When I finish a session, I leave them clean enough that future-me can pick up without reconstruction. The framework's largest unstated benefit is cognitive offload — I do not squander it by keeping state in my head.

---

Related:
- design/proposals/2026-04-11-solo-operator-advice.md — the analysis these commitments come from
- design/proposals/2026-04-11-tf-devflow-decision-rubric.md — the decision aids that operationalize these commitments
- design/specs/2026-04-02-paperclip-uaw-governance-design-Phase-1.md — the architectural framework
