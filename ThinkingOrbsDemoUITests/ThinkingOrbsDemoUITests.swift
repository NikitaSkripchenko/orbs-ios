import XCTest

@MainActor
final class ThinkingOrbsDemoUITests: XCTestCase {
    func testControlsSheetExposesEveryPublicOption() {
        let app = XCUIApplication()
        app.launch()
        XCTAssertTrue(app.buttons["Controls"].waitForExistence(timeout: 2))
        app.buttons["Controls"].tap()
        for identifier in ["statePicker", "sizePicker", "themePicker", "speedSlider"] {
            XCTAssertTrue(app.descendants(matching: .any)[identifier].waitForExistence(timeout: 2))
        }
        app.swipeUp()
        XCTAssertTrue(app.switches["Paused"].exists)
        XCTAssertTrue(app.switches["Reduce Motion Preview"].exists)
    }

    func testGalleryShowsFirstAndLastStates() {
        let app = XCUIApplication()
        app.launch()
        XCTAssertTrue(app.buttons["All Animations"].waitForExistence(timeout: 2))
        app.buttons["All Animations"].tap()
        XCTAssertTrue(app.staticTexts["Working"].waitForExistence(timeout: 2))
        for _ in 0..<5 where !app.staticTexts["Shaping"].exists {
            app.swipeUp()
        }
        XCTAssertTrue(app.staticTexts["Shaping"].exists)
    }
}
