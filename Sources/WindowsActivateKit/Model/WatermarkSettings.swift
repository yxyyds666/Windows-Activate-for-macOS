import Foundation

/// 全部可持久化的水印设置。纯值类型，便于单元测试。
public struct WatermarkSettings: Codable, Equatable, Sendable {
    public var isEnabled: Bool
    public var preset: WatermarkPreset
    public var language: WatermarkLanguage
    public var customTitle: String
    public var customSubtitle: String
    public var opacity: Double
    public var fontScale: Double
    public var corner: WatermarkCorner
    public var horizontalMargin: Double
    public var verticalMargin: Double
    public var showsShadow: Bool
    public var avoidsDockAndMenuBar: Bool
    public var showsOnAllDisplays: Bool
    public var overlayLevel: OverlayLevel
    public var theme: InterfaceTheme

    public static let opacityRange: ClosedRange<Double> = 0.1...1.0
    public static let fontScaleRange: ClosedRange<Double> = 0.6...2.5
    public static let marginRange: ClosedRange<Double> = 0...200

    public init(
        isEnabled: Bool = true,
        preset: WatermarkPreset = .activateWindows,
        language: WatermarkLanguage = .system,
        customTitle: String = "",
        customSubtitle: String = "",
        opacity: Double = 0.62,
        fontScale: Double = 1.0,
        corner: WatermarkCorner = .bottomTrailing,
        horizontalMargin: Double = 26,
        verticalMargin: Double = 22,
        showsShadow: Bool = true,
        avoidsDockAndMenuBar: Bool = true,
        showsOnAllDisplays: Bool = true,
        overlayLevel: OverlayLevel = .aboveEverything,
        theme: InterfaceTheme = .system
    ) {
        self.isEnabled = isEnabled
        self.preset = preset
        self.language = language
        self.customTitle = customTitle
        self.customSubtitle = customSubtitle
        self.opacity = opacity
        self.fontScale = fontScale
        self.corner = corner
        self.horizontalMargin = horizontalMargin
        self.verticalMargin = verticalMargin
        self.showsShadow = showsShadow
        self.avoidsDockAndMenuBar = avoidsDockAndMenuBar
        self.showsOnAllDisplays = showsOnAllDisplays
        self.overlayLevel = overlayLevel
        self.theme = theme
    }

    /// 解码时缺少的字段回落到默认值，方便以后增加设置项而不丢弃旧配置。
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let fallback = WatermarkSettings()
        func value<T: Decodable>(_ key: CodingKeys, _ fallback: T) -> T {
            ((try? container.decodeIfPresent(T.self, forKey: key)) ?? nil) ?? fallback
        }
        self.init(
            isEnabled: value(.isEnabled, fallback.isEnabled),
            preset: value(.preset, fallback.preset),
            language: value(.language, fallback.language),
            customTitle: value(.customTitle, fallback.customTitle),
            customSubtitle: value(.customSubtitle, fallback.customSubtitle),
            opacity: value(.opacity, fallback.opacity),
            fontScale: value(.fontScale, fallback.fontScale),
            corner: value(.corner, fallback.corner),
            horizontalMargin: value(.horizontalMargin, fallback.horizontalMargin),
            verticalMargin: value(.verticalMargin, fallback.verticalMargin),
            showsShadow: value(.showsShadow, fallback.showsShadow),
            avoidsDockAndMenuBar: value(.avoidsDockAndMenuBar, fallback.avoidsDockAndMenuBar),
            showsOnAllDisplays: value(.showsOnAllDisplays, fallback.showsOnAllDisplays),
            overlayLevel: value(.overlayLevel, fallback.overlayLevel),
            theme: value(.theme, fallback.theme)
        )
    }

    /// 把数值收敛到合法区间，避免手工改配置文件后出现异常显示。
    public func sanitized() -> WatermarkSettings {
        var copy = self
        copy.opacity = opacity.clamped(to: Self.opacityRange)
        copy.fontScale = fontScale.clamped(to: Self.fontScaleRange)
        copy.horizontalMargin = horizontalMargin.clamped(to: Self.marginRange)
        copy.verticalMargin = verticalMargin.clamped(to: Self.marginRange)
        if copy.preset == .custom && copy.customTitle.isEmpty && copy.customSubtitle.isEmpty {
            copy.preset = .activateWindows
        }
        return copy
    }

    /// 当前应当显示的水印文案。
    public func resolvedText(preferredLanguages: [String] = Locale.preferredLanguages) -> WatermarkText {
        let resolved = language.resolve(preferredLanguages: preferredLanguages)
        guard preset == .custom else { return preset.text(language: resolved) }
        return WatermarkText(title: customTitle, subtitle: customSubtitle)
    }
}

extension Comparable {
    func clamped(to range: ClosedRange<Self>) -> Self {
        min(max(self, range.lowerBound), range.upperBound)
    }
}
