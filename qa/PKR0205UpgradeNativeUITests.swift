import XCTest
import UIKit
import Darwin

// Ordinary installed product, one fresh EN iPhone 14 Pro. No route/state seeds.
final class PKR0205UpgradeNativeUITests: XCTestCase {
    private let app = XCUIApplication(bundleIdentifier: "com.example.pokerAnalyzer")

    override func setUpWithError() throws {
        continueAfterFailure = false
        XCUIDevice.shared.orientation = .portrait
        app.launchArguments = ["-AppleLanguages", "(en)", "-AppleLocale", "en_US"]
    }

    private func visible(_ text: String, timeout: TimeInterval = 4) -> Bool {
        app.descendants(matching: .any)
            .matching(NSPredicate(format: "label CONTAINS[cd] %@", text))
            .firstMatch.waitForExistence(timeout: timeout)
    }

    private func capture(_ tag: String) {
        print("PKR0205U_GATE_STATE " + tag)
        print("PKR0205U_SCREEN_CHECKPOINT " + tag + " epoch=" + String(Date().timeIntervalSince1970))
        fflush(stdout)
        print("PKR0205U_NATIVE_TREE_BEGIN " + tag + "\n" + app.debugDescription + "\nPKR0205U_NATIVE_TREE_END " + tag)
        fflush(stdout)
        RunLoop.current.run(until: Date().addingTimeInterval(45))
        print("PKR0205U_SCREEN_RELEASE " + tag + " epoch=" + String(Date().timeIntervalSince1970))
        fflush(stdout)
    }

    private func checkpoint(_ tag: String) {
        capture(tag)
        print("PKR0205U_PERSIST_CHECKPOINT " + tag + " epoch=" + String(Date().timeIntervalSince1970))
        fflush(stdout)
        RunLoop.current.run(until: Date().addingTimeInterval(45))
        print("PKR0205U_PERSIST_RELEASE " + tag + " epoch=" + String(Date().timeIntervalSince1970))
        fflush(stdout)
    }

    private func tapButton(_ label: String) {
        let button = app.buttons.matching(identifier: label).firstMatch
        guard button.waitForExistence(timeout: 15), button.isEnabled, button.isHittable else {
            capture("missing_button_" + label.replacingOccurrences(of: " ", with: "_").prefix(24))
            XCTFail("MISSING_ENABLED_HITTABLE_BUTTON " + label)
            return
        }
        print("PKR0205U_REAL_UI_BUTTON " + label)
        button.tap()
    }

    private func option(_ text: String) -> [XCUIElement] {
        if text == "I\u{2019}ve played casually" || text == "Try one quick check" {
            let predicate = NSPredicate(format: "label BEGINSWITH[cd] %@", text)
            for kind: XCUIElement.ElementType in [.button, .staticText] {
                let matches = app.descendants(matching: kind).matching(predicate)
                    .allElementsBoundByIndex.filter { $0.exists && $0.isHittable }
                if !matches.isEmpty { return matches }
            }
        }
        for letter in ["A", "B", "C", "D"] {
            let predicate = NSPredicate(format: "label BEGINSWITH[cd] %@", letter + "\n" + text)
            for kind: XCUIElement.ElementType in [.button, .staticText] {
                let matches = app.descendants(matching: kind).matching(predicate)
                    .allElementsBoundByIndex.filter { $0.exists && $0.isHittable }
                if !matches.isEmpty { return matches }
            }
        }
        let ordinary = app.buttons.matching(NSPredicate(format: "label == %@ OR label BEGINSWITH %@", text, text + "\n"))
            .allElementsBoundByIndex.filter { $0.exists && $0.isHittable && $0.frame.midY < app.frame.height * 0.85 }
        if !ordinary.isEmpty { return ordinary }
        // Physical seat controls expose the source-owned "Select <seat>"
        // accessibility action, distinct from passive seat labels.
        let seats = ["BB": "BB", "UTG": "UTG", "BTN": "BTN", "CO": "CO", "BTN (your seat)": "BTN"]
        if let seat = seats[text] {
            let label = "Select " + seat
            return app.buttons.matching(NSPredicate(format: "label == %@ OR label BEGINSWITH %@", label, label + "\n"))
                .allElementsBoundByIndex.filter { $0.exists && $0.isEnabled && $0.isHittable }
        }
        return []
    }

