# Replay Files Directory

This directory stores exported replay files from the Simulation Engine V2.

Each replay is stored as JSONL (JSON Lines) format, with one event per line.

## File Naming Convention

`replay_YYYYMMDD_HHMM.jsonl`

Example: `replay_20251105_1430.jsonl`

## Event Structure

Each line contains a JSON object with the following fields:

- `timestamp`: ISO 8601 timestamp
- `type`: Event type (action, street_change, pot_update, round_end, etc.)
- `seat_index`: Player seat (0-indexed)
- `action`: Optional player action (fold, call, raise, check)
- `amount`: Optional bet/raise amount
- `street`: Optional street name (preFlop, flop, turn, river)
- `pot`: Optional pot size

## Usage

Replay files can be reviewed by:
- AI Coach for hand analysis
- Analytics modules for pattern detection
- Manual review for training data
