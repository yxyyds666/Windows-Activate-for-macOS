import AppKit
import SwiftUI

enum SnapshotError: Error {
    case renderFailed
    case encodeFailed
}

/// 离屏渲染出界面截图，用来在不打断使用的情况下检查排版。
@MainActor
public enum SnapshotRenderer {
    public static func renderAll(into directory: URL) throws -> [URL] {
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        var written: [URL] = []

        written.append(try render(
            desktop(language: .simplifiedChinese),
            size: CGSize(width: 1000, height: 625),
            isDark: true,
            to: directory.appendingPathComponent("watermark-desktop-zh.png")
        ))
        written.append(try render(
            desktop(language: .english),
            size: CGSize(width: 1000, height: 625),
            isDark: true,
            to: directory.appendingPathComponent("watermark-desktop-en.png")
        ))

        let pages: [(SettingsPage, Bool)] = [
            (.general, false),
            (.activation, true),
            (.watermark, true),
            (.position, false),
            (.about, false)
        ]
        for (page, isDark) in pages {
            let name = "settings-\(page.rawValue)-\(isDark ? "dark" : "light").png"
            written.append(try render(
                settings(page: page),
                // 截图里没有滚动条，画布高一点才能看到整页内容。
                size: CGSize(width: 780, height: 760),
                isDark: isDark,
                to: directory.appendingPathComponent(name)
            ))
        }
        return written
    }

    private static func settings(page: SettingsPage) -> some View {
        let store = SettingsStore(
            defaults: UserDefaults(suiteName: "com.windowsactivate.snapshot") ?? .standard,
            storageKey: "snapshotSettings"
        )
        return SettingsView(store: store, chrome: WindowChromeModel(), initialPage: page)
    }

    private static func desktop(language: WatermarkLanguage) -> some View {
        var settings = WatermarkSettings()
        settings.language = language
        let text = settings.resolvedText(preferredLanguages: ["en"])
        return ZStack(alignment: .bottomTrailing) {
            LinearGradient(
                colors: [
                    Color(red: 0.09, green: 0.23, blue: 0.44),
                    Color(red: 0.02, green: 0.05, blue: 0.13)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            RadialGradient(
                colors: [Color.white.opacity(0.14), .clear],
                center: .init(x: 0.3, y: 0.25),
                startRadius: 4,
                endRadius: 520
            )
            WatermarkView(text: text, settings: settings)
                .padding(.trailing, settings.horizontalMargin)
                .padding(.bottom, settings.verticalMargin)
        }
    }

    private static func render<Content: View>(
        _ content: Content,
        size: CGSize,
        isDark: Bool,
        to url: URL
    ) throws -> URL {
        var rendered: CGImage?
        let draw = {
            let renderer = ImageRenderer(
                content: content
                    .environment(\.colorScheme, isDark ? .dark : .light)
                    .environment(\.winUIRendersOffscreen, true)
                    .frame(width: size.width, height: size.height)
            )
            renderer.scale = 2
            rendered = renderer.cgImage
        }

        if let appearance = NSAppearance(named: isDark ? .darkAqua : .aqua) {
            appearance.performAsCurrentDrawingAppearance(draw)
        } else {
            draw()
        }

        guard let image = rendered else { throw SnapshotError.renderFailed }
        let representation = NSBitmapImageRep(cgImage: image)
        representation.size = size
        guard let data = representation.representation(using: .png, properties: [:]) else {
            throw SnapshotError.encodeFailed
        }
        try data.write(to: url)
        return url
    }
}
