# Project Dependency Graph Distillation v1

## 1. Scope and status

This is a compact navigation aid distilled from local generated Graphify output
on 2026-06-23. It is advisory only. It does not override active SSOT docs,
roadmap order, source code, tests, user scope, or current runtime evidence.

The graph may be stale because no refresh was run for this note. Do not treat a
community name, graph edge, or degree score as proof that a subsystem is active
or safe to change.

## 2. Corpus summary

| Item | Local evidence |
| --- | --- |
| Corpus | 19,399 files, about 16.2M words |
| Graph | 74,191 nodes, 100,741 edges, 2,819 communities |
| Extraction | 99% extracted, 1% inferred, 0% ambiguous |
| Import cycles | None detected by Graphify |
| `GRAPH_REPORT.md` | about 637 KB |
| `graph.json` | about 60 MB |
| `graph.html` | about 55 MB |

All three inputs are generated local evidence in `graphify-out/` and remain
ignored and uncommitted.

## 3. Useful navigation hubs

Use these community labels as search starting points, then verify against the
active SSOT chain and source ownership.

| Need | Useful hub / files | Navigation value |
| --- | --- | --- |
| Active learner route | `Act0 Shell State`, `Act0 Home Shell`, `Act0 UI Components`, `Lesson Runner Shell` | Start at `lib/ui_v2/act0_shell/`, especially the preview shell and lesson runner. |
| Deterministic repair | `Learning State Management`, `Repair Intent Mapping` | Locate repair intent, mistake priority, receipt, and Review/Home handoff seams. |
| Session drills | `Session Drill Player`, `Drill Runner Adapter`, `Achievements & Drill Runtime` | Start at canonical launcher API, runtime adapter, and surfaced session runner. |
| Content/runtime boundary | `Content Manifest Loading`, `Manifest Validation & Checkpoints`, `Drill Runner Adapter` | Find authored-session and evaluator/adapter dependencies without using content inventory as roadmap truth. |
| Tooling and validation | `Pack Validation Tools`, `Audit Hub Builder`, `Validation Gate Rules` | Find narrow validators and evidence scripts; generated output remains non-authoritative. |

Confirmed active-path caution: Graphify places the canonical session-drill
launcher in `Session Drill Player` and its surfaced runner in
`Drill Runner Adapter`. The runner still lives under `lib/archive/legacy_runners/`
but is connected to the canonical launch path. Its location does not make it
safe to edit without a dedicated runtime contract.

## 4. Noisy graph areas

High-degree nodes are not product navigation authority. In this graph the
largest nodes are framework or syntactic hubs: `StatelessWidget` (1,082 edges),
`StatefulWidget` (739), `_` (470), and `MaterialPageRoute` (233). They are
expected to be high-degree but are low-value for determining product ownership.

Likewise, broad word queries can pull dormant pack, editor, autogen,
localization, analytics, persona, and legacy systems. Prefer exact symbols,
paths, or one narrow concept; inspect the returned files before acting.

## 5. Active versus legacy questions

- The graph confirms a live edge cluster from `canonicalSessionDrillRouteV1`
  and `CanonicalLauncherV1` to
  `CanonicalTerminalSessionDrillSurfacedRunnerV1` in `archive/legacy_runners`.
  This is a compatibility/runtime boundary, not permission to revive legacy
  UI families.
- `ModernTableScreenV1` appears in its own archived community but has graph
  connections to the active lesson runner. Treat it as a protected dependency:
  inspect the exact edge and source contract before any change.
- Communities such as AI personalization, dashboards, boosters, analytics,
  and older pack screens exist in the corpus. Their presence does not make them
  active Act0 product scope.

## 6. Current W6 repair-loop map

```
W6 range-bucket miss
  -> session-drill repair receipt adapter
  -> durable receipt persistence
  -> internal recheck consumer candidate
  -> SessionDrillRecheckLaunchQueueItemV1
  -> STOP: no Act0 cross-family queue target or target-drill route contract
```

The launch descriptor preserves source and target session/drill identity. It
cannot safely enter existing Act0 task-intent repair routing: that routing owns
Act0 world/lesson/task identity, while the canonical session route accepts only
a session id and the surfaced runner starts at its normal first drill.

## 7. Danger zones

Before proposing a change, verify source and SSOT ownership for:

- Modern Table and runner boundaries;
- canonical root and route APIs;
- telemetry contracts and owned event payloads;
- screenshot/capture tooling and all generated outputs;
- authored content, glossary safety, and session manifests;
- monetization/entitlement work;
- persona, AI/chat, dashboard, and XP/economy systems.

Graph links are discovery evidence, not authorization to cross these seams.

## 8. Future Graphify use

1. Run `graphify hook-check` as the lightweight default.
2. When `graphify-out/graph.json` exists, use a targeted `graphify query`,
   `path`, or `explain` for a specific seam.
3. Confirm all graph-derived claims in current source, tests, and SSOT docs.
4. Refresh with `graphify update .` only when graph freshness is materially
   required by the task.
5. Never stage or commit `graphify-out/` or `output/graphify-out/`.

## 9. Questions for a future architecture audit

1. Which explicit contract owns the boundary between Act0 task-intent repairs
   and session-drill recheck targets?
2. Can canonical session-drill launch support a validated optional initial
   drill id without altering completion, telemetry, or progress semantics?
3. Which archived runner files remain required by the canonical route, and
   which are truly dormant?
4. What is the smallest authoritative map of active Act0 launch owners and
   their allowed target types?
5. Which large Act0 shell responsibilities should be isolated only after a
   behavior-preserving contract is proven?
6. Which high-degree services are current-route dependencies versus legacy
   corpus noise?
7. What evidence budget should distinguish documentation-only, service-seam,
   route-contract, and visible UI changes?

## 10. Recommended Project Intelligence Layer step

Create **Agent Context Pack v1** next: a short, source-verified orientation
pack that names active SSOT docs, canonical runtime entry, protected seams,
current repair-loop boundary, standard validation commands, and generated
output policy. Keep it smaller and more durable than this graph distillation.

## Inputs inspected

- `docs/_reviews/graphify_tooling_setup_audit_v1.md`
- local `graphify-out/GRAPH_REPORT.md`
- local `graphify-out/graph.json`
- local `graphify-out/graph.html`
- targeted Graphify queries for Act0/runner, repair, session launch,
  legacy/archive, generated-output, and Modern Table relationships

## Intentional non-changes

No app code, UI, route, telemetry, Modern Table, content, glossary, tests, or
generated graph output changed. No full Graphify refresh was run.