    private func select(_ text: String) {
        let deadline = Date().addingTimeInterval(20)
        repeat {
            let choices = option(text)
            if choices.count == 1 && choices[0].isEnabled {
                print("PKR0205U_REAL_UI_CHOICE requested=" + text + " actual=" + choices[0].label)
                choices[0].tap()
                return
            }
            if choices.count > 1 { XCTFail("AMBIGUOUS_NATIVE_OPTION " + text); return }
            RunLoop.current.run(until: Date().addingTimeInterval(0.25))
        } while Date() < deadline
        capture("missing_option_" + text.replacingOccurrences(of: " ", with: "_").prefix(24))
        XCTFail("NO_SELECTABLE_NATIVE_OPTION " + text)
    }

    private func prepareChoice(_ text: String) {
        for step in 0..<24 {
            let teaching = app.otherElements.matching(NSPredicate(format: "label BEGINSWITH %@", "Theory navigation, page")).firstMatch
            if !teaching.exists, option(text).count == 1, option(text)[0].isEnabled { return }
            var choices: [XCUIElement] = []
            let deadline = Date().addingTimeInterval(12)
            repeat {
                choices = ["Next", "Continue", "Got it", "Next hand"].compactMap { label in
                    let button = app.buttons.matching(identifier: label).firstMatch
                    return button.exists && button.isEnabled && button.isHittable ? button : nil
                }
                if choices.count == 1 { break }
                RunLoop.current.run(until: Date().addingTimeInterval(0.25))
            } while Date() < deadline
            guard choices.count == 1 else {
                capture("teaching_route_blocked_" + String(step))
                XCTFail("NO_UNIQUE_AUTHORED_TEACHING_CTA " + text)
                return
            }
            print("PKR0205U_REAL_TEACHING_CTA " + choices[0].label)
            choices[0].tap()
        }
        XCTFail("AUTHORED_TEACHING_LIMIT " + text)
    }

    private func forward() {
        let deadline = Date().addingTimeInterval(15)
        repeat {
            let names = ["Next hand", "Continue", "Check original read"].filter { name in
                let button = app.buttons.matching(identifier: name).firstMatch
                return button.exists && button.isEnabled && button.isHittable
            }
            if names.count == 1 { tapButton(names[0]); return }
            RunLoop.current.run(until: Date().addingTimeInterval(0.25))
        } while Date() < deadline
        capture("feedback_route_blocked")
        XCTFail("NO_UNIQUE_FEEDBACK_FORWARD")
    }

    private func tab(_ label: String) {
        for kind: XCUIElement.ElementType in [.button, .staticText] {
            var items = app.descendants(matching: kind).matching(NSPredicate(format: "label == %@", label))
                .allElementsBoundByIndex.filter { $0.exists && $0.isHittable }
            if items.count > 1 { items = items.filter { $0.frame.midY > app.frame.height * 0.85 } }
            if items.count == 1 { items[0].tap(); return }
        }
        capture("missing_tab_" + label)
        XCTFail("NO_UNIQUE_NATIVE_TAB " + label)
    }

    private func backFromRunner() {
        let back = app.buttons.allElementsBoundByIndex.filter {
            $0.exists && $0.isEnabled && $0.isHittable &&
            $0.frame.minX < app.frame.width * 0.15 &&
            $0.frame.minY < app.frame.height * 0.15 &&
            $0.frame.width <= 48 && $0.frame.height <= 48 &&
            ($0.label.isEmpty || $0.label == "Back")
        }
        guard back.count == 1 else { capture("runner_back_missing"); XCTFail("NO_UNIQUE_RUNNER_BACK"); return }
        back[0].tap()
        XCTAssertTrue(visible("Learn", timeout: 15))
    }

    private func summaryToMap() {
        for _ in 0..<9 {
            let button = app.buttons.matching(identifier: "Back to map").firstMatch
            if button.exists && button.isEnabled && button.isHittable { tapButton("Back to map"); return }
            app.swipeUp()
        }
        capture("summary_map_cta_missing")
        XCTFail("NO_SUMMARY_BACK_TO_MAP")
    }

    private struct SourceStep {
        let id: String
        let question: String
        let answer: String
    }

