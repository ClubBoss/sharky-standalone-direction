# Action repair/recheck owner decision v1

## Decision

Choose **C1 — same-task Action repair/recheck**.

`actions_check_drill` directly assesses the `no_bet_yet` action-read signal;
its wrong result is typed `missed_action_read`. `actions_legal_context` is a
broader legal-actions task, so using it as the repair owner would weaken the
claimed learning relationship. The preview shell remains the one canonical
sequence/completion/progression owner; the task runner supplies the bounded
repair and recheck presentation states.

## Contract

Wrong `actions_check_drill` -> same-task repair micro-state -> same-task
recheck micro-state -> existing shell completion only after successful recheck.
The table relation remains `related_read`, never same-hand.
