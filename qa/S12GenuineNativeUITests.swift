import XCTest
import UIKit
import Darwin

final class S12GenuineNativeUITests: XCTestCase {
    private let app = XCUIApplication(bundleIdentifier: "com.example.pokerAnalyzer")
    override func setUpWithError() throws { continueAfterFailure = false }

    private func capture(_ tag: String, owning: XCUIApplication? = nil) {
        print("S11_GATE_STATE " + tag)
        print("S11_NATIVE_TREE_BEGIN " + tag + "\n" + (owning ?? app).debugDescription + "\nS11_NATIVE_TREE_END " + tag)
        // XCTest's screen service timed out on a responsive graded frame.
        // The hosted observer uses simctl's independently proven capture path.
        print("S11_SCREEN_CHECKPOINT " + tag + " epoch=" + String(Date().timeIntervalSince1970))
        fflush(stdout)
        RunLoop.current.run(until: Date().addingTimeInterval(45))
        print("S11_SCREEN_RELEASE " + tag + " epoch=" + String(Date().timeIntervalSince1970))
        fflush(stdout)
    }
    private func visible(_ label: String, timeout: TimeInterval = 3) -> Bool {
        let p = NSPredicate(format:"label CONTAINS[cd] %@",label)
        return app.descendants(matching:.any).matching(p).firstMatch.waitForExistence(timeout:timeout)
    }
    /// Intro -> Placement. A hosted run left the Intro unchanged 3s after a
    /// hittable `Find my start` tap while another run advanced; wait for the
    /// real transition, and only if the Intro is still the live screen repeat
    /// the same user tap once (logged). No state is injected.
    private func openPlacementFromIntro() {
        tapButton("Find my start")
        if visible("Where are you starting from?", timeout: 12) { return }
        let again = app.buttons.matching(identifier: "Find my start").firstMatch
        if again.exists && again.isEnabled && again.isHittable {
            print("S11_NAV_RETAP_AFTER_NO_TRANSITION Find my start")
            again.tap()
        }
        XCTAssertTrue(visible("Where are you starting from?", timeout: 20), "PLACEMENT_EXPERIENCE_SCREEN_NOT_FOUND")
    }
    /// Welcome step 2/3 is an ungraded action row. Native AX exposes real
    /// buttons `Fold`/`Check`/`Call`; the lettered StaticText form is only used
    /// by graded runner options. Tap the actual enabled Check button.
    private func tapWelcomeCheck() {
        XCTAssertTrue(visible("What action keeps playing for free?", timeout: 12), "WELCOME_DEMO_WRONG_SCREEN")
        tapSelectableOption("B\nCheck")
    }
    private func enabledButton(_ label: String, timeout: TimeInterval = 5) -> XCUIElement {
        let button = app.buttons.matching(identifier: label).firstMatch
        if !button.waitForExistence(timeout: timeout) {
            // Record the real AX tree and screen before failing; the previous
            // repair run left only the failed query chain.
            capture("missing_button_" + label.replacingOccurrences(of: " ", with: "_").prefix(24))
        }
        XCTAssertTrue(button.exists, "MISSING_REQUIRED_BUTTON " + label)
        XCTAssertTrue(button.isEnabled, "REQUIRED_CTA_DISABLED " + label)
        XCTAssertTrue(button.isHittable, "REQUIRED_CTA_NOT_HITTABLE " + label)
        return button
    }
    private func tapButton(_ label:String) {
        let b=enabledButton(label)
        print("S11_NAV_TAP_BUTTON " + label)
        b.tap()
    }
    private func tapTab(_ label: String) {
        for type: XCUIElement.ElementType in [.button, .staticText] {
            var matches = app.descendants(matching:type).matching(NSPredicate(format:"label == %@",label)).allElementsBoundByIndex.filter { $0.exists && $0.isHittable }
            // On the Review page the page title also reads "Review"; the bottom tab bar
            // item is the one in the lowest 15% of the window.
            if matches.count > 1 { matches = matches.filter { $0.frame.midY > app.frame.height * 0.85 } }
            if matches.count == 1 { matches[0].tap(); return }
        }
        persistedCheckpoint("missing_tab_"+label)
        XCTFail("NO_UNIQUE_NATIVE_TAB_"+label)
    }
    private func leaveRunnerThroughBack() {
        // Native receipt missing_tab_Home: active runner deliberately has no
        // bottom tabs. Its source-owned Back is the sole upper-left AX Button;
        // Flutter's IconButton currently exposes an empty native label.
        let back = app.buttons.allElementsBoundByIndex.filter {
            $0.exists && $0.isEnabled && $0.isHittable &&
            $0.frame.minX < app.frame.width * 0.15 &&
            $0.frame.minY < app.frame.height * 0.15 &&
            $0.frame.width <= 48 && $0.frame.height <= 48 &&
            ($0.label.isEmpty || $0.label == "Back")
        }
        guard back.count == 1 else {
            persistedCheckpoint("C9_runner_back_not_unique")
            XCTFail("NO_UNIQUE_SOURCE_OWNED_RUNNER_BACK"); return
        }
        print("S12_NAV_REAL_RUNNER_BACK " + back[0].debugDescription)
        back[0].tap()
        XCTAssertTrue(visible("Learn", timeout: 12), "RUNNER_BACK_DID_NOT_RETURN_TO_LEARN")
    }
    /// Responsive layouts expose the same authored option differently: standard
    /// width as lettered StaticText ("B\nCheck"), large width as a real Button
    /// labelled with the option text ("Check"). Native AX trees from runs
    /// 38546378310 (440x956 buttons) and 38546382439 (402x874 lettered text).
    /// Lettered/prefix match first, then the exact Button label of the option
    /// text. Always a unique, hittable element; never a seat label (StaticText).
    private func findOption(_ prefix: String) -> (found: [XCUIElement], via: String) {
        let pred = NSPredicate(format:"label BEGINSWITH[cd] %@", prefix)
        for type: XCUIElement.ElementType in [.button, .staticText] {
            let found = app.descendants(matching:type).matching(pred).allElementsBoundByIndex.filter { $0.exists && $0.isHittable }
            if !found.isEmpty { return (found, "prefix") }
        }
        let chars = Array(prefix)
        if chars.count > 2, chars[1] == "\n", chars[0].isUppercase {
            let text = String(chars[2...])
            // Compact (375x667) quick-check buttons carry the text twice: "X\nX".
            let exact = app.buttons.matching(NSPredicate(format:"label == %@ OR label BEGINSWITH %@", text, text + "\n")).allElementsBoundByIndex.filter { $0.exists && $0.isHittable && $0.frame.midY < app.frame.height * 0.85 }
            if !exact.isEmpty { return (exact, "button_exact") }
        }
        return ([], "none")
    }
    private func tapSelectableOption(_ exactOrPrefix:String) {
        let (found, via) = findOption(exactOrPrefix)
        if found.count == 1 {
            XCTAssertTrue(found[0].isEnabled, "OPTION_DISABLED "+exactOrPrefix)
            print("S11_NAV_SELECT_OPTION requested="+exactOrPrefix+" actual="+found[0].label+" via="+via)
            found[0].tap()
            return
        }
        if found.count > 1 {
            XCTFail("AMBIGUOUS_SELECTABLE_OPTION "+exactOrPrefix+" count="+String(found.count))
            return
        }
        capture("missing_option_"+exactOrPrefix.replacingOccurrences(of:" ",with:"_").replacingOccurrences(of:"\n",with:"_").prefix(18))
        XCTFail("MISSING_SELECTABLE_OPTION "+exactOrPrefix)
    }
    private func continueTeachingUntil(_ clue:String, max:Int) {
        for i in 0..<max {
            if visible(clue) {
                print("S11_NAV_REACHED "+clue+" step="+String(i))
                return
            }
            let options=["Continue","Next","Got it"]
            let available=options.compactMap{ name -> XCUIElement? in
                let b=app.buttons.matching(identifier:name).firstMatch
                return (b.exists && b.isEnabled && b.isHittable) ? b : nil
            }
            guard available.count == 1 else {
                capture("teaching_no_unique_continue_"+String(i))
                XCTFail("TEACHING_PROGRESS_CTA_AMBIGUOUS_OR_MISSING expected="+clue+" count="+String(available.count))
                return
            }
            print("S11_NAV_TEACHING_CONTINUE "+available[0].label)
            available[0].tap()
        }
        capture("teaching_limit_"+clue.prefix(18))
        XCTFail("TEACHING_PROGRESS_LIMIT expected="+clue)
    }


