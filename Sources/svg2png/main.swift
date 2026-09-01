import AppKit

// usage: svg2png <input.svg> <output.png> <pixelSize>
let args = CommandLine.arguments
guard args.count == 4, let size = Int(args[3]), size > 0 else {
    FileHandle.standardError.write(Data("usage: svg2png <input.svg> <output.png> <pixelSize>\n".utf8))
    exit(2)
}

let input = URL(fileURLWithPath: args[1])
let output = URL(fileURLWithPath: args[2])

// AppKit decodes SVG into a vector-backed representation, so this scales cleanly
// to any icon size from the single source file.
guard let image = NSImage(contentsOf: input) else {
    FileHandle.standardError.write(Data("cannot read \(input.path)\n".utf8))
    exit(1)
}

guard let rep = NSBitmapImageRep(
    bitmapDataPlanes: nil,
    pixelsWide: size,
    pixelsHigh: size,
    bitsPerSample: 8,
    samplesPerPixel: 4,
    hasAlpha: true,
    isPlanar: false,
    colorSpaceName: .deviceRGB,
    bytesPerRow: 0,
    bitsPerPixel: 0
) else {
    FileHandle.standardError.write(Data("cannot allocate \(size)x\(size) bitmap\n".utf8))
    exit(1)
}
rep.size = NSSize(width: size, height: size)

NSGraphicsContext.saveGraphicsState()
NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: rep)
image.draw(in: NSRect(x: 0, y: 0, width: size, height: size))
NSGraphicsContext.restoreGraphicsState()

guard let png = rep.representation(using: .png, properties: [:]) else {
    FileHandle.standardError.write(Data("cannot encode PNG\n".utf8))
    exit(1)
}
try png.write(to: output)
