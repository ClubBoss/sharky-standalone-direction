"""Stdlib tests for the beta gate CLI, with small fixture PLANs."""
from pathlib import Path
import subprocess
import sys
import tempfile
import unittest
from unittest.mock import patch

sys.path.insert(0, str(Path(__file__).resolve().parent))
import beta_gate_report_v1 as report

SCRIPT = Path(__file__).with_name("beta_gate_report_v1.py").resolve()


class BetaGateReportTest(unittest.TestCase):
    def run_report(self, *rows):
        with tempfile.TemporaryDirectory(dir=report.ROOT) as temp:
            plan = Path(temp) / "PLAN.md"
            out = Path(temp) / "report.md"
            text = "\n".join([
                report.HEADER, "|---|---|---|---|---|---|",
                "| **Раздел** | | | | | |", *rows, "",
                "| Этап | Результат | ID из Roadmap 2.0 | Оценка |",
                "|---|---|---|---|",
                "| После беты | Not a beta item | — | 2д |",
            ])
            plan.write_text(text, encoding="utf-8")
            result = subprocess.run(
                [sys.executable, "-B", "-I", str(SCRIPT), "--plan", str(plan),
                 "--out", str(out)], cwd=temp, capture_output=True, text=True,
            )
            self.assertTrue(out.is_file(), result.stdout + result.stderr)
            self.assertEqual(plan.read_text(encoding="utf-8"), text)
            return result.returncode, out.read_text(encoding="utf-8")

    def test_open_owner_visual_iphone_and_done(self):
        code, md = self.run_report(
            "| **V9** | Device | — | агент | 1д | Частично |",
            "| V7 | Art | — | агент | 1д | Открыто |",
            "| O4 | Access | — | владелец | влад. 2д | Открыто |",
            "| **Бета** | TestFlight | — | владелец | 1д | Блокер |",
            "| A8 | Build | — | агент | — | ✅ Done |",
            "| O2 | Quiet test | — | владелец | отложено | Отложено |",
        )
        self.assertEqual(code, 0)
        self.assertIn("Открыто: **4** · agent: **0** · отложено: **1**", md)
        self.assertIn("| V9 | iPhone · открыто", md)
        self.assertIn("capture_act0_screens_v1.sh v9 walkthrough", md)
        self.assertIn("V9_CHECKLIST_v1.md", md)
        self.assertIn("| V7 | visual · открыто", md)
        self.assertIn("| O4 | owner · открыто", md)
        self.assertIn("| Бета | owner · открыто", md)
        self.assertIn("| O2 | owner · отложено", md)
        self.assertNotIn("| A8 |", md)
        self.assertNotIn("После беты", md)

    def test_agent_is_failure_but_report_written(self):
        code, md = self.run_report(
            "| NEW | New work | — | агент | 1д | Требует работу |",
            "| Q14 | Maps | — | агент | 0,5д | Частично; ✅ запись внутри |",
            "| DONE | Done | — | агент | 1д | ✅ done |",
        )
        self.assertEqual(code, 1)
        self.assertIn("| NEW | agent · открыто: Требует работу | no prep yet | — |", md)
        self.assertIn("| Q14 | agent · открыто", md)
        self.assertIn("Agent: NEW, Q14", md)
        self.assertNotIn("| DONE |", md)

    def test_only_deferred_and_done_is_not_failure(self):
        code, md = self.run_report(
            "| NEW | Deferred | — | агент | отложено | Отложено |",
            "| V9 | Done | — | агент | 1д | ✅ done |",
        )
        self.assertEqual(code, 0)
        self.assertIn("Открыто: **0** · agent: **0** · отложено: **1**", md)
        self.assertIn("| NEW | agent · отложено", md)
        self.assertNotIn("| V9 |", md)

    def test_estimates_are_read_from_docs_and_total_excludes_deferred(self):
        with tempfile.TemporaryDirectory(dir=report.ROOT) as temp:
            root = Path(temp)
            day = root / report.DAY
            day.parent.mkdir(parents=True)
            day.write_text("**Before signing (~12–25 min):**\n"
                           "| 1. Sign · 30–40 min |\n"
                           "| 2. Install · 8–9 min |\n"
                           "| 5. Start quiet test · 15 min setup |\n",
                           encoding="utf-8")
            v9 = root / report.V9
            v9.write_text("On the final build (~35 minutes):", encoding="utf-8")
            quiet = root / report.QUIET
            quiet.parent.mkdir()
            quiet.write_text("20–30 minutes each", encoding="utf-8")
            (root / report.RELEASE).write_text(
                "5. **ждёт O4** · 40–55 мин. Metadata\n"
                "7. **ждёт O4** · 55–62 мин. Upload\n", encoding="utf-8",
            )
            lines = [report.HEADER, "|---|---|---|---|---|---|",
                     "| A8 | Build | — | агент | 1д | Open |",
                     "| O1 | Install | — | владелец | 1д | Open |",
                     "| V9 | Phone | — | агент | 1д | Open |",
                     "| V6 | Art | — | агент | 1д | Open |",
                     "| O2 | Quiet | — | владелец | отложено | Deferred |"]
            with patch.object(report, "ROOT", root):
                self.assertEqual(report.minutes(report.PREP["Бета"]), (22, 22))
                md, agent = report.render(lines, root / "docs/release/out.md")
                self.assertFalse(agent)
                self.assertIn("42–65 (dry run + подпись)", md)
                self.assertIn("35 (на телефоне)", md)
                self.assertIn("**85–109**", md)
                self.assertIn("75–165 (setup + 3–5 участников)", md)
                v9.write_text("No timing available.", encoding="utf-8")
                md, _ = report.render(lines, root / "docs/release/out.md")
                self.assertIn("**50–74**", md)
                self.assertIn("2 без оценки", md)


if __name__ == "__main__":
    unittest.main()
