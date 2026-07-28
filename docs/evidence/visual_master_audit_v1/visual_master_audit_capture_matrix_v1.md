# Visual Master Audit Capture Matrix v1

Candidate: `7c2fc8c7421bd3dabc1a2d13bbbcebb3bcf08b72`

Rows: **80**; **LIVE_PRODUCTION**: 44; **PRODUCTION_RENDERER_INJECTED_STATE**: 36.

## Acceptance gates

- all_rows_final_candidate_sha: `True`
- unique_state_device_modifier: `True`
- text_scale_1_4_minimum_10: `True`
- text_scale_required_families: `True`
- reduced_motion_core_states: `True`
- geometry_alias_policy: `iphone17_class and tall_phone share 402x874; only tall_phone is canonical for this pack.`
- geometry_alias_verified: `True`

## Geometry aliases

- `iphone17_class` → `tall_phone` for `runner.theory.hand_rankings`: `GEOMETRY_ALIAS`, same SHA: `True`
- `iphone17_class` → `tall_phone` for `runner.table_read.live`: `GEOMETRY_ALIAS`, same SHA: `True`
- `iphone17_class` → `tall_phone` for `runner.table_read.recheck.live`: `GEOMETRY_ALIAS`, same SHA: `True`
- `iphone17_class` → `tall_phone` for `runner.action_selection.live`: `GEOMETRY_ALIAS`, same SHA: `True`
- `iphone17_class` → `tall_phone` for `runner.seat_selection.vrt02`: `GEOMETRY_ALIAS`, same SHA: `True`
- `iphone17_class` → `tall_phone` for `runner.seat_selection.vrt02_correct`: `GEOMETRY_ALIAS`, same SHA: `True`
- `iphone17_class` → `tall_phone` for `runner.seat_selection.vrt02_incorrect`: `GEOMETRY_ALIAS`, same SHA: `True`
- `iphone17_class` → `tall_phone` for `runner.world3_seat_derivative`: `GEOMETRY_ALIAS`, same SHA: `True`
- `iphone17_class` → `tall_phone` for `runner.hand_comparison.live`: `GEOMETRY_ALIAS`, same SHA: `True`
- `iphone17_class` → `tall_phone` for `runner.showdown.live`: `GEOMETRY_ALIAS`, same SHA: `True`
- `iphone17_class` → `tall_phone` for `runner.completion.review`: `GEOMETRY_ALIAS`, same SHA: `True`

## Reduced-motion results

- `core.placement`: `FRAME_CAPTURED`
- `core.welcome`: `FRAME_CAPTURED`
- `core.firstWeekHome`: `FRAME_CAPTURED`
- `core.firstWeekLearn`: `EXPECTED_STATIC_PARITY`
- `core.runnerTheory`: `FRAME_CAPTURED`
- `core.runnerDrill`: `FRAME_CAPTURED`
- `core.runnerFirstWrongFeedback`: `EXPECTED_STATIC_PARITY`
- `core.repairResult`: `FRAME_CAPTURED`
- `core.firstWeekReview`: `EXPECTED_STATIC_PARITY`
- `core.profileEvidence`: `FRAME_CAPTURED`
- `core.sessionSummary`: `FRAME_CAPTURED`
- `core.worldCompletion`: `FRAME_CAPTURED`
- `runner.theory.hand_rankings`: `EXPECTED_STATIC_PARITY`
- `runner.table_read.live`: `EXPECTED_STATIC_PARITY`
- `runner.table_read.recheck.live`: `EXPECTED_STATIC_PARITY`
- `runner.action_selection.live`: `FRAME_CAPTURED`
- `runner.seat_selection.vrt02`: `EXPECTED_STATIC_PARITY`
- `runner.seat_selection.vrt02_correct`: `FRAME_CAPTURED`
- `runner.seat_selection.vrt02_incorrect`: `FRAME_CAPTURED`
- `runner.world3_seat_derivative`: `FRAME_CAPTURED`
- `runner.hand_comparison.live`: `EXPECTED_STATIC_PARITY`
- `runner.showdown.live`: `EXPECTED_STATIC_PARITY`
- `runner.completion.review`: `FRAME_CAPTURED`

