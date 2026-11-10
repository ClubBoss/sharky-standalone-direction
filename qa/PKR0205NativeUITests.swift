import XCTest
import UIKit
import Darwin

// Ordinary installed product, one fresh EN iPhone 14 Pro. No route/state seeds.
final class PKR0205NativeUITests: XCTestCase {
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
        // Querying XCTest accessibility can itself block while the simulator
        // is busy. Capture the tree BEFORE arming the 45-second native-screen
        // hold: the external simctl collector must capture within the hold.
        let tree = app.debugDescription
        print("PKR0205_GATE_STATE " + tag)
        print("PKR0205_NATIVE_TREE_BEGIN " + tag + "\n" + tree + "\nPKR0205_NATIVE_TREE_END " + tag)
        fflush(stdout)
        print("PKR0205_SCREEN_CHECKPOINT " + tag + " epoch=" + String(Date().timeIntervalSince1970))
        fflush(stdout)
        RunLoop.current.run(until: Date().addingTimeInterval(45))
        print("PKR0205_SCREEN_RELEASE " + tag + " epoch=" + String(Date().timeIntervalSince1970))
        fflush(stdout)
    }

    private func checkpoint(_ tag: String) {
        capture(tag)
        print("PKR0205_PERSIST_CHECKPOINT " + tag + " epoch=" + String(Date().timeIntervalSince1970))
        fflush(stdout)
        RunLoop.current.run(until: Date().addingTimeInterval(45))
        print("PKR0205_PERSIST_RELEASE " + tag + " epoch=" + String(Date().timeIntervalSince1970))
        fflush(stdout)
    }

    private func tapButton(_ label: String) {
        let button = app.buttons.matching(identifier: label).firstMatch
        guard button.waitForExistence(timeout: 15), button.isEnabled, button.isHittable else {
            capture("missing_button_" + label.replacingOccurrences(of: " ", with: "_").prefix(24))
            XCTFail("MISSING_ENABLED_HITTABLE_BUTTON " + label)
            return
        }
        print("PKR0205_REAL_UI_BUTTON " + label)
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
        return app.buttons.matching(NSPredicate(format: "label == %@ OR label BEGINSWITH %@", text, text + "\n"))
            .allElementsBoundByIndex.filter { $0.exists && $0.isHittable && $0.frame.midY < app.frame.height * 0.85 }
    }

    private func select(_ text: String) {
        let deadline = Date().addingTimeInterval(20)
        repeat {
            let choices = option(text)
            if choices.count == 1 && choices[0].isEnabled {
                print("PKR0205_REAL_UI_CHOICE requested=" + text + " actual=" + choices[0].label)
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
            print("PKR0205_REAL_TEACHING_CTA " + choices[0].label)
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

    func testDefinitionsFeedbackRestartAndUnprovedBlock() throws {
        app.launch()
        XCTAssertTrue(app.waitForExistence(timeout: 35))
        XCTAssertEqual(app.frame.width, 393, accuracy: 0.1)
        XCTAssertEqual(app.frame.height, 852, accuracy: 0.1)
        capture("P0_first_use")
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

        // Earn the real Guide prerequisites through ordinary UI, as in the
        // existing genuine native route. Placement skips are never promoted.
        backFromRunner(); tab("Home"); tab("Learn")
        checkpoint("P1_before_prerequisites")
        let first = app.buttons.matching(identifier: "Start first table").firstMatch
        if first.waitForExistence(timeout: 8) { tapButton("Start first table") }
        else { tapButton("Start") }
        let guide = ["BTN", "2 private cards, 3 board cards, 6 BB in the pot",
                     "2 private cards, 3 board cards, 4 BB in the pot",
                     "You are BTN, blinds are posted, and no board is out yet", "Review"]
        for answer in guide { prepareChoice(answer); select(answer); forward() }
        XCTAssertTrue(visible("Session complete", timeout: 15) || visible("What finished"))
        checkpoint("P2_guide_completed")
        summaryToMap()
        XCTAssertTrue(visible("Actions", timeout: 15) || visible("Fold, check, call, raise"))
        tapButton("Start")
        prepareChoice("Fold")
        XCTAssertTrue(visible("No bet faces you. Which action keeps you in the hand without adding chips?"))
        capture("P3_legal_context_question")
        select("Fold")
        XCTAssertTrue(visible("MISSED CLUE", timeout: 15) || visible("Folding gives up the hand"))
        checkpoint("P4_wrong_fold")
        tapButton("Try same clue")
        prepareChoice("Check")
        XCTAssertTrue(visible("What action keeps playing for free?"))
        select("Check")
        XCTAssertTrue(visible("CORRECT READ", timeout: 15) || visible("Check is legal"))
        checkpoint("P5_correct_repair")
        tapButton("Check original read")
        prepareChoice("Check")
        XCTAssertTrue(visible("No bet faces you. Which action keeps you in the hand without adding chips?"))
        select("Check")
        XCTAssertTrue(visible("CORRECT READ", timeout: 15) || visible("Check is legal"))
        checkpoint("P6_original_recheck")
        forward()
        prepareChoice("Check")
        XCTAssertTrue(visible("What action keeps playing for free?"))
        select("Check")
        forward()
        prepareChoice("Call")
        XCTAssertTrue(visible("Which action gives up the hand?"))
        checkpoint("P7_before_unproved")
        // Numeric Call 2 BB is intentionally not proved by this authored hand.
        select("Call")
        XCTAssertTrue(visible("This decision is temporarily unavailable", timeout: 12))
        XCTAssertTrue(visible("Which action gives up the hand?"))
        checkpoint("P8_unproved_refused")
        select("Fold")
        XCTAssertTrue(visible("This decision is temporarily unavailable", timeout: 12))
        XCTAssertTrue(visible("Which action gives up the hand?"))
        checkpoint("P8b_source_completion_refused")
        print("PKR0205_EARLY_FOLD_NATIVE_NOT_REACHED prerequisite=actions_fold_drill source_hold=true")
        print("PKR0205_ACTUAL_PROCESS_TERMINATE")
        app.terminate()
        XCTAssertTrue(app.wait(for: .notRunning, timeout: 15))
        print("PKR0205_ACTUAL_PROCESS_RELAUNCH")
        app.launch()
        XCTAssertTrue(app.waitForExistence(timeout: 35))
        XCTAssertEqual(app.frame.width, 393, accuracy: 0.1)
        XCTAssertEqual(app.frame.height, 852, accuracy: 0.1)
        XCTAssertFalse(visible("Find my start", timeout: 3), "RESTART_LOST_ONBOARDING")
        checkpoint("P9_after_restart")
        print("PKR0205_NATIVE_UI_ROUTE_COMPLETED canonical_evidence_verifier_pending=true")
    }
}
