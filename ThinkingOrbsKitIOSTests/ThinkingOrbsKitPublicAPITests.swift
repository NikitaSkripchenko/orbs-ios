import SwiftUI
import UIKit
import XCTest
import ThinkingOrbsKit

@MainActor
final class ThinkingOrbsKitPublicAPITests: XCTestCase {
    func testDefaultViewBuildsFromPublicAPI() {
        let view = ThinkingOrb()

        let host = UIHostingController(rootView: view)
        host.loadViewIfNeeded()
        host.view.layoutIfNeeded()
    }

    func testEveryPublicOptionBuildsFromConsumerModule() {
        for state in OrbState.allCases {
            for size in OrbSize.allCases {
                for theme in OrbTheme.allCases {
                    let view = ThinkingOrb(
                        state: state,
                        size: size,
                        theme: theme,
                        speed: 1.25,
                        paused: true,
                        reduceMotionOverride: true,
                        accessibilityLabel: "Custom status",
                        allowsHighRefreshRate: true
                    )

                    let host = UIHostingController(rootView: view)
                    host.loadViewIfNeeded()
                    host.view.layoutIfNeeded()
                }
            }
        }
    }

    func testPublicEnumRawValuesRemainStable() {
        XCTAssertEqual(OrbState.working.rawValue, "working")
        XCTAssertEqual(OrbSize.points20.rawValue, 20)
        XCTAssertEqual(OrbTheme.automatic.rawValue, "automatic")
    }

}
