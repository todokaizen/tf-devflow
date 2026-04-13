# TF-Devflow Pocket Rubric (Concise)

Date: 2026-04-11
Status: for recall, not rigid enforcement

For mental recall. Modify when the situation warrants — judgment over codification.



### **Phases — when unsure, pick one tier lower**

- **Exploratory** — disposable, no spec, executor only
- **Structural** — internal, short spec, spec → execute
- **Production** — user-facing, full pipeline
- **Durable** — authoritative, full pipeline



### Spec direction — commit once, restart if failing

- One clean paragraph → **I write, agent reviews**
- Three stuck drafts → **agent writes, I review**
- Tired → **agent writes**
- Critical → **I write + agent reviews + validator adversarial pass**

Never hybridize mid-draft. Start over in the other direction.



### Spec review — three checks, "looks good" = reject

1. Most likely failure?
2. What is missing that should be there?
3. Solving the right problem?

Name one concrete risk, or state "none found after adversarial review."



### Decision class — weak justification = Critical

- **Routine** — reversible, cheap, single venture, high confidence → log
- **Significant** — moderate cost or uncertainty → notify, proceed
- **Critical** — irreversible, cross-venture, external, or low-confidence → block



### Theater — stop if any fire

- Approved a spec without naming a risk
- Reclassified mid-flow to dodge a gate
- Skipped resume.md on return
- Reviewing code instead of spec fulfillment
- Gates > 20% of project time
- "Looks good" in a review comment

---

Related:
- 2026-04-11-tf-devflow-decision-rubric.md — expanded version
- 2026-04-11-tf-devflow-manifesto.md — commitments
- 2026-04-11-solo-operator-advice.md — analysis
