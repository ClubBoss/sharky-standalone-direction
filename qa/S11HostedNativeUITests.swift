import XCTest

final class S11HostedNativeUITests: XCTestCase {
    private let app = XCUIApplication(bundleIdentifier: "com.example.pokerAnalyzer")
    override func setUpWithError() throws { continueAfterFailure = false }

    private func witness(_ label: String, fullTree: Bool = false) {
        print("S11_NATIVE_STAGE=\(label)")
        if fullTree {
            print("S11_NATIVE_TREE_BEGIN=\(label)\n\(app.debugDescription)\nS11_NATIVE_TREE_END=\(label)")
        }
        let attachment = XCTAttachment(screenshot: XCUIScreen.main.screenshot())
        attachment.name = "S11_\(label)"
        attachment.lifetime = .keepAlways
        add(attachment)
    }

    private func button(_ text: String) -> XCUIElement {
        app.buttons.matching(NSPredicate(format: "label == %@", text)).firstMatch
    }

    private func requireButton(_ title: String, stage: String) {
        let element = button(title)
        guard element.waitForExistence(timeout: 8), element.isEnabled, element.isHittable else {
            witness("missing_enabled_\(stage)", fullTree: true)
            XCTFail("S11_STATE_ASSERT stage=\(stage) CTA=\(title) missing/disabled/covered")
            return
        }
        print("S11_NATIVE_ACTION stage=\(stage) exact_button=\(title)")
        element.tap()
        witness(stage)
    }

    private func requireChoice(prefix: String, stage: String) {
        // Flutter InkWell choices expose their rendered content as StaticText, NOT a
        // generic XCTest Button. Match the option's unique start, not instructional help copy.
        let predicate = NSPredicate(format: "label BEGINSWITH %@", prefix)
        let choices = app.staticTexts.matching(predicate)
        guard choices.count == 1 else {
            witness("choice_count_\(stage)", fullTree: true)
            XCTFail("S11_CHOICE_NOT_UNIQUE stage=\(stage) prefix=\(prefix) count=\(choices.count)")
            return
        }
        let choice = choices.element(boundBy: 0)
        guard choice.waitForExistence(timeout: 7), choice.isHittable else {
            witness("choice_missing_\(stage)", fullTree: true)
            XCTFail("S11_CHOICE_NOT_HITTABLE stage=\(stage) prefix=\(prefix)")
            return
        }
        print("S11_NATIVE_CHOICE stage=\(stage) actual=\(choice.label)")
        choice.tap()
        witness(stage)
    }

    private func openFirstRealLesson() {
        app.launch()
        XCTAssertTrue(app.waitForExistence(timeout: 30), "S11_APP_NOT_LAUNCHED")
        XCTAssertTrue(
            button("Find my start").waitForExistence(timeout: 12) ||
            app.staticTexts["Sharky Poker"].exists,
            "S11_EXPECTED_FRESH_PLACEMENT"
        )
        witness("placement_intro")
        requireButton("Find my start", stage: "placement_start")
        XCTAssertTrue(app.staticTexts.matching(NSPredicate(format: "label CONTAINS %@", "Where are you starting from?")).firstMatch.waitForExistence(timeout: 8))
        requireChoice(prefix: "I\u{2019}m new to poker", stage: "beginner_selected")
        let begin = button("Start from zero")
        XCTAssertTrue(begin.waitForExistence(timeout: 7), "S11_START_FROM_ZERO_NOT_SHOWN")
        XCTAssertTrue(begin.isEnabled && begin.isHittable, "S11_START_FROM_ZERO_NOT_ENABLED")
        requireButton("Start from zero", stage: "welcome_entered")
        requireButton("Try one table read", stage: "ungraded_welcome_preview")
        requireChoice(prefix: "Check", stage: "welcome_demo_ungraded")
        requireButton("Open my path", stage: "welcome_handoff_complete")
        requireButton("Start first hand", stage: "real_first_lesson")
    }

    func test01FirstAssessedDecision() {
        openFirstRealLesson()
        // A welcome demo choice does not count as an assessed attempt.
        // Only advance through real first-lesson theory until the distinct
        // 'find hero' question and its source-owned option are visible.
        for phase in 0..<9 {
            let question = app.staticTexts.matching(
                NSPredicate(format: "label CONTAINS %@", "Which label could change next hand")
            ).firstMatch
            if question.exists {
                requireChoice(prefix: "BTN", stage: "graded_find_hero_bottom")
                witness("after_first_real_grade", fullTree: true)
                print("S11_NATIVE_FIRST_ASSESSED_CHOICE_SUBMITTED task=what_poker_is_find_hero choice=bottom")
                return
            }
            let available = ["Continue", "Next", "Start", "Got it"].first {
                let b = button($0)
                return b.exists && b.isEnabled && b.isHittable
            }
            guard let next = available else {
                witness("theory_stuck_\(phase)", fullTree: true)
                XCTFail("S11_THEORY_PROGRESS_NOT_REACHABLE phase=\(phase)")
                return
            }
            requireButton(next, stage: "first_lesson_theory_\(phase)")
        }
        witness("no_graded_question_after_theory", fullTree: true)
        XCTFail("S11_REAL_GRADED_TASK_NOT_REACHED_AFTER_9_THEORY_STEPS")
    }
}
