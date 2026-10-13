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
        tapSelectableOption("B\nCheck")
        XCTAssertTrue(visible("Your path is ready."),"WELCOME_UNGRADED_HANDOFF_MISSING")
        capture("welcome_handoff")
        tapButton("Open my path")
        XCTAssertTrue(visible("Start first hand"),"HOME_PRIMARY_FIRST_LESSON_MISSING")
        capture("home_start_first_hand")
        tapButton("Start first hand")
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
                let navigation = ["Next", "Continue"].compactMap { title -> XCUIElement? in
                    let c = app.buttons.matching(identifier: title).firstMatch
                    return (c.exists && c.isEnabled && c.isHittable) ? c : nil
                }
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
        capture("first_real_graded_feedback")
        XCTAssertTrue(visible("Role separated from player.") || visible("CORRECT READ") || visible("Player and position separated."),
                      "FIRST_GRADED_FEEDBACK_ABSENT")
        print("S11_FIRST_NATIVE_GRADED_SUBMISSION_DONE; PERSISTENCE MUST BE VERIFIED SEPARATELY")
    }
}
