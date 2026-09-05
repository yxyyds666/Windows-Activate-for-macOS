import SwiftUI

/// 设置里的实时预览：一小块假桌面，按当前设置把水印贴上去。
struct WatermarkPreviewCard: View {
    let settings: WatermarkSettings

    /// 预览用的缩放：真按屏幕比例缩会小到看不清，这里折中一半。
    private let previewScale: Double = 0.5

    var body: some View {
        ZStack(alignment: alignment) {
            wallpaper
            WatermarkView(text: settings.resolvedText(), settings: previewSettings)
                .padding(.horizontal, settings.horizontalMargin * previewScale)
                .padding(.vertical, settings.verticalMargin * previewScale)
        }
        .frame(height: 168)
        .frame(maxWidth: .infinity)
        .clipShape(RoundedRectangle(cornerRadius: WinMetrics.controlCornerRadius))
        .overlay(
            RoundedRectangle(cornerRadius: WinMetrics.controlCornerRadius)
                .strokeBorder(WinColor.cardStroke, lineWidth: 1)
        )
        .accessibilityLabel("水印预览")
    }

    private var wallpaper: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 0.05, green: 0.19, blue: 0.40),
                    Color(red: 0.01, green: 0.05, blue: 0.14)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            // 一点点光晕，方便看清浅色文字的对比度
            RadialGradient(
                colors: [Color.white.opacity(0.16), .clear],
                center: .init(x: 0.28, y: 0.22),
                startRadius: 2,
                endRadius: 220
            )
        }
    }

    private var previewSettings: WatermarkSettings {
        var copy = settings
        copy.fontScale = settings.fontScale * previewScale
        copy.showsShadow = settings.showsShadow
        return copy
    }

    private var alignment: Alignment {
        switch settings.corner {
        case .bottomTrailing: return .bottomTrailing
        case .bottomLeading: return .bottomLeading
        case .topTrailing: return .topTrailing
        case .topLeading: return .topLeading
        }
    }
}
