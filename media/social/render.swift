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
struct Mark {
    let x: Double, y: Double, radius: Double, ink: Double, alpha: Double
}
struct Stroke {
    let x1: Double, y1: Double, x2: Double, y2: Double, width: Double, ink: Double, alpha: Double
}
struct Composition {
    var dots: [Mark] = []
    var lines: [Stroke] = []
    let light: Bool
    let gallery: Bool
    let ending: Bool
}
func mix(_ a: Double, _ b: Double, _ p: Double) -> Double { a + (b - a) * p }
func smooth(_ x: Double) -> Double { let p = clamp(x); return p * p * (3 - 2 * p) }
func path(_ a: Mark, _ b: Mark, _ p: Double) -> (Double, Double) {
    let dx = b.x - a.x, dy = b.y - a.y
    let distance = hypot(dx, dy)
    let arc = sin(.pi * p) * min(95, distance * 0.18)
    return (mix(a.x, b.x, p) - dy / max(1, distance) * arc,
            mix(a.y, b.y, p) + dx / max(1, distance) * arc)
}
func addOrb(_ state: OrbState, _ time: Double, _ cx: Double, _ cy: Double, _ size: Double,
            to composition: inout Composition) {
    let preset = OrbSpec.resolve(state: state, size: .points64)
    let speed = variant == "pulse" ? 1.30 : 1.15
    let frame = OrbEngine.frame(resolved: preset, size: .points64, modeTime: time * preset.speed * speed)
    let scale = size / 64
    let x = cx - size / 2, y = cy - size / 2
    for dot in frame.dots {
        composition.dots.append(Mark(x: x + dot.x * scale, y: y + dot.y * scale,
            radius: dot.radius * scale, ink: OrbInk.gray(white: dot.white, dark: !composition.light), alpha: dot.alpha))
    }
    for mark in frame.lines {
        composition.lines.append(Stroke(x1: x + mark.x1 * scale, y1: y + mark.y1 * scale,
            x2: x + mark.x2 * scale, y2: y + mark.y2 * scale, width: mark.width * scale,
            ink: OrbInk.gray(white: mark.white, dark: !composition.light), alpha: mark.alpha))
    }
}
let cuts: [Double] = variant == "pulse" ? [0, 1.5, 3, 4.5, 6, 7.5, 9, 12, 15, 18] : [0, 3, 6, 9, 13.5, 18]
func composition(_ index: Int, _ t: Double) -> Composition {
    let ending = index == cuts.count - 2
    let isGallery = variant == "pulse" ? index == 6 : index == 3
    let light = variant == "editorial" || (variant == "pulse" && [1, 3, 5].contains(index))
    var result = Composition(light: light, gallery: isGallery, ending: ending)
    let phase = clamp((t - cuts[index]) / (cuts[index + 1] - cuts[index]))
    if ending {
        addOrb(variant == "editorial" ? .shaping : .breathing, t, 535, 890,
               890 + 35 * ease(phase), to: &result)
    } else if isGallery {
        for (i, state) in states.enumerated() {
            addOrb(state, t, 235 + Double(i % 3) * 290, 555 + Double(i / 3) * 335,
                   205, to: &result)
        }
    } else if variant == "pulse" && index == 7 {
        addOrb(.composing, t, 535, 650, 690, to: &result)
        addOrb(.weaving, t, 535, 1230, 630, to: &result)
    } else {
        let sequence: [OrbState] = variant == "noir" ? [.searching, .solving, .composing] :
            variant == "editorial" ? [.weaving, .shaping, .composing] :
            [.working, .searching, .solving, .listening, .connecting, .weaving]
        let zoom = 1010 + 85 * sin(phase * .pi)
        addOrb(sequence[index], t, 535 + 14 * sin(phase * .pi * 2), 945, zoom, to: &result)
    }
    return result
}
func drawDot(_ x: Double, _ y: Double, _ radius: Double, _ ink: Double, _ alpha: Double) {
    context.setFillColor(CGColor(gray: ink, alpha: alpha))
    context.fillEllipse(in: CGRect(x: x - radius, y: y - radius, width: radius * 2, height: radius * 2))
}
func drawLines(_ lines: [Stroke], opacity: Double) {
    for mark in lines {
        context.setStrokeColor(CGColor(gray: mark.ink, alpha: mark.alpha * opacity))
        context.setLineWidth(mark.width)
        context.move(to: CGPoint(x: mark.x1, y: mark.y1))
        context.addLine(to: CGPoint(x: mark.x2, y: mark.y2)); context.strokePath()
    }
}
func ordered(_ dots: [Mark]) -> [Mark] {
    // Polar ordering produces coherent ribbons rather than random particle crossings.
    dots.sorted {
        let a = atan2($0.y - 945, $0.x - 535), b = atan2($1.y - 945, $1.x - 535)
        return a == b ? hypot($0.x - 535, $0.y - 945) < hypot($1.x - 535, $1.y - 945) : a < b
    }
}
func copies(_ index: Int, count: Int, total: Int) -> Int {
    ((index + 1) * total + count - 1) / count - (index * total + count - 1) / count
}
func renderTransition(_ from: Composition, _ to: Composition, _ p: Double) {
    drawLines(from.lines, opacity: 1 - p)
    drawLines(to.lines, opacity: p)
    let a = ordered(from.dots), b = ordered(to.dots)
    let count = max(a.count, b.count)
    guard !a.isEmpty && !b.isEmpty else { return }
    for i in 0..<count {
        let ai = i * a.count / count, bi = i * b.count / count
        let source = a[ai], target = b[bi]
        let (x, y) = path(source, target, p)
        // Split opacity when a source dot maps to several target particles.
        let aa = 1 - pow(1 - source.alpha, 1 / Double(copies(ai, count: a.count, total: count)))
        let ba = 1 - pow(1 - target.alpha, 1 / Double(copies(bi, count: b.count, total: count)))
        drawDot(x, y, mix(source.radius, target.radius, p), mix(source.ink, target.ink, p), mix(aa, ba, p))
    }
}
func scene(_ t: Double) {
    let index = (0..<(cuts.count - 1)).first { t < cuts[$0 + 1] } ?? cuts.count - 2
    let local = t - cuts[index]
    let span = variant == "pulse" ? 0.48 : 0.72
    let p = index == 0 ? 1 : smooth(local / span)
    let target = composition(index, t)
    let source = composition(max(0, index - 1), t)
    let startColor = source.light ? paper : charcoal, endColor = target.light ? paper : charcoal
    rect(0, 0, Double(width), Double(height),
         Ink(mix(startColor.r, endColor.r, p), mix(startColor.g, endColor.g, p), mix(startColor.b, endColor.b, p)))
    if p < 1 { renderTransition(source, target, p) }
    else {
        drawLines(target.lines, opacity: 1)
        for dot in target.dots { drawDot(dot.x, dot.y, dot.radius, dot.ink, dot.alpha) }
    }
    let startInk = source.light ? charcoal : white, endInk = target.light ? charcoal : white
    let ink = Ink(mix(startInk.r, endInk.r, p), mix(startInk.g, endInk.g, p), mix(startInk.b, endInk.b, p))
    context.saveGState()
    context.setAlpha(target.ending ? 1 - p : 1)
    text("ThinkingOrbsKit", 94, 205, 35, ink, font: "HelveticaNeue-Medium")
    context.restoreGState()
    let galleryOpacity = target.ending ? (source.gallery ? 1 - smooth(p / 0.45) : 0) : mix(source.gallery ? 1 : 0, target.gallery ? 1 : 0, p)
    if galleryOpacity > 0 {
        context.saveGState(); context.setAlpha(galleryOpacity)
        text("9 states", 94, 1490, 52, ink, font: "HelveticaNeue-Medium")
        context.restoreGState()
    }
    if target.ending {
        context.saveGState(); context.setAlpha(smooth((p - 0.45) / 0.55))
        text("ThinkingOrbsKit", 94, 1370 + 16 * (1 - p), 77, ink, font: "HelveticaNeue-Medium")
        text("github.com/NikitaSkripchenko/orbs-ios", 94, 1480 + 16 * (1 - p), 28,
             target.light ? charcoal : gray, font: "Menlo-Regular")
        context.restoreGState()
    }
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
if CommandLine.arguments.contains("--check") {
    for n in 1...40 {
        for total in n...80 {
            let weights = (0..<n).map { copies($0, count: n, total: total) }
            precondition(weights.reduce(0, +) == total && weights.allSatisfy { $0 > 0 })
            for count in weights {
                let alpha = 1 - pow(1 - 0.7, 1 / Double(count))
                precondition(abs((1 - pow(1 - alpha, Double(count))) - 0.7) < 1e-10)
            }
        }
    }
    let a = Mark(x: 10, y: 20, radius: 3, ink: 0.2, alpha: 0.5)
    let b = Mark(x: 80, y: 90, radius: 5, ink: 0.8, alpha: 0.9)
    precondition(path(a, b, 0) == (a.x, a.y))
    precondition(abs(path(a, b, 1).0 - b.x) < 1e-10 && abs(path(a, b, 1).1 - b.y) < 1e-10)
    for cut in cuts.dropFirst().dropLast() {
        for delta in [-1.0 / 30, 0, 0.24, 0.48, 0.72] { render(cut + delta) }
    }
    print("Passed transition endpoint, opacity, count and boundary rendering checks: \(variant)")
} else if previewOnly {
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