    // Exact source manifest 44cd1595c84163b8a4a555b5017496cbae44a20d4f8f3abedf634d10263cec67.
    // Main receipts below prove historic navigation, not final PKR numerical truth.
    private let what_poker_is: [SourceStep] = [
        SourceStep(id: "what_poker_is_find_hero", question: "Which label could change next hand while the player is still you?", answer: "BTN"),
        SourceStep(id: "what_poker_is_table_read_transfer", question: "What is the clean first table read?", answer: "2 private cards, 3 board cards, 6 BB in the pot"),
        SourceStep(id: "what_poker_is_table_read_recheck", question: "What is the clean table read here?", answer: "2 private cards, 3 board cards, 4 BB in the pot"),
        SourceStep(id: "first_table_guide_one_clear_choice", question: "What is the clean preflop setup here?", answer: "You are BTN, blinds are posted, and no board is out yet"),
        SourceStep(id: "first_table_guide_route_roles", question: "Where do you go to fix mistakes after a miss?", answer: "Review"),
    ]
    private let fold_check_call_raise: [SourceStep] = [
        SourceStep(id: "actions_legal_context", question: "No bet faces you. Which action keeps you in the hand without adding chips?", answer: "Check"),
        SourceStep(id: "actions_check_drill", question: "What action keeps playing for free?", answer: "Check"),
        SourceStep(id: "actions_fold_drill", question: "Which action gives up the hand?", answer: "Fold"),
        SourceStep(id: "actions_call_drill", question: "Which action matches the 1 BB price?", answer: "Call"),
        SourceStep(id: "actions_raise_drill", question: "Choose how to play your first action.", answer: "Raise"),
        SourceStep(id: "actions_review", question: "First in on the Button. What is cleaner than limping?", answer: "Raise"),
    ]
    private let blinds_action_order: [SourceStep] = [
        SourceStep(id: "blinds_posts_drill", question: "Tap the blind that sets the 1 BB baseline.", answer: "BB"),
        SourceStep(id: "blinds_first_actor", question: "Tap UTG.", answer: "UTG"),
        SourceStep(id: "blinds_last_actor", question: "Tap BB.", answer: "BB"),
        SourceStep(id: "blinds_postflop_button", question: "Tap the last postflop actor.", answer: "BTN"),
        SourceStep(id: "blinds_button_moves", question: "Which marker shows the dealer button this hand?", answer: "BTN"),
        SourceStep(id: "blinds_review", question: "Who acts first preflop?", answer: "UTG"),
    ]
    private let positions: [SourceStep] = [
        SourceStep(id: "positions_button", question: "Tap the Button.", answer: "BTN"),
        SourceStep(id: "positions_utg", question: "Tap UTG.", answer: "UTG"),
        SourceStep(id: "positions_cutoff", question: "Tap the cutoff.", answer: "CO"),
        SourceStep(id: "positions_late_seat", question: "Which seat acts latest after the flop?", answer: "BTN"),
        SourceStep(id: "positions_early_late", question: "Which seat is early preflop?", answer: "UTG"),
        SourceStep(id: "positions_review", question: "Which seat is latest after the flop here?", answer: "BTN (your seat)"),
    ]
    private let hand_rankings_table: [SourceStep] = [
        SourceStep(id: "hand_rankings_pair_drill", question: "What does hero have here?", answer: "Pair"),
        SourceStep(id: "hand_rankings_two_pair_drill", question: "Which hand is stronger?", answer: "Two pair"),
        SourceStep(id: "hand_rankings_trips_drill", question: "Which hand ranks higher?", answer: "Trips"),
        SourceStep(id: "hand_rankings_straight_drill", question: "What makes a straight?", answer: "Five in a row"),
        SourceStep(id: "hand_rankings_flush_drill", question: "Which hand ranks higher?", answer: "Flush"),
        SourceStep(id: "hand_rankings_full_house_drill", question: "What does hero have here?", answer: "Full house"),
        SourceStep(id: "hand_rankings_quads_drill", question: "What does hero have here?", answer: "Four of a kind"),
        SourceStep(id: "hand_rankings_royal_flush_drill", question: "What does hero have here?", answer: "Royal flush"),
        SourceStep(id: "hand_rankings_full_house_vs_flush_drill", question: "Which shown hand is stronger?", answer: "Hero full house"),
        SourceStep(id: "hand_rankings_quads_vs_full_house_drill", question: "Who wins at showdown?", answer: "Hero four of a kind"),
        SourceStep(id: "hand_rankings_royal_vs_flush_drill", question: "Which hand ranks higher?", answer: "Hero royal flush"),
        SourceStep(id: "hand_rankings_best_five_drill", question: "How many cards count at showdown?", answer: "Five"),
        SourceStep(id: "hand_rankings_review", question: "Which ranks higher: flush or straight?", answer: "Flush"),
    ]
    private let showdown_winning: [SourceStep] = [
        SourceStep(id: "showdown_foldout_drill", question: "What happens if everyone folds to you?", answer: "Win now"),
        SourceStep(id: "showdown_best_hand_drill", question: "What decides a showdown?", answer: "Best hand"),
        SourceStep(id: "showdown_kicker_drill", question: "Same pair. What can break the tie?", answer: "Kicker"),
        SourceStep(id: "showdown_board_plays_drill", question: "If both players use the same board, what can happen?", answer: "Tie"),
        SourceStep(id: "showdown_tie_drill", question: "What happens to the pot on a tie?", answer: "Split"),
        SourceStep(id: "showdown_review", question: "What wins at showdown?", answer: "Best hand"),
    ]
    private let buckets: [SourceStep] = [
        SourceStep(id: "hand_discipline_buckets_premium", question: "Which bucket is AA?", answer: "Premium"),
        SourceStep(id: "hand_discipline_buckets_strong", question: "Which bucket is JJ?", answer: "Strong"),
        SourceStep(id: "hand_discipline_buckets_medium", question: "Which bucket is KQo?", answer: "Medium"),
        SourceStep(id: "hand_discipline_buckets_trash", question: "Which bucket fits J8o early?", answer: "Trash"),
        SourceStep(id: "hand_discipline_buckets_borderline", question: "Which bucket is QJs before context helps?", answer: "Medium"),
    ]

