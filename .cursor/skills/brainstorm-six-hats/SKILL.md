---
name: brainstorm-six-hats
description: Use when the user asks to brainstorm, six hats, seven hats, de Bono, or wants structured multi-perspective ideation on a product/feature/problem before deciding or building.
---

# Brainstorm — Six Thinking Hats

## Overview

Run Edward de Bono’s **Six Thinking Hats** as a disciplined brainstorm. One hat at a time. No mixing. Finish with Blue-hat synthesis that turns perspectives into decisions or next experiments.

> People often say “seven hats.” The famous framework is **six**. Blue is the process/meta hat that opens and closes the session — that is what feels like a seventh voice.

## When to Use

- User says brainstorm / six hats / seven hats / de Bono / “think from every angle”
- Stuck between options (port vs harden, feature A vs B)
- Need creative options without collapsing into premature coding
- Want risks, feelings, facts, and ideas separated so they don’t cancel each other

**Do not use** when the user wants implementation, a single factual lookup, or a formal code review (use review/council skills instead).

## Hard Rules

1. **One hat at a time.** Never argue Yellow points inside Black, etc.
2. **Label every block** with the hat name + color.
3. **Time-box mentally:** short passes beat deep rabbit holes. Prefer 5–12 bullets per hat.
4. **Stay on the stated question.** If scope explodes, Blue hat must cut it.
5. **No code** unless Blue explicitly asks for a tiny illustrative snippet.
6. **End with Blue synthesis:** decisions, experiments, kill-list, and ordered next steps.
7. **Write the artifact** to `docs/brainstorms/YYYY-MM-DD-<topic>-six-hats.md` when working in a repo (unless user says not to).

## Hat Sequence (default)

Run in this order unless the user requests another:

| Order | Hat | Focus | Prompt the model must obey |
|---|---|---|---|
| 1 | **Blue** (open) | Process | Restate the question, success criteria, constraints, out-of-scope. Set the agenda. |
| 2 | **White** | Facts | Only known facts, data, evidence, unknowns. No opinions. Mark unknowns as questions. |
| 3 | **Red** | Feelings | Gut reactions, hunches, excitement, fear. No justification required. |
| 4 | **Yellow** | Benefits | Optimistic value: why it could work, upside, who wins. |
| 5 | **Black** | Risks | Caution: failure modes, costs, legal, safety, complexity, false confidence. |
| 6 | **Green** | Creativity | Alternatives, provocations, combinations, “how else?”, wild then practical. |
| 7 | **Blue** (close) | Synthesis | Merge hats into decisions, experiments, stop-doing list, ranked next actions. |

Optional second Green pass after Black if Black killed everything.

## Output Template

```markdown
# Six Hats — <topic>
Date: YYYY-MM-DD
Question: ...

## Blue (process) — open
- Question:
- Success looks like:
- Constraints:
- Out of scope:

## White (facts)
- ...
- Unknowns: ...

## Red (feelings)
- ...

## Yellow (benefits)
- ...

## Black (risks)
- ...

## Green (ideas)
- ...

## Blue (process) — close
### Decisions
- ...
### Experiments / spikes
- ...
### Kill / defer
- ...
### Next actions (ranked)
1. ...
```

## Facilitation Tips

- If the user dumps many topics, Blue must pick **one primary question** and park the rest.
- If facts are thin, White must say so — do not invent telemetry, APIs, or market data.
- Red is allowed to be irrational; do not debate it until Blue close.
- Black should be specific (“multicast entitlement may be refused”) not vague (“might be hard”).
- Green should include at least one **boring** option and one **provocative** option.
- Blue close must resolve conflicts (e.g. Yellow wants iOS now, Black says Android first).

## Combination With Other Skills

- After Blue close, if design is needed → brainstorming / writing-plans.
- If multi-model critique is needed → LLM council review.
- Do not skip hats because a prior council already ran — hats optimize *perspective coverage*, council optimizes *model disagreement*.

## Anti-Patterns

- Mixing “but the risk is…” into Yellow
- Turning White into a pitch
- Endless Green with no Blue close
- Implementing during the session
- Treating Red as invalid because it lacks evidence
