import XCTest

@MainActor
final class ThinkingOrbAccessibilityUITests: XCTestCase {
    func testPlaygroundOrbExposesDefaultImageLabel() {
        let app = XCUIApplication()
        app.launch()

        playgroundTab(in: app).tap()
        let orb = app.descendants(matching: .any)["playgroundOrb"]

        XCTAssertTrue(orb.waitForExistence(timeout: 2))
        XCTAssertEqual(orb.label, "Working…")
        XCTAssertEqual(orb.elementType, .image)
    }

    private func playgroundTab(in app: XCUIApplication) -> XCUIElement {
        app.descendants(matching: .any)
            .matching(NSPredicate(format: "label == %@ AND isEnabled == true", "Playground"))
            .firstMatch
    }
}
