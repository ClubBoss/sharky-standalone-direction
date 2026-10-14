import XCTest
import UIKit
import Darwin

final class S11HostedNativeUITests: XCTestCase {
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
            let matches = app.descendants(matching:type).matching(NSPredicate(format:"label == %@",label)).allElementsBoundByIndex.filter { $0.exists && $0.isHittable }
            if matches.count == 1 { matches[0].tap(); return }
        }
        capture("missing_tab_"+label)
        XCTFail("NO_UNIQUE_NATIVE_TAB_"+label)
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
            let exact = app.buttons.matching(NSPredicate(format:"label == %@ OR label BEGINSWITH %@", text, text + "\n")).allElementsBoundByIndex.filter { $0.exists && $0.isHittable }
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
            if let candidate = findOption(prefix).found.first, candidate.isEnabled {
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
        XCTAssertTrue(visible("Sharky Poker", timeout: 12) || visible("Find my start", timeout: 12),"FIRST_INSTALL_NOT_SHARKY")
        openPlacementFromIntro()
        capture("placement_unselected")
        // Native accessibility tree labels: actual tappable StaticText starts with this phrase.
        tapSelectableOption("I’m new to poker")
        capture("placement_selected")
        XCTAssertTrue(enabledButton("Start from zero").exists)
        tapButton("Start from zero")
        XCTAssertTrue(visible("Try one table read", timeout: 12),"WELCOME_INTRO_MISSING")
        capture("welcome_intro")
        tapButton("Try one table read")
        capture("welcome_demo")
        // Native Welcome is ungraded: Step 2/3 asks which action plays for free.
        // Accessibility exposes real Fold/Check/Call buttons here.
        tapWelcomeCheck()
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
        XCTAssertTrue(visible("Start first hand", timeout: 12),"HOME_PRIMARY_FIRST_LESSON_MISSING")
        capture("home_start_first_hand")
        if !wrongFinal {
            tapTab("Review")
            XCTAssertTrue(visible("Review is ready", timeout: 12))
            capture("D1_fresh_review_empty")
            tapButton("Open Learn")
            XCTAssertTrue(visible("First Table Guide", timeout: 12))
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
        XCTAssertTrue(visible("Where do you go to fix mistakes after a miss?", timeout: 12))
        XCTAssertFalse(visible("CORRECT READ"), "UNEARNED_POSITIVE_FINAL_FEEDBACK")
        XCTAssertFalse(app.buttons.matching(identifier:"Next hand").firstMatch.exists)
        let review = findOption("B\nReview").found.first
        XCTAssertTrue(review != nil && review!.isEnabled, "FINAL_REVIEW_OPTION_NOT_SELECTABLE")
        if wrongFinal {
            persistedCheckpoint("C1_wrong_prefinal")
            XCTAssertFalse(visible("CORRECT READ"), "UNEARNED_FEEDBACK_DURING_CHECKPOINT")
            XCTAssertFalse(app.buttons.matching(identifier:"Next hand").firstMatch.exists)
            tapSelectableOption("C\nLearn")
            XCTAssertFalse(visible("CORRECT READ"), "WRONG_FINAL_MARKED_CORRECT")
            XCTAssertTrue(visible("MISSED CLUE", timeout: 12), "NO_AUTHENTIC_WRONG_FEEDBACK")
            XCTAssertTrue(visible("Review was the better play.", timeout: 12), "WRONG_FINAL_REPAIR_EXPLANATION_MISSING")
            XCTAssertTrue(visible("Learn shows what to study next.", timeout: 12), "WRONG_FINAL_ROUTE_DISTINCTION_MISSING")
            _ = enabledButton("Try same clue")
            persistedCheckpoint("C1_wrong_answer")
            return
        }
        persistedCheckpoint("C1_prefinal")
        XCTAssertFalse(visible("CORRECT READ"), "UNEARNED_FEEDBACK_DURING_CHECKPOINT")
        XCTAssertFalse(app.buttons.matching(identifier:"Next hand").firstMatch.exists)
        tapSelectableOption("B\nReview")
        XCTAssertTrue(visible("CORRECT READ", timeout: 12), "FINAL_FEEDBACK_MISSING_AFTER_ANSWER")
        persistedCheckpoint("C1_final_answer")
        tapButton("Next hand")
        XCTAssertTrue(visible("Session complete", timeout: 12) || visible("What finished", timeout: 12), "NO_TRUE_LESSON_SUMMARY")
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
                if let option = findOption(prefix).found.first, option.isEnabled { return }
                let pot = app.staticTexts.matching(NSPredicate(format:"label BEGINSWITH %@", "A\nPot")).firstMatch
                if pot.exists && pot.isHittable {
                    tapSelectableOption("A\nPot")
                    continue
                }
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

    private func secondRecap(wrong: Bool = false) throws {
        app.launch()
        XCTAssertTrue(app.waitForExistence(timeout:35))
        capture("second_lesson_saved_home")
        // Home Continue is a personalized first-value repeat. Use the actual
        // curriculum mission whose focus was selected by Summary Back to map.
        tapTab("Learn")
        XCTAssertTrue(visible("What poker is", timeout: 12), "SECOND_LESSON_CURRENT_MISSION_MISSING")
        capture("second_lesson_actual_Learn_mission")
        tapButton("Start")
        XCTAssertTrue(visible("Step 1/7", timeout: 12), "SECOND_LESSON_POT_STACK_NOT_ENTERED")
        waitForSelectable("C\nEveryone folds")
        let recipe = ["C\nEveryone folds", "C\nBest hand", "B\nHero put in all remaining chips", "C\nOnly the chips CO matched", "A\nA fold or a showdown"]
        for (index, prefix) in recipe.enumerated() {
            XCTAssertTrue(visible("Step \(index+2)/7", timeout: 12))
            waitForSelectable(prefix)
            tapSelectableOption(prefix)
            XCTAssertTrue(visible("CORRECT READ", timeout: 12))
            tapButton("Next hand")
        }
        waitForSelectable("C\nChips already committed to the middle")
        XCTAssertTrue(visible("Step 7/7", timeout: 12))
        XCTAssertTrue(visible("What is the pot?", timeout: 12))
        XCTAssertFalse(visible("CORRECT READ"), "SECOND_REVIEW_UNEARNED_FEEDBACK")
        persistedCheckpoint("C1_second_review_entry")
        if wrong {
            app.terminate(); app.launch()
            XCTAssertTrue(app.waitForExistence(timeout:35))
            capture("recap_inflight_return")
            if findOption("C\nChips already committed to the middle").found.isEmpty {
                tapButton("Continue")
            }
            waitForSelectable("C\nChips already committed to the middle")
            XCTAssertFalse(visible("CORRECT READ"), "RECAP_RESUME_UNEARNED_FEEDBACK")
            persistedCheckpoint("recap_resumed_unanswered")
        }
        tapSelectableOption(wrong ? "B\nEveryone folds before showdown" : "C\nChips already committed to the middle")
        if wrong {
            XCTAssertFalse(visible("CORRECT READ"), "POT_RECAP_FOLDS_MARKED_CORRECT")
            XCTAssertTrue(visible("MISSED CLUE", timeout: 12))
            XCTAssertTrue(visible("does not define the pot", timeout: 12))
            _ = enabledButton("Try same clue")
            persistedCheckpoint("recap_wrong")
            return
        }
        XCTAssertTrue(visible("CORRECT READ", timeout: 12))
        XCTAssertTrue(visible("shared prize", timeout: 12))
        persistedCheckpoint("recap_correct")
        tapButton("Next hand")
        XCTAssertTrue(visible("Session complete", timeout: 12) || visible("What finished", timeout: 12))
        persistedCheckpoint("recap_summary")
        for _ in 0..<6 {
            if app.buttons.matching(identifier:"Back to map").firstMatch.exists && app.buttons.matching(identifier:"Back to map").firstMatch.isHittable { break }
            app.swipeUp()
        }
        tapButton("Back to map")
        tapTab("Home")
        persistedCheckpoint("recap_home")
        app.terminate(); app.launch()
        XCTAssertTrue(app.waitForExistence(timeout:35))
        persistedCheckpoint("recap_restart")
    }

    private func selectAction(_ action: String) {
        for letter in ["A", "B", "C"] {
            let prefix = letter + "\n" + action
            if let e = findOption(prefix).found.first, e.isEnabled { tapSelectableOption(prefix); return }
        }
        capture("missing_action_" + action)
        XCTFail("NO_SOURCE_OWNED_SELECTABLE_ACTION_" + action)
    }

    func test04AuthenticRepair() throws {
        // Real OS Reduce Motion on this isolated device (set by the workflow via
        // the simulator's OS accessibility preference before this app launch).
        // iOS Settings UI automation never reached idle after the Accessibility
        // tap (run 38541883243), so the setting is verified from the OS itself:
        // UIAccessibility in this runner process reads the same system value the
        // app's MediaQuery.disableAnimations is derived from. No app preference.
        let osReduceMotion = UIAccessibility.isReduceMotionEnabled
        print("S11_OS_REDUCE_MOTION isReduceMotionEnabled=" + String(osReduceMotion))
        XCTAssertTrue(osReduceMotion, "REDUCED_MOTION_NOT_ENABLED_BY_OS")
        // Source-owned placement recommendation opens Actions legitimately.
        // The fresh public topic pack is locked until its route is learned.
        app.launch(); XCTAssertTrue(app.waitForExistence(timeout:35))
        capture("D2_OS_reduced_motion_first_use")
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
        tapButton("Start recommended lesson")
        waitForSelectable("A\nFold")
        capture("C2_actual_action_source_entry")
        XCTAssertTrue(visible("No bet", timeout: 12) || visible("free", timeout: 12))
        selectAction("Fold")
        XCTAssertFalse(visible("CORRECT READ"))
        persistedCheckpoint("C2_wrong")
        tapButton("Try same clue")
        waitForSelectable("B\nCheck")
        tapButton("Need a hint?")
        XCTAssertTrue(visible("Quick hint", timeout: 12))
        capture("C2_assistance_teaching")
        // Compact tree (run on QA 419c348): the Quick hint panel replaces the option
        // list; the learner returns through the real `Back to choices` button.
        let optionsBehindHint = ["A", "B", "C"].contains { !findOption($0 + "\nCheck").found.isEmpty }
        if !optionsBehindHint { tapButton("Back to choices") }
        selectAction("Check")
        persistedCheckpoint("C2_assisted")
        // Product-owned feedback CTA advances mapped repair to source recheck.
        // Observed compact feedback (QA 62a95b0): CORRECT WITH HELP, "NEXT · REPAIR THE
        // CLUE", CTA `Try same clue` - the repair stays open until the recheck.
        XCTAssertTrue(visible("CORRECT WITH HELP", timeout: 12), "ASSISTED_ANSWER_NOT_LABELLED_WITH_HELP")
        let recheck = app.buttons.matching(identifier:"Check original read").firstMatch
        if recheck.exists && recheck.isHittable { tapButton("Check original read") }
        else if app.buttons.matching(identifier:"Try same clue").firstMatch.waitForExistence(timeout: 5) { tapButton("Try same clue") }
        else { tapButton("Next hand") }
        // Observed (QA 9473bda): `Try same clue` after the assisted answer opens the
        // Review repair card ("1 miss to fix", CTA `Practice this spot`). The matched
        // independent recheck is entered through that real repair CTA.
        if visible("Practice this repair", timeout: 6) || app.buttons.matching(identifier: "Practice this spot").firstMatch.exists {
            capture("C2_review_repair_card_before_recheck")
            tapButton("Practice this spot")
        }
        waitForSelectable("B\nCheck")
        XCTAssertFalse(visible("CORRECT READ"))
        selectAction("Check")
        persistedCheckpoint("C2_independent_recheck")
        if app.buttons.matching(identifier:"Continue").firstMatch.exists && app.buttons.matching(identifier:"Continue").firstMatch.isHittable { tapButton("Continue") }
        else { tapButton("Next hand") }
        XCTAssertTrue(visible("Session complete", timeout: 12) || visible("What finished", timeout: 12))
        persistedCheckpoint("C2_summary")
        for _ in 0..<6 {
            if app.buttons.matching(identifier:"Back to map").firstMatch.exists && app.buttons.matching(identifier:"Back to map").firstMatch.isHittable { break }
            app.swipeUp()
        }
        tapButton("Back to map"); tapTab("Review")
        persistedCheckpoint("C2_review")
        tapTab("You"); capture("B_You_saved_truth")
        tapTab("Home"); persistedCheckpoint("C2_home")
        app.terminate(); app.launch(); XCTAssertTrue(app.waitForExistence(timeout:35))
        persistedCheckpoint("C2_restart")
    }

    func test02SecondAuthoredReview() throws { try secondRecap() }
    private func openRetake() {
        tapTab("You")
        for _ in 0..<9 {
            let tools = app.staticTexts.matching(NSPredicate(format:"label BEGINSWITH %@","Intro & placement")).firstMatch
            if tools.exists && tools.isHittable { break }
            app.swipeUp()
        }
        tapSelectableOption("Intro & placement")
        tapButton("Retake placement")
        openPlacementFromIntro()
    }

    private func routeBridgeAndRetakes() {
        tapTab("Practice"); capture("B_Practice_bridge")
        tapTab("Review"); capture("B_Review_not_due_bridge")
        tapTab("You"); persistedCheckpoint("B_profile_before_retake")
        openRetake()
        tapSelectableOption("I’m new to poker"); tapButton("Start from zero")
        persistedCheckpoint("B_retake_zero_finished")
        openRetake()
        tapSelectableOption("I’ve played casually"); tapButton("Continue")
        tapSelectableOption("Try one quick check"); tapButton("Continue")
        tapButton("Start quick check")
        for (i, answer) in ["2 private · 3 board · Pot 6 BB", "Board cards", "Check"].enumerated() {
            selectAction(answer)
            XCTAssertTrue(visible("CORRECT READ", timeout: 12))
            tapButton(i == 2 ? "See my start" : "Next check")
        }
        capture("B_retake_diagnostic_result")
        tapButton("Start with the useful hand")
        persistedCheckpoint("B_retake_diagnostic_finished")
        app.terminate(); app.launch(); XCTAssertTrue(app.waitForExistence(timeout:35))
        persistedCheckpoint("B_retake_restart")
    }

    func test06CleanAndRecap() throws { try firstLesson(); try secondRecap(); routeBridgeAndRetakes() }
    func test03WrongRecap() throws { try firstLesson(); try secondRecap(wrong:true) }

    func test00FirstGraded() throws { try firstLesson() }
    func test01WrongFinal() throws { try firstLesson(wrongFinal: true) }
}