    private func persistedCheckpoint(_ tag: String) {
        capture(tag)
        print("S11_PERSIST_CHECKPOINT " + tag + " epoch=" + String(Date().timeIntervalSince1970))
        fflush(stdout)
        // Give the read-only hosted preference probe time to copy the real domain.
        RunLoop.current.run(until: Date().addingTimeInterval(45))
        print("S11_PERSIST_RELEASE " + tag + " epoch=" + String(Date().timeIntervalSince1970))
        fflush(stdout)
    }

    private func waitForSelectable(_ prefix: String) {
        for page in 0..<18 {
            let overlay = app.otherElements.matching(NSPredicate(format:"label BEGINSWITH %@", "Theory navigation, page")).firstMatch
            if !overlay.exists {
                if let option = findOption(prefix).found.first, option.isEnabled { return }
            }
            let deadline = Date().addingTimeInterval(5)
            var choices: [XCUIElement] = []
            repeat {
                choices = ["Next", "Continue", "Got it", "Next hand"].compactMap { name in
                    let item = app.buttons.matching(identifier:name).firstMatch
                    return item.exists && item.isEnabled && item.isHittable ? item : nil
                }
                if choices.count == 1 { break }
                RunLoop.current.run(until:Date().addingTimeInterval(0.15))
            } while Date() < deadline
            guard choices.count == 1 else {
                capture("second_review_navigation_blocked_\(page)")
                XCTFail("NO_SOURCE_OWNED_THEORY_CONTINUE_TO_" + prefix)
                return
            }
            choices[0].tap()
        }
        XCTFail("SECOND_REVIEW_ENTRY_NOT_REACHED")
    }

