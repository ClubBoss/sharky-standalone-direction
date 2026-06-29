# Human QA Capsule v1

Status: ACTIVE future evidence-gate capsule. Human QA is not currently executed.

## Current State

- Human QA has not been executed.
- W1-W6 are frozen until Human QA, regression failure, or concrete new evidence.
- W1-W6 have technical source/fixture/validator support, not learner-outcome proof.
- Do not claim 9.0, launch readiness, beginner mastery, or durable learning before Human QA.
- Participant requirements can be deferred until a Human QA execution wave is explicitly admitted.

## When To Use This Capsule

- Use for Human QA planning.
- Use for Human QA evidence synthesis.
- Use when a prompt proposes 9.0, launch, or learner-outcome claims.
- Use when a regression might affect novice comprehension.
- Do not use it as permission to run fake or synthetic QA.
- Keep any future protocol compact, reproducible, and evidence-linked.

## Purpose

Human QA should test the W1-W6 learner outcome chain. It should not be used to discover obvious missing definitions that source/fixture/validator work should already catch.

Human QA should answer:

- Can a novice understand the prompt?
- Can a novice identify the table signal?
- Can a novice choose the intended action or explanation?
- Can a novice explain the repair in their own words?
- Does confusion cluster around a missing prerequisite?
- Does time-to-decision improve or stay blocked?

## Suggested Future Protocol Outline

- Novice session.
- Short comprehension questions.
- Decision tasks from W1-W6 technical candidate families.
- Confusion log.
- Time-to-decision capture.
- Error type capture.
- Post-session recall.
- Claim-safety review after evidence synthesis.

## Evidence Fields

- participant/session id without sensitive data;
- task or concept family;
- user choice;
- correct/incorrect;
- error type;
- time to decision;
- confusion note;
- post-session recall result;
- severity.

## Readiness Impact Rules

- Passing technical validators does not equal Human QA.
- Human QA can lower confidence if novice confusion exposes a prerequisite gap.
- Human QA can support score movement only when the ledger rules allow it.
- One participant is evidence, not broad market proof.
- Any score proposal must name the exact outcome risk that moved.

## Forbidden

- No fake Human QA.
- No synthetic participant claims.
- No public launch claims.
- No 9.0 or learning-effect claims before real evidence.
- No W7-W12 opening as part of W1-W6 Human QA.
- No monetization activation from Human QA planning alone.

## Output Expectations

- Compact evidence artifact.
- Explicit pass/fail/needs-repair outcome.
- Exact source/fixture/test references for any discovered regression.
- Score movement only if evidence justifies it under the readiness ledger rules.
