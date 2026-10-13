import XCTest

final class S11HostedNativeUITests: XCTestCase {
    private let app = XCUIApplication(bundleIdentifier: "com.example.pokerAnalyzer")
    override func setUpWithError() throws { continueAfterFailure = false }

    private func capture(_ tag: String) {
        print("S11_GATE_STATE " + tag)
        print("S11_NATIVE_TREE_BEGIN " + tag + "\n" + app.debugDescription + "\nS11_NATIVE_TREE_END " + tag)
        let attachment = XCTAttachment(screenshot: XCUIScreen.main.screenshot())
        attachment.name = "S11_" + tag
        attachment.lifetime = .keepAlways
        add(attachment)
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

    func test00FirstGraded() throws {
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
        tapSelectableOption("B\\nCheck")
        XCTAssertTrue(visible("Your path is ready."),"WELCOME_UNGRADED_HANDOFF_MISSING")
        capture("welcome_handoff")
        tapButton("Open my path")
        XCTAssertTrue(visible("Start first hand"),"HOME_PRIMARY_FIRST_LESSON_MISSING")
        capture("home_start_first_hand")
        tapButton("Start first hand")
        capture("w1_theory_open")
        // Theory does not count as independent practice. Advance to the genuine assessed Find Hero task.
        continueTeachingUntil("UTG, HJ, and CO have acted.",max:8)
        tapSelectableOption("BTN (your seat)")
        capture("w1_theory_answered")
        continueTeachingUntil("Which label could change next hand",max:8)
        capture("first_real_graded_question")
        tapSelectableOption("BTN")
        capture("first_real_graded_feedback")
        XCTAssertTrue(visible("Role separated from player.") || visible("CORRECT READ") || visible("Player and position separated."),
                      "FIRST_GRADED_FEEDBACK_ABSENT")
        print("S11_FIRST_NATIVE_GRADED_SUBMISSION_DONE; PERSISTENCE MUST BE VERIFIED SEPARATELY")
    }
}
