import SwiftUI
import ThinkingOrbsKit

struct ContentView: View {
    private enum Tab: Hashable {
        case allAnimations
        case playground
    }

    @State private var selectedTab: Tab = .allAnimations
    @State private var state: OrbState = .working
    @State private var size: OrbSize = .points64
    @State private var theme: OrbTheme = .automatic
    @State private var speed = 1.0
    @State private var paused = false
    @State private var forcedReduceMotion = false

    var body: some View {
        TabView(selection: $selectedTab) {
            GalleryView(theme: theme, forcedReduceMotion: forcedReduceMotion)
                .tabItem {
                    Label("All Animations", systemImage: "square.grid.2x2")
                }
                .tag(Tab.allAnimations)

            PlaygroundView(
                state: $state,
                size: $size,
                theme: $theme,
                speed: $speed,
                paused: $paused,
                forcedReduceMotion: $forcedReduceMotion
            )
            .tabItem {
                Label("Playground", systemImage: "slider.horizontal.3")
            }
            .tag(Tab.playground)
        }
    }
}

private struct PlaygroundView: View {
    @Binding var state: OrbState
    @Binding var size: OrbSize
    @Binding var theme: OrbTheme
    @Binding var speed: Double
    @Binding var paused: Bool
    @Binding var forcedReduceMotion: Bool

    @State private var showsSettings = false

    var body: some View {
        NavigationView {
            ZStack {
                VStack(spacing: 16) {
                    ThinkingOrb(
                        state: state,
                        size: size,
                        theme: theme,
                        speed: speed,
                        paused: paused,
                        reduceMotionOverride: forcedReduceMotion
                    )
                    .accessibilityIdentifier("playgroundOrb")

                    Text(state.accessibilityLabel)
                        .font(.headline)

                    Text("\(Int(size.rawValue)) pt · \(theme.rawValue.capitalized)")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                VStack {
                    Spacer()

                    Button {
                        showsSettings = true
                    } label: {
                        Label("Settings", systemImage: "slider.horizontal.3")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
                    .frame(maxWidth: 520)
                }
            }
            .padding()
            .navigationTitle("Playground")
        }
        .sheet(isPresented: $showsSettings) {
            settingsSheet
        }
    }

    @ViewBuilder
    private var settingsSheet: some View {
        if #available(iOS 16.0, *) {
            controls
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
        } else {
            controls
        }
    }

    private var controls: some View {
        ControlsView(
            state: $state,
            size: $size,
            theme: $theme,
            speed: $speed,
            paused: $paused,
            forcedReduceMotion: $forcedReduceMotion
        )
    }
}
