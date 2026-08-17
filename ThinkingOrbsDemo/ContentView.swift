import SwiftUI
import ThinkingOrbsKit

struct ContentView: View {
    @State private var state: OrbState = .working
    @State private var size: OrbSize = .points64
    @State private var theme: OrbTheme = .automatic
    @State private var speed = 1.0
    @State private var paused = false
    @State private var forcedReduceMotion = false
    @State private var showsControls = false
    @State private var showsGallery = false

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    ThinkingOrb(
                        state: state,
                        size: size,
                        theme: theme,
                        speed: speed,
                        paused: paused,
                        reduceMotionOverride: forcedReduceMotion
                    )

                    Text(state.accessibilityLabel)
                        .font(.headline)

                    HStack(spacing: 12) {
                        Text("Inline")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        ThinkingOrb(
                            state: state,
                            size: .points20,
                            theme: theme,
                            speed: speed,
                            paused: paused,
                            reduceMotionOverride: forcedReduceMotion
                        )
                    }

                    Button("Controls") {
                        showsControls = true
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)

                    Button("All Animations") {
                        showsGallery = true
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.large)
                }
                .frame(maxWidth: 520)
                .padding()
                .frame(maxWidth: .infinity)
            }
            .navigationTitle("ThinkingOrbs")
        }
        .sheet(isPresented: $showsControls) {
            ControlsView(
                state: $state,
                size: $size,
                theme: $theme,
                speed: $speed,
                paused: $paused,
                forcedReduceMotion: $forcedReduceMotion
            )
        }
        .sheet(isPresented: $showsGallery) {
            GalleryView(theme: theme, forcedReduceMotion: forcedReduceMotion)
        }
    }
}