    private func selectAction(_ action: String) {
        // The option list renders after a screen transition that can take several
        // seconds on the hosted runner (run on QA 9ea3329 looked 0.3s after the tap).
        // Poll for a unique hittable option; ambiguity and absence still fail.
        let deadline = Date().addingTimeInterval(20)
        repeat {
            for letter in ["A", "B", "C", "D"] {
                let prefix = letter + "\n" + action
                if let e = findOption(prefix).found.first, e.isEnabled { tapSelectableOption(prefix); return }
            }
            RunLoop.current.run(until: Date().addingTimeInterval(0.5))
        } while Date() < deadline
        capture("missing_action_" + action)
        XCTFail("NO_SOURCE_OWNED_SELECTABLE_ACTION_" + action)
    }

    // Bounded navigation through authored teaching only. Answers below are
    // frozen from product source, never inferred from feedback or preferences.
    private func prepareChoice(_ answer: String) {
        for page in 0..<24 {
            let overlay = app.otherElements.matching(NSPredicate(format: "label BEGINSWITH %@", "Theory navigation, page")).firstMatch
            if !overlay.exists {
                for letter in ["A", "B", "C", "D"] {
                    if let e = findOption(letter + "\n" + answer).found.first, e.isEnabled { return }
                }
            }
            let deadline = Date().addingTimeInterval(12)
            var buttons: [XCUIElement] = []
            repeat {
                buttons = ["Next", "Continue", "Got it", "Next hand"].compactMap { name in
                    let e = app.buttons.matching(identifier: name).firstMatch
                    return e.exists && e.isEnabled && e.isHittable ? e : nil
                }
                if buttons.count == 1 { break }
                RunLoop.current.run(until: Date().addingTimeInterval(0.25))
            } while Date() < deadline
            guard buttons.count == 1 else {
                capture("C9_navigation_blocked_" + String(page))
                XCTFail("NO_UNIQUE_TEACHING_CTA_FOR_" + answer); return
            }
            print("S12_AUTHORED_TEACHING_TAP " + buttons[0].label)
            buttons[0].tap()
        }
        XCTFail("AUTHORED_TEACHING_LIMIT_" + answer)
    }
    private func feedbackForward() {
        let names = ["Next hand", "Continue", "Check original read"]
        let deadline = Date().addingTimeInterval(12)
        repeat {
            let live = names.filter { name in
                let b = app.buttons.matching(identifier: name).firstMatch
                return b.exists && b.isEnabled && b.isHittable
            }
            if live.count == 1 { tapButton(live[0]); return }
            RunLoop.current.run(until: Date().addingTimeInterval(0.25))
        } while Date() < deadline
        capture("C9_feedback_forward_missing")
        XCTFail("NO_UNIQUE_EXPECTED_FEEDBACK_FORWARD")
    }
    private func backToMap() {
        for _ in 0..<9 {
            let b = app.buttons.matching(identifier: "Back to map").firstMatch
            if b.exists && b.isEnabled && b.isHittable { tapButton("Back to map"); return }
            app.swipeUp()
        }
        capture("C9_summary_map_cta_missing"); XCTFail("SUMMARY_BACK_TO_MAP_MISSING")
    }

