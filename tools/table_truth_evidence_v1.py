#!/usr/bin/env python3
"""Summarize real Flutter cases and preserve paired TABLE.TRUTH provenance."""
import collections
import copy
import hashlib
import json
import pathlib
import re
import sys


NEW_AUTHORING_IDS = {
    'asm05_new_known_holes_turn_call_10',
    'asm05_new_known_holes_turn_call_40',
}
SOURCE_REFERENCES = {
    'historical_baseline': {
        'commit': 'fa079b6c5880814e231981a7bd5ed97df192d215',
        'state_sha256': 'e9f87d4bf73b75d77bd7b04ddf111cbf6b64e796259ffe42adadea9bbb3270e2',
        'factory_sha256': None,
    },
    'candidate': {
        'commit': '5b0dd2e300053e52b323e54df6c759ddb5f04b48',
        'state_sha256': 'd9a78d57817c8eaef7dc1a376f53ade7774229be4a34063d5dc0cf152bb67221',
        'factory_sha256': 'c9386ad268d84f7469727f6fb4dc4f6eb2e771fd8d3f91d4169d1d31f727016b',
    },
}
# Authoring origin above is immutable. This separately admitted source revision
# changes only two grading qualities in one existing task; producer HEAD remains
# an execution receipt (a later tooling-only commit can have identical bytes).
MAIN01_PRODUCER_REVISION = {
    'source_revision': 'fe6dd994774b3da2524e39ff322cad109687a9b5',
    'state_sha256': 'ee5fe77ef24b5541a35e6e58823497f7ca47560714de6366f96f3632cfd00c61',
    'factory_sha256': 'c9386ad268d84f7469727f6fb4dc4f6eb2e771fd8d3f91d4169d1d31f727016b',
}
MAIN01_TASK_ID = 'first_table_guide_one_clear_choice'
MAIN01_PRIOR_FINGERPRINT = '2c7cc8212fe8a0fe211c79b4be08391f4262c8a7ef1abfb170de27bbd41ce278'
MAIN01_CURRENT_FINGERPRINT = '2573cfd7f0d3d18a5680b1a744a6dde0c95714a4bd655cd14a9478a4fd139500'
MAIN01_QUALITY_REVISION = {
    'co_still_acting': ('wrong', 'suboptimal'),
    'hero_has_no_cards': ('suboptimal', 'wrong'),
}
CANONICAL_NEW_AUTHORING = pathlib.Path(__file__).resolve().parents[1] / (
    'test/tools/fixtures/table_truth_asm05_new_authoring_v1.json'
)
EXPECTED_CAPTURE_ARTIFACTS = {
    'choice-identity.json': 'c36878c369d880bcefc4c5f53b0f3247725e1c2439956619e511a77ccd06fd8d',
    'learning-contract.json': '1cf59348b0296053cf73b97201879b033479c83347a759b9be16bf87ea907d25',
    'ledger.json': '382960a25750f83cb26d33a5b6d8e80cdcf3a77f98f420bedc2b3030d33c368f',
    'runtime-inputs.json': '886e8e2bf0a90dbb7a37b58858502782d940fba4f82cc414b877a9f4ebda9c9f',
    'source-fingerprints.json': '6b848f76f99825b968eef9072b00e707a7ee5a9da278aaf3db3674c6cab1b786',
}


# Exact independently reviewed PR475 source revision. The source authoring
# origin and all five historical capture pins remain unchanged. A later
# test/tool-only producer HEAD may have these identical production bytes.
W01_PRODUCER_REVISION = {
    'source_revision': 'ce54743ede6fbb7aa258b180467a42a0d2eb5fd5',
    'state_sha256': '5c29f45055f0134fa506b0fd97d5265af6653f57ee6b86646784fb2c022ceaa9',
    'factory_sha256': 'c9386ad268d84f7469727f6fb4dc4f6eb2e771fd8d3f91d4169d1d31f727016b',
}
W01_REVISION = 'W01_REVIEWED_THEORY_CONTRACTS'
W01_CAPTURE_SHA256 = {'choice-identity.json': 'c8d63188ded16990ba2135ccd7952b9e98d3f7b7ae338891bab9a28705999564',
 'learning-contract.json': 'fb5f931f806fe80596b78f288b31b9f9241be5ad2e95619a49aba2381bef8b12',
 'ledger.json': '95fd32eff3116169d1fa888452ef40605567d3cf111248c07016cc1a5db03400',
 'runtime-inputs.json': 'a098e06199be210eb8ff90f9a1e3cd8fda21c0c61f90053323351992a4ef394a',
 'source-fingerprints.json': 'a1b19ba1b8eac40ab2641c7609a1308ca30f35c6b866e645d3bf116110457f1e'}
W01_CAPTURE_OPTIONS = {'choice-identity.json': {'blinds_theory': {'current': [['button_is_not_a_blind',
                                                         'BTN',
                                                         False,
                                                         'wrong',
                                                         'BB'],
                                                        ['bb', 'BB', True, 'correct', 'BB'],
                                                        ['sb', 'SB', False, 'wrong', 'BB']],
                                            'prior': [['top',
                                                       'UTG',
                                                       False,
                                                       'wrong',
                                                       'BTN (your seat)'],
                                                      ['bottom',
                                                       'BTN (your seat)',
                                                       True,
                                                       'correct',
                                                       'BTN (your seat)'],
                                                      ['random',
                                                       'BB',
                                                       False,
                                                       'wrong',
                                                       'BTN (your seat)']]},
                          'cards_ranks_suits_theory': {'current': [['rank_only',
                                                                    'Rank only',
                                                                    False,
                                                                    'wrong',
                                                                    'Rank and suit'],
                                                                   ['rank_and_suit',
                                                                    'Rank and suit',
                                                                    True,
                                                                    'correct',
                                                                    'Rank and suit'],
                                                                   ['suit_only',
                                                                    'Suit only',
                                                                    False,
                                                                    'wrong',
                                                                    'Rank and suit']],
                                                       'prior': [['king',
                                                                  'King',
                                                                  False,
                                                                  'wrong',
                                                                  'Ace'],
                                                                 ['ace',
                                                                  'Ace',
                                                                  True,
                                                                  'correct',
                                                                  'Ace'],
                                                                 ['suit',
                                                                  'Suit decides',
                                                                  False,
                                                                  'wrong',
                                                                  'Ace']]},
                          'hand_rankings_theory': {'current': [['hand_strength',
                                                                'Hand strength',
                                                                True,
                                                                'correct',
                                                                'Hand strength'],
                                                               ['seat_position',
                                                                'Seat position',
                                                                False,
                                                                'wrong',
                                                                'Hand strength']],
                                                   'prior': [['pair',
                                                              'Pair',
                                                              True,
                                                              'correct',
                                                              'Pair'],
                                                             ['high_card',
                                                              'High card',
                                                              False,
                                                              'wrong',
                                                              'Pair']]}},
 'learning-contract.json': {'blinds_theory': {'current': [{'id': 'button_is_not_a_blind',
                                                           'correct': False,
                                                           'quality': 'wrong',
                                                           'seat': 'btn',
                                                           'repairSeats': [],
                                                           'repairCards': [],
                                                           'repairLabels': []},
                                                          {'id': 'bb',
                                                           'correct': True,
                                                           'quality': 'correct',
                                                           'seat': 'bb',
                                                           'repairSeats': [],
                                                           'repairCards': [],
                                                           'repairLabels': []},
                                                          {'id': 'sb',
                                                           'correct': False,
                                                           'quality': 'wrong',
                                                           'seat': 'sb',
                                                           'repairSeats': [],
                                                           'repairCards': [],
                                                           'repairLabels': []}],
                                              'prior': [{'id': 'top',
                                                         'correct': False,
                                                         'quality': 'wrong',
                                                         'seat': 'utg',
                                                         'repairSeats': [],
                                                         'repairCards': [],
                                                         'repairLabels': []},
                                                        {'id': 'bottom',
                                                         'correct': True,
                                                         'quality': 'correct',
                                                         'seat': 'btn',
                                                         'repairSeats': [],
                                                         'repairCards': [],
                                                         'repairLabels': []},
                                                        {'id': 'random',
                                                         'correct': False,
                                                         'quality': 'wrong',
                                                         'seat': 'bb',
                                                         'repairSeats': [],
                                                         'repairCards': [],
                                                         'repairLabels': []}]},
                            'cards_ranks_suits_theory': {'current': [{'id': 'rank_only',
                                                                      'correct': False,
                                                                      'quality': 'wrong',
                                                                      'seat': None,
                                                                      'repairSeats': [],
                                                                      'repairCards': [],
                                                                      'repairLabels': []},
                                                                     {'id': 'rank_and_suit',
                                                                      'correct': True,
                                                                      'quality': 'correct',
                                                                      'seat': None,
                                                                      'repairSeats': [],
                                                                      'repairCards': [],
                                                                      'repairLabels': []},
                                                                     {'id': 'suit_only',
                                                                      'correct': False,
                                                                      'quality': 'wrong',
                                                                      'seat': None,
                                                                      'repairSeats': [],
                                                                      'repairCards': [],
                                                                      'repairLabels': []}],
                                                         'prior': [{'id': 'king',
                                                                    'correct': False,
                                                                    'quality': 'wrong',
                                                                    'seat': None,
                                                                    'repairSeats': [],
                                                                    'repairCards': [],
                                                                    'repairLabels': []},
                                                                   {'id': 'ace',
                                                                    'correct': True,
                                                                    'quality': 'correct',
                                                                    'seat': None,
                                                                    'repairSeats': [],
                                                                    'repairCards': [],
                                                                    'repairLabels': []},
                                                                   {'id': 'suit',
                                                                    'correct': False,
                                                                    'quality': 'wrong',
                                                                    'seat': None,
                                                                    'repairSeats': [],
                                                                    'repairCards': [],
                                                                    'repairLabels': []}]},
                            'hand_rankings_theory': {'current': [{'id': 'hand_strength',
                                                                  'correct': True,
                                                                  'quality': 'correct',
                                                                  'seat': None,
                                                                  'repairSeats': [],
                                                                  'repairCards': [],
                                                                  'repairLabels': []},
                                                                 {'id': 'seat_position',
                                                                  'correct': False,
                                                                  'quality': 'wrong',
                                                                  'seat': None,
                                                                  'repairSeats': [],
                                                                  'repairCards': [],
                                                                  'repairLabels': []}],
                                                     'prior': [{'id': 'pair',
                                                                'correct': True,
                                                                'quality': 'correct',
                                                                'seat': None,
                                                                'repairSeats': [],
                                                                'repairCards': [],
                                                                'repairLabels': []},
                                                               {'id': 'high_card',
                                                                'correct': False,
                                                                'quality': 'wrong',
                                                                'seat': None,
                                                                'repairSeats': [],
                                                                'repairCards': [],
                                                                'repairLabels': []}]}},
 'runtime-inputs.json': {'blinds_theory': {'current': [{'id': 'button_is_not_a_blind',
                                                        'label': 'BTN',
                                                        'amount': '',
                                                        'reason': 'BTN marks the dealer button. BB '
                                                                  'posts the full 1 BB blind.',
                                                        'preferred': 'BB'},
                                                       {'id': 'bb',
                                                        'label': 'BB',
                                                        'amount': '',
                                                        'reason': 'BB posts the full 1 BB blind, '
                                                                  'so later prices count from that '
                                                                  'baseline.',
                                                        'preferred': 'BB'},
                                                       {'id': 'sb',
                                                        'label': 'SB',
                                                        'amount': '',
                                                        'reason': 'SB posts only 0.5 BB. BB is the '
                                                                  'full 1 BB post players count '
                                                                  'from.',
                                                        'preferred': 'BB'}],
                                           'prior': [{'id': 'top',
                                                      'label': 'UTG',
                                                      'amount': '',
                                                      'reason': 'UTG acts before HJ, CO, and BTN '
                                                                'in preflop order.',
                                                      'preferred': 'BTN (your seat)'},
                                                     {'id': 'bottom',
                                                      'label': 'BTN (your seat)',
                                                      'amount': '',
                                                      'reason': 'After UTG, HJ, and CO, BTN acts '
                                                                'before SB and BB.',
                                                      'preferred': 'BTN (your seat)'},
                                                     {'id': 'random',
                                                      'label': 'BB',
                                                      'amount': '',
                                                      'reason': 'BB acts after BTN preflop, so it '
                                                                'is not next here.',
                                                      'preferred': 'BTN (your seat)'}]},
                         'cards_ranks_suits_theory': {'current': [{'id': 'rank_only',
                                                                   'label': 'Rank only',
                                                                   'amount': '',
                                                                   'reason': 'Rank names the '
                                                                             'value, but a card '
                                                                             'also has a suit.',
                                                                   'preferred': 'Rank and suit'},
                                                                  {'id': 'rank_and_suit',
                                                                   'label': 'Rank and suit',
                                                                   'amount': '',
                                                                   'reason': 'Rank names the value '
                                                                             'and suit names the '
                                                                             'symbol family.',
                                                                   'preferred': 'Rank and suit'},
                                                                  {'id': 'suit_only',
                                                                   'label': 'Suit only',
                                                                   'amount': '',
                                                                   'reason': 'Suit names the '
                                                                             'symbol family, but a '
                                                                             'card also has a '
                                                                             'rank.',
                                                                   'preferred': 'Rank and suit'}],
                                                      'prior': [{'id': 'king',
                                                                 'label': 'King',
                                                                 'amount': '',
                                                                 'reason': 'Ace is higher than '
                                                                           'king in this beginner '
                                                                           'drill.',
                                                                 'preferred': 'Ace'},
                                                                {'id': 'ace',
                                                                 'label': 'Ace',
                                                                 'amount': '',
                                                                 'reason': 'Compare top card '
                                                                           'first: ace outranks '
                                                                           'king in this spot.',
                                                                 'preferred': 'Ace'},
                                                                {'id': 'suit',
                                                                 'label': 'Suit decides',
                                                                 'amount': '',
                                                                 'reason': 'Suit does not make one '
                                                                           'rank higher than '
                                                                           'another.',
                                                                 'preferred': 'Ace'}]},
                         'hand_rankings_theory': {'current': [{'id': 'hand_strength',
                                                               'label': 'Hand strength',
                                                               'amount': '',
                                                               'reason': 'Rankings tell which made '
                                                                         'hand is stronger, such '
                                                                         'as a flush over a '
                                                                         'straight.',
                                                               'preferred': 'Hand strength'},
                                                              {'id': 'seat_position',
                                                               'label': 'Seat position',
                                                               'amount': '',
                                                               'reason': 'Seat position affects '
                                                                         'action order, not the '
                                                                         'hand ranking.',
                                                               'preferred': 'Hand strength'}],
                                                  'prior': [{'id': 'pair',
                                                             'label': 'Pair',
                                                             'amount': '',
                                                             'reason': 'Hero has a pair with the '
                                                                       'board.',
                                                             'preferred': 'Pair'},
                                                            {'id': 'high_card',
                                                             'label': 'High card',
                                                             'amount': '',
                                                             'reason': 'A matching rank makes a '
                                                                       'pair.',
                                                             'preferred': 'Pair'}]}},
 'source-fingerprints.json': {'blinds_theory': {'current': {'world_id': 'world_1',
                                                            'lesson_id': 'blinds_action_order',
                                                            'fingerprint': '89474286be5d6633993452fa57e7568d1e66f75b4c89748cf61a37f58b812ce0'},
                                                'prior': {'world_id': 'world_1',
                                                          'lesson_id': 'blinds_action_order',
                                                          'fingerprint': 'b10ea2093f254cae6df8d3a8702aed685bfd49de9a65724f76342fd6cd9ad46f'}},
                              'cards_ranks_suits_theory': {'current': {'world_id': 'world_1',
                                                                       'lesson_id': 'cards_ranks_suits',
                                                                       'fingerprint': '5d6e7323768eb9839cfa346e344225af733faefb72fc5cde47dc104c4f8eb7e8'},
                                                           'prior': {'world_id': 'world_1',
                                                                     'lesson_id': 'cards_ranks_suits',
                                                                     'fingerprint': 'da18579f003d9a05d2feb9ba458ed793be8ab2fc5d98943e8daf13101533d6fd'}},
                              'hand_rankings_theory': {'current': {'world_id': 'world_1',
                                                                   'lesson_id': 'hand_rankings_table',
                                                                   'fingerprint': 'e8a637f48694e11be593a92647711bd105b38afa4395361031cb2eb7473a4c02'},
                                                       'prior': {'world_id': 'world_1',
                                                                 'lesson_id': 'hand_rankings_table',
                                                                 'fingerprint': '9211311af696efd47e86e41bf2a670711541def3254083aa1b134903129bf43c'}}}}
