#!/usr/bin/env python3
"""B149: offline comparison of hypothetical monthly-subscription offers."""
import argparse
from dataclasses import dataclass
import json
import math
from pathlib import Path
import random

# Sequential course snapshot: act0_shell_lessons_w{1_w4,5_w8,9_w12}_v1.dart.
LESSONS = (15, 7, 7, 7, 7, 7, 3, 5, 4, 4, 6, 7)
W4_END = sum(LESSONS[:4])
W12_ENTRY = sum(LESSONS[:11])
DAYS = 365
COHORT = 4000  # virtual installs; revenue scaled to 1,000
SEED = 149
SCENARIOS = ('low', 'base', 'high')
PROBABILITIES = {
    'd1_retention', 'd7_retention', 'd30_retention', 'trial_to_paid',
    'monthly_churn', 'wall_offer_to_paid', 'bankroll_offer_to_paid',
    'practice_offer_to_paid', 'offer_to_trial',
    'bankroll_pace_fraction', 'persistent_activity_fraction', 'practice_participation',
}
POSITIVE = {'daily_lessons', 'monthly_price_usd', 'post_d30_half_life_days'}
DAY_INPUTS = {'practice_repeat_day', 'trial_days'}
INPUTS = PROBABILITIES | POSITIVE | DAY_INPUTS


@dataclass(frozen=True)
class Model:
    name: str
    wall_after_world: int | None = None
    bankroll: bool = False
    trial: bool = False
    practice: bool = False

    def __post_init__(self):
        if self.wall_after_world is not None and (
            type(self.wall_after_world) is not int or not 4 <= self.wall_after_world < 12
        ):
            raise ValueError('a course wall must be after W4 or later, never before W4')
        if self.bankroll and self.wall_after_world is not None:
            raise ValueError('no double gate: bankroll plus course wall')
        if self.trial and self.wall_after_world is None:
            raise ValueError('course trial requires a protected free course floor')


MODELS = (
    Model('Free control'),
    Model('W4 wall', wall_after_world=4),
    Model('Bankroll', bankroll=True),
    Model('Trial then subscription', wall_after_world=4, trial=True),
    Model('Free course + paid practice', practice=True),
    Model('Wall + practice', wall_after_world=4, practice=True),
    Model('Bankroll + practice', bankroll=True, practice=True),
    Model('Trial + practice', wall_after_world=4, trial=True, practice=True),
)


def load_inputs(path):
    raw = json.loads(Path(path).read_text(encoding='utf-8'))
    if not isinstance(raw, dict) or set(raw) != INPUTS:
        raise ValueError(f'expected exactly these inputs: {sorted(INPUTS)}')
    for key, item in raw.items():
        if not isinstance(item, dict) or not item.get('source') or item.get('status') not in ('assumed', 'measured'):
            raise ValueError(f'{key}: source and assumed/measured status required')
        values = [item.get(s) for s in SCENARIOS]
        if any(type(v) not in (int, float) or not math.isfinite(v) for v in values):
            raise ValueError(f'{key}: finite numeric low/base/high required')
        if values != sorted(values):
            raise ValueError(f'{key}: low <= base <= high required')
        if key in PROBABILITIES and not all(0 <= v <= 1 for v in values):
            raise ValueError(f'{key}: probability outside [0, 1]')
        if key in POSITIVE and not all(v > 0 for v in values):
            raise ValueError(f'{key}: must be positive')
        if key in DAY_INPUTS and not all(type(v) is int and 1 <= v <= DAYS for v in values):
            raise ValueError(f'{key}: whole days in [1, 365] required')
    for scenario in SCENARIOS:
        p = {key: val[scenario] for key, val in raw.items()}
        if not p['d1_retention'] >= p['d7_retention'] >= p['d30_retention']:
            raise ValueError(f'{scenario}: expected D1 >= D7 >= D30')
    return raw


def retention_curve(p):
    """Exact-age daily activity marginal, not subscriber survival."""
    anchors = ((0, 1.0), (1, p['d1_retention']), (7, p['d7_retention']), (30, p['d30_retention']))
    curve = [1.0]
    for (left, a), (right, b) in zip(anchors, anchors[1:]):
        curve.extend(a + (b - a) * (d - left) / (right - left) for d in range(left + 1, right + 1))
    curve.extend(p['d30_retention'] * 2 ** (-(d - 30) / p['post_d30_half_life_days']) for d in range(31, DAYS))
    return curve