    func test04AuthenticRepair() throws {
        let osReduceMotion = UIAccessibility.isReduceMotionEnabled
        print("S12_OS_REDUCE_MOTION " + String(osReduceMotion))
        // Source-owned placement recommendation opens Actions legitimately.
        // The fresh public topic pack is locked until its route is learned.
        app.launch(); XCTAssertTrue(app.waitForExistence(timeout:35))
        capture("first_use")
        openPlacementFromIntro()
        tapSelectableOption("I’ve played casually"); tapButton("Continue")
        tapSelectableOption("Try one quick check"); tapButton("Continue")
        tapButton("Start quick check")
        for (i, answer) in ["2 private · 3 board · Pot 6 BB", "Board cards", "Check"].enumerated() {
            selectAction(answer)
            XCTAssertTrue(visible("CORRECT READ", timeout: 12))
            tapButton(i == 2 ? "See my start" : "Next check")
        }
        capture("C2_actual_placement_recommendation")
        tapButton("Start with the useful hand")
        tapButton("Try one table read")
        tapWelcomeCheck()
        // Casual-player route (compact 375x667 tree, run 1708834): "Your path is
        // ready... You tried Check. This preview was ungraded." with the real
        // handoff CTA `Start recommended lesson` (`Open my path` is the beginner route).
        let recommended = app.buttons.matching(identifier: "Start recommended lesson").firstMatch
        _ = recommended.waitForExistence(timeout: 15)
        // Motion probe (indicative only): wall time for the tap, and from the tap
        // returning to the first selectable option. Compared across Reduce Motion on/off.
        let probeStart = Date()
        tapButton("Start recommended lesson")
        let probeTapped = Date()
        waitForSelectable("A\nFold")
        print("S11_MOTION_PROBE first_entry tap_s=" + String(format: "%.2f", probeTapped.timeIntervalSince(probeStart)) + " tap_to_options_s=" + String(format: "%.2f", Date().timeIntervalSince(probeTapped)) + " reduce_motion=" + String(osReduceMotion))

        // Fresh simulator: all prerequisites below are earned by actual UI.
        // Placement skips retain their original source-owned provenance.
        leaveRunnerThroughBack()
        tapTab("Home"); tapTab("Learn")
        persistedCheckpoint("C9_before_prerequisites")
        let firstStart = app.buttons.matching(identifier: "Start first table").firstMatch
        if firstStart.waitForExistence(timeout: 8) { tapButton("Start first table") }
        else { tapButton("Start") }
        // Meet the table is exposition; its Continue opens the first graded drill.
        let guideAnswers = ["BTN", "2 private cards, 3 board cards, 6 BB in the pot",
                            "2 private cards, 3 board cards, 4 BB in the pot",
                            "You are BTN, blinds are posted, and no board is out yet", "Review"]
        for (i, answer) in guideAnswers.enumerated() {
            prepareChoice(answer); selectAction(answer)
            print("S12_AUTHORED_GRADED_STEP guide_" + String(i) + " answer=" + answer + "\n" + app.debugDescription)
            feedbackForward()
        }
        XCTAssertTrue(visible("Session complete", timeout: 15) || visible("What finished"), "GUIDE_SUMMARY_NOT_REACHED")
        persistedCheckpoint("C9_guide_summary")
        backToMap()
        XCTAssertTrue(visible("Actions", timeout: 12) || visible("Fold, check, call, raise"), "ACTIONS_NOT_UNLOCKED")
        // Mission Start selects the first incomplete Actions task: Legal actions.
        tapButton("Start")
        prepareChoice("Fold")
        capture("C9_source_question")
        selectAction("Fold")
        XCTAssertTrue(visible("MISSED CLUE", timeout: 12) || visible("better play"))
        persistedCheckpoint("C9_source_wrong")
        tapButton("Try same clue")
        prepareChoice("Check")
        // Guidance is the product's targeted same-clue repair and explanation.
        // Do not request another quickHint: that intentionally exits to Review.
        capture("C9_guided_repair_question")
        selectAction("Check")
        persistedCheckpoint("C9_independent_correction")
        tapButton("Check original read")
        prepareChoice("Check")
        capture("C9_original_recheck_question")
        selectAction("Check")
        persistedCheckpoint("C9_original_recheck_answer")
        feedbackForward()
        persistedCheckpoint("C9_original_recheck_completed")
        // Actual remaining authored tasks, followed by the source-owned wrap-up
        // retry of the original miss before Summary. No direct completion calls.
        for (i, answer) in ["Check", "Fold", "Call", "Raise", "Raise", "Check"].enumerated() {
            prepareChoice(answer); selectAction(answer)
            print("S12_AUTHORED_GRADED_STEP actions_" + String(i) + " answer=" + answer + "\n" + app.debugDescription)
            feedbackForward()
        }
        XCTAssertTrue(visible("Session complete", timeout: 15) || visible("What finished"), "ACTIONS_SESSION_SUMMARY_NOT_REACHED")
        persistedCheckpoint("C9_actions_summary")
        // Scroll the real Summary to expose assessment/progress metrics and CTAs.
        app.swipeUp(); capture("C9_actions_summary_metrics")
        // V10 restart is already accepted; this bounded lane ends at V09 Summary.
    }