W01_LEDGER_REVISIONS = [{'task_id': 'cards_ranks_suits_theory',
  'current': 'feedback/rank_only',
  'prior': 'feedback/king',
  'indices': [1023]},
 {'task_id': 'cards_ranks_suits_theory',
  'current': 'feedback/rank_and_suit',
  'prior': 'feedback/ace',
  'indices': [1024]},
 {'task_id': 'cards_ranks_suits_theory',
  'current': 'feedback/suit_only',
  'prior': 'feedback/suit',
  'indices': [1025]},
 {'task_id': 'blinds_theory',
  'current': 'feedback/button_is_not_a_blind',
  'prior': 'feedback/top',
  'indices': [4932]},
 {'task_id': 'blinds_theory',
  'current': 'feedback/bb',
  'prior': 'feedback/bottom',
  'indices': [4933]},
 {'task_id': 'blinds_theory',
  'current': 'feedback/sb',
  'prior': 'feedback/random',
  'indices': [4934]},
 {'task_id': 'hand_rankings_theory',
  'current': 'feedback/hand_strength',
  'prior': 'feedback/pair',
  'indices': [5289,
              5290,
              5291,
              5292,
              5293,
              5294,
              5295,
              5296,
              5297,
              5298,
              5299,
              5300,
              5301,
              5302,
              5303,
              5304,
              5305,
              5306,
              5307,
              5308,
              5309,
              5310,
              5311,
              5312,
              5313]},
 {'task_id': 'hand_rankings_theory',
  'current': 'feedback/seat_position',
  'prior': 'feedback/high_card',
  'indices': [5314,
              5315,
              5316,
              5317,
              5318,
              5319,
              5320,
              5321,
              5322,
              5323,
              5324,
              5325,
              5326,
              5327,
              5328,
              5329,
              5330,
              5331,
              5332,
              5333,
              5334,
              5335,
              5336,
              5337,
              5338]}]


def summarize(path, expected, code):
    starts, cases, errors = {}, [], []
    for line in pathlib.Path(path).read_text().splitlines():
        try:
            event = json.loads(line)
        except json.JSONDecodeError:
            continue
        if not isinstance(event, dict):
            continue
        if event.get('type') == 'testStart':
            starts[event['test']['id']] = event['test']
        elif event.get('type') == 'testDone':
            test = starts.get(event['testID'], {})
            if not event.get('hidden') and not test.get('name', '').startswith('loading '):
                cases.append({**test, **event})
        elif event.get('type') == 'error':
            errors.append(event)
    counts = collections.Counter('skipped' if c.get('skipped') else c['result'] for c in cases)
    result = {'counts': dict(counts), 'case_count': len(cases), 'exit_code': code,
              'expected': expected, 'cases': cases, 'errors': errors}
    pathlib.Path(path + '.summary.json').write_text(json.dumps(result, indent=2))
    print(json.dumps({k: result[k] for k in ['counts', 'case_count', 'exit_code', 'expected']}))
    compile_error = any('Compilation failed' in e.get('error', '') or 'Failed to load' in e.get('error', '') for e in errors)
    valid = bool(cases) and not counts['skipped'] and not compile_error
    valid &= (code != 0 and (counts['error'] + counts['failure']) > 0) if expected == 'red' else (code == 0 and counts['error'] == 0 and counts['failure'] == 0)
    if not valid:
        for e in errors[-8:]:
            print(e.get('error', ''))
        raise SystemExit('TABLE.TRUTH execution does not establish the expected result')


# PKG1 uses actual typed captures; prior W01 and original pins stay immutable.
PKG1_REVISION = "PKG1_REVIEWED_HAND_SEAT_FACTS"
PKG1_PRODUCER_REVISION = {'source_revision': '504fce48eeba627af4d860b891d7b3ee456e913b',
 'state_sha256': '144558357cb8a237a607deb39d591450262c8146301f4c566fc09d7ce98b6644',
 'factory_sha256': 'c9386ad268d84f7469727f6fb4dc4f6eb2e771fd8d3f91d4169d1d31f727016b'}
PKG1_CAPTURE_SHA256 = {'choice-identity.json': 'c8d63188ded16990ba2135ccd7952b9e98d3f7b7ae338891bab9a28705999564',
 'learning-contract.json': 'fb5f931f806fe80596b78f288b31b9f9241be5ad2e95619a49aba2381bef8b12',
 'ledger.json': 'f9a44a4c528ca0387658fd14a6d934f51e3105af457f572938c9a1e883023821',
 'runtime-inputs.json': '5afdbce17e46031d250851613d59bda3b16ee4ad91f107ab18b174ba4e014780',
 'source-fingerprints.json': '25c36eb744dfefc1ba69ab9d63d74f1b90bcd9505f68480e90b42b11aaf04040'}
PKG1_CAPTURE_LEAVES = {'runtime-inputs.json': [(['hand_discipline_buckets_borderline', 'caption'],
                          'Hero holds Q♥ J♠ before the flop.',
                          'Hero holds Qs Js before the flop.'),
                         (['hand_discipline_buckets_borderline', 'table', 'hero', 0], 'Qh', 'Qs'),
                         (['hand_discipline_buckets_borderline', 'table', 'seats', 3, 'cards', 0],
                          'Qh',
                          'Qs'),
                         (['apply_btn_open', 'teaching', 0, 'body'],
                          'AJo is a strong bucket. BTN acts last. Pot is clean. Open.',
                          'AJo is a strong bucket. BTN acts last after the flop. Pot is clean. Open.'),
                         (['same_hand_different_seat_same_hand_early_fold', 'options', 0, 'reason'],
                          'Weak offsuit hands from early position can simply fold.',
                          'The course baseline folds ATo from UTG in this unopened pot.'),
                         (['same_hand_different_seat_same_hand_early_fold', 'options', 1, 'reason'],
                          'Position is early and the hand bucket is too weak.',
                          'Read ATo and UTG together. The course baseline here is Fold, not an automatic '
                          'open.'),
                         (['position_apply_early_fold', 'options', 0, 'reason'],
                          'Weak offsuit hands from early position can simply fold.',
                          'The course baseline folds ATo from UTG in this unopened pot.'),
                         (['position_apply_early_fold', 'options', 1, 'reason'],
                          'Position is early and the hand bucket is too weak.',
                          'Read ATo and UTG together. The course baseline here is Fold, not an automatic '
                          'open.'),
                         (['position_apply_hj_fold', 'options', 0, 'reason'],
                          'Position is early and the hand bucket is too weak.',
                          'Read KTo and HJ together. The course baseline here is Fold, not an automatic '
                          'open.'),
                         (['position_apply_hj_fold', 'options', 1, 'reason'],
                          'Weak offsuit hands from early position can simply fold.',
                          'The course baseline folds KTo from HJ in this unopened pot.'),
                         (['position_checkpoint_position_checkpoint_early_fold', 'options', 0, 'reason'],
                          'Position is early and the hand bucket is too weak.',
                          'Read A9o and UTG together. The course baseline here is Fold, not an automatic '
                          'open.'),
                         (['position_checkpoint_position_checkpoint_early_fold', 'options', 1, 'reason'],
                          'Weak offsuit hands from early position can simply fold.',
                          'The course baseline folds A9o from UTG in this unopened pot.')],
 'source-fingerprints.json': [(['hand_discipline_buckets_borderline', 'fingerprint'],
                               'f528fbd3c9dfdcb4692167d5e0d722cd4d1d107688f631d0f6038a534f8ee4d5',
                               '45dbf4315b3fdeff5de099cf2db2935b8b029e4b1dd290f86e70a6159ca1c5ce'),
                              (['same_hand_different_seat_same_hand_early_fold', 'fingerprint'],
                               'a3398cf7828d26c701ff08663112b8ce67f6451374240933f3e5437734910757',
                               '75accc138b72178108bc6e302fc05719d4e319a8721d0f9fee17ca99d1f26c6b'),
                              (['position_apply_early_fold', 'fingerprint'],
                               '2a06cf610f5e4126da08eb64635835bf914ba0062638747d7eafc505e3ea0bff',
                               '94ad43b5d81cb888c32af9e312909b287bfd903caf7163a954ac324c7f24e85d'),
                              (['position_apply_hj_fold', 'fingerprint'],
                               '62a0220a4d6194d568df88e4c880965e513d21865c7b1745acb68715218a3369',
                               '5ebeeb72c4f0c1cfb5f1f11f91e53dfcf88290a49d048e1e31e9a3de51729ded'),
                              (['position_checkpoint_position_checkpoint_early_fold', 'fingerprint'],
                               '5fb039d357fa09c136f72f3f614a8f7cdb49c93f187a5372fc7aed6263d26b61',
                               'f0d88794d13f35c1584ee3e0c16ad5635ad7209527d1a811134619611bd7afde')],
 'ledger.json': [([9844, 'reason'], 'table=Js,Qh seat=Js,Qh', 'table=Js,Qs seat=Js,Qs'),
                 ([9844, 'rendered_meaning'], 'table=Js,Qh seat=Js,Qh', 'table=Js,Qs seat=Js,Qs'),
                 ([9844, 'expectation_or_exception'], 'table=Js,Qh seat=Js,Qh', 'table=Js,Qs seat=Js,Qs'),
                 ([9845, 'reason'], 'physical deck Qh,Js', 'physical deck Qs,Js'),
                 ([9845, 'rendered_meaning'], 'physical deck Qh,Js', 'physical deck Qs,Js'),
                 ([9845, 'expectation_or_exception'], 'physical deck Qh,Js', 'physical deck Qs,Js'),
                 ([9866, 'reason'], 'table=Js,Qh seat=Js,Qh', 'table=Js,Qs seat=Js,Qs'),
                 ([9866, 'rendered_meaning'], 'table=Js,Qh seat=Js,Qh', 'table=Js,Qs seat=Js,Qs'),
                 ([9866, 'expectation_or_exception'], 'table=Js,Qh seat=Js,Qh', 'table=Js,Qs seat=Js,Qs'),
                 ([9867, 'reason'], 'physical deck Qh,Js', 'physical deck Qs,Js'),
                 ([9867, 'rendered_meaning'], 'physical deck Qh,Js', 'physical deck Qs,Js'),
                 ([9867, 'expectation_or_exception'], 'physical deck Qh,Js', 'physical deck Qs,Js'),
                 ([9888, 'reason'], 'table=Js,Qh seat=Js,Qh', 'table=Js,Qs seat=Js,Qs'),
                 ([9888, 'rendered_meaning'], 'table=Js,Qh seat=Js,Qh', 'table=Js,Qs seat=Js,Qs'),
                 ([9888, 'expectation_or_exception'], 'table=Js,Qh seat=Js,Qh', 'table=Js,Qs seat=Js,Qs'),
                 ([9889, 'reason'], 'physical deck Qh,Js', 'physical deck Qs,Js'),
                 ([9889, 'rendered_meaning'], 'physical deck Qh,Js', 'physical deck Qs,Js'),
                 ([9889, 'expectation_or_exception'], 'physical deck Qh,Js', 'physical deck Qs,Js'),
                 ([9910, 'reason'], 'table=Js,Qh seat=Js,Qh', 'table=Js,Qs seat=Js,Qs'),
                 ([9910, 'rendered_meaning'], 'table=Js,Qh seat=Js,Qh', 'table=Js,Qs seat=Js,Qs'),
                 ([9910, 'expectation_or_exception'], 'table=Js,Qh seat=Js,Qh', 'table=Js,Qs seat=Js,Qs'),
                 ([9911, 'reason'], 'physical deck Qh,Js', 'physical deck Qs,Js'),
                 ([9911, 'rendered_meaning'], 'physical deck Qh,Js', 'physical deck Qs,Js'),
                 ([9911, 'expectation_or_exception'], 'physical deck Qh,Js', 'physical deck Qs,Js'),
                 ([9932, 'reason'], 'table=Js,Qh seat=Js,Qh', 'table=Js,Qs seat=Js,Qs'),
                 ([9932, 'rendered_meaning'], 'table=Js,Qh seat=Js,Qh', 'table=Js,Qs seat=Js,Qs'),
                 ([9932, 'expectation_or_exception'], 'table=Js,Qh seat=Js,Qh', 'table=Js,Qs seat=Js,Qs'),
                 ([9933, 'reason'], 'physical deck Qh,Js', 'physical deck Qs,Js'),
                 ([9933, 'rendered_meaning'], 'physical deck Qh,Js', 'physical deck Qs,Js'),
                 ([9933, 'expectation_or_exception'], 'physical deck Qh,Js', 'physical deck Qs,Js'),
                 ([9954, 'reason'], 'table=Js,Qh seat=Js,Qh', 'table=Js,Qs seat=Js,Qs'),
                 ([9954, 'rendered_meaning'], 'table=Js,Qh seat=Js,Qh', 'table=Js,Qs seat=Js,Qs'),
                 ([9954, 'expectation_or_exception'], 'table=Js,Qh seat=Js,Qh', 'table=Js,Qs seat=Js,Qs'),
                 ([9955, 'reason'], 'physical deck Qh,Js', 'physical deck Qs,Js'),
                 ([9955, 'rendered_meaning'], 'physical deck Qh,Js', 'physical deck Qs,Js'),
                 ([9955, 'expectation_or_exception'], 'physical deck Qh,Js', 'physical deck Qs,Js'),
                 ([9976, 'reason'], 'table=Js,Qh seat=Js,Qh', 'table=Js,Qs seat=Js,Qs'),
                 ([9976, 'rendered_meaning'], 'table=Js,Qh seat=Js,Qh', 'table=Js,Qs seat=Js,Qs'),
                 ([9976, 'expectation_or_exception'], 'table=Js,Qh seat=Js,Qh', 'table=Js,Qs seat=Js,Qs'),
                 ([9977, 'reason'], 'physical deck Qh,Js', 'physical deck Qs,Js'),
                 ([9977, 'rendered_meaning'], 'physical deck Qh,Js', 'physical deck Qs,Js'),
                 ([9977, 'expectation_or_exception'], 'physical deck Qh,Js', 'physical deck Qs,Js'),
                 ([9998, 'reason'], 'table=Js,Qh seat=Js,Qh', 'table=Js,Qs seat=Js,Qs'),
                 ([9998, 'rendered_meaning'], 'table=Js,Qh seat=Js,Qh', 'table=Js,Qs seat=Js,Qs'),
                 ([9998, 'expectation_or_exception'], 'table=Js,Qh seat=Js,Qh', 'table=Js,Qs seat=Js,Qs'),
                 ([9999, 'reason'], 'physical deck Qh,Js', 'physical deck Qs,Js'),
                 ([9999, 'rendered_meaning'], 'physical deck Qh,Js', 'physical deck Qs,Js'),
                 ([9999, 'expectation_or_exception'], 'physical deck Qh,Js', 'physical deck Qs,Js')]}
