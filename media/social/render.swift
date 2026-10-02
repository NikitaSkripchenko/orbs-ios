// Promotional compositions using the unchanged ThinkingOrbsKit engine.
// Original orb design and mathematics: © 2026 Jakub Antalik, MIT (see LICENSE).
// This macOS export utility does not imply macOS support for the SwiftUI package.
import AppKit
import CoreText
import ImageIO

let width = 1080
let height = 1920
let fps = 30
let duration = 18.0
let states = OrbState.allCases
let variant = CommandLine.arguments.count > 1 ? CommandLine.arguments[1] : "noir"
let output = CommandLine.arguments.count > 2 ? CommandLine.arguments[2] : "media/social"
let previewOnly = CommandLine.arguments.contains("--preview")
precondition(["noir", "editorial", "pulse"].contains(variant))
let space = CGColorSpaceCreateDeviceRGB()
let context = CGContext(data: nil, width: width, height: height, bitsPerComponent: 8,
                        bytesPerRow: width * 4, space: space,
                        bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)!

struct Ink {
    let r: Double, g: Double, b: Double
    init(_ r: Double, _ g: Double, _ b: Double) { self.r = r; self.g = g; self.b = b }
    var color: CGColor { CGColor(red: r, green: g, blue: b, alpha: 1) }
}
let paper = Ink(0.95, 0.94, 0.91)
let charcoal = Ink(0.035, 0.041, 0.048)
let white = Ink(0.94, 0.95, 0.96)
let orange = Ink(0.88, 0.24, 0.10)
let mint = Ink(0.65, 0.94, 0.69)
let gray = Ink(0.51, 0.54, 0.57)

