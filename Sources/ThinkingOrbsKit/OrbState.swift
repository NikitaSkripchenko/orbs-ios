/// The semantic activity represented by a thinking orb.
public enum OrbState: String, CaseIterable, Hashable, Sendable {
    case working
    case searching
    case solving
    case listening
    case connecting
    case weaving
    case composing
    case breathing
    case shaping

    /// The default VoiceOver label for the state.
    public var accessibilityLabel: String {
        switch self {
        case .working: "Working…"
        case .searching: "Searching…"
        case .solving: "Solving…"
        case .listening: "Listening…"
        case .connecting: "Connecting…"
        case .weaving: "Weaving…"
        case .composing: "Composing…"
        case .breathing: "Thinking…"
        case .shaping: "Shaping…"
        }
    }
}