def activity_profiles(p, cohort=COHORT):
    """Common draws for all models; mixed persistent and intermittent activity."""
    rng = random.Random(SEED)
    curve = retention_curve(p)
    for _ in range(cohort):
        persistent = rng.random() < p['persistent_activity_fraction']
        rank = rng.random()
        # Consume all draws even for persistent users, to keep comparisons paired.
        active = []
        for d, rate in enumerate(curve):
            daily = rng.random()
            if (rank if persistent else daily) < rate:
                active.append(d)
        yield active, tuple(rng.random() for _ in range(5)), tuple(rng.random() for _ in range(12))


def simulate(model, p, profiles):
    revenue = reached = 0.0
    wall = sum(LESSONS[:model.wall_after_world]) if model.wall_after_world else None
    for active, offers, renewals in profiles:
        progress = 0.0
        course_offer_seen = practice_offer_seen = False
        trial_end = paid_day = None
        # Monthly billing: twelve equal calendar-month approximations per year.
        paid_until = -1

        def subscribe(day):
            nonlocal revenue, paid_until, paid_day
            paid_day = day
            paid_until = day + round(DAYS / 12)
            revenue += p['monthly_price_usd']
            for index, draw in enumerate(renewals):
                renewal = day + round((index + 1) * DAYS / 12)
                if renewal >= DAYS or draw < p['monthly_churn']:
                    break
                revenue += p['monthly_price_usd']
                paid_until = day + round((index + 2) * DAYS / 12)

        for day in active:
            # Trial can convert even if the learner does not open the app that day.
            if trial_end is not None and day >= trial_end and paid_day is None and offers[2] < p['trial_to_paid']:
                subscribe(trial_end)
            if (model.practice and offers[4] < p['practice_participation']
                    and day >= p['practice_repeat_day'] and not practice_offer_seen):
                practice_offer_seen = True
                if paid_day is None and (trial_end is None or day >= trial_end) and offers[3] < p['practice_offer_to_paid']:
                    subscribe(day)
            budget = p['daily_lessons']
            boundary = wall if wall is not None else W4_END
            if (wall is not None or model.bankroll) and progress + budget > boundary and not course_offer_seen:
                course_offer_seen = True
                if paid_day is None:
                    if model.trial:
                        if offers[0] < p['offer_to_trial']:
                            trial_end = day + p['trial_days']
                    elif offers[1] < p['bankroll_offer_to_paid' if model.bankroll else 'wall_offer_to_paid']:
                        subscribe(day)
            access = day < paid_until or (trial_end is not None and day < trial_end)
            if wall is not None and not access:
                progress = min(progress + budget, wall) if progress < wall else progress
            elif model.bankroll and not access:
                # W1–W4 fully accessible; free practice/refill slows only new lessons.
                free_budget = min(budget, max(0, W4_END - progress))
                progress += free_budget + (budget - free_budget) * p['bankroll_pace_fraction']
            else:
                progress += budget
            progress = min(progress, sum(LESSONS))
        if trial_end is not None and trial_end < DAYS and paid_day is None and offers[2] < p['trial_to_paid']:
            subscribe(trial_end)
        reached += progress >= W12_ENTRY
    return revenue * 1000 / len(profiles), reached * 100 / len(profiles)


def compare(raw, cohort=COHORT):
    results = {}
    for scenario in SCENARIOS:
        p = {key: value[scenario] for key, value in raw.items()}
        profiles = list(activity_profiles(p, cohort))
        results[scenario] = {model.name: simulate(model, p, profiles) for model in MODELS}
    return results


def render(raw, results):
    assumed = sorted(key for key, value in raw.items() if value['status'] == 'assumed')
    lines = ['SIMULATION ONLY — not willingness-to-pay evidence.',
             'Assumed inputs: ' + (', '.join(assumed) or 'none (model structure still hypothetical)'),
             '12-month gross USD / 1,000 installs | W12 unlocked % of installs',
             'Model                          | Low USD | Low W12 | Base USD | Base W12 | High USD | High W12',
             '-' * 101]
    for model in MODELS:
        cells = [f'{revenue:8.0f} | {reach:6.1f}%' for revenue, reach in
                 (results[s][model.name] for s in SCENARIOS)]
        lines.append(f'{model.name:30} | ' + ' | '.join(cells))
    ranked = sorted(results['base'], key=lambda m: results['base'][m][0], reverse=True)
    groups = []
    for name in ranked:
        if groups and results['base'][groups[-1][0]][0] == results['base'][name][0]:
            groups[-1].append(name)
        else:
            groups.append([name])
    lines.append('Base gross revenue ranking: ' + ' > '.join(' = '.join(group) for group in groups))
    return '\n'.join(lines)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('inputs', type=Path, help='JSON parameter ranges with provenance')
    args = parser.parse_args()
    try:
        raw = load_inputs(args.inputs)
    except (OSError, ValueError) as exc:
        parser.error(str(exc))
    print(render(raw, compare(raw)))


if __name__ == '__main__':
    main()
