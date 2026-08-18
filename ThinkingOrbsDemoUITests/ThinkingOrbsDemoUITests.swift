import XCTest

@MainActor
final class ThinkingOrbsDemoUITests: XCTestCase {
    func testAllAnimationsIsTheDefaultTabAndShowsEveryState() {
        let app = XCUIApplication()
        app.launch()

        XCTAssertTrue(app.tabBars.buttons["All Animations"].waitForExistence(timeout: 2))
        XCTAssertTrue(app.tabBars.buttons["All Animations"].isSelected)
        XCTAssertTrue(app.staticTexts["Working"].waitForExistence(timeout: 2))
        for _ in 0..<5 where !app.staticTexts["Shaping"].exists {
            app.swipeUp()
        }
        XCTAssertTrue(app.staticTexts["Shaping"].exists)
    }

    func testPlaygroundCentersPreviewAndSettingsSheetExposesEveryPublicOption() {
        let app = XCUIApplication()
        app.launch()

        XCTAssertTrue(app.tabBars.buttons["Playground"].waitForExistence(timeout: 2))
        app.tabBars.buttons["Playground"].tap()
        XCTAssertTrue(app.descendants(matching: .any)["playgroundOrb"].waitForExistence(timeout: 2))
        XCTAssertTrue(app.buttons["Settings"].waitForExistence(timeout: 2))
        app.buttons["Settings"].tap()

        for identifier in ["statePicker", "sizePicker", "themePicker", "speedSlider"] {
            XCTAssertTrue(app.descendants(matching: .any)[identifier].waitForExistence(timeout: 2))
        }
        app.swipeUp()
        XCTAssertTrue(app.switches["Paused"].exists)
        XCTAssertTrue(app.switches["Reduce Motion Preview"].exists)
    }
}
