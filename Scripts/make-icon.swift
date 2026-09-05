#!/usr/bin/env swift

// 生成应用图标：浅色圆角底 + Windows 徽标四格。
// 用法：swift Scripts/make-icon.swift <输出 iconset 目录>

import AppKit

let arguments = CommandLine.arguments
guard arguments.count > 1 else {
    FileHandle.standardError.write(Data("用法：swift make-icon.swift <输出目录>\n".utf8))
    exit(1)
}

let outputDirectory = URL(fileURLWithPath: arguments[1], isDirectory: true)
try? FileManager.default.createDirectory(at: outputDirectory, withIntermediateDirectories: true)

func drawIcon(side: CGFloat) -> NSBitmapImageRep? {
    let pixels = Int(side)
    guard let rep = NSBitmapImageRep(
        bitmapDataPlanes: nil,
        pixelsWide: pixels,
        pixelsHigh: pixels,
        bitsPerSample: 8,
        samplesPerPixel: 4,
        hasAlpha: true,
        isPlanar: false,
        colorSpaceName: .deviceRGB,
        bytesPerRow: 0,
        bitsPerPixel: 0
    ) else { return nil }

    guard let context = NSGraphicsContext(bitmapImageRep: rep) else { return nil }
    NSGraphicsContext.saveGraphicsState()
    NSGraphicsContext.current = context

    let inset = side * 0.09
    let plate = NSRect(x: inset, y: inset, width: side - inset * 2, height: side - inset * 2)
    let radius = plate.width * 0.225
    let platePath = NSBezierPath(roundedRect: plate, xRadius: radius, yRadius: radius)

    let gradient = NSGradient(colors: [
        NSColor(srgbRed: 1, green: 1, blue: 1, alpha: 1),
        NSColor(srgbRed: 0.85, green: 0.90, blue: 0.96, alpha: 1)
    ])
    gradient?.draw(in: platePath, angle: -90)

    NSColor(srgbRed: 0, green: 0, blue: 0, alpha: 0.08).setStroke()
    platePath.lineWidth = max(1, side * 0.004)
    platePath.stroke()

    let tile = plate.width * 0.29
    let gap = plate.width * 0.055
    let flagSide = tile * 2 + gap
    let originX = plate.midX - flagSide / 2
    let originY = plate.midY - flagSide / 2
    let tileRadius = tile * 0.06
    NSColor(srgbRed: 0, green: 0.47, blue: 0.83, alpha: 1).setFill()
    for (column, row) in [(0, 0), (1, 0), (0, 1), (1, 1)] {
        let rect = NSRect(
            x: originX + CGFloat(column) * (tile + gap),
            y: originY + CGFloat(row) * (tile + gap),
            width: tile,
            height: tile
        )
        NSBezierPath(roundedRect: rect, xRadius: tileRadius, yRadius: tileRadius).fill()
    }

    NSGraphicsContext.restoreGraphicsState()
    return rep
}

let variants: [(name: String, side: Int)] = [
    ("icon_16x16", 16), ("icon_16x16@2x", 32),
    ("icon_32x32", 32), ("icon_32x32@2x", 64),
    ("icon_128x128", 128), ("icon_128x128@2x", 256),
    ("icon_256x256", 256), ("icon_256x256@2x", 512),
    ("icon_512x512", 512), ("icon_512x512@2x", 1024)
]

for variant in variants {
    guard let rep = drawIcon(side: CGFloat(variant.side)),
          let data = rep.representation(using: .png, properties: [:]) else {
        FileHandle.standardError.write(Data("生成 \(variant.name) 失败\n".utf8))
        exit(1)
    }
    let url = outputDirectory.appendingPathComponent("\(variant.name).png")
    try data.write(to: url)
    print("写入 \(url.lastPathComponent)")
}