## Core-family coverage

| Family | Status | Representative | Block |
| --- | --- | --- | --- |
| placement_intro_question_result | PRODUCTION_RENDERER_INJECTED_STATE | core.placement | none |
| welcome_and_first_handoff | PRODUCTION_RENDERER_INJECTED_STATE | core.welcome | none |
| home | PRODUCTION_RENDERER_INJECTED_STATE | core.firstWeekHome | none |
| learn | PRODUCTION_RENDERER_INJECTED_STATE | core.firstWeekLearn | none |
| theory | LIVE_PRODUCTION | runner.theory.hand_rankings | none |
| table_read | LIVE_PRODUCTION | runner.table_read.live | none |
| decision | LIVE_PRODUCTION | runner.action_selection.live | none |
| VRT02 | LIVE_PRODUCTION | runner.seat_selection.vrt02 | none |
| incorrect_feedback | LIVE_PRODUCTION | runner.seat_selection.vrt02_incorrect | none |
| repair_recheck | LIVE_PRODUCTION | runner.table_read.recheck.live | none |
| practice | PRODUCTION_RENDERER_INJECTED_STATE | core.runnerDrill | none |
| review_queued_focused | PRODUCTION_RENDERER_INJECTED_STATE | core.firstWeekReview | none |
| profile_evidence | PRODUCTION_RENDERER_INJECTED_STATE | core.profileEvidence | none |
| session_summary | PRODUCTION_RENDERER_INJECTED_STATE | core.sessionSummary | none |
| lesson_completion | LIVE_PRODUCTION | runner.completion.review | none |
| world_band_milestone | PRODUCTION_RENDERER_INJECTED_STATE | core.worldCompletion | none |
| world3_derivative | LIVE_PRODUCTION | runner.world3_seat_derivative | none |
| hand_comparison | LIVE_PRODUCTION | runner.hand_comparison.live | none |
| showdown | LIVE_PRODUCTION | runner.showdown.live | none |
| course_map_locked_state | PRODUCTION_CAPTURE_UNREACHABLE | — | EXTERNAL_OR_ROUTE_ACCESS_REQUIRED |
| Sharky_art_transition | PRODUCTION_CAPTURE_UNREACHABLE | — | EXTERNAL_OR_ROUTE_ACCESS_REQUIRED |

