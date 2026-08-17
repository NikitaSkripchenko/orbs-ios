import SwiftUI
import ThinkingOrbsKit

struct GalleryView: View {
    @Environment(\.dismiss) private var dismiss
    let theme: OrbTheme
    let forcedReduceMotion: Bool

    private let columns = [GridItem(.adaptive(minimum: 120), spacing: 24)]

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
                                reduceMotionOverride: forcedReduceMotion
                            )
                            Text(state.accessibilityLabel.replacingOccurrences(of: "…", with: ""))
                                .font(.subheadline)
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("All Animations")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}
