import SwiftUI

/// 桌面水印本体：两段浅灰文字，尽量还原 Windows 右下角那块水印的排版。
public struct WatermarkView: View {
    private let text: WatermarkText
    private let settings: WatermarkSettings

    public init(text: WatermarkText, settings: WatermarkSettings) {
        self.text = text
        self.settings = settings
    }

    private var scale: CGFloat { CGFloat(settings.fontScale) }
    private var language: ResolvedLanguage { settings.language.resolve() }
    private var alignment: HorizontalAlignment { settings.corner.isTrailing ? .trailing : .leading }
    private var textAlignment: TextAlignment { settings.corner.isTrailing ? .trailing : .leading }

    public var body: some View {
        VStack(alignment: alignment, spacing: 6 * scale) {
            if !text.title.isEmpty {
                Text(text.title)
                    .font(Font(WinFont.watermark(size: 26 * scale, language: language)))
            }
            if !text.subtitle.isEmpty {
                Text(text.subtitle)
                    .font(Font(WinFont.watermark(size: 15 * scale, language: language)))
                    .lineSpacing(3 * scale)
            }
        }
        .multilineTextAlignment(textAlignment)
        .foregroundStyle(Color.white.opacity(settings.opacity))
        .shadow(color: .black.opacity(settings.showsShadow ? 0.5 : 0), radius: 4 * scale, x: 0, y: 1)
        .fixedSize()
        .padding(Self.shadowInset(for: settings))
        .accessibilityHidden(true)
    }

    /// 阴影需要在窗口里留出余量，否则会被窗口边缘切掉；
    /// 覆盖层再把这块余量从边距里扣回去，保证实际间距不变。
    public static func shadowInset(for settings: WatermarkSettings) -> CGFloat {
        settings.showsShadow ? (10 * CGFloat(settings.fontScale)).rounded() : 2
    }
}