PKG1_LEDGER_IDENTITIES = {9844: {'task_id': 'hand_discipline_buckets_borderline',
        'phase': 'authored/drill',
        'step_phase_variant': 'authored/drill',
        'invariant': 'D5.hero_representation'},
 9845: {'task_id': 'hand_discipline_buckets_borderline',
        'phase': 'authored/drill',
        'step_phase_variant': 'authored/drill',
        'invariant': 'D5.deck_unique'},
 9866: {'task_id': 'hand_discipline_buckets_borderline',
        'phase': 'teaching/0/raw',
        'step_phase_variant': 'teaching/0/raw',
        'invariant': 'D5.hero_representation'},
 9867: {'task_id': 'hand_discipline_buckets_borderline',
        'phase': 'teaching/0/raw',
        'step_phase_variant': 'teaching/0/raw',
        'invariant': 'D5.deck_unique'},
 9888: {'task_id': 'hand_discipline_buckets_borderline',
        'phase': 'teaching/0/projected',
        'step_phase_variant': 'teaching/0/projected',
        'invariant': 'D5.hero_representation'},
 9889: {'task_id': 'hand_discipline_buckets_borderline',
        'phase': 'teaching/0/projected',
        'step_phase_variant': 'teaching/0/projected',
        'invariant': 'D5.deck_unique'},
 9910: {'task_id': 'hand_discipline_buckets_borderline',
        'phase': 'decision',
        'step_phase_variant': 'decision',
        'invariant': 'D5.hero_representation'},
 9911: {'task_id': 'hand_discipline_buckets_borderline',
        'phase': 'decision',
        'step_phase_variant': 'decision',
        'invariant': 'D5.deck_unique'},
 9932: {'task_id': 'hand_discipline_buckets_borderline',
        'phase': 'feedback/strong',
        'step_phase_variant': 'feedback/strong',
        'invariant': 'D5.hero_representation'},
 9933: {'task_id': 'hand_discipline_buckets_borderline',
        'phase': 'feedback/strong',
        'step_phase_variant': 'feedback/strong',
        'invariant': 'D5.deck_unique'},
 9954: {'task_id': 'hand_discipline_buckets_borderline',
        'phase': 'feedback/medium',
        'step_phase_variant': 'feedback/medium',
        'invariant': 'D5.hero_representation'},
 9955: {'task_id': 'hand_discipline_buckets_borderline',
        'phase': 'feedback/medium',
        'step_phase_variant': 'feedback/medium',
        'invariant': 'D5.deck_unique'},
 9976: {'task_id': 'hand_discipline_buckets_borderline',
        'phase': 'feedback/trash',
        'step_phase_variant': 'feedback/trash',
        'invariant': 'D5.hero_representation'},
 9977: {'task_id': 'hand_discipline_buckets_borderline',
        'phase': 'feedback/trash',
        'step_phase_variant': 'feedback/trash',
        'invariant': 'D5.deck_unique'},
 9998: {'task_id': 'hand_discipline_buckets_borderline',
        'phase': 'review',
        'step_phase_variant': 'review',
        'invariant': 'D5.hero_representation'},
 9999: {'task_id': 'hand_discipline_buckets_borderline',
        'phase': 'review',
        'step_phase_variant': 'review',
        'invariant': 'D5.deck_unique'}}


# Exact task-local W01 Button and postflop option explanations.
W01_POSITION_REVISION = "W01_POSITION_OPTION_FEEDBACK"
W01_POSITION_PRODUCER_REVISION = {'source_revision': 'e1171c9d2c0142d7c281fab335d3c035cb210145',
 'state_sha256': 'a9e29e8c43cd7f446d24e94979698c07e4fe8533f77d8bb99973838092f46baa',
 'factory_sha256': 'c9386ad268d84f7469727f6fb4dc4f6eb2e771fd8d3f91d4169d1d31f727016b'}
W01_POSITION_CAPTURE_SHA256 = {'choice-identity.json': 'c8d63188ded16990ba2135ccd7952b9e98d3f7b7ae338891bab9a28705999564',
 'learning-contract.json': 'fb5f931f806fe80596b78f288b31b9f9241be5ad2e95619a49aba2381bef8b12',
 'ledger.json': 'f9a44a4c528ca0387658fd14a6d934f51e3105af457f572938c9a1e883023821',
 'runtime-inputs.json': 'a8963ef7dc429e4acbca06b695d8621388d8e7b664e6a725e4742a647db6dac5',
 'source-fingerprints.json': '468e7edb9f3031263e2055b3946425e7d6bf1a87580272ece75d5efc80c26198'}
W01_POSITION_CAPTURE_LEAVES = {'runtime-inputs.json': [(['positions_theory', 'options', 0, 'reason'],
                          'UTG acts before HJ, CO, and BTN in preflop order.',
                          'UTG is an early position, not the dealer button.'),
                         (['positions_theory', 'options', 1, 'reason'],
                          'BB acts after BTN preflop, so it is not next here.',
                          'BB is the big blind, not the dealer button.'),
                         (['positions_theory', 'options', 2, 'reason'],
                          'After UTG, HJ, and CO, BTN acts before SB and BB.',
                          'BTN marks the dealer button in this six-seat table.'),
                         (['positions_review', 'options', 0, 'reason'],
                          'UTG acts before HJ, CO, and BTN in preflop order.',
                          'UTG acts before BTN after the flop in this six-seat hand.'),
                         (['positions_review', 'options', 1, 'reason'],
                          'BB acts after BTN preflop, so it is not next here.',
                          'BB acts before BTN after the flop in this six-seat hand.'),
                         (['positions_review', 'options', 2, 'reason'],
                          'After UTG, HJ, and CO, BTN acts before SB and BB.',
                          'BTN acts last after the flop in this six-seat hand.')],
 'source-fingerprints.json': [(['positions_theory', 'fingerprint'],
                               '9d7cbd60701adfde1d728fd95293d9fccf2100297eed1e65e5417cd9455a0c1a',
                               '491e226a7f75e24333de616beddb342b381ddb257e17f8aa46dd7d424095a11e'),
                              (['positions_review', 'fingerprint'],
                               '0b87ad231ce697c4aa3a27cf3ca2536d9bfc6173696aa058a908188b266d748f',
                               '5f82d32f64c23407a3685a0870d1c062ed6fcb0cc0ac4b79236840c268547877')]}


# Exact context clarification for two existing W3 position recaps.
W3_RECAP_REVISION = "W3_POSTFLOP_RECAP_CONTEXT"
W3_RECAP_PRODUCER_REVISION = {'source_revision': '6afb991a0d1bb3141d98a1240d9f636f44254978',
 'state_sha256': '1d8a7c148b4bd320a8f9f2c7373135cfea8eaf9171ac272359dd007148626b34',
 'factory_sha256': 'c9386ad268d84f7469727f6fb4dc4f6eb2e771fd8d3f91d4169d1d31f727016b'}
W3_RECAP_CAPTURE_SHA256 = {'choice-identity.json': 'c8d63188ded16990ba2135ccd7952b9e98d3f7b7ae338891bab9a28705999564',
 'learning-contract.json': 'fb5f931f806fe80596b78f288b31b9f9241be5ad2e95619a49aba2381bef8b12',
 'ledger.json': 'f9a44a4c528ca0387658fd14a6d934f51e3105af457f572938c9a1e883023821',
 'runtime-inputs.json': '46aa4511a4760592dc2dec0263d21c2fb20d451c332ed64e60dcbd638b984dda',
 'source-fingerprints.json': 'fd79ac0ac07e2c7ecb7cd2706a088d719faae8ab30d9bd0db803a471f59ff4d8'}
W3_RECAP_CAPTURE_LEAVES = {'runtime-inputs.json': [(['button_advantage_button_recap', 'hint'],
                          'A later seat usually has more information before choosing.',
                          'Compare the live-seat order after the flop.'),
                         (['button_advantage_button_recap', 'question'],
                          'Which seat usually sees more first?',
                          'Which seat acts last after the flop here?'),
                         (['button_advantage_button_recap', 'options', 0, 'reason'],
                          'UTG acts before HJ, CO, and BTN in preflop order.',
                          'UTG acts before BTN after the flop on this six-seat table.'),
                         (['button_advantage_button_recap', 'options', 1, 'reason'],
                          'After UTG, HJ, and CO, BTN acts before SB and BB.',
                          'BTN acts last after the flop on this six-seat table.'),
                         (['button_advantage_button_recap', 'options', 2, 'reason'],
                          'BB acts after BTN preflop, so it is not next here.',
                          'BB acts before BTN after the flop on this six-seat table.'),
                         (['early_vs_late_w2_position_recap', 'hint'],
                          'A later seat usually has more information before choosing.',
                          'Compare the live-seat order after the flop.'),
                         (['early_vs_late_w2_position_recap', 'question'],
                          'Which seat usually sees more first?',
                          'Which seat acts last after the flop here?'),
                         (['early_vs_late_w2_position_recap', 'options', 0, 'reason'],
                          'UTG acts before HJ, CO, and BTN in preflop order.',
                          'UTG acts before BTN after the flop on this six-seat table.'),
                         (['early_vs_late_w2_position_recap', 'options', 1, 'reason'],
                          'After UTG, HJ, and CO, BTN acts before SB and BB.',
                          'BTN acts last after the flop on this six-seat table.'),
                         (['early_vs_late_w2_position_recap', 'options', 2, 'reason'],
                          'BB acts after BTN preflop, so it is not next here.',
                          'BB acts before BTN after the flop on this six-seat table.')],
 'source-fingerprints.json': [(['button_advantage_button_recap', 'fingerprint'],
                               '8eca9ad0f31b6d25e60de93e409ae422567a3c796f4d3e0e2a39e1ee9efe6d85',
                               '7b99c3fecdd489d5554704e7b615f321c0fc901e0b66b74e76e182c842307188'),
                              (['early_vs_late_w2_position_recap', 'fingerprint'],
                               'bd53d2b91c108ef96d88f29ec636389c7dc8b5bc26dacb9dd253f3bccd29218c',
                               '413056256132a36fd9a683665a7f6b79218d5df21b6dc9b2773f847bf5b3cf5b')]}


# Literal ATo teaching alignment only; original authoring and every earlier pin remain unchanged.
W3_ATO_TEACHING_REVISION = "W3_ATO_TEACHING_FACT_ALIGNMENT"
W3_ATO_TEACHING_PRODUCER_REVISION = {'source_revision': 'ada355a15faabcb29bd6fbad3ff7a79caff58d09',
 'state_sha256': 'f0037dc13e6ea3478008620e9b1b75d14c7eeaa70e22887a67851718e9bc2947',
 'factory_sha256': 'c9386ad268d84f7469727f6fb4dc4f6eb2e771fd8d3f91d4169d1d31f727016b'}
W3_ATO_TEACHING_CAPTURE_SHA256 = {'runtime-inputs.json': '3fb8c1633d446b025866538ca539cf8ff051590694f7b53f73d531d2c1d637c4',
 'source-fingerprints.json': 'fd79ac0ac07e2c7ecb7cd2706a088d719faae8ab30d9bd0db803a471f59ff4d8',
 'choice-identity.json': 'c8d63188ded16990ba2135ccd7952b9e98d3f7b7ae338891bab9a28705999564',
 'learning-contract.json': 'fb5f931f806fe80596b78f288b31b9f9241be5ad2e95619a49aba2381bef8b12',
 'ledger.json': 'f9a44a4c528ca0387658fd14a6d934f51e3105af457f572938c9a1e883023821'}
W3_ATO_TEACHING_CAPTURE_LEAVES = {'runtime-inputs.json': [(['same_hand_different_seat_same_hand_late_open',
                           'teaching',
                           0,
                           'title'],
                          'Late playable hand.',
                          'Read the displayed hand and seat.'),
                         (['same_hand_different_seat_same_hand_late_open',
                           'teaching',
                           0,
                           'body'],
                          'KTs on the Button is playable when nobody entered.',
                          'ATo means ace-ten offsuit. The displayed cards are '
                          'the ace of diamonds and ten of clubs. Read this '
                          'hand with the Button seat and unopened-pot '
                          'context.'),
                         (['position_apply_late_open', 'teaching', 0, 'title'],
                          'Late playable hand.',
                          'Read the displayed hand and seat.'),
                         (['position_apply_late_open', 'teaching', 0, 'body'],
                          'KTs on the Button is playable when nobody entered.',
                          'ATo means ace-ten offsuit. The displayed cards are '
                          'the ace of diamonds and ten of clubs. Read this '
                          'hand with the Button seat and unopened-pot '
                          'context.'),
                         (['position_checkpoint_position_checkpoint_late_open',
                           'teaching',
                           0,
                           'title'],
                          'Late playable hand.',
                          'Read the displayed hand and seat.'),
                         (['position_checkpoint_position_checkpoint_late_open',
                           'teaching',
                           0,
                           'body'],
                          'KTs on the Button is playable when nobody entered.',
                          'ATo means ace-ten offsuit. The displayed cards are '
                          'the ace of diamonds and ten of clubs. Read this '
                          'hand with the Button seat and unopened-pot '
                          'context.')]}


# Align two existing action assessments with their inherited action question.
W3_RECAP_PROMPT_REVISION = "W3_RECAP_ACTION_PROMPT_ALIGNMENT"
W3_RECAP_PROMPT_PRODUCER_REVISION = {'source_revision': '678a790d1c9c20a736c250787625da51d5fc3f2e',
 'state_sha256': '67e1f8ec174b58eb7e7de8f3638b63210cff5472660ed95dc2702f6a6ec71f89',
 'factory_sha256': 'c9386ad268d84f7469727f6fb4dc4f6eb2e771fd8d3f91d4169d1d31f727016b'}
W3_RECAP_PROMPT_CAPTURE_SHA256 = {'runtime-inputs.json': 'a6cfe262deb0bfdfeb0b718dd729732d27607e1ca6c349b3c00f2675fdcbffba',
 'source-fingerprints.json': '4b3af81fb132315d73c2c43f843c28c6a70ca9397dae7c088a912bfdaaf1f012',
 'choice-identity.json': 'c8d63188ded16990ba2135ccd7952b9e98d3f7b7ae338891bab9a28705999564',
 'learning-contract.json': 'fb5f931f806fe80596b78f288b31b9f9241be5ad2e95619a49aba2381bef8b12',
 'ledger.json': 'f9a44a4c528ca0387658fd14a6d934f51e3105af457f572938c9a1e883023821'}
W3_RECAP_PROMPT_CAPTURE_LEAVES = {'runtime-inputs.json': [(['position_apply_recap', 'question'],
                          'What should you check after the bucket?',
                          'What is the simple action?'),
                         (['position_checkpoint_position_checkpoint_review',
                           'question'],
                          'What should you check after the bucket?',
                          'What is the simple action?')],
 'source-fingerprints.json': [(['position_apply_recap', 'fingerprint'],
                               '1f82f0f3f797b73969cc3d9e6df57e43ee220e5df8d9217aac879f00429c045b',
                               '72242d32d6cc24415d687747308418c599efc5523363d0705c12ae192db9b012'),
                              (['position_checkpoint_position_checkpoint_review',
                                'fingerprint'],
                               '51efd5c94ce391121d3dc6c0a2fc3c2211da8d32c470ef20be484bafca8f7a5d',
                               'a72741f70c4bd15cdfc8f257a3d35215f46fbc246e024d7cc565989d4787d92a')]}


