import AppKit
import SwiftUI

extension NSColor {
    fileprivate convenience init(hex: UInt32, alpha: CGFloat = 1) {
        self.init(
            srgbRed: CGFloat((hex >> 16) & 0xFF) / 255,
            green: CGFloat((hex >> 8) & 0xFF) / 255,
            blue: CGFloat(hex & 0xFF) / 255,
            alpha: alpha
        )
    }

    fileprivate static func winDynamic(light: NSColor, dark: NSColor) -> NSColor {
        NSColor(name: nil) { appearance in
            appearance.bestMatch(from: [.aqua, .darkAqua]) == .darkAqua ? dark : light
        }
    }
}

private func token(
    light: UInt32,
    lightAlpha: CGFloat = 1,
    dark: UInt32,
    darkAlpha: CGFloat = 1
) -> Color {
    Color(nsColor: .winDynamic(
        light: NSColor(hex: light, alpha: lightAlpha),
        dark: NSColor(hex: dark, alpha: darkAlpha)
    ))
}

/// Windows 11（WinUI 3 / Fluent）的颜色令牌，浅色与深色两套值。
public enum WinColor {
    // 背景与图层
    public static let solidBackgroundBase = token(light: 0xF3F3F3, dark: 0x202020)
    public static let layerFill = token(light: 0xFFFFFF, lightAlpha: 0.5, dark: 0x3A3A3A, darkAlpha: 0.3)
    public static let cardBackground = token(light: 0xFFFFFF, lightAlpha: 0.7, dark: 0xFFFFFF, darkAlpha: 0.0512)
    public static let cardBackgroundSecondary = token(light: 0xF6F6F6, lightAlpha: 0.5, dark: 0xFFFFFF, darkAlpha: 0.0326)

    // 控件填充
    public static let controlFill = token(light: 0xFFFFFF, lightAlpha: 0.7, dark: 0xFFFFFF, darkAlpha: 0.0605)
    public static let controlFillHover = token(light: 0xF9F9F9, lightAlpha: 0.5, dark: 0xFFFFFF, darkAlpha: 0.0837)
    public static let controlFillPressed = token(light: 0xF9F9F9, lightAlpha: 0.3, dark: 0xFFFFFF, darkAlpha: 0.0326)
    public static let controlFillDisabled = token(light: 0xF9F9F9, lightAlpha: 0.3, dark: 0xFFFFFF, darkAlpha: 0.0419)
    public static let controlFillInputActive = token(light: 0xFFFFFF, dark: 0x1F1F1F, darkAlpha: 0.8)
    public static let controlAltFill = token(light: 0xFFFFFF, lightAlpha: 0.5, dark: 0x000000, darkAlpha: 0.1)
    public static let subtleFillHover = token(light: 0x000000, lightAlpha: 0.0373, dark: 0xFFFFFF, darkAlpha: 0.0605)
    public static let subtleFillPressed = token(light: 0x000000, lightAlpha: 0.0241, dark: 0xFFFFFF, darkAlpha: 0.0419)

    // 描边
    public static let controlStroke = token(light: 0x000000, lightAlpha: 0.0578, dark: 0xFFFFFF, darkAlpha: 0.0698)
    public static let controlStrokeSecondary = token(light: 0x000000, lightAlpha: 0.1622, dark: 0xFFFFFF, darkAlpha: 0.0698)
    public static let controlStrongStroke = token(light: 0x000000, lightAlpha: 0.4458, dark: 0xFFFFFF, darkAlpha: 0.5442)
    public static let cardStroke = token(light: 0x000000, lightAlpha: 0.0578, dark: 0xFFFFFF, darkAlpha: 0.0578)
    public static let dividerStroke = token(light: 0x000000, lightAlpha: 0.0803, dark: 0xFFFFFF, darkAlpha: 0.0837)

    // 文字
    public static let textPrimary = token(light: 0x000000, lightAlpha: 0.8956, dark: 0xFFFFFF)
    public static let textSecondary = token(light: 0x000000, lightAlpha: 0.6063, dark: 0xFFFFFF, darkAlpha: 0.7725)
    public static let textTertiary = token(light: 0x000000, lightAlpha: 0.4458, dark: 0xFFFFFF, darkAlpha: 0.5442)
    public static let textDisabled = token(light: 0x000000, lightAlpha: 0.3614, dark: 0xFFFFFF, darkAlpha: 0.3628)

    // 主题色
    public static let accent = token(light: 0x005FB8, dark: 0x60CDFF)
    public static let accentHover = token(light: 0x1A6DC0, dark: 0x53BDEB)
    public static let accentPressed = token(light: 0x3384CB, dark: 0x4AA9D2)
    public static let accentDisabled = token(light: 0x000000, lightAlpha: 0.2169, dark: 0xFFFFFF, darkAlpha: 0.1581)
    public static let textOnAccent = token(light: 0xFFFFFF, dark: 0x000000, darkAlpha: 0.8956)

    // 标题栏关闭按钮
    public static let closeHover = Color(nsColor: NSColor(hex: 0xC42B1C))
    public static let closePressed = Color(nsColor: NSColor(hex: 0xC42B1C, alpha: 0.9))

    // 窗口边框
    public static let windowBorder = token(light: 0x000000, lightAlpha: 0.16, dark: 0xFFFFFF, darkAlpha: 0.12)

    // 开关
    public static let toggleKnobOff = token(light: 0x5D5D5D, dark: 0xD1D1D1)
    public static let toggleKnobOn = token(light: 0xFFFFFF, dark: 0x000000, darkAlpha: 0.8956)
}

/// WinUI 常用尺寸。
public enum WinMetrics {
    public static let controlCornerRadius: CGFloat = 4
    public static let overlayCornerRadius: CGFloat = 8
    public static let windowCornerRadius: CGFloat = 8
    public static let controlHeight: CGFloat = 32
    public static let captionButtonWidth: CGFloat = 46
    public static let captionBarHeight: CGFloat = 32
    public static let navigationPaneWidth: CGFloat = 196
}

/// Windows 11 的字号阶梯。
public enum WinText {
    public static let caption = Font(WinFont.ui(size: 12))
    public static let body = Font(WinFont.ui(size: 14))
    public static let bodyStrong = Font(WinFont.ui(size: 14, weight: .semibold))
    public static let bodyLarge = Font(WinFont.ui(size: 18))
    public static let subtitle = Font(WinFont.ui(size: 20, weight: .semibold))
    public static let title = Font(WinFont.ui(size: 28, weight: .semibold))
}
