# Act0 Architecture Split Roadmap (Wave F Prep)

**Goal:**
- Bring `act0_shell_state_v1.dart` under 8k LOC
- Isolate progression, review, recommendation, placement, profile/habit, and UI tokens
- Enable future evolution and maintainability for 100/100 product
- No breaking changes or refactors in this doc — only roadmap, TODOs, and safe comments

---

## 1. Current Monolith Structure
- `Act0ShellStateV1` holds:
  - Progression state (worlds, lessons, tasks, runner)
  - Review state (mistakes, stats, repair)
  - Recommendation logic (learning path, next action)
  - Placement mapping (diagnostic, skill stats)
  - Profile/habit state (player, streak, achievements)
  - UI tokens (labels, colors, sizes)
  - Feedback/copy (titles, reasons)

## 2. Target Split (First Pass)
- **progression/**
  - progression_state.dart
  - lesson_card.dart
  - world_card.dart
- **review/**
  - review_state.dart
  - mistake_record.dart
- **recommendation/**
  - recommendation_logic.dart
- **placement/**
  - placement_mapping.dart
  - skill_stat.dart
- **profile/**
  - profile_state.dart
  - habit_state.dart
  - achievement.dart
- **tokens/**
  - act0_shell_tokens_v1.dart (UI only)
- **feedback/**
  - feedback_titles.dart
  - feedback_reasons.dart

## 3. Coupling Audit (Safe for All Agents)
- [ ] Progression state uses profile/habit fields (should be decoupled)
- [ ] Review state reads from progression (should use interface)
- [ ] Recommendation logic depends on both progression and review (should be injected)
- [ ] Placement mapping uses skill stats from profile (should be isolated)
- [ ] UI tokens and feedback/copy are referenced in state (should be imported only in UI layer)

## 4. Safe TODO/ROADMAP Comments (For All Agents)
- Add `// TODO(Wave F): Move to progression_state.dart` above progression logic blocks
- Add `// TODO(Wave F): Move to review_state.dart` above review logic
- Add `// TODO(Wave F): Move to profile_state.dart` above profile/habit logic
- Add `// TODO(Wave F): Move to act0_shell_tokens_v1.dart` above UI tokens
- Add `// TODO(Wave F): Decouple feedback/copy from state` above feedback/copy blocks

## 5. Next Steps (Non-Blocking)
- No code moved yet — only comments and roadmap
- All agents can continue work in monolith; split will be coordinated after preview suite is green
- This doc is the single source of split plan for Wave F

---

**Created:** 2026-05-13
**Author:** Copilot agent (Wave F prep)
