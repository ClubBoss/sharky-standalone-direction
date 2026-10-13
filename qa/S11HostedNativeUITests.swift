import XCTest

final class S11HostedNativeUITests: XCTestCase {
    private let app = XCUIApplication(bundleIdentifier: "com.example.pokerAnalyzer")
    override func setUpWithError() throws { continueAfterFailure = false }

    private func capture(_ label: String) {
        print("S11_NATIVE_SCREEN \(label)")
        print("S11_NATIVE_TREE_BEGIN \(label)\n\(app.debugDescription)\nS11_NATIVE_TREE_END \(label)")
        let a = XCTAttachment(screenshot: XCUIScreen.main.screenshot())
        a.name = "S11_\(label)"
        a.lifetime = .keepAlways
        add(a)
    }
    @discardableResult private func tap(_ needle: String, wait: TimeInterval = 1.0) -> Bool {
        let pred = NSPredicate(format: "label CONTAINS[cd] %@", needle)
        for kind: XCUIElement.ElementType in [.button, .link, .staticText, .other] {
            let el = app.descendants(matching: kind).matching(pred).firstMatch
            if el.waitForExistence(timeout: wait), el.isHittable {
                print("S11_TAP requested=\(needle) actual=\(el.label)")
                el.tap()
                return true
            }
        }
        return false
    }
    private func progress(_ label: String, limit: Int = 30) -> Bool {
        for i in 0..<limit {
            if tap(label) {
                print("S11_ANSWER_TAPPED \(label) step=\(i)")
                capture("answered_\(label.prefix(18))")
                return true
            }
            let progression = ["Continue", "Start", "Next", "Got it", "Learn", "Begin", "Poker from Zero"]
            var moved = false
            for next in progression {
                if tap(next) { moved = true; break }
            }
            if !moved {
                print("S11_NAVIGATION_STUCK expected=\(label) at step=\(i)")
                capture("stuck_\(label.prefix(15))")
                return false
            }
        }
        capture("timed_out_\(label.prefix(15))")
        return false
    }
    func test00NativeSmokeAndAccessibility() throws {
        app.launch()
        XCTAssertTrue(app.waitForExistence(timeout: 35), "Native app failed to launch")
        capture("entry")
        XCTAssertTrue(app.staticTexts["Sharky"].exists || app.staticTexts["Poker from Zero"].exists || app.buttons["Learn"].exists, "No recognizable Sharky root accessibility semantics")
    }
    func test10C1IndependentClean() throws {
        app.launch()
        capture("C1_initial")
        let sequence = [
            "BTN (your seat)",
            "2 private cards, 3 board cards, 6 BB in the pot",
            "2 private cards, 3 board cards, 4 BB in the pot",
            "You are BTN, blinds are posted, and no board is out yet"
        ]
        for expected in sequence {
            XCTAssertTrue(progress(expected), "C1 missing real actionable option: \(expected)")
        }
        _ = tap("Continue")
        _ = tap("Summary")
        capture("C1_summary_after_four")
        print("S11_C1_UI_SEQUENCE_FINISHED; HOST MUST ASSERT EXACT FOUR PERSISTED RECORDS AND XP")
    }
    func test20C2WrongRepairMixed() throws {
        app.launch()
        capture("C2_entry")
        _ = tap("Learn")
        _ = tap("Fold, check, call, raise")
        _ = tap("Continue")
        XCTAssertTrue(progress("Fold"), "Could not submit real incorrect Fold at legal-actions decision")
        capture("C2_original_wrong")
        _ = tap("Continue")
        _ = tap("Quick Hint")
        XCTAssertTrue(progress("Check"), "Mapped repair Check not accessible")
        capture("C2_assisted_repair")
        _ = tap("Continue")
        XCTAssertTrue(progress("Check"), "Independent original-source Check recheck not accessible")
        capture("C2_independent_recheck")
        for choice in ["Fold", "Call", "Raise"] {
            _ = tap("Continue")
            XCTAssertTrue(progress(choice), "C2 subsequent source task not accessible: \(choice)")
        }
        _ = tap("Continue")
        _ = tap("Summary")
        capture("C2_mixed_summary")
        app.terminate()
        app.launch()
        capture("C2_home_after_restart")
        print("S11_C2_UI_SEQUENCE_FINISHED; HOST MUST ASSERT WRONG/ASSISTED/RECHECK DISTINCT LEDGER AND NO DUPLICATE XP")
    }
}
