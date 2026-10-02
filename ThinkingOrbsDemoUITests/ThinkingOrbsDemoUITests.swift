import XCTest
import UIKit

@MainActor
final class ThinkingOrbsDemoUITests: XCTestCase {
    func testDemoFollowsSystemReduceMotion() {
        let reduced = UIAccessibility.isReduceMotionEnabled
        if let expected = ProcessInfo.processInfo.environment["EXPECTED_REDUCE_MOTION"] {
            XCTAssertEqual(reduced, expected == "1", "Verify the simulator setting before testing the app")
        }
        let app = XCUIApplication()
        app.launch()
        let galleryOrb = app.images["Working…"]
        XCTAssertTrue(galleryOrb.waitForExistence(timeout: 2))
        assertMotion(of: galleryOrb, reduced: reduced)

        tab(named: "Playground", in: app).tap()
        let playgroundOrb = app.descendants(matching: .any)["playgroundOrb"]
        XCTAssertTrue(playgroundOrb.waitForExistence(timeout: 2))
        assertMotion(of: playgroundOrb, reduced: reduced)
    }

    private func assertMotion(of orb: XCUIElement, reduced: Bool) {
        let first = orb.screenshot()
        Thread.sleep(forTimeInterval: 0.2)
        let difference = pixelDifference(first, orb.screenshot())
        if reduced {
            XCTAssertLessThanOrEqual(difference, 2, "System Reduce Motion must freeze the demo")
        } else {
            XCTAssertGreaterThan(difference, 2, "The default demo must animate when motion is allowed")
        }
    }

    func testPausedOrbKeepsItsFrameAcrossSpeedChanges() {
        let app = XCUIApplication()
        app.launch()
        tab(named: "Playground", in: app).tap()
        let orb = app.descendants(matching: .any)["playgroundOrb"]
        XCTAssertTrue(orb.waitForExistence(timeout: 2))

        let running = orb.screenshot()
        Thread.sleep(forTimeInterval: 0.2)
        XCTAssertGreaterThan(pixelDifference(orb.screenshot(), running), 2)

        showMotionControls(in: app)
        app.switches["Paused"].coordinate(withNormalizedOffset: CGVector(dx: 0.9, dy: 0.5)).tap()
        XCTAssertEqual(app.switches["Paused"].value as? String, "1")
        dismissSettingsIfNeeded(in: app)
        Thread.sleep(forTimeInterval: 0.2)
        let frozenShot = orb.screenshot()
        let frozenAttachment = XCTAttachment(screenshot: frozenShot)
        frozenAttachment.name = "Frozen before speed change"
        frozenAttachment.lifetime = .keepAlways
        add(frozenAttachment)

        showMotionControls(in: app)
        XCTAssertEqual(app.switches["Paused"].value as? String, "1")
        app.sliders["speedSlider"].adjust(toNormalizedSliderPosition: 0.75)
        dismissSettingsIfNeeded(in: app)
        Thread.sleep(forTimeInterval: 0.2)
        let changedShot = orb.screenshot()
        let changedAttachment = XCTAttachment(screenshot: changedShot)
        changedAttachment.name = "Frozen after speed change"
        changedAttachment.lifetime = .keepAlways
        add(changedAttachment)
        // Repeated Canvas rasterization can differ by one 8-bit color step.
        // Geometry parity still uses the unchanged 1e-4 golden tolerance.
        XCTAssertLessThanOrEqual(pixelDifference(changedShot, frozenShot), 2,
                                 "A speed change must not move a paused orb")

        showMotionControls(in: app)
        app.switches["Paused"].coordinate(withNormalizedOffset: CGVector(dx: 0.9, dy: 0.5)).tap()
        dismissSettingsIfNeeded(in: app)
        Thread.sleep(forTimeInterval: 0.2)
        XCTAssertGreaterThan(pixelDifference(orb.screenshot(), frozenShot), 2)
    }

    private func pixelDifference(_ first: XCUIScreenshot, _ second: XCUIScreenshot) -> Int {
        guard let a = first.image.cgImage, let b = second.image.cgImage,
              a.width == b.width, a.height == b.height else {
            XCTFail("Screenshots must have matching pixel dimensions")
            return 255
        }
        func pixels(_ image: CGImage) -> [UInt8] {
            var bytes = [UInt8](repeating: 0, count: image.width * image.height * 4)
            bytes.withUnsafeMutableBytes { buffer in
                guard let context = CGContext(
                    data: buffer.baseAddress, width: image.width, height: image.height,
                    bitsPerComponent: 8, bytesPerRow: image.width * 4,
                    space: CGColorSpaceCreateDeviceRGB(),
                    bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
                ) else {
                    XCTFail("Could not decode screenshot pixels")
                    return
                }
                context.draw(image, in: CGRect(x: 0, y: 0, width: image.width, height: image.height))
            }
            return bytes
        }
        return zip(pixels(a), pixels(b)).map { abs(Int($0) - Int($1)) }.max() ?? 255
    }

    private func showMotionControls(in app: XCUIApplication) {
        if app.buttons["Settings"].exists { app.buttons["Settings"].tap() }
        for _ in 0..<3 where !app.switches["Paused"].isHittable { app.swipeUp() }
        XCTAssertTrue(app.switches["Paused"].isHittable)
    }

    private func dismissSettingsIfNeeded(in app: XCUIApplication) {
        if app.buttons["Done"].exists { app.buttons["Done"].tap() }
    }

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