    // S12.V route probe only. Not a Turn/River gameplay or visual PASS.
    func test05NaturalTurnRiverTaskSelectorProbe() throws {
        app.launch()
        XCTAssertTrue(app.waitForExistence(timeout: 35), "STOP_APP_NOT_LAUNCHED")
        openPlacementFromIntro()
        tapSelectableOption("I’ve played casually")
        tapButton("Continue")
        tapSelectableOption("Try one quick check")
        tapButton("Continue")
        tapButton("Start quick check")
        for (i, answer) in ["2 private · 3 board · Pot 6 BB", "Board cards", "Check"].enumerated() {
            selectAction(answer)
            let initialCorrectAX = visible("CORRECT READ", timeout: 12)
            if !initialCorrectAX && i == 0 {
                // Previous exact-hosted iOS 26.5 Standard captured painted
                // CORRECT READ + Next check, but XCTest AX still exposed the
                // preceding choices. Capture both without injecting a state,
                // tapping again, or pretending that pixels prove semantics.
                print("S12V_AX_CAUSE_CHECK_FIRST_FEEDBACK_NOT_FOUND")
                capture("AX01_standard_placement_feedback_disagreement")
                let recoveredCorrectAX = visible("CORRECT READ", timeout: 10)
                let forward = app.buttons.matching(identifier: "Next check").firstMatch
                let forwardReady =
                    forward.exists && forward.isEnabled && forward.isHittable
                print("S12V_AX_CAUSE_CHECK_AFTER_NATIVE_CAPTURE correct=" +
                    String(recoveredCorrectAX) + " next_hittable=" +
                    String(forwardReady) + "\n" + app.debugDescription)
                XCTAssertTrue(
                    recoveredCorrectAX && forwardReady,
                    "STOP_PLACEMENT_AX_NOT_RESTORED_AFTER_NATIVE_CAPTURE")
            } else {
                XCTAssertTrue(initialCorrectAX, "STOP_PLACEMENT_ACTUAL_FEEDBACK")
            }
            tapButton(i == 2 ? "See my start" : "Next check")
        }
        tapButton("Start with the useful hand")
        tapButton("Try one table read")
        tapWelcomeCheck()
        tapButton("Start recommended lesson")
        waitForSelectable("A\nFold")
        leaveRunnerThroughBack()
        tapTab("Home")
        tapTab("Learn")
        capture("TR01_actual_learn_after_placement")

        // Mission Start chooses first non-path-closed and is NOT a task selector.
        var openedFullPath = false
        for _ in 0..<12 {
            let all = app.buttons.matching(identifier: "All lessons").firstMatch
            if all.exists && all.isEnabled && all.isHittable {
                print("S12V_ROUTE_ACTUAL_TAP " + all.label)
                all.tap()
                openedFullPath = true
                break
            }
            app.swipeUp()
        }
        guard openedFullPath else {
            capture("TR02_no_visible_all_lessons")
            XCTFail("STOP_NO_HITTABLE_ALL_LESSONS")
            return
        }
        capture("TR02_full_path_real_ui")

        // Search text is an expectation, not an observed task identity.
        var foundLesson = false
        for _ in 0..<26 {
            let rows = app.staticTexts.matching(
                NSPredicate(format: "label CONTAINS[cd] %@", "Your first hand")
            ).allElementsBoundByIndex.filter { $0.exists && $0.isHittable }
            if rows.count == 1 {
                print("S12V_ROUTE_REAL_LESSON_TAP actual=" + rows[0].label)
                rows[0].tap()
                foundLesson = true
                break
            }
            if rows.count > 1 {
                capture("TR03_ambiguous_lesson")
                XCTFail("STOP_AMBIGUOUS_REAL_LESSON_ROW")
                return
            }
            app.swipeUp()
        }
        guard foundLesson else {
            capture("TR03_no_reachable_lesson")
            XCTFail("STOP_NO_HITTABLE_YOUR_FIRST_HAND")
            return
        }
        capture("TR03_real_lesson_selected")

        var foundTurn = false
        for _ in 0..<10 {
            let tasks = app.staticTexts.matching(
                NSPredicate(format: "label CONTAINS[cd] %@", "Turn card")
            ).allElementsBoundByIndex.filter { $0.exists && $0.isHittable }
            if tasks.count == 1 {
                print("S12V_ROUTE_REAL_TASK_TAP actual=" + tasks[0].label)
                tasks[0].tap()
                foundTurn = true
                break
            }
            if tasks.count > 1 {
                capture("TR04_ambiguous_turn")
                XCTFail("STOP_AMBIGUOUS_TURN_TASK_ROW")
                return
            }
            app.swipeUp()
        }
        guard foundTurn else {
            capture("TR04_turn_not_hittable")
            XCTFail("STOP_NO_HITTABLE_TURN_TASK_ROW")
            return
        }
        // Compact native receipt #39938389524: the Turn label received a tap,
        // but the selection did not create any Retry element in native AX.
        // This is not a task/completion injection: allow one further tap on
        // the same real visible source-owned row, and only if focus is absent.
        // A pre-existing Retry may be below the fold but is still in AX.
        if !app.buttons.matching(identifier: "Retry").firstMatch.exists {
            let turn = app.staticTexts.matching(
                NSPredicate(format: "label CONTAINS[cd] %@", "Turn card")
            ).allElementsBoundByIndex.filter { $0.exists && $0.isHittable }
            guard turn.count == 1 else {
                capture("TR04_compact_turn_row_lost_before_retap")
                XCTFail("STOP_NO_UNIQUE_REAL_TURN_ROW_FOR_BOUNDED_RETAP")
                return
            }
            print("S12V_REAL_TURN_FOCUS_RETRY_ONE_SOURCE_ROW_TAP label=" + turn[0].label)
            turn[0].tap()
            RunLoop.current.run(until: Date().addingTimeInterval(1.0))
            capture("TR04_after_one_bounded_focus_retap")
        }
        capture("TR04_after_actual_turn_row_tap")
        guard app.buttons.matching(identifier: "Retry").firstMatch.exists else {
            XCTFail("STOP_TURN_SELECTION_DID_NOT_EXPOSE_NATIVE_RETRY")
            return
        }
        print("S12V_ROUTE_TASK_ROW_TAPPED_AND_CTA_EXISTS_IN_AX=YES; GAMEPLAY_STREET_BOARD_POT_NOT_VERIFIED")
    }

