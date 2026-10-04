import SwiftUI
import ThinkingOrbsKit

struct GalleryView: View {
    let theme: OrbTheme
    let forcedReduceMotion: Bool
    let allowsHighRefreshRate: Bool

    private let columns = [
        GridItem(.adaptive(minimum: 144, maximum: 200), spacing: 24)
    ]

    var body: some View {
        NavigationView {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 28) {
                    ForEach(OrbState.allCases, id: \.self) { state in
                        VStack(spacing: 10) {
                            ThinkingOrb(
                                state: state,
                                size: .points64,
                                theme: theme,
                                reduceMotionOverride: forcedReduceMotion ? true : nil,
                                allowsHighRefreshRate: allowsHighRefreshRate
                            )
                            Text(state.accessibilityLabel.replacingOccurrences(of: "…", with: ""))
                                .font(.subheadline)
                        }
                    }
                }
                .padding()
                .frame(maxWidth: 992)
                .frame(maxWidth: .infinity)
            }
            .navigationTitle("All Animations")
        }
        .navigationViewStyle(.stack)
    }
}