func clamp(_ x: Double) -> Double { min(1, max(0, x)) }
func ease(_ x: Double) -> Double { let v = clamp(x); return 1 - pow(1 - v, 3) }
func rect(_ x: Double, _ y: Double, _ w: Double, _ h: Double, _ ink: Ink, _ alpha: Double = 1) {
    context.setFillColor(CGColor(red: ink.r, green: ink.g, blue: ink.b, alpha: alpha))
    context.fill(CGRect(x: x, y: y, width: w, height: h))
}
func line(_ x: Double, _ y: Double, _ x2: Double, _ y2: Double, _ ink: Ink, _ alpha: Double = 1) {
    context.setStrokeColor(CGColor(red: ink.r, green: ink.g, blue: ink.b, alpha: alpha))
    context.setLineWidth(1)
    context.move(to: CGPoint(x: x, y: y)); context.addLine(to: CGPoint(x: x2, y: y2)); context.strokePath()
}
func text(_ value: String, _ x: Double, _ y: Double, _ size: Double, _ ink: Ink,
          font: String = "HelveticaNeue", tracking: Double = 0, maxWidth: Double = 880) {
    let typeface = CTFontCreateWithName(font as CFString, size, nil)
    let attributes: [NSAttributedString.Key: Any] = [
        .font: typeface, .foregroundColor: ink.color, .kern: tracking
    ]
    let ctLine = CTLineCreateWithAttributedString(NSAttributedString(string: value, attributes: attributes))
    let measured = CTLineGetTypographicBounds(ctLine, nil, nil, nil)
    let scale = min(1, maxWidth / max(1, measured))
    context.saveGState()
    context.translateBy(x: x, y: y + size * 0.82)
    context.scaleBy(x: scale, y: -scale)
    context.textPosition = .zero
    CTLineDraw(ctLine, context)
    context.restoreGState()
}
func orb(_ state: OrbState, _ time: Double, _ cx: Double, _ cy: Double, _ size: Double, dark: Bool) {
    let preset = OrbSpec.resolve(state: state, size: .points64)
    let frame = OrbEngine.frame(resolved: preset, size: .points64, modeTime: time * preset.speed)
    context.saveGState()
    context.translateBy(x: cx - size / 2, y: cy - size / 2)
    context.scaleBy(x: size / 64, y: size / 64)
    for mark in frame.lines {
        context.setStrokeColor(CGColor(gray: OrbInk.gray(white: mark.white, dark: dark), alpha: mark.alpha))
        context.setLineWidth(mark.width)
        context.move(to: CGPoint(x: mark.x1, y: mark.y1))
        context.addLine(to: CGPoint(x: mark.x2, y: mark.y2)); context.strokePath()
    }
    for dot in frame.dots {
        context.setFillColor(CGColor(gray: OrbInk.gray(white: dot.white, dark: dark), alpha: dot.alpha))
        context.fillEllipse(in: CGRect(x: dot.x - dot.radius, y: dot.y - dot.radius,
                                      width: dot.radius * 2, height: dot.radius * 2))
    }
    context.restoreGState()
}
func gallery(_ t: Double, top: Double, dark: Bool, spacing: Double = 280) {
    for (i, state) in states.enumerated() {
        let x = 235.0 + Double(i % 3) * 290
        let y = top + Double(i / 3) * spacing
        orb(state, t, x, y, 190, dark: dark)
    }
}
func scene(_ t: Double) {
    let cuts: [Double] = variant == "pulse" ? [0, 1.5, 3, 4.5, 6, 7.5, 9, 12, 15, 18] : [0, 4.5, 9, 13.5, 18]
    let index = (0..<(cuts.count - 1)).first { t < cuts[$0 + 1] } ?? cuts.count - 2
    let local = t - cuts[index]
    let length = cuts[index + 1] - cuts[index]
    let ending = index == cuts.count - 2
    let light = variant == "editorial" || (variant == "pulse" && [1, 3, 5].contains(index))
    let ink = light ? charcoal : white
    rect(0, 0, Double(width), Double(height), light ? paper : charcoal)
    // The pulse cut uses a hard exposure change on the beat; the other edits breathe.
    let incoming = index == 0 || variant == "pulse" ? 1 : ease(local / 0.30)
    let outgoing = ending || variant == "pulse" ? 1 : clamp((length - local) / 0.15)
    context.saveGState()
    context.setAlpha(incoming * outgoing)
    context.translateBy(x: 0, y: 18 * (1 - incoming))
    if !ending {
        text("ThinkingOrbsKit", 94, 205, 35, ink, font: "HelveticaNeue-Medium")
        rect(925, 212, 13, 13, variant == "editorial" ? orange : variant == "pulse" ? mint : white)
    }
    if ending {
        orb(variant == "editorial" ? .shaping : .breathing, t, 535, 890,
            860 + 30 * ease(local / length), dark: !light)
        text("ThinkingOrbsKit", 94, 1370, 77, ink, font: "HelveticaNeue-Medium")
        text("github.com/NikitaSkripchenko/orbs-ios", 94, 1480, 28,
             light ? charcoal : gray, font: "Menlo-Regular")
        text("Original orbs · Jakub Antalik · MIT", 94, 1655, 22,
             light ? charcoal : gray)
    } else if (variant != "pulse" && index == 2) || (variant == "pulse" && index == 6) {
        gallery(t, top: 555, dark: !light, spacing: 335)
        text("9 состояний", 94, 1490, 52, ink, font: "HelveticaNeue-Medium")
    } else if variant == "pulse" && index == 7 {
        orb(.composing, t, 535, 650, 690, dark: true)
        orb(.weaving, t, 535, 1230, 630, dark: true)
    } else {
        let selected: OrbState
        if variant == "noir" { selected = index == 0 ? .searching : .composing }
        else if variant == "editorial" { selected = index == 0 ? .weaving : .shaping }
        else { selected = [.working, .searching, .solving, .listening, .connecting, .weaving][index] }
        let zoom = variant == "pulse" ? 1060 - 75 * ease(local / length) : 990 + 65 * ease(local / length)
        orb(selected, t, 535, 945, zoom, dark: !light)
    }
    context.restoreGState()
}

func render(_ t: Double) {
    context.saveGState()
    context.translateBy(x: 0, y: Double(height))
    context.scaleBy(x: 1, y: -1)
    scene(t)
    context.restoreGState()
}
func png(_ path: String) throws {
    guard let image = context.makeImage(),
          let destination = CGImageDestinationCreateWithURL(URL(fileURLWithPath: path) as CFURL,
                                                           "public.png" as CFString, 1, nil) else {
        throw NSError(domain: "SocialExport", code: 1)
    }
    CGImageDestinationAddImage(destination, image, nil)
    guard CGImageDestinationFinalize(destination) else { throw NSError(domain: "SocialExport", code: 2) }
}