# Reviewed factual revision: exact source and whole-capture pins from the
# immutable root-produced W5 catalog; reconstruct the prior admitted capture.
W5_FACTUAL_REVISION = 'W5_REVIEWED_FACTUAL_TEXT'
W5_FACTUAL_PRODUCER_REVISION = {
    'source_revision': 'afd761cdb345792f3d9fb34ad1ca2ac06304078b',
    'state_sha256': '060fe41d05761315fce1515d535dab429d7db0bf224ae69b81e50517d961affe',
    'factory_sha256': 'c9386ad268d84f7469727f6fb4dc4f6eb2e771fd8d3f91d4169d1d31f727016b',
}
W5_FACTUAL_CAPTURE_SHA256 = {
    'choice-identity.json': 'c8d63188ded16990ba2135ccd7952b9e98d3f7b7ae338891bab9a28705999564',
    'learning-contract.json': 'fb5f931f806fe80596b78f288b31b9f9241be5ad2e95619a49aba2381bef8b12',
    'ledger.json': 'f9a44a4c528ca0387658fd14a6d934f51e3105af457f572938c9a1e883023821',
    'runtime-inputs.json': '03cfd5297a050ac6b944cb601a950a0a40be3f4403bac3a7fbad0386d49286df',
    'source-fingerprints.json': 'd5f4538ab6ed478981292a96efd7461a841558f999e0b0be6505af4abf4490b4',
}
W5_FACTUAL_CAPTURE_LEAVES = {
    'runtime-inputs.json': [
        (['straight_draws_w5_gap_board', 'caption'],
         'A-Q-4 has large rank gaps.', 'A-K-4 has large rank gaps.'),
        (['outs_improvement_w5_straight_out', 'options', 0, 'reason'],
         'With 5-6-7-8 on board, any 9 completes the straight.',
         'Private 5-6, shared board cards 7-8: any 9 completes the straight.'),
    ],
    'source-fingerprints.json': [
        (['straight_draws_w5_gap_board', 'fingerprint'],
         'a429177581e597e1c181ffe2f03786c3829b8cf4d750123c19ebfbea5a799563',
         '30513654fee320cb6896659ca544ca7789c2737a44ed86eb7197786e9c8b0a5b'),
        (['outs_improvement_w5_straight_out', 'fingerprint'],
         'ebf8b44cf0fa44519add67ed7feeafaca8dae4de3e4c2993c17810ddccd8c0df',
         'fea2696fe977d743583d645d3a18be52d8a8f581ae76c9cc992e8fd31ad7f7eb'),
    ],
}
W5_FACTUAL_PROTECTED_FINGERPRINTS = {'same_hand_different_seat_same_hand_late_open': '5731c58b4fbc4bce4a7ded4f9b130afb4e8f2b900c68ad52bc4ace914adc9805',
 'position_apply_late_open': '834529b14664a30cf01b7b00c50bb8e191762a9c73de066127c5e78aa7d92b9f',
 'position_checkpoint_position_checkpoint_late_open': '9652fa85867d717e25fbb5ea67dedace383f91698f93477bcb76a092706023ee',
 'position_apply_recap': '72242d32d6cc24415d687747308418c599efc5523363d0705c12ae192db9b012',
 'position_checkpoint_position_checkpoint_review': 'a72741f70c4bd15cdfc8f257a3d35215f46fbc246e024d7cc565989d4787d92a'}
W5_FACTUAL_PROTECTED_RUNTIME_SHA256 = {'same_hand_different_seat_same_hand_late_open': '926b211be6180986efd9f4d00f4cead111849df00d8ea0845da8ef4e0b4cdea8',
 'position_apply_late_open': '926b211be6180986efd9f4d00f4cead111849df00d8ea0845da8ef4e0b4cdea8',
 'position_checkpoint_position_checkpoint_late_open': '926b211be6180986efd9f4d00f4cead111849df00d8ea0845da8ef4e0b4cdea8',
 'position_apply_recap': '2843ead970c11961bebb0e25044e984ecc5590195da243a9c0e62dfa8be52d05',
 'position_checkpoint_position_checkpoint_review': '2843ead970c11961bebb0e25044e984ecc5590195da243a9c0e62dfa8be52d05'}


def _require_w5_factual_admission():
    """Unfilled proposals and changed invariant captures cannot admit W5."""
    source = W5_FACTUAL_PRODUCER_REVISION
    if (not re.fullmatch(r'[0-9a-f]{40}', str(source.get('source_revision')))
        or source.get('state_sha256') != '060fe41d05761315fce1515d535dab429d7db0bf224ae69b81e50517d961affe'
        or source.get('factory_sha256') != W3_RECAP_PROMPT_PRODUCER_REVISION['factory_sha256']
        or set(W5_FACTUAL_CAPTURE_SHA256) != set(W3_RECAP_PROMPT_CAPTURE_SHA256)
        or any(not re.fullmatch(r'[0-9a-f]{64}', str(value))
               for value in W5_FACTUAL_CAPTURE_SHA256.values())
        or any(W5_FACTUAL_CAPTURE_SHA256[name] != W3_RECAP_PROMPT_CAPTURE_SHA256[name]
               for name in ('choice-identity.json', 'learning-contract.json', 'ledger.json'))
        or any(not re.fullmatch(r'[0-9a-f]{64}', str(current)) or current == prior
               for _, prior, current in W5_FACTUAL_CAPTURE_LEAVES['source-fingerprints.json'])):
        raise SystemExit('W5 factual admission is unfinalized or inconsistent')


# Exact source/capture pins and four ledger labels admitted by root review.
W24_CONTEXT_REVISION = 'W24_REVIEWED_CONTEXT_RECAP'
W24_CONTEXT_TASK_ID = 'same_hand_different_seat_w3_same_hand_recap'
W24_CONTEXT_PRODUCER_REVISION = {
    'source_revision': '83450b0376135922ff32f4a2af8766bcf2820418',
    'state_sha256': 'f0e0cdce91c4805c3b48691b6e5c8f020119cfe57abcc45aff24a472e496d36c',
    'factory_sha256': 'c9386ad268d84f7469727f6fb4dc4f6eb2e771fd8d3f91d4169d1d31f727016b',
    # Separate source-origin packet pin: typed producer receipt lacks Runner.
    'runner_sha256': 'ce7c84d43281783148ae81c9c50f628865ef3f35769461d21bf9bd3c83446fad',
}
W24_CONTEXT_CAPTURE_SHA256 = {
    'choice-identity.json': '9b48c0554054630384f4085bbb37b01f21b2ebb27fa8d90f18f13211f94ed998',
    'learning-contract.json': '37df4a54ea23a88ab9f567d6f863277e89df20be50dcad628ef4da88cdee5646',
    'ledger.json': 'c18b7fe1ca87e826908f703c4ce1f408bc62a8ce710183178ced8435585988d4',
    'runtime-inputs.json': '0f9978e7d7d6c4f81394bbd3b609ec2ef2f2f81e475f0b7db4cd221935cd63fc',
    'source-fingerprints.json': 'a1968092b92d488770fcee798569d87845f03cfd1c1041458b68ad100202bccf',
}
# Four reviewed scalar phase-ID renames; no status/witness/row allowance.
W24_CONTEXT_LEDGER_REVIEW = 'EXACT_FOUR_PHASE_LEAVES_CONFIRMED'
W24_CONTEXT_CAPTURE_LEAVES = {'learning-contract.json': [(['same_hand_different_seat_w3_same_hand_recap', 'options'],
                             [{'id': 'utg',
                               'correct': False,
                               'quality': 'wrong',
                               'seat': 'utg',
                               'repairSeats': [],
                               'repairCards': [],
                               'repairLabels': []},
                              {'id': 'btn',
                               'correct': True,
                               'quality': 'correct',
                               'seat': 'btn',
                               'repairSeats': [],
                               'repairCards': [],
                               'repairLabels': []}],
                             [{'id': 'one_answer',
                               'correct': False,
                               'quality': 'wrong',
                               'seat': None,
                               'repairSeats': [],
                               'repairCards': [],
                               'repairLabels': []},
                              {'id': 'framework',
                               'correct': True,
                               'quality': 'correct',
                               'seat': None,
                               'repairSeats': [],
                               'repairCards': [],
                               'repairLabels': []}])],
 'choice-identity.json': [(['same_hand_different_seat_w3_same_hand_recap'],
                           [['utg', 'UTG', False, 'wrong', 'BTN'], ['btn', 'BTN', True, 'correct', 'BTN']],
                           [['one_answer', 'One answer per hand', False, 'wrong', 'Bucket, seat, frame'],
                            ['framework', 'Bucket, seat, frame', True, 'correct', 'Bucket, seat, frame']])],
 'runtime-inputs.json': [(['same_hand_different_seat_w3_same_hand_recap', 'options'],
                          [{'id': 'utg',
                            'label': 'UTG',
                            'amount': '',
                            'reason': 'UTG is early and has less information.',
                            'preferred': 'BTN'},
                           {'id': 'btn',
                            'label': 'BTN',
                            'amount': '',
                            'reason': 'BTN is late and often acts last after the flop.',
                            'preferred': 'BTN'}],
                          [{'id': 'one_answer',
                            'label': 'One answer per hand',
                            'amount': '',
                            'reason': 'One hand can change action when position or action frame changes.',
                            'preferred': 'Bucket, seat, frame'},
                           {'id': 'framework',
                            'label': 'Bucket, seat, frame',
                            'amount': '',
                            'reason': 'The reusable preflop read is hand bucket, position, and action frame '
                                      'before choosing.',
                            'preferred': 'Bucket, seat, frame'}])],
 'source-fingerprints.json': [(['same_hand_different_seat_w3_same_hand_recap', 'fingerprint'],
                               '13dd28c27603ef3aed59e6dc814ca85952a7e61cec6bebfda26ba16c1e643404',
                               '01dbd18c3bb86b31f053111959738cb6767a459b732438c7bf2bcf5ba0960c9c')],
 'ledger.json': [([15979, 'phase'], 'feedback/utg', 'feedback/one_answer'),
                 ([15979, 'step_phase_variant'], 'feedback/utg', 'feedback/one_answer'),
                 ([15980, 'phase'], 'feedback/btn', 'feedback/framework'),
                 ([15980, 'step_phase_variant'], 'feedback/btn', 'feedback/framework')]}


def _require_w24_context_admission():
    source = W24_CONTEXT_PRODUCER_REVISION
    if (not re.fullmatch(r'[0-9a-f]{40}', str(source.get('source_revision')))
        or source.get('source_revision') == W5_FACTUAL_PRODUCER_REVISION['source_revision']
        or any(not re.fullmatch(r'[0-9a-f]{64}', str(source.get(key))) for key in ('state_sha256', 'runner_sha256'))
        or source.get('state_sha256') == W5_FACTUAL_PRODUCER_REVISION['state_sha256']
        or source.get('runner_sha256') == 'ad14bd86c7770e1810b2f5d3149c5a4fb7a470b5dbcdeb793c248aa5cc30e118'
        or source.get('factory_sha256') != W5_FACTUAL_PRODUCER_REVISION['factory_sha256']
        or set(W24_CONTEXT_CAPTURE_SHA256) != set(W5_FACTUAL_CAPTURE_SHA256)
        or any(not re.fullmatch(r'[0-9a-f]{64}', str(value)) or value == W5_FACTUAL_CAPTURE_SHA256[name]
               for name, value in W24_CONTEXT_CAPTURE_SHA256.items())
        or any(not re.fullmatch(r'[0-9a-f]{64}', str(current)) or current == prior
               for _, prior, current in W24_CONTEXT_CAPTURE_LEAVES['source-fingerprints.json'])
        or W24_CONTEXT_LEDGER_REVIEW != 'EXACT_FOUR_PHASE_LEAVES_CONFIRMED'):
        raise SystemExit('W24 context admission is unfinalized or inconsistent')


# New explicit W01 contexts: exact independently reviewed source/capture delta.
# Original authoring origin, all predecessor pins and raw captures stay intact.
WP03_CONTEXT_REVISION = 'W01_REVIEWED_EXPLICIT_MECHANICAL_CONTEXTS_V2_15'
WP03_CONTEXT_PRODUCER_REVISION = {'source_revision': '16e42ac9c48727a73489dd3ad0326a417024498d',
 'state_sha256': '8093daf2c0d9626e0b19e880fe09d45f0164d8e3082dee4e67c72ffdbffd0ae2',
 'factory_sha256': 'c9386ad268d84f7469727f6fb4dc4f6eb2e771fd8d3f91d4169d1d31f727016b',
 'runner_sha256': 'f691135ab617db9b3b806fc98d47fcf8f853fe97f9c5565d27092f704f4b4e5f',
 'source_proof_sha256': 'b0a3151d85d49149ca4f3beefe91d070c9d6c5e5b5d63c48020287bec2cf2b57',
 'street_replay_sha256': 'abe0a0754633390f99fe219b1e6213299878a3fb1a65aadac445840f4ced6bdf',
 'repair_gap_sha256': '1e24cdbe4b4fbf1af9104d9949834a5acf65789247e6db31d31caeb825627a5a'}
WP03_CONTEXT_CAPTURE_SHA256 = {'learning-contract.json': '37df4a54ea23a88ab9f567d6f863277e89df20be50dcad628ef4da88cdee5646',
 'choice-identity.json': '3d04f53c19ccd152e8044938fc9912af27bac0bd4427e8044425b824110b0a5d',
 'runtime-inputs.json': 'c65325d08650cf8c267ae4ee4cc7cda521a35b98c256dcce20050175f1a7ca7c',
 'source-fingerprints.json': '6288843805fee1529f89a6882046a79545695c77e70cd9a0defc1fe9ca9475f9',
 'ledger.json': 'b7ccf7b8304db06abe35b1a0192928e1ea8d1f7e4dd47d5288f9af85d7c65a27'}
WP03_CONTEXT_FIXTURE = pathlib.Path(__file__).resolve().parents[1] / (
    'test/tools/fixtures/table_truth_wp03_explicit_contexts_v1.json'
)
WP03_CONTEXT_FIXTURE_SHA256 = '1156f92b96f7464fa3f868f77bc45b36d6b3a931d45d83f6e0ea64c3009b68c0'
WP03_CHECK_EXTENSION_FIXTURE = pathlib.Path(__file__).resolve().parents[1] / (
    'test/tools/fixtures/table_truth_wp03_check_mechanics_v2.json'
)
WP03_CHECK_EXTENSION_FIXTURE_SHA256 = 'd39db69f36e9e933588b3331c48fdda380b7e38a329a5f023d33d38191de82f7'
WP03_CONTEXT_LEDGER_REVIEW = 'EXACT_ELEVEN_SOURCE_CONTEXT_GROUPS_CONFIRMED'