    private func startCurrentLesson() {
        let first = app.buttons.matching(identifier: "Start first table").firstMatch
        if first.exists && first.isEnabled && first.isHittable { tapButton("Start first table") }
        else { tapButton("Start") }
    }

    private func finishAuthoredLesson() {
        for _ in 0..<8 {
            if visible("Session complete", timeout: 2) || visible("What finished", timeout: 2) { return }
            // Only authored nonchoice review/theory CTAs may remain. In
            // particular, W2 bucket recap has no authored answer options.
            forward()
        }
        capture("missing_authored_lesson_summary")
        XCTFail("NO_ACTUAL_LESSON_COMPLETION_SUMMARY")
    }

    private func completeLesson(_ steps: [SourceStep], checkpoint tag: String) {
        startCurrentLesson()
        for step in steps {
            prepareChoice(step.answer)
            XCTAssertTrue(visible(step.question, timeout: 12), "UNEXPECTED_AUTHORED_QUESTION " + step.id)
            print("PKR0205U_EXPECTED_SOURCE_STEP " + step.id)
            select(step.answer)
            forward()
        }
        finishAuthoredLesson()
        checkpoint(tag)
        summaryToMap()
    }

    private func openWorldTwo() {
        tapButton("Open worlds")
        for _ in 0..<8 {
            for kind: XCUIElement.ElementType in [.button, .staticText, .other] {
                let exact = app.descendants(matching: kind).matching(NSPredicate(format: "label == %@", "World 2"))
                    .allElementsBoundByIndex.filter { $0.exists && $0.isEnabled && $0.isHittable }
                if exact.count == 1 { exact[0].tap(); return }
                let grouped = app.descendants(matching: kind).matching(NSPredicate(format: "label MATCHES %@", "(?s)^(2\\n)?World 2(\\n.*)?$"))
                    .allElementsBoundByIndex.filter { $0.exists && $0.isEnabled && $0.isHittable && $0.frame.height < 240 }
                if grouped.count == 1 { grouped[0].tap(); return }
            }
            app.swipeUp()
        }
        capture("world_two_not_selectable")
        XCTFail("WORLD_TWO_NOT_SELECTABLE_THROUGH_REAL_UI")
    }