// Original, deterministic sound design: chords, plucks, soft kick and filtered ticks.
// No samples, external music, speech, or third-party audio are used.
func soundtrack(_ path: String) throws {
    let sampleRate = 48000
    let samples = Int(duration * Double(sampleRate))
    var pcm = Data(capacity: samples * 4)
    let bpm = variant == "pulse" ? 120.0 : variant == "editorial" ? 100.0 : 80.0
    let beat = 60 / bpm
    let roots = [130.8128, 103.8262, 155.5635, 116.5409]
    var seed: UInt64 = 12345
    for i in 0..<samples {
        let t = Double(i) / Double(sampleRate)
        let section = min(3, Int(t / 4.5))
        let root = roots[section]
        let cross = clamp(t.truncatingRemainder(dividingBy: 4.5) / 0.3)
        let oldRoot = roots[max(0, section - 1)]
        var pad = 0.0
        for ratio in [1.0, pow(2, 3.0/12), pow(2, 7.0/12), 2.0] {
            pad += (sin(2 * .pi * root * ratio * t) * cross + sin(2 * .pi * oldRoot * ratio * t) * (1 - cross)) * 0.031
        }
        let p = t.truncatingRemainder(dividingBy: beat / 2)
        let note = [0.0, 7.0, 12.0, 15.0, 7.0, 10.0, 12.0, 19.0][Int(t / (beat / 2)) % 8]
        let hz = root * 2 * pow(2, note / 12)
        let pluck = (sin(2 * .pi * hz * p) + 0.24 * sin(2 * .pi * hz * 2 * p)) * exp(-p * 12) * min(1, p * 600) * 0.10
        let k = t.truncatingRemainder(dividingBy: beat)
        let kick = sin(2 * .pi * (46 * k + 3.2 * (1 - exp(-k * 25)))) * exp(-k * 17) * 0.21
        seed = seed &* 6364136223846793005 &+ 1
        let noise = Double(seed >> 32) / Double(UInt32.max) * 2 - 1
        let hat = noise * exp(-p * 130) * 0.033
        let fade = min(clamp(t / 0.2), clamp((duration - t) / 0.7))
        for channel in 0..<2 {
            let spread = sin(t * 0.7 + Double(channel) * .pi) * 0.12
            let value = (pad * (1 + spread) + pluck * (1 - spread) + kick + hat) * fade
            var sample = Int16(max(-32767, min(32767, value * 32767))).littleEndian
            withUnsafeBytes(of: &sample) { pcm.append(contentsOf: $0) }
        }
    }
    var wav = Data()
    func word<T: FixedWidthInteger>(_ n: T) { var v = n.littleEndian; withUnsafeBytes(of: &v) { wav.append(contentsOf: $0) } }
    wav.append(contentsOf: "RIFF".utf8); word(UInt32(pcm.count + 36)); wav.append(contentsOf: "WAVEfmt ".utf8)
    word(UInt32(16)); word(UInt16(1)); word(UInt16(2)); word(UInt32(sampleRate)); word(UInt32(sampleRate * 4))
    word(UInt16(4)); word(UInt16(16)); wav.append(contentsOf: "data".utf8); word(UInt32(pcm.count)); wav.append(pcm)
    try wav.write(to: URL(fileURLWithPath: path))
}

try FileManager.default.createDirectory(atPath: output, withIntermediateDirectories: true)
if previewOnly {
    for (i, t) in [1.5, 5.0, 9.5, 12.0, 16.0].enumerated() {
        render(t); try png("\(output)/\(variant)-preview-\(i).png")
    }
} else {
    let audio = "\(output)/\(variant)-sound.wav"
    try soundtrack(audio)
    let encoder = Process()
    encoder.executableURL = URL(fileURLWithPath: "/opt/homebrew/bin/ffmpeg")
    encoder.arguments = ["-hide_banner", "-loglevel", "error", "-y", "-f", "rawvideo", "-pixel_format", "rgba",
                         "-video_size", "1080x1920", "-framerate", String(fps), "-i", "pipe:0", "-i", audio,
                         "-c:v", "libx264", "-preset", "fast", "-crf", "18", "-pix_fmt", "yuv420p",
                         "-color_primaries", "bt709", "-color_trc", "bt709", "-colorspace", "bt709",
                         "-c:a", "aac", "-b:a", "192k", "-af", "loudnorm=I=-16:TP=-1.5:LRA=9",
                         "-movflags", "+faststart", "-shortest", "\(output)/thinking-orbs-\(variant).mp4"]
    let pipe = Pipe(); encoder.standardInput = pipe
    try encoder.run()
    for i in 0..<Int(duration * Double(fps)) {
        try autoreleasepool {
            render(Double(i) / Double(fps))
            try pipe.fileHandleForWriting.write(contentsOf: Data(bytes: context.data!, count: width * height * 4))
        }
        if i % 150 == 0 { fputs("\(variant): \(i)/540 frames\n", stderr) }
    }
    try pipe.fileHandleForWriting.close(); encoder.waitUntilExit()
    guard encoder.terminationStatus == 0 else { throw NSError(domain: "FFmpeg", code: Int(encoder.terminationStatus)) }
    render(1.5); try png("\(output)/\(variant)-cover.png")
    print("Exported \(output)/thinking-orbs-\(variant).mp4")
}