def _load_wp03_context_fixture():
    """Immutable predecessor metadata only; never a physical-source admission."""
    source = WP03_CONTEXT_PRODUCER_REVISION
    if (not re.fullmatch(r'[0-9a-f]{40}', str(source.get('source_revision')))
        or any(not re.fullmatch(r'[0-9a-f]{64}', str(source.get(key)))
               for key in ('state_sha256', 'runner_sha256', 'source_proof_sha256', 'street_replay_sha256', 'repair_gap_sha256'))
        or source.get('factory_sha256') != W24_CONTEXT_PRODUCER_REVISION['factory_sha256']
        or source.get('state_sha256') == W24_CONTEXT_PRODUCER_REVISION['state_sha256']
        or set(WP03_CONTEXT_CAPTURE_SHA256) != set(W24_CONTEXT_CAPTURE_SHA256)
        or any(not re.fullmatch(r'[0-9a-f]{64}', str(value))
               for value in WP03_CONTEXT_CAPTURE_SHA256.values())
        or WP03_CONTEXT_LEDGER_REVIEW != 'EXACT_ELEVEN_SOURCE_CONTEXT_GROUPS_CONFIRMED'
        or hashlib.sha256(WP03_CONTEXT_FIXTURE.read_bytes()).hexdigest() != WP03_CONTEXT_FIXTURE_SHA256):
        raise SystemExit('WP03 explicit-context admission is unfinalized or inconsistent')
    # Keep the previously admitted thirteen-record fixture immutable. The
    # current family appends exactly two records; no earlier record is replaced.
    prior = json.loads(WP03_CONTEXT_FIXTURE.read_text())
    if hashlib.sha256(WP03_CHECK_EXTENSION_FIXTURE.read_bytes()).hexdigest() != WP03_CHECK_EXTENSION_FIXTURE_SHA256:
        raise SystemExit('WP03 Check extension fixture changed')
    extension = json.loads(WP03_CHECK_EXTENSION_FIXTURE.read_text())
    added_ids = {'actions_legal_context', 'actions_check_drill'}
    if (prior.get('schema') != 1 or len(prior.get('task_ids', [])) != 13
        or len(prior.get('ledger_groups', [])) != 9
        or extension.get('schema') != 1
        or extension.get('task_ids') != ['actions_legal_context', 'actions_check_drill']
        or extension.get('predecessor_fixture_sha256') != WP03_CONTEXT_FIXTURE_SHA256
        or extension.get('predecessor_capture_sha256') != prior.get('capture_sha256')
        or extension.get('current_source_origin_packet') != source
        or set(extension.get('task_changes', {})) != set(prior['task_changes'])
        or len(extension.get('ledger_groups', [])) != 2
        or {g['task_id'] for g in extension['ledger_groups']} != added_ids
        or added_ids.intersection(prior['task_ids'])):
        raise SystemExit('WP03 exact Check extension membership changed')
    fixture = copy.deepcopy(prior)
    fixture['capture_sha256'] = extension['capture_sha256']
    for name, changes in extension['task_changes'].items():
        expected_ids = added_ids if name in ('runtime-inputs.json', 'source-fingerprints.json') else set()
        if set(changes) != expected_ids or set(changes).intersection(fixture['task_changes'][name]):
            raise SystemExit('WP03 Check extension overwrites prior or unchanged records')
        fixture['task_changes'][name].update(copy.deepcopy(changes))
    fixture['task_ids'].extend(extension['task_ids'])
    fixture['ledger_groups'].extend(copy.deepcopy(extension['ledger_groups']))
    if (len(fixture['task_ids']) != 15 or len(fixture['ledger_groups']) != 11
        or fixture['capture_sha256'] != WP03_CONTEXT_CAPTURE_SHA256):
        raise SystemExit('WP03 current fifteen-context capture changed')
    return fixture


def _require_wp03_context_admission():
    fixture = _load_wp03_context_fixture()
    source = WP03_CONTEXT_PRODUCER_REVISION
    source_root = pathlib.Path(__file__).resolve().parents[1] / 'lib/ui_v2/act0_shell'
    for key, filename in (
        ('state_sha256', 'act0_shell_state_v1.dart'),
        ('factory_sha256', 'act0_asm05_authored_decision_truth_v1.dart'),
        ('runner_sha256', 'act0_lesson_runner_shell_v1.dart'),
        ('source_proof_sha256', 'act0_authored_source_proof_v1.dart'),
        ('street_replay_sha256', 'act0_street_replay_contract_v1.dart'),
        ('repair_gap_sha256', 'act0_repair_gap_adjudication_v1.dart'),
    ):
        if hashlib.sha256((source_root / filename).read_bytes()).hexdigest() != source[key]:
            raise SystemExit(f'WP03 source-origin packet bytes changed: {filename}')
    return fixture


def wp03_context_w24_capture(name, value):
    """Reconstruct W24 in memory; never edit current or historical captures.

    The existing TableTruth verifier owns applicability/statuses. This stage
    pins its actual output, including unresolved context, rather than declaring
    source-owned actor/stack operands certified by that older capture schema.
    """
    fixture = _require_wp03_context_admission()
    return _wp03_context_w24_capture_core(name, value, fixture)


def _wp03_context_w24_capture_core(name, value, fixture):
    """Pure literal inverse; callers must first admit their physical source."""
    result = copy.deepcopy(value)
    try:
        if _digest(result) != WP03_CONTEXT_CAPTURE_SHA256[name]:
            raise ValueError('whole current WP03 capture')
        if name == 'ledger.json':
            groups = {row['task_id']: row for row in fixture['ledger_groups']}
            rebuilt = []
            seen = set()
            index = 0
            while index < len(result):
                task_id = result[index]['task_id']
                end = index + 1
                while end < len(result) and result[end]['task_id'] == task_id:
                    end += 1
                if task_id in seen:
                    raise ValueError('noncontiguous or duplicate task group')
                seen.add(task_id)
                rows = result[index:end]
                if task_id in groups:
                    admitted = groups[task_id]
                    if (len(rows) != admitted['current_count']
                        or _digest(rows) != admitted['current_sha256']
                        or dict(collections.Counter(row['status'] for row in rows)) != admitted['current_statuses']
                        or any(row['task_id'] != task_id for row in admitted['prior_rows'])):
                        raise ValueError('exact ledger identity/status/witness group')
                    rows = copy.deepcopy(admitted['prior_rows'])
                rebuilt.extend(rows)
                index = end
            if not set(groups) <= seen:
                raise ValueError('missing admitted ledger group')
            result = rebuilt
        else:
            for task_id, change in fixture['task_changes'][name].items():
                if result[task_id] != change['current']:
                    raise ValueError('literal current WP03 task record')
                result[task_id] = copy.deepcopy(change['prior'])
        if _digest(result) != W24_CONTEXT_CAPTURE_SHA256[name]:
            raise ValueError('whole reconstructed W24 capture')
    except (KeyError, TypeError, IndexError, ValueError) as error:
        raise SystemExit(f'WP03 explicit-context exact revision mismatch: {name}') from error
    return result


W4_PURPOSE_TEACHING_REVISION = 'W4_REVIEWED_PURPOSE_INTRO_TEACHING_V1'
W4_PURPOSE_TEACHING_PRODUCER_REVISION = {
    **WP03_CONTEXT_PRODUCER_REVISION,
    'source_revision': '19b1f23145a8cddf0a95ce87c6588fe1047cd0bd',
    'state_sha256': '2872c28c67b536a7de6218e34f6365f30ecf8d970355e8b6ed5fd41297a41ae8',
}
W4_PURPOSE_TEACHING_CAPTURE_SHA256 = {
    **WP03_CONTEXT_CAPTURE_SHA256,
    'runtime-inputs.json': 'b29f9a9e3b83c75659d83110caa8b476d79c7d1e21a39e64573e45d72fa6bc81',
}
W4_PURPOSE_TEACHING_FIXTURE = pathlib.Path(__file__).resolve().parents[1] / (
    'test/tools/fixtures/table_truth_w4_purpose_teaching_v1.json'
)
W4_PURPOSE_TEACHING_FIXTURE_SHA256 = '9736efd213d87678da7aa700a15c226d950c0b207de98f66b4ae9c8067d23265'


def _load_w4_purpose_teaching_fixture():
    """Immutable predecessor metadata; not a physical-current admission."""
    _load_wp03_context_fixture()
    source = W4_PURPOSE_TEACHING_PRODUCER_REVISION
    if (hashlib.sha256(W4_PURPOSE_TEACHING_FIXTURE.read_bytes()).hexdigest()
            != W4_PURPOSE_TEACHING_FIXTURE_SHA256):
        raise SystemExit('W4 purpose teaching fixture changed')
    fixture = json.loads(W4_PURPOSE_TEACHING_FIXTURE.read_text())
    if (fixture.get('schema') != 1
        or fixture.get('package') != 'WP03-W4-PURPOSE-INTRO-REPAIR-01'
        or fixture.get('task_id') != 'w4_purpose_intro'
        or fixture.get('changed_capture') != 'runtime-inputs.json'
        or fixture.get('changed_leaf') != ['teaching', 0, 'body']
        or fixture.get('current_source_origin_packet') != source
        or fixture.get('predecessor_revision') != WP03_CONTEXT_REVISION
        or fixture.get('predecessor_source_origin_packet') != WP03_CONTEXT_PRODUCER_REVISION
        or fixture.get('predecessor_capture_sha256') != WP03_CONTEXT_CAPTURE_SHA256
        or fixture.get('capture_sha256') != W4_PURPOSE_TEACHING_CAPTURE_SHA256
        or source != {**WP03_CONTEXT_PRODUCER_REVISION,
                      'source_revision': '19b1f23145a8cddf0a95ce87c6588fe1047cd0bd',
                      'state_sha256': '2872c28c67b536a7de6218e34f6365f30ecf8d970355e8b6ed5fd41297a41ae8'}):
        raise SystemExit('W4 purpose teaching exact revision metadata changed')
    prior, current = fixture['prior_record'], copy.deepcopy(fixture['current_record'])
    if (current['teaching'][0]['body'] !=
            'Name the bet purpose first. Value means worse hands can still call. '
            'A bluff tries to make better hands fold. Protection makes the next card cost money.'
        or prior['teaching'][0]['body'] !=
            'Name the bet purpose first. Value gets calls, bluff gets folds, '
            'protection makes the next card cost money.'):
        raise SystemExit('W4 purpose teaching literal body changed')
    current['teaching'][0]['body'] = prior['teaching'][0]['body']
    if current != prior:
        raise SystemExit('W4 purpose overlay changes more than one teaching body')
    for key, expected in (
        ('source_task_before', '7123d280b727bbc013389a187e55fc3f2dd48414edf7741092dbd782f781455e'),
        ('source_task_after', 'bb8fa089dbd88a043b57461ce69284ca228221ebeecead26f45a2cbb79ea3f58'),
    ):
        value = fixture.get(key)
        if not isinstance(value, str) or hashlib.sha256(value.encode()).hexdigest() != expected:
            raise SystemExit('W4 purpose immutable source binding changed')
    return fixture


def _require_w4_purpose_teaching_admission():
    """One closed current overlay; never rebind the sealed V2_15 producer."""
    fixture = _load_w4_purpose_teaching_fixture()
    source = W4_PURPOSE_TEACHING_PRODUCER_REVISION
    source_root = pathlib.Path(__file__).resolve().parents[1] / 'lib/ui_v2/act0_shell'
    for key, filename in (
        ('state_sha256', 'act0_shell_state_v1.dart'),
        ('factory_sha256', 'act0_asm05_authored_decision_truth_v1.dart'),
        ('runner_sha256', 'act0_lesson_runner_shell_v1.dart'),
        ('source_proof_sha256', 'act0_authored_source_proof_v1.dart'),
        ('street_replay_sha256', 'act0_street_replay_contract_v1.dart'),
        ('repair_gap_sha256', 'act0_repair_gap_adjudication_v1.dart'),
    ):
        if hashlib.sha256((source_root / filename).read_bytes()).hexdigest() != source[key]:
            raise SystemExit(f'W4 purpose physical source changed: {filename}')
    actual = (source_root / 'act0_shell_state_v1.dart').read_bytes()
    after, before = (fixture[key].encode() for key in ('source_task_after', 'source_task_before'))
    if (actual.count(after) != 1
        or hashlib.sha256(actual.replace(after, before, 1)).hexdigest()
            != WP03_CONTEXT_PRODUCER_REVISION['state_sha256']):
        raise SystemExit('W4 purpose task inverse does not restore exact V2_15 State')
    return fixture


def w4_purpose_teaching_wp03_capture(name, value):
    """Reverse the exact teaching leaf to all five sealed V2_15 captures."""
    fixture = _require_w4_purpose_teaching_admission()
    return _w4_purpose_teaching_wp03_capture_core(name, value, fixture)


def _w4_purpose_teaching_wp03_capture_core(name, value, fixture):
    """Pure inverse; callers first admit their own closed physical revision."""
    result = copy.deepcopy(value)
    try:
        if _digest(result) != W4_PURPOSE_TEACHING_CAPTURE_SHA256[name]:
            raise ValueError('whole current W4 teaching capture')
        if name == 'runtime-inputs.json':
            task_id = fixture['task_id']
            if result[task_id] != fixture['current_record']:
                raise ValueError('literal current W4 teaching task')
            result[task_id] = copy.deepcopy(fixture['prior_record'])
        if _digest(result) != WP03_CONTEXT_CAPTURE_SHA256[name]:
            raise ValueError('whole reconstructed V2_15 capture')
    except (KeyError, TypeError, IndexError, ValueError) as error:
        raise SystemExit(f'W4 purpose teaching exact capture mismatch: {name}') from error
    return result


FOLDED_BTN_REVISION = 'W01_REVIEWED_FOLDED_TO_BTN_MECHANICS_V1_3'
FOLDED_BTN_PRODUCER_REVISION = {
    **W4_PURPOSE_TEACHING_PRODUCER_REVISION,
    'source_revision': '6dd4e7e17237538430b43844a462cf15ac9dc7f7',
    'state_sha256': '36581ea5cec60798aac3a123a72e792af95a60cd5d5ce093543896227accd7d0',
}
FOLDED_BTN_CAPTURE_SHA256 = {
    **W4_PURPOSE_TEACHING_CAPTURE_SHA256,
    'runtime-inputs.json': '41020288736063ea86c892ede5c2a882c1ddd09cbd21e1cdad5881e6f0b6599c',
    'source-fingerprints.json': '3ff7c58ac38406b10dd5f6e69af048a2b14ebd9947e68c8c5d0705717f2b4816',
    'ledger.json': '02a4b1c62e20951fcb0ec1f2426be6bd22456c17e9cd540a37bf52d2f85b9cad',
}
FOLDED_BTN_FIXTURE = pathlib.Path(__file__).resolve().parents[1] / (
    'test/tools/fixtures/table_truth_folded_btn_mechanics_v1.json'
)
FOLDED_BTN_FIXTURE_SHA256 = '4312dce98c1da100258d54b89fb003c41a38d831ef76bee47a679f450d855350'
FOLDED_BTN_TASK_IDS = ('actions_theory', 'actions_raise_drill', 'actions_review')