    func test01EarnHistoricalWorldOne() throws {
        app.launch()
        XCTAssertTrue(app.waitForExistence(timeout: 35))
        let firstUse = app.buttons.matching(identifier: "Find my start").firstMatch
        let readyDeadline = Date().addingTimeInterval(60)
        repeat {
            if firstUse.exists && firstUse.isEnabled && firstUse.isHittable { break }
            RunLoop.current.run(until: Date().addingTimeInterval(0.25))
        } while Date() < readyDeadline
        XCTAssertTrue(firstUse.exists && firstUse.isEnabled && firstUse.isHittable, "REAL_FIRST_USE_UI_NOT_READY")
        print("PKR0205U_REAL_FIRST_USE_READY epoch=" + String(Date().timeIntervalSince1970))
        fflush(stdout)
        XCTAssertEqual(app.frame.width, 393, accuracy: 0.1)
        XCTAssertEqual(app.frame.height, 852, accuracy: 0.1)
        capture("M0_fresh_main")
        tapButton("Find my start")
        if !visible("Where are you starting from?", timeout: 12) {
            let retry = app.buttons.matching(identifier: "Find my start").firstMatch
            if retry.exists && retry.isEnabled && retry.isHittable { retry.tap() }
        }
        XCTAssertTrue(visible("Where are you starting from?", timeout: 20))
        select("I\u{2019}ve played casually"); tapButton("Continue")
        select("Try one quick check"); tapButton("Continue")
        tapButton("Start quick check")
        for (index, answer) in ["2 private \u{00B7} 3 board \u{00B7} Pot 6 BB", "Board cards", "Check"].enumerated() {
            select(answer)
            XCTAssertTrue(visible("CORRECT READ", timeout: 15))
            tapButton(index == 2 ? "See my start" : "Next check")
        }
        tapButton("Start with the useful hand")
        tapButton("Try one table read")
        XCTAssertTrue(visible("What action keeps playing for free?", timeout: 15))
        select("Check")
        tapButton("Start recommended lesson")
        prepareChoice("Fold")
        backFromRunner(); tab("Home"); tab("Learn")
        checkpoint("M1_real_placement")
        completeLesson(what_poker_is, checkpoint: "M2_guide")
        completeLesson(fold_check_call_raise, checkpoint: "M3_actions")
        completeLesson(blinds_action_order, checkpoint: "M4_blinds")
        completeLesson(positions, checkpoint: "M5_positions")
        completeLesson(hand_rankings_table, checkpoint: "M6_rankings")
        completeLesson(showdown_winning, checkpoint: "M7_showdown")
        openWorldTwo()
        XCTAssertTrue(app.buttons.matching(identifier: "Start").firstMatch.waitForExistence(timeout: 15))
        checkpoint("M8_real_world_two_unlocked")
        print("PKR0205U_MAIN_HISTORY_NAVIGATION_ONLY no_final_numeric_recertification=true")
        app.terminate()
        XCTAssertTrue(app.wait(for: .notRunning, timeout: 15))
        print("PKR0205U_MAIN_TERMINATED_FOR_ORDINARY_UPGRADE")
    }

    func test02FinalEarlyFoldAndRestart() throws {
        app.launch()
        XCTAssertTrue(app.waitForExistence(timeout: 35))
        XCTAssertEqual(app.frame.width, 393, accuracy: 0.1)
        XCTAssertEqual(app.frame.height, 852, accuracy: 0.1)
        XCTAssertFalse(visible("Find my start", timeout: 3), "UPGRADE_LOST_ACTUAL_LEARNER")
        checkpoint("U0_preserved_on_final_launch")
        tab("Learn"); openWorldTwo()
        completeLesson(buckets, checkpoint: "U1_final_buckets")
        startCurrentLesson()
        prepareChoice("Raise")
        XCTAssertTrue(visible("What is the clean action?", timeout: 12))
        checkpoint("U2_actual_earlyfold_question")
        select("Raise")
        XCTAssertTrue(visible("MISSED CLUE", timeout: 15) || visible("Position is early"))
        checkpoint("U3_wrong_raise")
        tapButton("Try same clue")
        prepareChoice("Call")
        XCTAssertTrue(visible("Which action matches the 1 BB price?", timeout: 12))
        checkpoint("U4_actual_mapped_price_repair")
        select("Call")
        XCTAssertTrue(visible("This decision is temporarily unavailable", timeout: 12))
        checkpoint("U5_mapped_price_refused")
        backFromRunner(); tab("Learn"); openWorldTwo()
        startCurrentLesson()
        prepareChoice("Fold")
        XCTAssertTrue(visible("What is the clean action?", timeout: 12))
        capture("U6_actual_original_retry_question")
        select("Fold")
        XCTAssertTrue(visible("CORRECT READ", timeout: 15) || visible("Excellent spot"))
        checkpoint("U7_correct_original_retry")
        forward()
        checkpoint("U8_original_completion")
        backFromRunner(); tab("Learn")
        checkpoint("U9_before_restart")
        print("PKR0205U_ACTUAL_PROCESS_TERMINATE")
        app.terminate()
        XCTAssertTrue(app.wait(for: .notRunning, timeout: 15))
        print("PKR0205U_ACTUAL_PROCESS_RELAUNCH")
        app.launch()
        XCTAssertTrue(app.waitForExistence(timeout: 35))
        XCTAssertFalse(visible("Find my start", timeout: 3))
        checkpoint("U10_after_restart")
        print("PKR0205U_ORIGINAL_RETRY_AFTER_FEEDBACK not_matched_recheck=true")
        print("PKR0205U_ACTUAL_EARLYFOLD_ROUTE_COMPLETED full_pkr_hold=true")
    }
}
