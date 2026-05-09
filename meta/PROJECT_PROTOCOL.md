# Poker Analyzer — Autonomous Optimization Protocol (AOP)
**Version:** 1.0  
**Status:** ENABLED  
**Date Activated:** 2025-11-07  

---

## 🎯 Purpose
To formalize proactive, simulation-driven decision-making within the Poker Analyzer project.  
The goal: maintain continuous evolution toward maximal **User EV (Expected Value)** while preserving CI stability and design coherence.

---

## ⚙️ 1. Modes

| Mode | Description |
|------|--------------|
| **UX Hypothesis Simulation Mode** | The assistant may simulate player cohorts, run behavioral EV projections, and recommend UX/content structures with the highest expected user value. |
| **Proactive Architectural Mutation** | The assistant may autonomously propose or apply architectural or UX changes when projected EV gain ≥ 4 %. |
| **EV-Pipeline-5 Enforcement** | All changes continue to pass through the standard 5-stage pipeline (Retro → Context → EV Analysis → Agent Selection → Next Prompt). |

---

## 📈 2. Trust Parameters

| ΔEV (Expected Gain) | Permission Level | Action |
|----------------------|-----------------|--------|
| ≥ 4 % | Full autonomy | Immediate Codex/Copilot prompt generation |
| 1 – 3 % | Advisory mode | Logged as *Alternative Hypothesis* (requires user confirmation) |
| < 1 % | Passive mode | Archived silently for trend analysis |

---

## 🧩 3. Scope of Mutation

**Allowed:**  
- UX flow & progression (learning maps, branching, onboarding)  
- Architectural integration (discipline routing, path planner logic)  
- Content sequencing & adaptive difficulty pacing  
- Visual theme & animation tokens  
- Telemetry schema & analytics refinement  
- QA pipeline improvements  

**Restricted / Manual Approval Required:**  
- Monetization or payment logic  
- Backend or API integrations (Firebase, external hooks)  
- Legal/compliance text and privacy disclosures  

---

## 🧾 4. Logging & Transparency
Each proactive action must include:  
- Estimated ΔEV gain  
- Affected modules/files  
- Rollback path  
- CI/test compatibility status  

All are recorded in the **Retro Summary** section of the EV-Pipeline-5 report.

---

## 🛡️ 5. Fail-Safe
If an autonomous mutation breaks CI or lowers EV after simulation,  
the system automatically:
1. Reverts to the last verified stable stage.  
2. Flags the change as *Dormant Hypothesis*.  
3. Logs the rollback event to Telemetry and roadmap history.

---

## ✅ 6. Activation Record
| Field | Value |
|--------|--------|
| Protocol ID | `AOP-PA-v1.0` |
| Maintainer | ChatGPT / Codex EV Pipeline |
| Activated by | Elmar Salimzade |
| Scope | Full Poker Analyzer Repository |
| Auto-Mutation Threshold | 4 % EV gain |

---

**End of Protocol**
