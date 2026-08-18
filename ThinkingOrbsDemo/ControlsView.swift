import SwiftUI
import ThinkingOrbsKit

struct ControlsView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var state: OrbState
    @Binding var size: OrbSize
    @Binding var theme: OrbTheme
    @Binding var speed: Double
    @Binding var paused: Bool
    @Binding var forcedReduceMotion: Bool

    var body: some View {
        NavigationView {
            ZStack {
                Color(uiColor: .systemGroupedBackground)
                    .ignoresSafeArea()

                ControlsForm(
                    state: $state,
                    size: $size,
                    theme: $theme,
                    speed: $speed,
                    paused: $paused,
                    forcedReduceMotion: $forcedReduceMotion
                )
                .frame(maxWidth: 640)
            }
            .navigationTitle("Animation & Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
        .navigationViewStyle(.stack)
    }
}

struct ControlsForm: View {
    @Binding var state: OrbState
    @Binding var size: OrbSize
    @Binding var theme: OrbTheme
    @Binding var speed: Double
    @Binding var paused: Bool
    @Binding var forcedReduceMotion: Bool

    var body: some View {
        Form {
            Section("Animation") {
                Picker("State", selection: $state) {
                    ForEach(OrbState.allCases, id: \.self) { value in
                        Text(value.accessibilityLabel).tag(value)
                    }
                }
                .accessibilityIdentifier("statePicker")
            }

            Section {
                Picker("Size", selection: $size) {
                    Text("20 pt").tag(OrbSize.points20)
                    Text("64 pt").tag(OrbSize.points64)
                }
                .pickerStyle(.segmented)
                .accessibilityIdentifier("sizePicker")

                Picker("Theme", selection: $theme) {
                    Text("Auto").tag(OrbTheme.automatic)
                    Text("Light").tag(OrbTheme.light)
                    Text("Dark").tag(OrbTheme.dark)
                }
                .pickerStyle(.segmented)
                .accessibilityIdentifier("themePicker")
            }

            Section("Motion") {
                VStack(alignment: .leading) {
                    Text("Speed")
                    Slider(value: $speed, in: 0.25...2, step: 0.05)
                        .accessibilityValue(String(format: "%.2f", speed))
                        .accessibilityIdentifier("speedSlider")
                }

                Button("Reset Speed") {
                    speed = 1
                }

                Toggle("Paused", isOn: $paused)
                Toggle("Reduce Motion Preview", isOn: $forcedReduceMotion)
            }
        }
    }
}
