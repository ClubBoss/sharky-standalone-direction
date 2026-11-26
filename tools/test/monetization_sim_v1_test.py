import sys
from pathlib import Path
import unittest

TOOLS = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(TOOLS))
import monetization_sim_v1 as sim


class MonetizationSimTest(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.raw = sim.load_inputs(TOOLS / 'monetization_sim_inputs_assumed_v1.json')
        cls.base = {key: item['base'] for key, item in cls.raw.items()}

    def test_deterministic_comparison(self):
        first = sim.compare(self.raw, cohort=300)
        second = sim.compare(self.raw, cohort=300)
        self.assertEqual(sim.render(self.raw, first), sim.render(self.raw, second))
        self.assertEqual(set(first['base']), {m.name for m in sim.MODELS})

    def test_reject_wall_before_w4_and_double_gate(self):
        for world in (0, 1, 2, 3):
            with self.subTest(world=world), self.assertRaises(ValueError):
                sim.Model('invalid', wall_after_world=world)
        with self.assertRaises(ValueError):
            sim.Model('double gate', wall_after_world=4, bankroll=True)

    def test_higher_retention_improves_revenue_and_learning(self):
        low = dict(self.base, d1_retention=.2, d7_retention=.08, d30_retention=.03)
        high = dict(self.base, d1_retention=.5, d7_retention=.4, d30_retention=.3)
        before = list(sim.activity_profiles(low, 1000))
        after = list(sim.activity_profiles(high, 1000))
        model = sim.Model('practice', practice=True)
        low_revenue, low_reach = sim.simulate(model, low, before)
        high_revenue, high_reach = sim.simulate(model, high, after)
        self.assertGreater(high_revenue, low_revenue)
        self.assertGreater(high_reach, low_reach)

    def test_free_course_preserves_learning_and_wall_limits_it(self):
        p = dict(self.base, wall_offer_to_paid=0, practice_offer_to_paid=0)
        profiles = [(list(range(365)), (0.5,) * 5, (0.5,) * 12)]
        self.assertEqual(sim.simulate(sim.MODELS[0], p, profiles), (0, 100))
        self.assertEqual(sim.simulate(sim.Model('practice', practice=True), p, profiles), (0, 100))
        self.assertEqual(sim.simulate(sim.Model('wall', wall_after_world=4), p, profiles), (0, 0))

    def test_single_subscription_and_twelve_charges(self):
        p = dict(self.base, wall_offer_to_paid=1, practice_offer_to_paid=1, monthly_churn=0, practice_repeat_day=1, practice_participation=1)
        profiles = [(list(range(365)), (0,) * 5, (1,) * 12)]
        model = sim.Model('mixed', wall_after_world=4, practice=True)
        revenue, reach = sim.simulate(model, p, profiles)
        self.assertEqual(revenue, 12 * p['monthly_price_usd'] * 1000)
        self.assertEqual(reach, 100)

    def test_trial_expires_and_conversion_without_later_visit(self):
        p = dict(self.base, daily_lessons=40, offer_to_trial=1, trial_to_paid=1, monthly_churn=1)
        model = sim.Model('trial', wall_after_world=4, trial=True)
        revenue, reach = sim.simulate(model, p, [([0], (0,) * 5, (0,) * 12)])
        self.assertEqual(revenue, p['monthly_price_usd'] * 1000)
        self.assertEqual(reach, 0)


if __name__ == '__main__':
    unittest.main()