def _require_folded_btn_admission():
    """Exact three task bindings and one helper, not a new strategy admission."""
    w4 = _load_w4_purpose_teaching_fixture()
    if hashlib.sha256(FOLDED_BTN_FIXTURE.read_bytes()).hexdigest() != FOLDED_BTN_FIXTURE_SHA256:
        raise SystemExit('Folded BTN fixture changed')
    fixture = json.loads(FOLDED_BTN_FIXTURE.read_text())
    source = FOLDED_BTN_PRODUCER_REVISION
    ids = set(FOLDED_BTN_TASK_IDS)
    if (fixture.get('schema') != 1
        or fixture.get('package') != 'WP03-W01-FOLDED-TO-BTN-MECHANICS-03'
        or fixture.get('task_ids') != list(FOLDED_BTN_TASK_IDS)
        or fixture.get('current_source_origin_packet') != source
        or fixture.get('predecessor_revision') != W4_PURPOSE_TEACHING_REVISION
        or fixture.get('predecessor_source_origin_packet') != W4_PURPOSE_TEACHING_PRODUCER_REVISION
        or fixture.get('predecessor_capture_sha256') != W4_PURPOSE_TEACHING_CAPTURE_SHA256
        or fixture.get('capture_sha256') != FOLDED_BTN_CAPTURE_SHA256
        or source != {**W4_PURPOSE_TEACHING_PRODUCER_REVISION,
                      'source_revision': '6dd4e7e17237538430b43844a462cf15ac9dc7f7',
                      'state_sha256': '36581ea5cec60798aac3a123a72e792af95a60cd5d5ce093543896227accd7d0'}
        or set(fixture.get('task_changes', {})) !=
            {'learning-contract.json', 'choice-identity.json', 'runtime-inputs.json', 'source-fingerprints.json'}
        or len(fixture.get('ledger_groups', [])) != 3
        or {g['task_id'] for g in fixture['ledger_groups']} != ids
        or [x['task_id'] for x in fixture.get('source_binding_changes', [])] != list(FOLDED_BTN_TASK_IDS)):
        raise SystemExit('Folded BTN closed revision metadata changed')
    for name, changes in fixture['task_changes'].items():
        expected = ids if name in ('runtime-inputs.json', 'source-fingerprints.json') else set()
        if set(changes) != expected:
            raise SystemExit('Folded BTN changes outside exact mechanical contexts')
    source_root = pathlib.Path(__file__).resolve().parents[1] / 'lib/ui_v2/act0_shell'
    for key, filename in (
        ('state_sha256', 'act0_shell_state_v1.dart'),
        ('factory_sha256', 'act0_asm05_authored_decision_truth_v1.dart'),
        ('runner_sha256', 'act0_lesson_runner_shell_v1.dart'),
        ('source_proof_sha256', 'act0_authored_source_proof_v1.dart'),
        ('street_replay_sha256', 'act0_street_replay_contract_v1.dart'),
        ('repair_gap_sha256', 'act0_repair_gap_adjudication_v1.dart'),
    ):
        if hashlib.sha256((source_root / filename).read_bytes()).hexdigest() != source[key]:
            raise SystemExit(f'Folded BTN physical source changed: {filename}')
    restored = (source_root / 'act0_shell_state_v1.dart').read_bytes()
    for change in fixture['source_binding_changes']:
        current, prior = change['current'].encode(), change['prior'].encode()
        if not current or restored.count(current) != 1:
            raise SystemExit('Folded BTN source binding inverse is not unique')
        restored = restored.replace(current, prior, 1)
    helper = fixture['source_helper_added'].encode()
    if not helper or restored.count(helper) != 1:
        raise SystemExit('Folded BTN added helper inverse is not unique')
    restored = restored.replace(helper, b'', 1)
    if hashlib.sha256(restored).hexdigest() != W4_PURPOSE_TEACHING_PRODUCER_REVISION['state_sha256']:
        raise SystemExit('Folded BTN inverse does not restore entire sealed W4 State')
    after, before = (w4[key].encode() for key in ('source_task_after', 'source_task_before'))
    if (restored.count(after) != 1
        or hashlib.sha256(restored.replace(after, before, 1)).hexdigest()
            != WP03_CONTEXT_PRODUCER_REVISION['state_sha256']):
        raise SystemExit('Folded BTN ancestor inverse does not restore sealed V2_15 State')
    return fixture


def folded_btn_w4_capture(name, value):
    """Reverse only three literal records/groups to all five sealed W4 captures."""
    fixture = _require_folded_btn_admission()
    result = copy.deepcopy(value)
    try:
        if _digest(result) != FOLDED_BTN_CAPTURE_SHA256[name]:
            raise ValueError('whole current folded BTN capture')
        if name == 'ledger.json':
            groups = {row['task_id']: row for row in fixture['ledger_groups']}
            rebuilt, seen, index = [], set(), 0
            while index < len(result):
                task_id = result[index]['task_id']
                end = index + 1
                while end < len(result) and result[end]['task_id'] == task_id:
                    end += 1
                if task_id in seen:
                    raise ValueError('duplicate or noncontiguous ledger group')
                seen.add(task_id)
                rows = result[index:end]
                if task_id in groups:
                    group = groups[task_id]
                    if (len(rows) != group['current_count']
                        or _digest(rows) != group['current_sha256']
                        or dict(collections.Counter(r['status'] for r in rows)) != group['current_statuses']
                        or len(group['prior_rows']) != group['prior_count']
                        or _digest(group['prior_rows']) != group['prior_sha256']
                        or any(r['task_id'] != task_id for r in group['prior_rows'])):
                        raise ValueError('literal ledger group/status/witness')
                    rows = copy.deepcopy(group['prior_rows'])
                rebuilt.extend(rows)
                index = end
            if not set(groups) <= seen:
                raise ValueError('missing admitted group')
            result = rebuilt
        else:
            for task_id, change in fixture['task_changes'][name].items():
                if result[task_id] != change['current']:
                    raise ValueError('literal current folded BTN task record')
                result[task_id] = copy.deepcopy(change['prior'])
        if _digest(result) != W4_PURPOSE_TEACHING_CAPTURE_SHA256[name]:
            raise ValueError('whole reconstructed W4 capture')
    except (KeyError, TypeError, IndexError, ValueError) as error:
        raise SystemExit(f'Folded BTN exact capture mismatch: {name}') from error
    return result


def _digest(value):
    encoded = json.dumps(value, separators=(',', ':'), ensure_ascii=False).encode()
    return hashlib.sha256(encoded).hexdigest()


def producer_revision(cohort, role):
    reference = cohort.get('admitted_source_reference')
    if reference != SOURCE_REFERENCES[role]:
        raise SystemExit('Admitted source reference changed')
    receipt = cohort.get('producer_receipt')
    if (not isinstance(receipt, dict)
        or not isinstance(receipt.get('head'), str)
        or not re.fullmatch(r'[0-9a-f]{40}', receipt['head'])):
        raise SystemExit('Producing HEAD receipt is missing or malformed')
    source_bytes = {
        key: receipt.get(key) for key in ('state_sha256', 'factory_sha256')
    }
    origin_bytes = {key: reference[key] for key in source_bytes}
    if source_bytes == origin_bytes:
        return 'ORIGINAL_AUTHORING_BYTES'
    admitted_bytes = {key: MAIN01_PRODUCER_REVISION[key] for key in source_bytes}
    if role == 'candidate' and source_bytes == admitted_bytes:
        return 'MAIN01_REVIEWED_SETUP_QUALITIES'
    w01_bytes = {key: W01_PRODUCER_REVISION[key] for key in source_bytes}
    if role == 'candidate' and source_bytes == w01_bytes:
        return W01_REVISION
    pkg1_bytes = {key: PKG1_PRODUCER_REVISION[key] for key in source_bytes}
    if role == 'candidate' and source_bytes == pkg1_bytes:
        return PKG1_REVISION
    position_bytes = {key: W01_POSITION_PRODUCER_REVISION[key] for key in source_bytes}
    if role == 'candidate' and source_bytes == position_bytes:
        return W01_POSITION_REVISION
    w3_recap_bytes = {key: W3_RECAP_PRODUCER_REVISION[key] for key in source_bytes}
    if role == 'candidate' and source_bytes == w3_recap_bytes:
        return W3_RECAP_REVISION
    ato_bytes = {key: W3_ATO_TEACHING_PRODUCER_REVISION[key] for key in source_bytes}
    if role == 'candidate' and source_bytes == ato_bytes:
        return W3_ATO_TEACHING_REVISION
    prompt_bytes = {key: W3_RECAP_PROMPT_PRODUCER_REVISION[key] for key in source_bytes}
    if role == 'candidate' and source_bytes == prompt_bytes:
        return W3_RECAP_PROMPT_REVISION
    w5_bytes = {key: W5_FACTUAL_PRODUCER_REVISION[key] for key in source_bytes}
    if role == 'candidate' and source_bytes == w5_bytes:
        _require_w5_factual_admission()
        return W5_FACTUAL_REVISION
    context_bytes = {key: W24_CONTEXT_PRODUCER_REVISION[key] for key in source_bytes}
    if role == 'candidate' and source_bytes == context_bytes:
        _require_w24_context_admission()
        return W24_CONTEXT_REVISION
    wp03_bytes = {key: WP03_CONTEXT_PRODUCER_REVISION[key] for key in source_bytes}
    if role == 'candidate' and source_bytes == wp03_bytes:
        _require_wp03_context_admission()
        return WP03_CONTEXT_REVISION
    w4_teaching_bytes = {key: W4_PURPOSE_TEACHING_PRODUCER_REVISION[key] for key in source_bytes}
    if role == 'candidate' and source_bytes == w4_teaching_bytes:
        _require_w4_purpose_teaching_admission()
        return W4_PURPOSE_TEACHING_REVISION
    folded_btn_bytes = {key: FOLDED_BTN_PRODUCER_REVISION[key] for key in source_bytes}
    if role == 'candidate' and source_bytes == folded_btn_bytes:
        _require_folded_btn_admission()
        return FOLDED_BTN_REVISION
    raise SystemExit('Producing source receipt does not match admitted bytes')


def main01_origin_capture(name, value):
    """Return an in-memory origin comparison; never rewrite captured artifacts."""
    result = copy.deepcopy(value)
    if name in ('learning-contract.json', 'choice-identity.json'):
        try:
            options = (result[MAIN01_TASK_ID]['options']
                       if name == 'learning-contract.json' else result[MAIN01_TASK_ID])
            by_id = {(row['id'] if isinstance(row, dict) else row[0]): row
                     for row in options}
            if len(options) != 3 or set(by_id) != {
                'hero_btn_preflop_setup', *MAIN01_QUALITY_REVISION
            }:
                raise ValueError('unexpected choice identities')
            for choice, (prior, current) in MAIN01_QUALITY_REVISION.items():
                row = by_id[choice]
                if name == 'learning-contract.json':
                    if row['quality'] != current or row['correct'] is not False:
                        raise ValueError('unexpected current grading cell')
                    row['quality'] = prior
                else:
                    if len(row) != 5 or row[3] != current or row[2] is not False:
                        raise ValueError('unexpected current choice cell')
                    row[3] = prior
        except (KeyError, TypeError, IndexError, ValueError) as error:
            raise SystemExit(f'MAIN01 exact quality revision mismatch: {name}') from error
    elif name == 'source-fingerprints.json':
        if result.get(MAIN01_TASK_ID) != {
            'world_id': 'world_1', 'lesson_id': 'what_poker_is',
            'fingerprint': MAIN01_CURRENT_FINGERPRINT,
        }:
            raise SystemExit('MAIN01 exact setup fingerprint mismatch')
        result[MAIN01_TASK_ID]['fingerprint'] = MAIN01_PRIOR_FINGERPRINT
    return result


def w01_origin_capture(name, value):
    """Reverse only reviewed option fields/IDs on a copy of the exact capture."""
    result = copy.deepcopy(value)
    try:
        if name == 'ledger.json':
            if len(result) != 62712:
                raise ValueError('ledger cardinality')
            for revision in W01_LEDGER_REVISIONS:
                for index in revision['indices']:
                    row = result[index]
                    if row['task_id'] != revision['task_id']:
                        raise ValueError('ledger task/index')
                    for field in ('phase', 'step_phase_variant'):
                        if row[field] != revision['current']:
                            raise ValueError('ledger phase')
                        row[field] = revision['prior']
        else:
            for task_id, revision in W01_CAPTURE_OPTIONS[name].items():
                if name in ('learning-contract.json', 'runtime-inputs.json'):
                    if result[task_id]['options'] != revision['current']:
                        raise ValueError('option fields/order')
                    result[task_id]['options'] = copy.deepcopy(revision['prior'])
                else:
                    if result[task_id] != revision['current']:
                        raise ValueError('choice/fingerprint fields')
                    result[task_id] = copy.deepcopy(revision['prior'])
    except (KeyError, TypeError, IndexError, ValueError) as error:
        raise SystemExit(f'W01 exact theory revision mismatch: {name}') from error
    return result


def pkg1_w01_capture(name, value):
    """Reverse literal PKG1 leaves on a copy; require the entire exact W01 capture."""
    result = copy.deepcopy(value)
    try:
        if name == 'ledger.json':
            if len(result) != 62712:
                raise ValueError('ledger cardinality')
            for index, identity in PKG1_LEDGER_IDENTITIES.items():
                if any(result[index][key] != expected for key, expected in identity.items()):
                    raise ValueError('ledger identity')
        for path, prior, current in PKG1_CAPTURE_LEAVES.get(name, []):
            node = result
            for key in path[:-1]:
                node = node[key]
            if node[path[-1]] != current:
                raise ValueError('literal current leaf')
            node[path[-1]] = copy.deepcopy(prior)
        if _digest(result) != W01_CAPTURE_SHA256[name]:
            raise ValueError('whole reconstructed W01 capture')
    except (KeyError, TypeError, IndexError, ValueError) as error:
        raise SystemExit(f'PKG1 exact hand/seat revision mismatch: {name}') from error
    return result


def w01_position_pkg1_capture(name, value):
    """Reverse only six option reasons and two fingerprints on a copy."""
    result = copy.deepcopy(value)
    try:
        for path, prior, current in W01_POSITION_CAPTURE_LEAVES.get(name, []):
            node = result
            for key in path[:-1]:
                node = node[key]
            if node[path[-1]] != current:
                raise ValueError('literal current leaf')
            node[path[-1]] = copy.deepcopy(prior)
        if _digest(result) != PKG1_CAPTURE_SHA256[name]:
            raise ValueError('whole reconstructed PKG1 capture')
    except (KeyError, TypeError, IndexError, ValueError) as error:
        raise SystemExit(f'W01 position exact revision mismatch: {name}') from error
    return result


def w3_recap_position_capture(name, value):
    """Reverse only the two reviewed recap contexts on an in-memory copy."""
    result = copy.deepcopy(value)
    try:
        for path, prior, current in W3_RECAP_CAPTURE_LEAVES.get(name, []):
            node = result
            for key in path[:-1]:
                node = node[key]
            if node[path[-1]] != current:
                raise ValueError('literal current leaf')
            node[path[-1]] = copy.deepcopy(prior)
        if _digest(result) != W01_POSITION_CAPTURE_SHA256[name]:
            raise ValueError('whole reconstructed W01 position capture')
    except (KeyError, TypeError, IndexError, ValueError) as error:
        raise SystemExit(f'W3 recap exact revision mismatch: {name}') from error
    return result


def w3_ato_teaching_recap_capture(name, value):
    """Reverse exactly six reviewed teaching leaves on a copy, retaining every prior pin."""
    result = copy.deepcopy(value)
    try:
        for path, prior, current in W3_ATO_TEACHING_CAPTURE_LEAVES.get(name, []):
            node = result
            for key in path[:-1]:
                node = node[key]
            if node[path[-1]] != current:
                raise ValueError('literal current teaching leaf')
            node[path[-1]] = copy.deepcopy(prior)
        if _digest(result) != W3_RECAP_CAPTURE_SHA256[name]:
            raise ValueError('whole reconstructed W3 recap capture')
    except (KeyError, TypeError, IndexError, ValueError) as error:
        raise SystemExit(f'ATo teaching exact revision mismatch: {name}') from error
    return result


def w3_recap_prompt_ato_capture(name, value):
    """Reverse only two action questions and their fingerprints on a copy."""
    result = copy.deepcopy(value)
    try:
        for path, prior, current in W3_RECAP_PROMPT_CAPTURE_LEAVES.get(name, []):
            node = result
            for key in path[:-1]:
                node = node[key]
            if node[path[-1]] != current:
                raise ValueError('literal current recap prompt leaf')
            node[path[-1]] = copy.deepcopy(prior)
        if _digest(result) != W3_ATO_TEACHING_CAPTURE_SHA256[name]:
            raise ValueError('whole reconstructed ATo teaching capture')
    except (KeyError, TypeError, IndexError, ValueError) as error:
        raise SystemExit(f'Recap prompt exact revision mismatch: {name}') from error
    return result