| State | Geometry | Modifier | Phase | Status | SHA-256 |
| --- | --- | --- | --- | --- | --- |
| core.placement | compact | none | placement_question | PRODUCTION_RENDERER_INJECTED_STATE | `aa5a39a1ad123bc55624fe66978665790346bacb4b242bcd3f395855985e676b` |
| core.welcome | compact | none | welcome_handoff | PRODUCTION_RENDERER_INJECTED_STATE | `a0a655442ae50f0b9b71fc4215ac864de396b8b35d159ab9063c79967ba7149c` |
| core.firstWeekHome | compact | none | home_learn | PRODUCTION_RENDERER_INJECTED_STATE | `ff81546c94276693a47542676cda4a46e6e73b04077cc707d5311dcfe21e321d` |
| core.firstWeekLearn | compact | none | home_learn | PRODUCTION_RENDERER_INJECTED_STATE | `a7b6f614289732cb86b69b1a9e2e76eda6a55f6fd3b1d9bf203a885a1fb0dc59` |
| core.runnerTheory | compact | none | theory | PRODUCTION_RENDERER_INJECTED_STATE | `ab33ac012e2dfad1aee24dd5d746bcf2f6e744ba33e947012f281dbf54f52173` |
| core.runnerDrill | compact | none | decision | PRODUCTION_RENDERER_INJECTED_STATE | `80b9957b09e39eb6fd94e3623284e59347c253fb4ff481a707ac05f3fc0e85da` |
| core.runnerFirstWrongFeedback | compact | none | incorrect_feedback | PRODUCTION_RENDERER_INJECTED_STATE | `0f43f8137219de22a1d3f0bf30dce3b2ebcb8ee2b7640c980694c3f3da5cfd32` |
| core.repairResult | compact | none | repair_recheck | PRODUCTION_RENDERER_INJECTED_STATE | `f3c6f247ac0987b5da1724a16f5a4ac7b8258300e5cd54a5da5ceb8df7e179e5` |
| core.firstWeekReview | compact | none | review_focused | PRODUCTION_RENDERER_INJECTED_STATE | `0629b61c12ef926d6959c3f1e2ec88111c75b0f74deb4ab1bc0821b171373f55` |
| core.profileEvidence | compact | none | profile_evidence | PRODUCTION_RENDERER_INJECTED_STATE | `bdcebaaf8ecb17aa94c0c6e2349a81f23e1d9dda73841b47ddd691a8ee5f5430` |
| core.sessionSummary | compact | none | session_summary | PRODUCTION_RENDERER_INJECTED_STATE | `fc157195d5e6ba571b0b9182339ddc31c2654630ec78d573c21d8464f7341a11` |
| core.worldCompletion | compact | none | world_milestone | PRODUCTION_RENDERER_INJECTED_STATE | `a1c6ed2474490442a504c4114e286d32164178cd771b6dbb3333e70f9195af73` |
| core.placement | compact | reduced_motion | placement_question | PRODUCTION_RENDERER_INJECTED_STATE | `c748e5c9f7f6bb4b0dbe61da59235757e85cf8ecfa9a6ec45032c16c187d5d68` |
| core.welcome | compact | reduced_motion | welcome_handoff | PRODUCTION_RENDERER_INJECTED_STATE | `42bd7930e4b92c678b679cfa147f6e1b9e04226abc510d831b439321f33e6fc8` |
| core.firstWeekHome | compact | reduced_motion | home_learn | PRODUCTION_RENDERER_INJECTED_STATE | `6d70444bac24e81715cc0a8143f5550b7e31bc68c5e0d6633fcef11f9b5523c6` |
| core.firstWeekLearn | compact | reduced_motion | home_learn | PRODUCTION_RENDERER_INJECTED_STATE | `a7b6f614289732cb86b69b1a9e2e76eda6a55f6fd3b1d9bf203a885a1fb0dc59` |
| core.runnerTheory | compact | reduced_motion | theory | PRODUCTION_RENDERER_INJECTED_STATE | `9c933f5de1954c25a37e4a6316ed520f804ae02334810b18392d7fb5d7fb1ae8` |
| core.runnerDrill | compact | reduced_motion | decision | PRODUCTION_RENDERER_INJECTED_STATE | `475d4646c451060e6b1757501ebb03df08499cbd3df8f2c489d11ff977bdd34d` |
| core.runnerFirstWrongFeedback | compact | reduced_motion | incorrect_feedback | PRODUCTION_RENDERER_INJECTED_STATE | `0f43f8137219de22a1d3f0bf30dce3b2ebcb8ee2b7640c980694c3f3da5cfd32` |
| core.repairResult | compact | reduced_motion | repair_recheck | PRODUCTION_RENDERER_INJECTED_STATE | `b7833389191b73699d1e40d60aee64ea6cf54131481ca897d214d750120c3e96` |
| core.firstWeekReview | compact | reduced_motion | review_focused | PRODUCTION_RENDERER_INJECTED_STATE | `0629b61c12ef926d6959c3f1e2ec88111c75b0f74deb4ab1bc0821b171373f55` |
| core.profileEvidence | compact | reduced_motion | profile_evidence | PRODUCTION_RENDERER_INJECTED_STATE | `b66a625c116525136307e879e2d5bb4941dc5ead6869454d14bbcbb3d5d7d51e` |
| core.sessionSummary | compact | reduced_motion | session_summary | PRODUCTION_RENDERER_INJECTED_STATE | `c89a8f1890d41e15cf5df943bd9b4d1d5fcea65411b79a679b6761d3336eb788` |
| core.worldCompletion | compact | reduced_motion | world_milestone | PRODUCTION_RENDERER_INJECTED_STATE | `7be86402991378085ad589785a818986cf046f7fdf3b98758dc8daac03006cd5` |
| core.placement | compact | text_scale_1_4 | placement_question | PRODUCTION_RENDERER_INJECTED_STATE | `338cac4dad10d3689332760484ed86c9080c2507549d8ab5d195dc4d7557e4e0` |
| core.welcome | compact | text_scale_1_4 | welcome_handoff | PRODUCTION_RENDERER_INJECTED_STATE | `469bfeade8af7e1df7e1ae6e47a03f79388bbcfdb24b375209d36cffd89cc5a1` |
| core.firstWeekHome | compact | text_scale_1_4 | home_learn | PRODUCTION_RENDERER_INJECTED_STATE | `5c2f7d1ae652da24732597d039c78eeddf5777eba7e5e62540c38334ee041067` |
| core.firstWeekLearn | compact | text_scale_1_4 | home_learn | PRODUCTION_RENDERER_INJECTED_STATE | `e7c840d0e4005c862163622d3cd8148c68243c4a57e8ac532870b0acc424014d` |
| core.runnerTheory | compact | text_scale_1_4 | theory | PRODUCTION_RENDERER_INJECTED_STATE | `28a01eaa98f14fed599fc28d337f5856b2db30d3e5ff52fa76a0bb039ce288d5` |
| core.runnerDrill | compact | text_scale_1_4 | decision | PRODUCTION_RENDERER_INJECTED_STATE | `64df8e7a842c9df76ebe38577ca1f43733b99f91c4ffc3e34107e63a82b3ad05` |
| core.runnerFirstWrongFeedback | compact | text_scale_1_4 | incorrect_feedback | PRODUCTION_RENDERER_INJECTED_STATE | `dcb4f1c7b9c203f0dd0cab68abde546ce959e4eb2aacc7fc1bf9caa089d181ba` |
| core.repairResult | compact | text_scale_1_4 | repair_recheck | PRODUCTION_RENDERER_INJECTED_STATE | `c4fc86d791a5fb9a1fd3abb412a17be446e45effa5359fece54614d57469a6ea` |
| core.firstWeekReview | compact | text_scale_1_4 | review_focused | PRODUCTION_RENDERER_INJECTED_STATE | `7843cbaa0bb35e07847f93205ca944ad459730631f0d858924a24b82c1563dcb` |
| core.profileEvidence | compact | text_scale_1_4 | profile_evidence | PRODUCTION_RENDERER_INJECTED_STATE | `656a81f4797353b751ab90099865a0e4206d2f93ee183361a764434d2e34d9da` |
| core.sessionSummary | compact | text_scale_1_4 | session_summary | PRODUCTION_RENDERER_INJECTED_STATE | `ee6b21cd08b16c595187dadc44e0850750d7d1e215231e2974eebb61b9bef9d0` |
| core.worldCompletion | compact | text_scale_1_4 | world_milestone | PRODUCTION_RENDERER_INJECTED_STATE | `3fd9ae311dfe00165413f4dff7b70d98ab1c0ca61094c953d2f317d0222afb01` |
| runner.theory.hand_rankings | compact | none | theory | LIVE_PRODUCTION | `99f3cdcc6d04d3b8657bc4b9594058a9549d204b4b6b69f10c9ab025bc947836` |
| runner.table_read.live | compact | none | table_reading_prompt | LIVE_PRODUCTION | `a9ee0d6a8a7c43f9c8bd00e907b3f64692ac905b52b66a7759631f56848ec683` |
| runner.table_read.recheck.live | compact | none | recheck | LIVE_PRODUCTION | `8fc098761bc163921a84d545ee6446babd0b00deec2ba7f7183d49599c7bef70` |
| runner.action_selection.live | compact | none | action_selection | LIVE_PRODUCTION | `753504ac4045388bab63270c319ac976c230ca6d54c34969819cf0d89b16b156` |
| runner.seat_selection.vrt02 | compact | none | seat_selection | LIVE_PRODUCTION | `7b73bbbf7da871481bfee6c847cc9a0e084853fcfc5644c35f6dd602f9f74c72` |
| runner.seat_selection.vrt02_correct | compact | none | correct_feedback | LIVE_PRODUCTION | `7ee1a7567ef63ddcbe20276dbb705c55a84e46b75c088b8eb9ab823aa2234ddb` |
| runner.seat_selection.vrt02_incorrect | compact | none | incorrect_feedback | LIVE_PRODUCTION | `426bf40f8d8b5beb729765aa13bec2bbc8454ecefcff1d72e796f51287c1075d` |
| runner.world3_seat_derivative | compact | none | seat_selection_derivative | LIVE_PRODUCTION | `cca401245d7aba91b31d797b57c404b799f47cbc583e2be0b60aeb8d5165969f` |
| runner.hand_comparison.live | compact | none | non_table_decision | LIVE_PRODUCTION | `548dadf6efb2269a26033d27064ce5aef8f1984db3d084a9b4f9103f7a9e320f` |
| runner.showdown.live | compact | none | table_reading_prompt | LIVE_PRODUCTION | `f460ea89fcd0cfdbc5b70649c84a822cd04988c4e27e08531f2fa1a24a30715e` |
| runner.completion.review | compact | none | lesson_completion | LIVE_PRODUCTION | `775d0d5b2ed0b7ab50d4626daf351091fadf1ebcf2865397c7c7c0d964be5965` |
| runner.theory.hand_rankings | compact | reduced_motion | theory | LIVE_PRODUCTION | `99f3cdcc6d04d3b8657bc4b9594058a9549d204b4b6b69f10c9ab025bc947836` |
| runner.table_read.live | compact | reduced_motion | table_reading_prompt | LIVE_PRODUCTION | `a9ee0d6a8a7c43f9c8bd00e907b3f64692ac905b52b66a7759631f56848ec683` |
| runner.table_read.recheck.live | compact | reduced_motion | recheck | LIVE_PRODUCTION | `8fc098761bc163921a84d545ee6446babd0b00deec2ba7f7183d49599c7bef70` |
| runner.action_selection.live | compact | reduced_motion | action_selection | LIVE_PRODUCTION | `a05d7b5da05b58a9d239691ffbfbb10f9b46e5383ec948cf0035576bc971012c` |
| runner.seat_selection.vrt02 | compact | reduced_motion | seat_selection | LIVE_PRODUCTION | `7b73bbbf7da871481bfee6c847cc9a0e084853fcfc5644c35f6dd602f9f74c72` |
| runner.seat_selection.vrt02_correct | compact | reduced_motion | correct_feedback | LIVE_PRODUCTION | `bbf98a114bcecc640145e070900b8c1c61f5c03ad60d88c7a0e4cd20630ef469` |
| runner.seat_selection.vrt02_incorrect | compact | reduced_motion | incorrect_feedback | LIVE_PRODUCTION | `ab846d285dfeec13d575486238c21e0953d146c60184ce1e52dfcd1ba8498d0b` |
| runner.world3_seat_derivative | compact | reduced_motion | seat_selection_derivative | LIVE_PRODUCTION | `efcc31b94e2721da76fe73084cbc09aabd2280df652722012522a0a7d804fe4d` |
| runner.hand_comparison.live | compact | reduced_motion | non_table_decision | LIVE_PRODUCTION | `548dadf6efb2269a26033d27064ce5aef8f1984db3d084a9b4f9103f7a9e320f` |
| runner.showdown.live | compact | reduced_motion | table_reading_prompt | LIVE_PRODUCTION | `f460ea89fcd0cfdbc5b70649c84a822cd04988c4e27e08531f2fa1a24a30715e` |
| runner.completion.review | compact | reduced_motion | lesson_completion | LIVE_PRODUCTION | `239c5b9adf8b5f74e4a0ef3d42cc3e7973d0c9e4c7dec46807235d4ef6791a41` |
| runner.theory.hand_rankings | compact | text_scale_1_4 | theory | LIVE_PRODUCTION | `e0137d22b9cbbb58ef7f3cb3dd3646ade580bb4c87ff92aa551ba1da6aed348f` |
| runner.table_read.live | compact | text_scale_1_4 | table_reading_prompt | LIVE_PRODUCTION | `950a22062da0e06d4a917539adff45dace4ce38e8dcf535bcaae96bdb3d61d44` |
| runner.table_read.recheck.live | compact | text_scale_1_4 | recheck | LIVE_PRODUCTION | `505d7be91ae923be8e547ac482fc3195e72634475452fb3dfb0c36e9f3987b13` |
| runner.action_selection.live | compact | text_scale_1_4 | action_selection | LIVE_PRODUCTION | `a311ad9b6bd9e7e47fbafc2d78ce5b701ca25e0ee407ee11f8e849903b3cf088` |
| runner.seat_selection.vrt02 | compact | text_scale_1_4 | seat_selection | LIVE_PRODUCTION | `e66c446cb5b84fee08c868b4a99a64d8e8f9588a2fff0b375d79e63d2cd39646` |
| runner.seat_selection.vrt02_correct | compact | text_scale_1_4 | correct_feedback | LIVE_PRODUCTION | `a43a1865e3d0de66d8e6dcc73a43de64d4a68631ab425f123600f00131633ca9` |
| runner.seat_selection.vrt02_incorrect | compact | text_scale_1_4 | incorrect_feedback | LIVE_PRODUCTION | `79d5cb3fbbd8b2722194e631d3409aace00d12efee6a43dd0ed5c1cb786c5be0` |
| runner.world3_seat_derivative | compact | text_scale_1_4 | seat_selection_derivative | LIVE_PRODUCTION | `db02ac466c0342aef73e09b1a7d21272fab9136ebcafb03d65118aaff78ecc9d` |
| runner.hand_comparison.live | compact | text_scale_1_4 | non_table_decision | LIVE_PRODUCTION | `be4cfc14d2fadf00760fe9326fd1689527885ec7e5a4b85fd561fae591f72191` |
| runner.showdown.live | compact | text_scale_1_4 | table_reading_prompt | LIVE_PRODUCTION | `2dcf06f003aed6308c6e8d9d4fde7e1a1c5459b21073e4ee3b04eec88a2cc67c` |
| runner.completion.review | compact | text_scale_1_4 | lesson_completion | LIVE_PRODUCTION | `b6f64fdf4e0fdb5067f2b879e0c11c2962d880f9e996da7f7323dd2344b5c548` |
| runner.theory.hand_rankings | tall_phone | none | theory | LIVE_PRODUCTION | `01984a62df60a4cfa091df86508deda17d2343dae0864e67c0d26fd8e8e857e0` |
| runner.table_read.live | tall_phone | none | table_reading_prompt | LIVE_PRODUCTION | `6f0e0c08f51f06d343d06beb2ac5aaf51f6e169debaa4949b750364d09f34722` |
| runner.table_read.recheck.live | tall_phone | none | recheck | LIVE_PRODUCTION | `8a7630b93c7b12791d9c20a3a36b7387579d2bb1109667118587fb9fd2aa370b` |
| runner.action_selection.live | tall_phone | none | action_selection | LIVE_PRODUCTION | `d5d1501e064e255ac94815793a3a845c8249b36199b84c28ae565e776d306157` |
| runner.seat_selection.vrt02 | tall_phone | none | seat_selection | LIVE_PRODUCTION | `aee6bf4780825be3e802e18072ddc7437164a033da447c1dc1d7e564ce73599e` |
| runner.seat_selection.vrt02_correct | tall_phone | none | correct_feedback | LIVE_PRODUCTION | `efaabc34a82f0dcfcb89cd9d8767d0617164400912398c9402b15755449cb9d5` |
| runner.seat_selection.vrt02_incorrect | tall_phone | none | incorrect_feedback | LIVE_PRODUCTION | `4fab764aaf63003758ea1d8305f6d990c585842c91c0f0798210689cacd49cc4` |
| runner.world3_seat_derivative | tall_phone | none | seat_selection_derivative | LIVE_PRODUCTION | `16c84a19f72970bd4f66e469bc4f8f204abd9b0852e908a60642839a42416ffe` |
| runner.hand_comparison.live | tall_phone | none | non_table_decision | LIVE_PRODUCTION | `f2d81d46ff8dbb40ffbc6f276f19d93c3aa355b09a13772e9a728ff3fcf09439` |
| runner.showdown.live | tall_phone | none | table_reading_prompt | LIVE_PRODUCTION | `23bb493e976513dc8b48a04823fac7683105757a8fb5e8c141250276a09433d7` |
| runner.completion.review | tall_phone | none | lesson_completion | LIVE_PRODUCTION | `50bc157f40ded9cd4d4ec4840105c21bb1a0720e6c74cff5e6593cf1f1757ee0` |
