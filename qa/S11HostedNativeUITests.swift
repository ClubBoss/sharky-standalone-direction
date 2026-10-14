import XCTest
import Darwin

final class S11HostedNativeUITests: XCTestCase {
    private let app = XCUIApplication(bundleIdentifier: "com.example.pokerAnalyzer")
    override func setUpWithError() throws { continueAfterFailure = false }

    private func capture(_ tag: String) {
        print("S11_GATE_STATE " + tag)
        print("S11_NATIVE_TREE_BEGIN " + tag + "\n" + app.debugDescription + "\nS11_NATIVE_TREE_END " + tag)
        // XCTest's screen service timed out on a responsive graded frame.
        // The hosted observer uses simctl's independently proven capture path.
        print("S11_SCREEN_CHECKPOINT " + tag + " epoch=" + String(Date().timeIntervalSince1970))
        fflush(stdout)
        let startupFrame = ["first_install_intro", "placement_unselected", "placement_selected"].contains(tag)
        RunLoop.current.run(until: Date().addingTimeInterval(startupFrame ? 30 : 15))
        print("S11_SCREEN_RELEASE " + tag + " epoch=" + String(Date().timeIntervalSince1970))
        fflush(stdout)
    }
    private func visible(_ label: String) -> Bool {
        let p = NSPredicate(format:"label CONTAINS[cd] %@",label)
        return app.descendants(matching:.any).matching(p).firstMatch.waitForExistence(timeout:3)
    }
    private func enabledButton(_ label: String, timeout: TimeInterval = 5) -> XCUIElement {
        let button = app.buttons.matching(identifier: label).firstMatch
        XCTAssertTrue(button.waitForExistence(timeout: timeout), "MISSING_REQUIRED_BUTTON " + label)
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
            let matches = app.descendants(matching:type).matching(NSPredicate(format:"label == %@",label)).allElementsBoundByIndex.filter { $0.exists && $0.isHittable }
            if matches.count == 1 { matches[0].tap(); return }
        }
        capture("missing_tab_"+label)
        XCTFail("NO_UNIQUE_NATIVE_TAB_"+label)
    }
    private func tapSelectableOption(_ exactOrPrefix:String) {
        let pred=NSPredicate(format:"label BEGINSWITH[cd] %@",exactOrPrefix)
        for type: XCUIElement.ElementType in [.button, .staticText] {
            let matches=app.descendants(matching:type).matching(pred)
            let found=matches.allElementsBoundByIndex.filter { $0.exists && $0.isHittable }
            if found.count == 1 {
                XCTAssertTrue(found[0].isEnabled, "OPTION_DISABLED "+exactOrPrefix)
                print("S11_NAV_SELECT_OPTION requested="+exactOrPrefix+" actual="+found[0].label)
                found[0].tap()
                return
            }
            if found.count > 1 {
                XCTFail("AMBIGUOUS_SELECTABLE_OPTION "+exactOrPrefix+" count="+String(found.count))
                return
            }
        }
        capture("missing_option_"+exactOrPrefix.replacingOccurrences(of:" ",with:"_").prefix(18))
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


    /// Advance from a confirmed graded feedback frame to an authored task.
    /// Step number plus distinct option label is the source-owned identity.
    private func submitW1Followup(step: Int, prefix: String, tag: String) {
        tapButton("Next hand")
        guard visible("Step \(step)/6") else {
            capture("w1_wrong_step_\(step)")
            XCTFail("W1_NEXT_TASK_STEP_MISMATCH expected=\(step)")
            return
        }
        var submitted = false
        for page in 0..<8 {
            let overlay = app.otherElements.matching(
                NSPredicate(format:"label BEGINSWITH %@", "Theory navigation, page")
            ).firstMatch
            if overlay.exists {
                let deadline = Date().addingTimeInterval(5)
                var available: [XCUIElement] = []
                repeat {
                    available = ["Continue","Next"].compactMap { title -> XCUIElement? in
                        let element = app.buttons.matching(identifier:title).firstMatch
                        return (element.exists && element.isHittable && element.isEnabled) ? element : nil
                    }
                    if available.count == 1 { break }
                    RunLoop.current.run(until:Date().addingTimeInterval(0.15))
                } while Date() < deadline
                guard available.count == 1 else {
                    capture("w1_\(tag)_locked_theory")
                    XCTFail("W1_THEORY_OVERLAY_NOT_ADVANCING task=\(tag)")
                    return
                }
                available[0].tap()
                continue
            }
            let candidate = app.staticTexts.matching(
                NSPredicate(format:"label BEGINSWITH[cd] %@",prefix)
            ).firstMatch
            if candidate.exists && candidate.isHittable && candidate.isEnabled {
                tapSelectableOption(prefix)
                submitted = true
                break
            }
            capture("w1_\(tag)_choice_not_present_\(page)")
            XCTFail("W1_EXPECTED_GRADED_CHOICE_MISSING task=\(tag) prefix=\(prefix)")
            return
        }
        guard submitted else {
            XCTFail("W1_GRADED_SUBMISSION_TIMEOUT task=\(tag)")
            return
        }
        let next = app.buttons.matching(identifier:"Next hand").firstMatch
        guard next.waitForExistence(timeout:10) && next.isEnabled else {
            capture("w1_\(tag)_feedback_no_next")
            XCTFail("W1_FEEDBACK_NOT_CONFIRMED task=\(tag)")
            return
        }
        capture("w1_\(tag)_graded_feedback")
        print("S11_CLEAN_GRADED_SUBMITTED task=\(tag)")
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

    private func firstLesson(wrongFinal: Bool = false) throws {
        app.launch()
        XCTAssertTrue(app.waitForExistence(timeout:35))
        capture("first_install_intro")
        XCTAssertTrue(visible("Sharky Poker") || visible("Find my start"),"FIRST_INSTALL_NOT_SHARKY")
        tapButton("Find my start")
        XCTAssertTrue(visible("Where are you starting from?"),"PLACEMENT_EXPERIENCE_SCREEN_NOT_FOUND")
        capture("placement_unselected")
        // Native accessibility tree labels: actual tappable StaticText starts with this phrase.
        tapSelectableOption("I’m new to poker")
        capture("placement_selected")
        XCTAssertTrue(enabledButton("Start from zero").exists)
        tapButton("Start from zero")
        XCTAssertTrue(visible("Try one table read"),"WELCOME_INTRO_MISSING")
        capture("welcome_intro")
        tapButton("Try one table read")
        capture("welcome_demo")
        // Native Welcome is ungraded: Step 2/3 asks which action plays for free.
        // Accessibility represents the option as StaticText `B\\nCheck`, not a BTN seat.
        XCTAssertTrue(visible("What action keeps playing for free?"), "WELCOME_DEMO_WRONG_SCREEN")
        tapSelectableOption("B\nCheck")
        // Await the actual handoff CTA after the ungraded welcome choice;
        // a matching option tap alone is not a confirmed transition.
        let handoff = app.buttons.matching(identifier: "Open my path").firstMatch
        guard handoff.waitForExistence(timeout: 12) && handoff.isEnabled && handoff.isHittable else {
            capture("welcome_handoff_missing_after_choice")
            XCTFail("WELCOME_TRANSITION_NOT_COMPLETED_AFTER_UNGRADED_CHOICE")
            return
        }
        capture("welcome_handoff")
        tapButton("Open my path")
        XCTAssertTrue(visible("Start first hand"),"HOME_PRIMARY_FIRST_LESSON_MISSING")
        capture("home_start_first_hand")
        if !wrongFinal {
            tapTab("Review")
            XCTAssertTrue(visible("Review is ready"))
            capture("D1_fresh_review_empty")
            tapButton("Open Learn")
            XCTAssertTrue(visible("First Table Guide"))
            capture("D1_empty_review_CTA_to_Learn")
            // The real empty-state CTA has changed the handoff context.
            // Continue on its observed curriculum mission, not a stale Home label.
            tapButton("Start first table")
        } else {
            tapButton("Start first hand")
        }
        capture("w1_theory_open")
        // Deterministic source-owned route. The lesson's four teaching pages
        // may advance directly to the Step 2/6 graded decision. Never search
        // backwards for a prior theory clue when the graded question is present.
        var atFindHero = false
        for step in 0..<10 {
            // The live question is rendered BEHIND the teaching overlay.
            // Accessibility shows "Theory navigation, page 1 of 2" and only
            // the Next CTA while answers are intentionally not selectable.
            // Do not interpret a visible question as an actionable decision.
            let theoryOverlay = app.otherElements.matching(
                NSPredicate(format: "label BEGINSWITH %@", "Theory navigation, page")
            ).firstMatch
            if theoryOverlay.exists {
                // The production theory rail intentionally locks Continue
                // for 820 ms per page. Await *enabled* state without tapping a
                // disabled control or treating a normal dwell as a dead end.
                let deadline = Date().addingTimeInterval(5.0)
                var navigation: [XCUIElement] = []
                repeat {
                    navigation = ["Next", "Continue"].compactMap { title -> XCUIElement? in
                        let c = app.buttons.matching(identifier: title).firstMatch
                        return (c.exists && c.isEnabled && c.isHittable) ? c : nil
                    }
                    if navigation.count == 1 { break }
                    RunLoop.current.run(until: Date().addingTimeInterval(0.15))
                } while Date() < deadline
                guard navigation.count == 1 else {
                    capture("blocked_theory_overlay_" + String(step))
                    XCTFail("S11_OVERLAY_NAVIGATION_NOT_SINGLE step=" + String(step))
                    return
                }
                print("S11_NATIVE_OVERLAY_ADVANCE step=" + String(step) + " label=" + navigation[0].label)
                navigation[0].tap()
                continue
            }
            if visible("Which label could change next hand while the player is still you?") {
                atFindHero = true
                print("S11_NATIVE_GRADED_SCREEN_REACHED task=what_poker_is_find_hero at_step=" + String(step))
                break
            }
            if visible("UTG, HJ, and CO have acted.") {
                // This is source-owned meet-table teaching. The authored correct
                // choice is the C-positioned 'BTN (your seat)', not generic BTN.
                tapSelectableOption("C\nBTN (your seat)")
                capture("meet_table_theory_choice")
                continue
            }
            let next = ["Next", "Continue", "Got it"].compactMap { label -> XCUIElement? in
                let c = app.buttons.matching(identifier: label).firstMatch
                return (c.exists && c.isEnabled && c.isHittable) ? c : nil
            }
            guard next.count == 1 else {
                capture("first_lesson_unexpected_state_" + String(step))
                XCTFail("S11_FIRST_LESSON_PROGRESS_NOT_DEFINED step=" + String(step))
                return
            }
            print("S11_NATIVE_THEORY_ADVANCE " + next[0].label)
            next[0].tap()
        }
        guard atFindHero else {
            capture("find_hero_not_reached")
            XCTFail("S11_GRADED_FIND_HERO_NOT_REACHED")
            return
        }
        capture("first_real_graded_question")
        // Native option labels contain the authored ordinal, e.g. "B\nBTN".
        // Exact prefix avoids matching the miniature table's 'BTN' seat label.
        tapSelectableOption("B\nBTN")
        let feedback = app.staticTexts.matching(NSPredicate(
            format: "label CONTAINS[cd] %@ OR label CONTAINS[cd] %@",
            "Role separated from player.", "Player and position separated."
        )).firstMatch
        guard feedback.waitForExistence(timeout: 10) || visible("CORRECT READ") else {
            capture("first_graded_feedback_not_confirmed")
            XCTFail("FIRST_GRADED_FEEDBACK_ABSENT_AFTER_SUBMISSION")
            return
        }
        capture("first_real_graded_feedback")
        print("S11_FIRST_NATIVE_GRADED_SUBMISSION_DONE; PERSISTENCE MUST BE VERIFIED SEPARATELY")
        submitW1Followup(step:3, prefix:"B\n2 private cards, 3 board cards, 6 BB", tag:"what_poker_is_table_read_transfer")
        submitW1Followup(step:4, prefix:"C\n2 private cards, 3 board cards, 4 BB", tag:"what_poker_is_table_read_recheck")
        submitW1Followup(step:5, prefix:"B\nYou are BTN, blinds are posted", tag:"first_table_guide_one_clear_choice")
        capture("C1_after_four_independent_correct_submissions")
        print("S11_C1_FOUR_SOURCE_OWNED_SUBMISSIONS_DONE; persisted ledger must verify 4/4 and XP")
        // The authored World-1 path includes a final route-roles review task.
        // Do not invent a fifth assessed record or claim Summary early.
        tapButton("Next hand")
        guard visible("Step 6/6") else {
            capture("C1_route_roles_not_reached")
            XCTFail("C1_ROUTE_ROLES_REVIEW_NOT_REACHED")
            return
        }
        waitForSelectable("B\nReview")
        XCTAssertTrue(visible("Where do you go to fix mistakes after a miss?"))
        XCTAssertFalse(visible("CORRECT READ"), "UNEARNED_POSITIVE_FINAL_FEEDBACK")
        XCTAssertFalse(app.buttons.matching(identifier:"Next hand").firstMatch.exists)
        let review = app.staticTexts.matching(NSPredicate(format:"label BEGINSWITH %@", "B\nReview")).firstMatch
        XCTAssertTrue(review.exists && review.isHittable && review.isEnabled)
        if wrongFinal {
            persistedCheckpoint("C1_wrong_prefinal")
            XCTAssertFalse(visible("CORRECT READ"), "UNEARNED_FEEDBACK_DURING_CHECKPOINT")
            XCTAssertFalse(app.buttons.matching(identifier:"Next hand").firstMatch.exists)
            tapSelectableOption("C\nLearn")
            XCTAssertFalse(visible("CORRECT READ"), "WRONG_FINAL_MARKED_CORRECT")
            XCTAssertTrue(visible("One more distinction.") || visible("WRONG READ"), "NO_AUTHENTIC_WRONG_FEEDBACK")
            persistedCheckpoint("C1_wrong_answer")
            return
        }
        persistedCheckpoint("C1_prefinal")
        XCTAssertFalse(visible("CORRECT READ"), "UNEARNED_FEEDBACK_DURING_CHECKPOINT")
        XCTAssertFalse(app.buttons.matching(identifier:"Next hand").firstMatch.exists)
        tapSelectableOption("B\nReview")
        XCTAssertTrue(visible("CORRECT READ"), "FINAL_FEEDBACK_MISSING_AFTER_ANSWER")
        persistedCheckpoint("C1_final_answer")
        tapButton("Next hand")
        XCTAssertTrue(visible("Session complete") || visible("What finished"), "NO_TRUE_LESSON_SUMMARY")
        persistedCheckpoint("C1_summary")
        // Summary owns the full screen; return through its actual map CTA.
        for _ in 0..<5 {
            let back = app.buttons.matching(identifier:"Back to map").firstMatch
            if back.exists && back.isHittable { break }
            app.swipeUp()
        }
        tapButton("Back to map")
        tapTab("Home")
        persistedCheckpoint("C1_home")
        app.terminate()
        app.launch()
        XCTAssertTrue(app.waitForExistence(timeout:35))
        XCTAssertFalse(visible("CORRECT READ"), "STALE_FEEDBACK_ON_RESTART")
        persistedCheckpoint("C1_restart")
    }

    private func waitForSelectable(_ prefix: String) {
        for page in 0..<18 {
            let overlay = app.otherElements.matching(NSPredicate(format:"label BEGINSWITH %@", "Theory navigation, page")).firstMatch
            if !overlay.exists {
                let option = app.staticTexts.matching(NSPredicate(format:"label BEGINSWITH %@", prefix)).firstMatch
                if option.exists && option.isHittable && option.isEnabled { return }
                let pot = app.staticTexts.matching(NSPredicate(format:"label BEGINSWITH %@", "A\nPot")).firstMatch
                if pot.exists && pot.isHittable {
                    tapSelectableOption("A\nPot")
                    continue
                }
            }
            let deadline = Date().addingTimeInterval(5)
            var choices: [XCUIElement] = []
            repeat {
                choices = ["Next", "Continue", "Got it"].compactMap { name in
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

    func test02SecondAuthoredReview() throws {
        app.launch()
        XCTAssertTrue(app.waitForExistence(timeout:35))
        capture("second_lesson_saved_home")
        // Home Continue is a personalized first-value repeat. Use the actual
        // curriculum mission whose focus was selected by Summary Back to map.
        tapTab("Learn")
        XCTAssertTrue(visible("What poker is"), "SECOND_LESSON_CURRENT_MISSION_MISSING")
        capture("second_lesson_actual_Learn_mission")
        tapButton("Start")
        XCTAssertTrue(visible("Step 1/7"), "SECOND_LESSON_POT_STACK_NOT_ENTERED")
        waitForSelectable("C\nEveryone folds")
        let recipe = ["C\nEveryone folds", "C\nBest hand", "B\nHero put in all remaining chips", "C\nOnly the chips CO matched", "A\nA fold or a showdown"]
        for (index, prefix) in recipe.enumerated() {
            XCTAssertTrue(visible("Step \(index+2)/7"))
            waitForSelectable(prefix)
            tapSelectableOption(prefix)
            XCTAssertTrue(visible("CORRECT READ"))
            tapButton("Next hand")
        }
        waitForSelectable("C\nEveryone folds")
        XCTAssertTrue(visible("Step 7/7"))
        XCTAssertFalse(visible("CORRECT READ"), "SECOND_REVIEW_UNEARNED_FEEDBACK")
        persistedCheckpoint("C1_second_review_entry")
        // Exact-source falsifier: this recap inherits win-condition answers,
        // while asking for the definition of the pot. Record the real grading.
        if visible("What is the pot?") {
            tapSelectableOption("C\nEveryone folds")
            XCTAssertTrue(visible("CORRECT READ"))
            persistedCheckpoint("C1_second_review_mismatch_graded")
            XCTFail("MATERIAL_SOURCE_REVIEW_QUESTION_CHOICES_MISMATCH: What is the pot? graded Everyone folds as correct")
            return
        }
        XCTFail("SECOND_REVIEW_SOURCE_QUESTION_CHANGED; REQUIRE_RECONCILIATION")
    }

    func test00FirstGraded() throws { try firstLesson() }
    func test01WrongFinal() throws { try firstLesson(wrongFinal: true) }
}