def w5_factual_prompt_capture(name, value):
    """Reverse exactly two factual runtime leaves and their two fingerprints."""
    _require_w5_factual_admission()
    result = copy.deepcopy(value)
    try:
        if name == 'runtime-inputs.json':
            for task_id, expected in W5_FACTUAL_PROTECTED_RUNTIME_SHA256.items():
                if _digest(result[task_id]) != expected:
                    raise ValueError('protected runtime input')
        if name == 'source-fingerprints.json':
            for task_id, expected in W5_FACTUAL_PROTECTED_FINGERPRINTS.items():
                if result[task_id]['fingerprint'] != expected:
                    raise ValueError('protected source fingerprint')
        for path, prior, current in W5_FACTUAL_CAPTURE_LEAVES.get(name, []):
            node = result
            for key in path[:-1]:
                node = node[key]
            if node[path[-1]] != current:
                raise ValueError('literal current W5 factual leaf')
            node[path[-1]] = copy.deepcopy(prior)
        if _digest(result) != W3_RECAP_PROMPT_CAPTURE_SHA256[name]:
            raise ValueError('whole reconstructed recap prompt capture')
    except (KeyError, TypeError, IndexError, ValueError) as error:
        raise SystemExit(f'W5 factual exact revision mismatch: {name}') from error
    return result


def w24_context_w5_capture(name, value):
    """Reverse one exact recap and four separately reviewed ledger phase leaves."""
    _require_w24_context_admission()
    result = copy.deepcopy(value)
    try:
        if name == 'runtime-inputs.json':
            for task_id, expected in W5_FACTUAL_PROTECTED_RUNTIME_SHA256.items():
                if _digest(result[task_id]) != expected: raise ValueError('protected runtime input')
        if name == 'source-fingerprints.json':
            for task_id, expected in W5_FACTUAL_PROTECTED_FINGERPRINTS.items():
                if result[task_id]['fingerprint'] != expected: raise ValueError('protected source fingerprint')
        for path, prior, current in W24_CONTEXT_CAPTURE_LEAVES.get(name, []):
            node = result
            for key in path[:-1]: node = node[key]
            if node[path[-1]] != current: raise ValueError('literal current W24 context leaf')
            if name == 'ledger.json' and node['task_id'] != W24_CONTEXT_TASK_ID: raise ValueError('ledger target identity')
            node[path[-1]] = copy.deepcopy(prior)
        if _digest(result) != W5_FACTUAL_CAPTURE_SHA256[name]: raise ValueError('whole reconstructed corrected W5 capture')
    except (KeyError, TypeError, IndexError, ValueError) as error:
        raise SystemExit(f'W24 context exact revision mismatch: {name}') from error
    return result


def reviewed_origin_capture(name, value, revision):
    if revision == FOLDED_BTN_REVISION:
        w4 = folded_btn_w4_capture(name, value)
        wp03 = _w4_purpose_teaching_wp03_capture_core(name, w4, _load_w4_purpose_teaching_fixture())
        w24 = _wp03_context_w24_capture_core(name, wp03, _load_wp03_context_fixture())
        return reviewed_origin_capture(name, w24, W24_CONTEXT_REVISION)
    if revision == W4_PURPOSE_TEACHING_REVISION:
        predecessor = w4_purpose_teaching_wp03_capture(name, value)
        w24 = _wp03_context_w24_capture_core(name, predecessor, _load_wp03_context_fixture())
        return reviewed_origin_capture(name, w24, W24_CONTEXT_REVISION)
    if revision == WP03_CONTEXT_REVISION:
        return reviewed_origin_capture(name, wp03_context_w24_capture(name, value), W24_CONTEXT_REVISION)
    if revision == W24_CONTEXT_REVISION: value = w24_context_w5_capture(name, value)
    if revision in (W5_FACTUAL_REVISION, W24_CONTEXT_REVISION, WP03_CONTEXT_REVISION, W4_PURPOSE_TEACHING_REVISION, FOLDED_BTN_REVISION):
        value = w5_factual_prompt_capture(name, value)
    if revision in (W3_RECAP_PROMPT_REVISION, W5_FACTUAL_REVISION, W24_CONTEXT_REVISION, WP03_CONTEXT_REVISION, W4_PURPOSE_TEACHING_REVISION, FOLDED_BTN_REVISION):
        value = w3_recap_prompt_ato_capture(name, value)
    if revision in (W3_ATO_TEACHING_REVISION, W3_RECAP_PROMPT_REVISION, W5_FACTUAL_REVISION, W24_CONTEXT_REVISION, WP03_CONTEXT_REVISION, W4_PURPOSE_TEACHING_REVISION, FOLDED_BTN_REVISION):
        value = w3_ato_teaching_recap_capture(name, value)
    if revision in (W3_RECAP_REVISION, W3_ATO_TEACHING_REVISION, W3_RECAP_PROMPT_REVISION, W5_FACTUAL_REVISION, W24_CONTEXT_REVISION, WP03_CONTEXT_REVISION, W4_PURPOSE_TEACHING_REVISION, FOLDED_BTN_REVISION):
        value = w3_recap_position_capture(name, value)
    if revision in (W01_POSITION_REVISION, W3_RECAP_REVISION, W3_ATO_TEACHING_REVISION, W3_RECAP_PROMPT_REVISION, W5_FACTUAL_REVISION, W24_CONTEXT_REVISION, WP03_CONTEXT_REVISION, W4_PURPOSE_TEACHING_REVISION, FOLDED_BTN_REVISION):
        value = w01_position_pkg1_capture(name, value)
    if revision in (PKG1_REVISION, W01_POSITION_REVISION, W3_RECAP_REVISION, W3_ATO_TEACHING_REVISION, W3_RECAP_PROMPT_REVISION, W5_FACTUAL_REVISION, W24_CONTEXT_REVISION, WP03_CONTEXT_REVISION, W4_PURPOSE_TEACHING_REVISION, FOLDED_BTN_REVISION):
        value = pkg1_w01_capture(name, value)
    if revision in (W01_REVISION, PKG1_REVISION, W01_POSITION_REVISION, W3_RECAP_REVISION, W3_ATO_TEACHING_REVISION, W3_RECAP_PROMPT_REVISION, W5_FACTUAL_REVISION, W24_CONTEXT_REVISION, WP03_CONTEXT_REVISION, W4_PURPOSE_TEACHING_REVISION, FOLDED_BTN_REVISION):
        value = w01_origin_capture(name, value)
    return main01_origin_capture(name, value)


def validate_capture_artifacts(source, revision, names=None):
    """Pin every field of the reviewed capture to the unchanged original capture.

    Original artifacts retain exact raw-byte checks. Reviewed revisions use
    canonical JSON, reversing only their literal reviewed changes. W01 also
    requires the exact current whole-capture bytes before any reconstruction;
    every reconstructed capture must reproduce its unchanged original pin.
    """
    if revision == FOLDED_BTN_REVISION: _require_folded_btn_admission()
    if revision == W4_PURPOSE_TEACHING_REVISION: _require_w4_purpose_teaching_admission()
    if revision == WP03_CONTEXT_REVISION: _require_wp03_context_admission()
    if revision == W24_CONTEXT_REVISION: _require_w24_context_admission()
    if revision == W5_FACTUAL_REVISION:
        _require_w5_factual_admission()
    names = EXPECTED_CAPTURE_ARTIFACTS if names is None else names
    for name, expected in names.items():
        raw = (pathlib.Path(source) / name).read_bytes()
        observed = hashlib.sha256(raw).hexdigest()
        if revision in ('MAIN01_REVIEWED_SETUP_QUALITIES', W01_REVISION, PKG1_REVISION, W01_POSITION_REVISION, W3_RECAP_REVISION, W3_ATO_TEACHING_REVISION, W3_RECAP_PROMPT_REVISION, W5_FACTUAL_REVISION, W24_CONTEXT_REVISION, WP03_CONTEXT_REVISION, W4_PURPOSE_TEACHING_REVISION, FOLDED_BTN_REVISION):
            captured = json.loads(raw)
            compact = json.dumps(captured, separators=(',', ':'), ensure_ascii=False).encode()
            if raw != compact:
                raise SystemExit(f'Captured JSON byte encoding drift: {name}')
            if revision == FOLDED_BTN_REVISION and observed != FOLDED_BTN_CAPTURE_SHA256.get(name):
                raise SystemExit(f'Folded BTN current capture artifact drift: {name}')
            if revision == W4_PURPOSE_TEACHING_REVISION and observed != W4_PURPOSE_TEACHING_CAPTURE_SHA256.get(name):
                raise SystemExit(f'W4 purpose teaching current capture artifact drift: {name}')
            if revision == WP03_CONTEXT_REVISION and observed != WP03_CONTEXT_CAPTURE_SHA256.get(name):
                raise SystemExit(f'WP03 context current capture artifact drift: {name}')
            if revision == W24_CONTEXT_REVISION and observed != W24_CONTEXT_CAPTURE_SHA256.get(name):
                raise SystemExit(f'W24 context current capture artifact drift: {name}')
            if revision == W5_FACTUAL_REVISION and observed != W5_FACTUAL_CAPTURE_SHA256.get(name):
                raise SystemExit(f'W5 factual current capture artifact drift: {name}')
            if revision == W3_RECAP_PROMPT_REVISION and observed != W3_RECAP_PROMPT_CAPTURE_SHA256.get(name):
                raise SystemExit(f'Recap prompt current capture artifact drift: {name}')
            if revision == W3_ATO_TEACHING_REVISION and observed != W3_ATO_TEACHING_CAPTURE_SHA256.get(name):
                raise SystemExit(f'ATo teaching current capture artifact drift: {name}')
            if revision == W3_RECAP_REVISION and observed != W3_RECAP_CAPTURE_SHA256.get(name):
                raise SystemExit(f'W3 recap current capture artifact drift: {name}')
            if revision == W01_POSITION_REVISION and observed != W01_POSITION_CAPTURE_SHA256.get(name):
                raise SystemExit(f'W01 position current capture artifact drift: {name}')
            if revision == PKG1_REVISION and observed != PKG1_CAPTURE_SHA256.get(name):
                raise SystemExit(f'PKG1 current capture artifact drift: {name}')
            if revision == W01_REVISION and observed != W01_CAPTURE_SHA256.get(name):
                raise SystemExit(f'W01 current capture artifact drift: {name}')
            observed = _digest(reviewed_origin_capture(name, captured, revision))
        if observed != expected:
            raise SystemExit(f'Captured source artifact drift: {name}')


def validate_typed_cohort(root):
    root = pathlib.Path(root)
    base = json.loads((root / 'baseline' / 'learning-contract.json').read_text())
    final = json.loads((root / 'candidate' / 'learning-contract.json').read_text())
    base_cohort = json.loads((root / 'baseline' / 'typed-cohort-v2.json').read_text())
    final_cohort = json.loads((root / 'candidate' / 'typed-cohort-v2.json').read_text())
    canonical = json.loads(CANONICAL_NEW_AUTHORING.read_text())
    if (
        canonical.get('schema') != 1
        or canonical.get('admitted_source_reference')
        != SOURCE_REFERENCES['candidate']['commit']
        or canonical.get('capture_artifacts') != EXPECTED_CAPTURE_ARTIFACTS
        or canonical.get('d3_no_old_blind_fail_count') != 0
        or set(canonical.get('tasks', {})) != NEW_AUTHORING_IDS
    ):
        raise SystemExit('Pinned ASM05 canonical record fixture is malformed')
    for role, cohort in (
        ('historical_baseline', base_cohort),
        ('candidate', final_cohort),
    ):
        if cohort.get('schema') != 2 or cohort.get('role') != role:
            raise SystemExit('Unknown or mismatched typed cohort role')
        revision = producer_revision(cohort, role)
        if role == 'candidate':
            candidate_revision = revision
    if base_cohort.get('new_authoring'):
        raise SystemExit('Historical baseline contains NEW_AUTHORING additions')
    addition_rows = final_cohort.get('new_authoring', [])
    additions = {row.get('task_id'): row for row in addition_rows}
    if len(addition_rows) != len(NEW_AUTHORING_IDS) or set(additions) != NEW_AUTHORING_IDS:
        raise SystemExit('NEW_AUTHORING cohort is missing or contains unknown tasks')
    historical_ids = set(base_cohort.get('historical_ids', []))
    if (
        historical_ids != set(final_cohort.get('historical_ids', []))
        or len(historical_ids) != 367
    ):
        raise SystemExit('Historical cohort identity changed')
    if set(base) != historical_ids or set(final) != historical_ids | NEW_AUTHORING_IDS:
        raise SystemExit('Learning contract cohort key set is inconsistent')
    comparison_contract = final
    if candidate_revision in ('MAIN01_REVIEWED_SETUP_QUALITIES', W01_REVISION, PKG1_REVISION, W01_POSITION_REVISION, W3_RECAP_REVISION, W3_ATO_TEACHING_REVISION, W3_RECAP_PROMPT_REVISION, W5_FACTUAL_REVISION, W24_CONTEXT_REVISION, WP03_CONTEXT_REVISION, W4_PURPOSE_TEACHING_REVISION, FOLDED_BTN_REVISION):
        validate_capture_artifacts(root / 'candidate', candidate_revision)
        comparison_contract = reviewed_origin_capture(
            'learning-contract.json', final, candidate_revision)
    if {key: comparison_contract[key] for key in historical_ids} != base:
        raise SystemExit('Learning identity, XP, correctness or repair contract changed')
    before = json.loads((root / 'baseline' / 'runtime-inputs.json').read_text())
    after = json.loads((root / 'candidate' / 'runtime-inputs.json').read_text())
    before_fingerprints = json.loads(
        (root / 'baseline' / 'source-fingerprints.json').read_text()
    )
    after_fingerprints = json.loads(
        (root / 'candidate' / 'source-fingerprints.json').read_text()
    )
    before_choices = json.loads((root / 'baseline' / 'choice-identity.json').read_text())
    after_choices = json.loads((root / 'candidate' / 'choice-identity.json').read_text())
    for label, historical, candidate in (
        ('runtime input', before, after),
        ('source fingerprint', before_fingerprints, after_fingerprints),
        ('choice identity', before_choices, after_choices),
    ):
        if set(historical) != historical_ids or set(candidate) != (
            historical_ids | NEW_AUTHORING_IDS
        ):
            raise SystemExit(f'{label} cohort key set is inconsistent')
    comparison_choices = (
        reviewed_origin_capture('choice-identity.json', after_choices, candidate_revision)
        if candidate_revision in ('MAIN01_REVIEWED_SETUP_QUALITIES', W01_REVISION, PKG1_REVISION, W01_POSITION_REVISION, W3_RECAP_REVISION, W3_ATO_TEACHING_REVISION, W3_RECAP_PROMPT_REVISION, W5_FACTUAL_REVISION, W24_CONTEXT_REVISION, WP03_CONTEXT_REVISION, W4_PURPOSE_TEACHING_REVISION, FOLDED_BTN_REVISION) else after_choices
    )
    if any(before_choices[key] != comparison_choices[key] for key in historical_ids):
        raise SystemExit('Historical choice identity changed')
    for task_id in NEW_AUTHORING_IDS:
        expected = canonical['tasks'][task_id]
        actual_bundle = [
            final[task_id],
            after_fingerprints[task_id],
            after_choices[task_id],
            after[task_id],
        ]
        expected_bundle = [
            expected['learning_contract'],
            expected['source_fingerprint'],
            expected['choice_identity'],
            expected['runtime_input'],
        ]
        if actual_bundle != expected_bundle:
            raise SystemExit(f'NEW_AUTHORING canonical record mismatch: {task_id}')
        row = additions[task_id]
        identity = {
            key: value
            for key, value in row.items()
            if key not in {'artifact_sha256', 'source_binding_sha256'}
        }
        if identity != {
            'task_id': task_id,
            'world_id': 'world_12',
            'lesson_id': 'decision_over_outcome',
            'provenance': 'NEW_AUTHORING_ASM05',
        }:
            raise SystemExit(f'NEW_AUTHORING identity is malformed: {task_id}')
        if row.get('artifact_sha256') != _digest(actual_bundle):
            raise SystemExit(f'NEW_AUTHORING artifact digest mismatch: {task_id}')
        source_binding = [
            final_cohort['admitted_source_reference'],
            task_id,
            actual_bundle,
        ]
        if row.get('source_binding_sha256') != _digest(source_binding):
            raise SystemExit(f'NEW_AUTHORING source binding mismatch: {task_id}')
    return {
        'root': root,
        'base': base,
        'final': final,
        'historical_ids': historical_ids,
        'before': before,
        'after': after,
        'before_fingerprints': before_fingerprints,
        'after_fingerprints': after_fingerprints,
        'before_choices': before_choices,
        'after_choices': after_choices,
        'additions': additions,
        'final_cohort': final_cohort,
        'candidate_revision': candidate_revision,
        'historical_learning_contract_identical': {key: final[key] for key in historical_ids} == base,
        'historical_choice_identity_identical': all(before_choices[key] == after_choices[key] for key in historical_ids),
    }


