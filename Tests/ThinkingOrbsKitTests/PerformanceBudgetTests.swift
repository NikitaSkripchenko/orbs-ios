import Foundation
import Testing
@testable import ThinkingOrbsKit

struct PerformanceBudgetTests {
    @Test
    func allStateGalleryStaysWithinCPUFrameBudget() {
        let resolvedPresets = OrbState.allCases.map { state in
            OrbSpec.resolve(state: state, size: .points64)
        }
        let iterations = 500
        var checksum = 0

        for state in OrbState.allCases {
            checksum += OrbEngine.frame(state: state, size: .points64, modeTime: 0).dots.count
        }

        let start = ContinuousClock.now
        for iteration in 0..<iterations {
            let modeTime = Double(iteration) / 60
            for resolved in resolvedPresets {
                let frame = OrbEngine.frame(
                    resolved: resolved,
                    size: .points64,
                    modeTime: modeTime
                )
                checksum += frame.dots.count + frame.lines.count
            }
        }
        let average = start.duration(to: .now) / iterations
        let budgetMilliseconds = ProcessInfo.processInfo.environment["THINKING_ORBS_GALLERY_BUDGET_MS"]
            .flatMap(Double.init) ?? 20
        let budget = Duration.milliseconds(budgetMilliseconds)

        #expect(checksum > 0)
        #expect(average < budget, "Average gallery geometry time was \(average); budget is \(budget)")
    }
}
