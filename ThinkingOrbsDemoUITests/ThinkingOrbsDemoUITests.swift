import XCTest
import UIKit

@MainActor
final class ThinkingOrbsDemoUITests: XCTestCase {
    func testIPadUsesNativeAdaptiveLayout() {
        guard UIDevice.current.userInterfaceIdiom == .pad else { return }

        let supportedDeviceFamilies = Bundle.main.object(forInfoDictionaryKey: "UIDeviceFamily") as? [Int] ?? []
        XCTAssertTrue(supportedDeviceFamilies.contains(2))

        let app = XCUIApplication()
        app.launch()

        XCTAssertTrue(tab(named: "All Animations", in: app).waitForExistence(timeout: 2))
        let firstAnimation = app.staticTexts["Working"]
        let lastAnimation = app.staticTexts["Shaping"]
        XCTAssertTrue(firstAnimation.waitForExistence(timeout: 2))
        XCTAssertTrue(lastAnimation.waitForExistence(timeout: 2))
        XCTAssertGreaterThan(lastAnimation.frame.midY, firstAnimation.frame.midY + 40)

        tab(named: "Playground", in: app).tap()
        let orb = app.descendants(matching: .any)["playgroundOrb"]
        let settingsPanel = app.descendants(matching: .any)["inlineSettingsPanel"]
        XCTAssertTrue(orb.waitForExistence(timeout: 2))
        XCTAssertTrue(settingsPanel.waitForExistence(timeout: 2))
        XCTAssertFalse(app.buttons["Settings"].exists)
        XCTAssertGreaterThan(settingsPanel.frame.minX, orb.frame.midX)
    }

    func testAllAnimationsIsTheDefaultTabAndShowsEveryState() {
        let app = XCUIApplication()
        app.launch()

        let allAnimationsTab = tab(named: "All Animations", in: app)
        XCTAssertTrue(allAnimationsTab.waitForExistence(timeout: 2))
        XCTAssertTrue(allAnimationsTab.isSelected)
        XCTAssertTrue(app.staticTexts["Working"].waitForExistence(timeout: 2))
        for _ in 0..<5 where !app.staticTexts["Shaping"].exists {
            app.swipeUp()
        }
        XCTAssertTrue(app.staticTexts["Shaping"].exists)
    }

    func testPlaygroundCentersPreviewAndAdaptiveSettingsExposeEveryPublicOption() {
        let app = XCUIApplication()
        app.launch()

        let playgroundTab = tab(named: "Playground", in: app)
        XCTAssertTrue(playgroundTab.waitForExistence(timeout: 2))
        playgroundTab.tap()
        XCTAssertTrue(app.descendants(matching: .any)["playgroundOrb"].waitForExistence(timeout: 2))

        if UIDevice.current.userInterfaceIdiom == .pad {
            XCTAssertTrue(app.descendants(matching: .any)["inlineSettingsPanel"].waitForExistence(timeout: 2))
        } else {
            XCTAssertTrue(app.buttons["Settings"].waitForExistence(timeout: 2))
            app.buttons["Settings"].tap()
        }

        for identifier in ["statePicker", "sizePicker", "themePicker", "speedSlider"] {
            XCTAssertTrue(app.descendants(matching: .any)[identifier].waitForExistence(timeout: 2))
        }
        app.swipeUp()
        XCTAssertTrue(app.switches["Paused"].exists)
        XCTAssertTrue(app.switches["Reduce Motion Preview"].exists)
    }

    private func tab(named name: String, in app: XCUIApplication) -> XCUIElement {
        app.descendants(matching: .any)
            .matching(NSPredicate(format: "label == %@ AND isEnabled == true", name))
            .firstMatch
    }
}