def compare(root):
    identity = validate_typed_cohort(root)
    root = identity['root']
    historical_ids = identity['historical_ids']
    before = identity['before']
    after = identity['after']
    before_fingerprints = identity['before_fingerprints']
    after_fingerprints = identity['after_fingerprints']
    before_choices = identity['before_choices']
    after_choices = identity['after_choices']
    delta = {
        key: {'before': before[key], 'after': after[key]}
        for key in historical_ids
        if before[key] != after[key]
    }
    (root / 'runtime-input-delta.json').write_text(json.dumps(delta, indent=2))
    fingerprint_delta = {}
    for task_id in sorted(historical_ids):
        old = before_fingerprints[task_id]
        new = after_fingerprints[task_id]
        changed = old['fingerprint'] != new['fingerprint']
        classification = ('SOURCE_CONDITION_CHANGED' if changed else
                          'PRESENTATION_OR_TEACHING_ONLY' if task_id in delta else 'UNCHANGED')
        fingerprint_delta[task_id] = {
            'before': old, 'after': new, 'classification': classification,
            'changed_runtime_fields': [field for field in before[task_id]
                                       if before[task_id][field] != after[task_id][field]],
            'historical_record_policy': 'retain original fingerprint, grade, assistance, XP and repair lineage',
            'current_source_policy': 'reject old fingerprint' if changed else 'regrade against current compatible source',
        }
    (root / 'source-fingerprint-delta.json').write_text(json.dumps(fingerprint_delta, indent=2))
    fingerprint_counts = dict(collections.Counter(v['classification'] for v in fingerprint_delta.values()))
    ledgers = {}
    for phase in ['baseline', 'candidate']:
        rows = json.loads((root / phase / 'ledger.json').read_text())
        ledgers[phase] = {
            'tasks': len({r['task_id'] for r in rows}),
            'variants': len({(r['task_id'], r['phase']) for r in rows}),
            'rows': len(rows), 'statuses': dict(collections.Counter(r['status'] for r in rows)),
            'by_invariant': {i: dict(collections.Counter(r['status'] for r in rows if r['invariant'] == i)) for i in sorted({r['invariant'] for r in rows})},
            'failed_ids': sorted({r['task_id'] for r in rows if r['status'] == 'FAIL'}),
        }
    if not ledgers['baseline']['statuses'].get('FAIL', 0):
        raise SystemExit('Baseline contains no genuine RED source counterexamples')
    if ledgers['candidate']['statuses'].get('FAIL', 0):
        raise SystemExit('Candidate retains invariant failures: ' + str(ledgers['candidate']['failed_ids']))
    new_authoring = {
        task_id: {
            'cohort': identity['additions'][task_id],
            'learning_contract': identity['final'][task_id],
            'source_fingerprint': after_fingerprints[task_id],
            'choice_identity': after_choices[task_id],
            'runtime_input': after[task_id],
        }
        for task_id in sorted(NEW_AUTHORING_IDS)
    }
    result = {'ledgers': ledgers, 'runtime_changed_task_count': len(delta), 'runtime_changed_task_ids': sorted(delta),
              'historical_learning_contract_identical': identity['historical_learning_contract_identical'],
              'historical_choice_identity_identical': identity['historical_choice_identity_identical'],
              'historical_contracts_identical_except_reviewed_setup_qualities': identity['candidate_revision'] not in (W01_REVISION, PKG1_REVISION, W01_POSITION_REVISION, W3_RECAP_REVISION, W3_ATO_TEACHING_REVISION, W3_RECAP_PROMPT_REVISION, W5_FACTUAL_REVISION, W24_CONTEXT_REVISION, WP03_CONTEXT_REVISION, W4_PURPOSE_TEACHING_REVISION, FOLDED_BTN_REVISION),
              'historical_contracts_identical_except_exact_reviewed_revisions': True,
              'reviewed_theory_changes': ([
                  {'task_id': task_id, 'changed_fields': ['options', 'source_fingerprint', 'feedback_phase_choice_ids'],
                   'historical_record_policy': 'retain original fingerprint, grade, assistance, XP and repair lineage',
                   'current_source_policy': 'reject old fingerprint'}
                  for task_id in W01_CAPTURE_OPTIONS['learning-contract.json']
              ] if identity['candidate_revision'] in (W01_REVISION, PKG1_REVISION, W01_POSITION_REVISION, W3_RECAP_REVISION, W3_ATO_TEACHING_REVISION, W3_RECAP_PROMPT_REVISION, W5_FACTUAL_REVISION, W24_CONTEXT_REVISION, WP03_CONTEXT_REVISION, W4_PURPOSE_TEACHING_REVISION, FOLDED_BTN_REVISION) else []),
              'reviewed_folded_btn_mechanical_changes': ({'task_ids': list(FOLDED_BTN_TASK_IDS), 'runtime_changes_vs_W4': 3, 'assessment_FP_changes_vs_W4': 3, 'other_contexts_unchanged_vs_W4': 366, 'strategy_grading': 'UNKNOWN_PRESERVED_NOT_ADMITTED', 'normal_theory_reachability': 'UNKNOWN_REPRESENTATIVE_ANSWER_STAGE_ONLY', 'old_raw_record_policy': 'retain exact old history; no automatic new-context proof'}
                  if identity['candidate_revision'] == FOLDED_BTN_REVISION else {}),
              'reviewed_folded_btn_source_origin_packet': (dict(FOLDED_BTN_PRODUCER_REVISION)
                  if identity['candidate_revision'] == FOLDED_BTN_REVISION else {}),
              'reviewed_w4_purpose_teaching_change': ({'task_id': 'w4_purpose_intro', 'field': 'teaching[0].body', 'changed_task_count_vs_V2_15': 1, 'unchanged_task_count_vs_V2_15': 368, 'assessment_fingerprint_changes_vs_V2_15': 0, 'study_revision_policy': 'old study retained but cannot establish revised teaching', 'actual_prechoice_exposure': 'UNKNOWN'}
                  if identity['candidate_revision'] == W4_PURPOSE_TEACHING_REVISION else {}),
              'reviewed_w4_purpose_teaching_source_origin_packet': (dict(W4_PURPOSE_TEACHING_PRODUCER_REVISION)
                  if identity['candidate_revision'] == W4_PURPOSE_TEACHING_REVISION else {}),
              'reviewed_wp03_context_changes': ({name: len(rows) for name, rows in _require_wp03_context_admission()['task_changes'].items()}
                  if identity['candidate_revision'] == WP03_CONTEXT_REVISION else {}),
              'reviewed_wp03_source_origin_packet': (dict(WP03_CONTEXT_PRODUCER_REVISION)
                  if identity['candidate_revision'] == WP03_CONTEXT_REVISION else {}),
              'wp03_scope': ('15 new authored contexts: 13 previously admitted plus 2 Check contexts; 11 verifier groups; native/learning/parent acceptance remains separate'
                  if identity['candidate_revision'] == WP03_CONTEXT_REVISION else None),
              'candidate_producer_revision': identity['candidate_revision'],
              'producer_receipt': identity['final_cohort']['producer_receipt'],
              'reviewed_hand_seat_changes': ({name: len(leaves) for name, leaves in PKG1_CAPTURE_LEAVES.items()}
                  if identity['candidate_revision'] in (PKG1_REVISION, W01_POSITION_REVISION, W3_RECAP_REVISION, W3_ATO_TEACHING_REVISION, W3_RECAP_PROMPT_REVISION, W5_FACTUAL_REVISION, W24_CONTEXT_REVISION, WP03_CONTEXT_REVISION, W4_PURPOSE_TEACHING_REVISION, FOLDED_BTN_REVISION) else {}),
              'reviewed_position_feedback_changes': ({name: len(rows) for name, rows in W01_POSITION_CAPTURE_LEAVES.items()}
                  if identity['candidate_revision'] in (W01_POSITION_REVISION, W3_RECAP_REVISION, W3_ATO_TEACHING_REVISION, W3_RECAP_PROMPT_REVISION, W5_FACTUAL_REVISION, W24_CONTEXT_REVISION, WP03_CONTEXT_REVISION, W4_PURPOSE_TEACHING_REVISION, FOLDED_BTN_REVISION) else {}),
              'reviewed_w3_recap_changes': ({name: len(rows) for name, rows in W3_RECAP_CAPTURE_LEAVES.items()}
                  if identity['candidate_revision'] in (W3_RECAP_REVISION, W3_ATO_TEACHING_REVISION, W3_RECAP_PROMPT_REVISION, W5_FACTUAL_REVISION, W24_CONTEXT_REVISION, WP03_CONTEXT_REVISION, W4_PURPOSE_TEACHING_REVISION, FOLDED_BTN_REVISION) else {}),
              'reviewed_ato_teaching_changes': ({name: len(rows) for name, rows in W3_ATO_TEACHING_CAPTURE_LEAVES.items()}
                  if identity['candidate_revision'] in (W3_ATO_TEACHING_REVISION, W3_RECAP_PROMPT_REVISION, W5_FACTUAL_REVISION, W24_CONTEXT_REVISION, WP03_CONTEXT_REVISION, W4_PURPOSE_TEACHING_REVISION, FOLDED_BTN_REVISION) else {}),
              'reviewed_recap_prompt_changes': ({name: len(rows) for name, rows in W3_RECAP_PROMPT_CAPTURE_LEAVES.items()}
                  if identity['candidate_revision'] in (W3_RECAP_PROMPT_REVISION, W5_FACTUAL_REVISION, W24_CONTEXT_REVISION, WP03_CONTEXT_REVISION, W4_PURPOSE_TEACHING_REVISION, FOLDED_BTN_REVISION) else {}),
              'reviewed_w5_factual_changes': ({name: len(rows) for name, rows in W5_FACTUAL_CAPTURE_LEAVES.items()}
                  if identity['candidate_revision'] in (W5_FACTUAL_REVISION, W24_CONTEXT_REVISION, WP03_CONTEXT_REVISION, W4_PURPOSE_TEACHING_REVISION, FOLDED_BTN_REVISION) else {}),
              'protected_w5_context_ids_unchanged': (sorted(W5_FACTUAL_PROTECTED_FINGERPRINTS)
                  if identity['candidate_revision'] in (W5_FACTUAL_REVISION, W24_CONTEXT_REVISION, WP03_CONTEXT_REVISION, W4_PURPOSE_TEACHING_REVISION, FOLDED_BTN_REVISION) else []),
              'reviewed_w24_context_changes': ({name: len(rows) for name, rows in W24_CONTEXT_CAPTURE_LEAVES.items()}
                  if identity['candidate_revision'] == W24_CONTEXT_REVISION else {}),
              'reviewed_w24_source_files': (dict(W24_CONTEXT_PRODUCER_REVISION)
                  if identity['candidate_revision'] == W24_CONTEXT_REVISION else {}),
              'w24_runner_pin_provenance': ('reviewed source-origin packet; not the typed producer factory receipt'
                  if identity['candidate_revision'] == W24_CONTEXT_REVISION else None),
              'reviewed_producer_source_revision': (FOLDED_BTN_PRODUCER_REVISION['source_revision']
                  if identity['candidate_revision'] == FOLDED_BTN_REVISION else W4_PURPOSE_TEACHING_PRODUCER_REVISION['source_revision']
                  if identity['candidate_revision'] == W4_PURPOSE_TEACHING_REVISION else WP03_CONTEXT_PRODUCER_REVISION['source_revision']
                  if identity['candidate_revision'] == WP03_CONTEXT_REVISION else W24_CONTEXT_PRODUCER_REVISION['source_revision']
                  if identity['candidate_revision'] == W24_CONTEXT_REVISION else W5_FACTUAL_PRODUCER_REVISION['source_revision']
                  if identity['candidate_revision'] == W5_FACTUAL_REVISION else W3_RECAP_PROMPT_PRODUCER_REVISION['source_revision']
                  if identity['candidate_revision'] == W3_RECAP_PROMPT_REVISION else W3_ATO_TEACHING_PRODUCER_REVISION['source_revision']
                  if identity['candidate_revision'] == W3_ATO_TEACHING_REVISION else W3_RECAP_PRODUCER_REVISION['source_revision']
                  if identity['candidate_revision'] == W3_RECAP_REVISION else W01_POSITION_PRODUCER_REVISION['source_revision']
                  if identity['candidate_revision'] == W01_POSITION_REVISION else PKG1_PRODUCER_REVISION['source_revision']
                  if identity['candidate_revision'] == PKG1_REVISION else W01_PRODUCER_REVISION['source_revision']
                  if identity['candidate_revision'] in (W01_REVISION, PKG1_REVISION, W01_POSITION_REVISION, W3_RECAP_REVISION, W3_ATO_TEACHING_REVISION, W3_RECAP_PROMPT_REVISION, W5_FACTUAL_REVISION, W24_CONTEXT_REVISION, WP03_CONTEXT_REVISION, W4_PURPOSE_TEACHING_REVISION, FOLDED_BTN_REVISION) else
                  MAIN01_PRODUCER_REVISION['source_revision']
                  if identity['candidate_revision'] == 'MAIN01_REVIEWED_SETUP_QUALITIES' else None),
              'reviewed_quality_changes': ([
                  {'task_id': MAIN01_TASK_ID, 'choice_id': choice, 'before': prior, 'after': current}
                  for choice, (prior, current) in MAIN01_QUALITY_REVISION.items()
              ] if identity['candidate_revision'] in ('MAIN01_REVIEWED_SETUP_QUALITIES', W01_REVISION, PKG1_REVISION, W01_POSITION_REVISION, W3_RECAP_REVISION, W3_ATO_TEACHING_REVISION, W3_RECAP_PROMPT_REVISION, W5_FACTUAL_REVISION, W24_CONTEXT_REVISION, WP03_CONTEXT_REVISION, W4_PURPOSE_TEACHING_REVISION, FOLDED_BTN_REVISION) else []),
              'historical_cohort_count': len(historical_ids),
              'new_authoring': new_authoring,
              'canonical_source_fingerprints': fingerprint_counts, 'native': 'PENDING'}
    (root / 'comparison.json').write_text(json.dumps(result, indent=2))
    hashes = {str(p.relative_to(root)): hashlib.sha256(p.read_bytes()).hexdigest() for p in sorted(root.rglob('*')) if p.is_file()}
    (root / 'sha256.json').write_text(json.dumps(hashes, indent=2))
    print(json.dumps(result))


if __name__ == '__main__':
    if sys.argv[1] == 'tests':
        summarize(sys.argv[2], sys.argv[3], int(sys.argv[4]))
    else:
        compare(sys.argv[2])
