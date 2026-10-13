#!/usr/bin/env python3
"""Strict independent C1 native checkpoint judge; reads actual app plists only."""
import json
import plistlib
import sys
from pathlib import Path

root = Path(sys.argv[1])
expected = {
    'what_poker_is_find_hero': 'bottom',
    'what_poker_is_table_read_transfer': 'two_three_six',
    'what_poker_is_table_read_recheck': 'two_three_four',
    'first_table_guide_one_clear_choice': 'hero_btn_preflop_setup',
    'first_table_guide_route_roles': 'review',
}
observed = {}
def load(tag):
    plist = plistlib.loads((root / tag / 'learner.plist').read_bytes())
    state = json.loads(plist['flutter.act0_shell_progress_v1'])
    observed[tag] = state
    return state

def records(state, count):
    rows = state['learningEvidenceHistory']
    assert len(rows) == count
    assert len({r['recordId'] for r in rows}) == count
    assert len({r['taskId'] for r in rows}) == count
    assert len({r['runId'] for r in rows}) == 1
    assert [r['createdOrder'] for r in rows] == sorted({r['createdOrder'] for r in rows})
    assert all(r['worldId'] == 'world_1' and r['errorType'] == 'none' for r in rows)
    assert all(r['recordId'] and r['runId'] and r['sessionId'] and r['recordedAtUtc'] for r in rows)
    assert all(r['choiceId'] == expected[r['taskId']] == r['expectedChoiceId'] and r['isCorrect'] is True and r['assistanceKind'] == 'none' and r['runKind'] == 'lesson' and r['lessonId'] == 'what_poker_is' for r in rows)
    return rows

try:
    before = load('C1_prefinal')
    original = records(before, 4)
    assert before['earnedXp'] == 25
    assert set(before['completedTaskIds']) == set(expected) - {'first_table_guide_route_roles'} | {'what_poker_is_theory'}
    assert len(before['completedTaskIds']) == len(set(before['completedTaskIds'])) == 5
    assert not before['completedLessonIds']
    assert 'first_table_guide_route_roles' not in before['completedTaskIds']
    assert before['selectedTaskId'] == 'first_table_guide_route_roles'
    assert before.get('resumeSelectedOptionId') is None
    answered = load('C1_final_answer')
    rows = records(answered, 5)
    assert rows[:4] == original
    assert len({r['sessionId'] for r in rows}) == 1
    assert answered['earnedXp'] == 25 and not answered['completedLessonIds']
    assert answered['completedTaskIds'] == before['completedTaskIds']
    for tag in ['C1_summary', 'C1_home', 'C1_restart']:
        state = load(tag)
        assert records(state, 5) == rows
        assert state['earnedXp'] == 30
        assert len(state['completedTaskIds']) == len(set(state['completedTaskIds'])) == 6
        assert state['completedLessonIds'] == ['what_poker_is']
        assert set(state['completedTaskIds']) == set(before['completedTaskIds']) | {'first_table_guide_route_roles'}
    verdict = {'status': 'PASS_C1_NATIVE_CLOSURE', 'checkpoints': observed}
except (AssertionError, KeyError, OSError, ValueError) as exc:
    verdict = {'status': 'FAIL_C1_NATIVE_CLOSURE', 'error': repr(exc), 'checkpoints': observed}
(root / 'closure-verdict.json').write_text(json.dumps(verdict, indent=2))
print(verdict['status'], verdict.get('error', ''))
sys.exit(0 if verdict['status'].startswith('PASS') else 1)
