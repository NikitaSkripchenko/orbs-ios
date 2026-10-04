import SwiftUI
import ThinkingOrbsKit
import UIKit

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
    @State private var allowsHighRefreshRate = false

    var body: some View {
        TabView(selection: $selectedTab) {
            GalleryView(theme: theme, forcedReduceMotion: forcedReduceMotion, allowsHighRefreshRate: allowsHighRefreshRate)
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
                forcedReduceMotion: $forcedReduceMotion,
                allowsHighRefreshRate: $allowsHighRefreshRate
            )
            .tabItem {
                Label("Playground", systemImage: "slider.horizontal.3")
            }
            .tag(Tab.playground)
        }
    }
}

private struct PlaygroundView: View {
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    @Binding var state: OrbState
    @Binding var size: OrbSize
    @Binding var theme: OrbTheme
    @Binding var speed: Double
    @Binding var paused: Bool
    @Binding var forcedReduceMotion: Bool
    @Binding var allowsHighRefreshRate: Bool

    @State private var showsSettings = false

    var body: some View {
        NavigationView {
            Group {
                if usesInlineSettings {
                    GeometryReader { proxy in
                        HStack(spacing: 0) {
                            preview
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .padding(32)

                            Divider()

                            inlineSettings
                                .frame(width: settingsWidth(for: proxy.size.width))
                        }
                    }
                } else {
                    ZStack {
                        preview

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
                }
            }
            .navigationTitle("Playground")
        }
        .navigationViewStyle(.stack)
        .sheet(isPresented: $showsSettings) {
            settingsSheet
        }
        .onChange(of: horizontalSizeClass) { _ in
            if usesInlineSettings {
                showsSettings = false
            }
        }
    }

    private var usesInlineSettings: Bool {
        UIDevice.current.userInterfaceIdiom == .pad && horizontalSizeClass == .regular
    }

    private var preview: some View {
        VStack(spacing: 16) {
            ThinkingOrb(
                state: state,
                size: size,
                theme: theme,
                speed: speed,
                paused: paused,
                reduceMotionOverride: forcedReduceMotion ? true : nil,
                allowsHighRefreshRate: allowsHighRefreshRate
            )
            .accessibilityIdentifier("playgroundOrb")

            Text(state.accessibilityLabel)
                .font(.headline)

            Text("\(Int(size.rawValue)) pt · \(theme.rawValue.capitalized)")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var inlineSettings: some View {
        VStack(spacing: 0) {
            HStack(spacing: 10) {
                Image(systemName: "slider.horizontal.3")
                    .foregroundStyle(.tint)
                Text("Settings")
                    .font(.title2.bold())
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)

            Divider()

            ControlsForm(
                state: $state,
                size: $size,
                theme: $theme,
                speed: $speed,
                paused: $paused,
                forcedReduceMotion: $forcedReduceMotion,
                allowsHighRefreshRate: $allowsHighRefreshRate
            )
        }
        .background(Color(uiColor: .systemGroupedBackground))
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("inlineSettingsPanel")
    }

    private func settingsWidth(for availableWidth: CGFloat) -> CGFloat {
        min(max(availableWidth * 0.38, 320), 420)
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
            forcedReduceMotion: $forcedReduceMotion,
            allowsHighRefreshRate: $allowsHighRefreshRate
        )
    }
}
