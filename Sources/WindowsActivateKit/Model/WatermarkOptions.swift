import Foundation

/// 水印文案预设，对应不同 Windows 版本的未激活提示。
public enum WatermarkPreset: String, Codable, CaseIterable, Sendable {
    /// Windows 11 / 10 的“激活 Windows”水印。
    case activateWindows
    /// Windows 7 的“此 Windows 副本不是正版”水印。
    case notGenuine
    /// 用户自定义文案。
    case custom

    public var displayName: String {
        switch self {
        case .activateWindows: return "Windows 11 / 10：激活 Windows"
        case .notGenuine: return "Windows 7：副本不是正版"
        case .custom: return "自定义文案"
        }
    }
}

/// 水印文案使用的语言。
public enum WatermarkLanguage: String, Codable, CaseIterable, Sendable {
    case system
    case simplifiedChinese
    case english

    public var displayName: String {
        switch self {
        case .system: return "跟随系统"
        case .simplifiedChinese: return "简体中文"
        case .english: return "English"
        }
    }

    /// 把“跟随系统”解析成具体语言。
    public func resolve(preferredLanguages: [String] = Locale.preferredLanguages) -> ResolvedLanguage {
        switch self {
        case .simplifiedChinese: return .simplifiedChinese
        case .english: return .english
        case .system:
            let isChinese = preferredLanguages.first?.lowercased().hasPrefix("zh") ?? false
            return isChinese ? .simplifiedChinese : .english
        }
    }
}

/// 解析后的水印语言。
public enum ResolvedLanguage: String, Sendable {
    case simplifiedChinese
    case english
}

/// 水印的显示位置，以屏幕的四个角为锚点。
public enum WatermarkCorner: String, Codable, CaseIterable, Sendable {
    case bottomTrailing
    case bottomLeading
    case topTrailing
    case topLeading

    public var displayName: String {
        switch self {
        case .bottomTrailing: return "右下角"
        case .bottomLeading: return "左下角"
        case .topTrailing: return "右上角"
        case .topLeading: return "左上角"
        }
    }

    public var isTrailing: Bool { self == .bottomTrailing || self == .topTrailing }
    public var isBottom: Bool { self == .bottomTrailing || self == .bottomLeading }
}

/// 覆盖层的窗口层级。
public enum OverlayLevel: String, Codable, CaseIterable, Sendable {
    case aboveEverything
    case floating
    case desktop

    public var displayName: String {
        switch self {
        case .aboveEverything: return "覆盖所有窗口"
        case .floating: return "浮于普通窗口之上"
        case .desktop: return "贴在桌面壁纸上"
        }
    }

    public var detail: String {
        switch self {
        case .aboveEverything: return "全屏应用、程序坞和菜单栏之上都能看到，最接近 Windows"
        case .floating: return "全屏应用会遮住水印"
        case .desktop: return "任何窗口都会遮住水印"
        }
    }
}

/// 设置窗口的明暗主题。
public enum InterfaceTheme: String, Codable, CaseIterable, Sendable {
    case system
    case light
    case dark

    public var displayName: String {
        switch self {
        case .system: return "跟随系统"
        case .light: return "浅色"
        case .dark: return "深色"
        }
    }
}

/// 水印上显示的两段文字。
public struct WatermarkText: Equatable, Sendable {
    public var title: String
    public var subtitle: String

    public init(title: String, subtitle: String) {
        self.title = title
        self.subtitle = subtitle
    }
}

extension WatermarkPreset {
    /// 预设文案，逐字对应简体中文 / 英文版 Windows 的原文。
    public func text(language: ResolvedLanguage) -> WatermarkText {
        switch (self, language) {
        case (.activateWindows, .simplifiedChinese):
            return WatermarkText(title: "激活 Windows", subtitle: "转到“设置”以激活 Windows。")
        case (.activateWindows, .english):
            return WatermarkText(title: "Activate Windows", subtitle: "Go to Settings to activate Windows.")
        case (.notGenuine, .simplifiedChinese):
            return WatermarkText(title: "Windows 7", subtitle: "内部版本 7601\n此 Windows 副本不是正版")
        case (.notGenuine, .english):
            return WatermarkText(title: "Windows 7", subtitle: "Build 7601\nThis copy of Windows is not genuine")
        case (.custom, .simplifiedChinese):
            return WatermarkText(title: "激活 Windows", subtitle: "转到“设置”以激活 Windows。")
        case (.custom, .english):
            return WatermarkText(title: "Activate Windows", subtitle: "Go to Settings to activate Windows.")
        }
    }
}