    // Stage 2: genuine UI-only gameplay probe, with native evidence receipts.
    // A green XCTest does not by itself prove 4/5 painted cards: inspect
    // the original native screenshots and AX tree before accepting S12.V.
    func test06NativeTurnRiverBoardAndPotProbe() throws {
        try test05NaturalTurnRiverTaskSelectorProbe()
        RunLoop.current.run(until: Date().addingTimeInterval(1.2))

        // The selected task's native CTA is below the fold on both exact
        // devices in run 39925606783 (Standard AX has Retry at zero frame).
        // Reach it only through natural visible UI scrolling, never by
        // coordinate injection, hidden-element tapping, or progress mutation.
        func visibleRetryAfterScroll(_ stage: String) -> [XCUIElement] {
            for attempt in 0..<12 {
                let buttons = app.buttons.matching(identifier: "Retry")
                    .allElementsBoundByIndex.filter {
                        $0.exists && $0.isEnabled && $0.isHittable
                    }
                if !buttons.isEmpty {
                    print("S12V_REAL_RETRY_VISIBLE stage=" + stage +
                          " count=" + String(buttons.count) +
                          " scrolls=" + String(attempt))
                    return buttons
                }
                print("S12V_RETRY_BELOW_FOLD stage=" + stage +
                      " scroll=" + String(attempt + 1))
                app.swipeUp()
            }
            return []
        }

        let turnRetry = visibleRetryAfterScroll("turn")
        guard turnRetry.count == 1 else {
            capture("TR05_no_unique_turn_retry")
            XCTFail("STOP_TURN_TASK_FOCUS_OR_RETRY_NOT_VISIBLE count=" + String(turnRetry.count))
            return
        }
        capture("TR05_actual_turn_retry_visible")
        print("S12V_REAL_TURN_RETRY_TAP actual=" + turnRetry[0].label)
        turnRetry[0].tap()
        guard visible("Pot 5 BB", timeout: 15) else {
            capture("TR06_turn_no_native_pot")
            XCTFail("STOP_TURN_GAMEPLAY_POT_NOT_VISIBLE")
            return
        }
        capture("TR06_actual_turn_gameplay")
        print("S12V_TURN_NATIVE_POT_VISIBLE=YES; PAINTED_BOARD_COUNT_REQUIRES_ORIGINAL_SCREEN_REVIEW")
        leaveRunnerThroughBack()

        // Standard original AX #39938389524: after returning from Turn the
        // target lesson is collapsed. All lessons is NOT a task selector:
        // reopen the actual lesson row before searching for River card.
        print("S12V_RIVER_OPEN_ALL_LESSONS")
        tapButton("All lessons")
        var reopenedFirstHand = false
        for _ in 0..<20 {
            let lessons = app.staticTexts.matching(
                NSPredicate(format: "label CONTAINS[cd] %@", "Your first hand")
            ).allElementsBoundByIndex.filter { $0.exists && $0.isHittable }
            if lessons.count == 1 {
                print("S12V_RIVER_REOPEN_REAL_LESSON label=" + lessons[0].label)
                lessons[0].tap()
                reopenedFirstHand = true
                break
            }
            if lessons.count > 1 {
                capture("TR07_ambiguous_reopen_lesson")
                XCTFail("STOP_AMBIGUOUS_REAL_RIVER_PARENT_LESSON")
                return
            }
            app.swipeUp()
        }
        guard reopenedFirstHand else {
            capture("TR07_no_reachable_reopen_lesson")
            XCTFail("STOP_NO_SOURCE_OWNED_RIVER_PARENT_LESSON")
            return
        }
        capture("TR07_reopened_source_owned_lesson")

        // Native River proof #39955048811 failed after a real River-row tap.
        // Source permits same-task taps to toggle the popup closed; whether
        // that happened in the native run remains UNVERIFIED.
        // Before touching River, select the distinct real Turn row. This
        // deterministically prevents a subsequent River tap from being the
        // same popup task; no hidden state or coordinates are injected.
        var turnFocusRow: XCUIElement?
        for _ in 0..<20 {
            let rows = app.staticTexts.matching(
                NSPredicate(format: "label CONTAINS[cd] %@", "Turn card")
            ).allElementsBoundByIndex.filter { $0.exists && $0.isHittable }
            if rows.count == 1 {
                turnFocusRow = rows[0]
                break
            }
            if rows.count > 1 {
                capture("TR07_ambiguous_distinct_turn_focus")
                XCTFail("STOP_AMBIGUOUS_DISTINCT_TURN_FOCUS")
                return
            }
            app.swipeUp()
        }
        guard let turn = turnFocusRow else {
            capture("TR07_distinct_turn_focus_unreachable")
            XCTFail("STOP_DISTINCT_TURN_FOCUS_NOT_REACHABLE")
            return
        }
        print("S12V_RIVER_DISTINCT_TASK_PRIME_TURN label=" + turn.label)
        turn.tap()
        RunLoop.current.run(until: Date().addingTimeInterval(1.2))

        // Exact Standard vs SE3 differential from native #39976582872:
        // only Standard swiped after Turn selection and before River tap.
        // Capture genuine source-owned task focus/frames at THREE points.
        // Do NOT retry River taps or mutate any user progression state.
        func checkpointRiverFocus(_ tag: String, _ swipes: Int) {
            let turn = app.staticTexts.matching(
                NSPredicate(format: "label CONTAINS[cd] %@", "Turn card")
            ).allElementsBoundByIndex.filter { $0.exists }
            let river = app.staticTexts.matching(
                NSPredicate(format: "label CONTAINS[cd] %@", "River card")
            ).allElementsBoundByIndex.filter { $0.exists }
            let tree = app.debugDescription
            let turnStart = tree.range(of: "label: 'Turn card")
            let riverStart = tree.range(of: "label: 'River card")
            let showdownStart = tree.range(of: "label: 'Showdown read")
            let retryStart = tree.range(of: "label: 'Retry'")
            let turnOwned = turnStart != nil && riverStart != nil &&
                retryStart != nil && turnStart!.lowerBound < retryStart!.lowerBound &&
                retryStart!.lowerBound < riverStart!.lowerBound
            let riverOwned = riverStart != nil && showdownStart != nil &&
                retryStart != nil && riverStart!.lowerBound < retryStart!.lowerBound &&
                retryStart!.lowerBound < showdownStart!.lowerBound
            print("S12V_RIVER_FOCUS_CHECKPOINT stage=" + tag +
                  " swipes=" + String(swipes) +
                  " turn_count=" + String(turn.count) +
                  " turn_frame=" + (turn.count == 1 ? String(describing: turn[0].frame) : "NONE") +
                  " river_count=" + String(river.count) +
                  " river_frame=" + (river.count == 1 ? String(describing: river[0].frame) : "NONE") +
                  " river_hittable=" + String(river.count == 1 && river[0].isHittable) +
                  " turn_retry_owned_by_AX_order=" + String(turnOwned) +
                  " river_retry_owned_by_AX_order=" + String(riverOwned))
            capture(tag)
        }

        checkpointRiverFocus("TR07_focus_01_after_turn_before_scroll", 0)
        var riverRow: XCUIElement?
        var riverScrollCount = 0
        // One observed Standard-only scroll maximum; a longer search would
        // erase causal attribution. Compact should require no extra scroll.
        for _ in 0..<2 {
            let rows = app.staticTexts.matching(
                NSPredicate(format: "label CONTAINS[cd] %@", "River card")
            ).allElementsBoundByIndex.filter { $0.exists && $0.isHittable }
            if rows.count == 1 {
                riverRow = rows[0]
                break
            }
            if rows.count > 1 {
                capture("TR07_ambiguous_river_row")
                XCTFail("STOP_AMBIGUOUS_REAL_RIVER_TASK_ROW")
                return
            }
            if riverScrollCount >= 1 { break }
            print("S12V_RIVER_STANDARD_INTERVENING_NATIVE_SWIPE_UP")
            app.swipeUp()
            riverScrollCount += 1
            RunLoop.current.run(until: Date().addingTimeInterval(0.35))
        }
        checkpointRiverFocus("TR07_focus_02_post_scroll_pre_river_tap", riverScrollCount)
        guard riverRow != nil else {
            XCTFail("STOP_RIVER_ROW_UNHITTABLE_AFTER_ONE_DIAGNOSTIC_SCROLL")
            return
        }
        // Re-resolve after native screenshot/AX hold; never tap a stale frame.
        let ready = app.staticTexts.matching(
            NSPredicate(format: "label CONTAINS[cd] %@", "River card")
        ).allElementsBoundByIndex.filter { $0.exists && $0.isHittable }
        guard ready.count == 1 else {
            XCTFail("STOP_RIVER_ROW_MOVED_AFTER_PRETAP_NATIVE_CHECKPOINT")
            return
        }
        print("S12V_REAL_RIVER_ROW_TAP_AFTER_DISTINCT_TASK actual=" + ready[0].label +
              " frame=" + String(describing: ready[0].frame) +
              " extra_swipes=" + String(riverScrollCount))
        ready[0].tap()
        RunLoop.current.run(until: Date().addingTimeInterval(1.2))
        checkpointRiverFocus("TR07_focus_03_immediate_after_river_tap", riverScrollCount)
        // On compact, the real River Retry may be BELOW the visible fold.
        // First scroll the normal UI to expose exactly one enabled CTA,
        // then verify its ownership from native frames: River < Retry <
        // Showdown. A stale Turn-owned Retry cannot pass this guard.
        func nativeAXShowsRiverOwnedRetry() -> Bool {
            let river = app.staticTexts.matching(
                NSPredicate(format: "label CONTAINS[cd] %@", "River card")
            ).allElementsBoundByIndex.filter { $0.exists }
            let showdown = app.staticTexts.matching(
                NSPredicate(format: "label CONTAINS[cd] %@", "Showdown read")
            ).allElementsBoundByIndex.filter { $0.exists }
            let retries = app.buttons.matching(identifier: "Retry")
                .allElementsBoundByIndex.filter {
                    $0.exists && $0.isEnabled && $0.isHittable
                }
            guard river.count == 1, showdown.count == 1,
                  retries.count == 1 else {
                print("S12V_RIVER_FRAME_OWNER_STOP counts=" +
                      String(river.count) + "/" + String(showdown.count) +
                      "/" + String(retries.count))
                return false
            }
            let r = river[0].frame
            let n = showdown[0].frame
            let b = retries[0].frame
            let owned = b.midY > r.maxY && b.midY < n.minY &&
                        b.midX >= r.minX && b.midX <= r.maxX
            print("S12V_RIVER_FRAME_OWNER_CHECK river=" +
                  String(describing: r) + " retry=" +
                  String(describing: b) + " next=" +
                  String(describing: n) + " owned=" + String(owned))
            return owned
        }
        let riverRetry = visibleRetryAfterScroll("river")
        guard riverRetry.count == 1 else {
            capture("TR07_no_unique_river_retry")
            XCTFail("STOP_RIVER_TASK_FOCUS_OR_RETRY_NOT_VISIBLE count=" + String(riverRetry.count))
            return
        }
        guard nativeAXShowsRiverOwnedRetry() else {
            capture("TR07_river_retry_lost_native_ax_ownership")
            XCTFail("STOP_RIVER_RETRY_OWNERSHIP_CHANGED_WHILE_SCROLLING")
            return
        }
        capture("TR07_actual_river_retry_visible")
        print("S12V_REAL_RIVER_RETRY_TAP actual=" + riverRetry[0].label)
        riverRetry[0].tap()
        guard visible("Pot 5 BB", timeout: 15) else {
            capture("TR08_river_no_native_pot")
            XCTFail("STOP_RIVER_GAMEPLAY_POT_NOT_VISIBLE")
            return
        }
        capture("TR08_actual_river_gameplay")
        print("S12V_RIVER_NATIVE_POT_VISIBLE=YES; PAINTED_BOARD_COUNT_REQUIRES_ORIGINAL_SCREEN_REVIEW")
    }

}
