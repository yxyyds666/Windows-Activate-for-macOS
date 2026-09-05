import SwiftUI

public enum WinCaptionAction {
    case close
    case maximize
    case minimize
}

/// Windows 的标题栏按钮组：关闭、最大化/还原、最小化。
/// 按需求放在窗口左上角，用 Windows 的 × 字形代替 macOS 的红绿灯。
public struct WinCaptionButtons: View {
    private let isZoomed: Bool
    private let action: (WinCaptionAction) -> Void

    public init(isZoomed: Bool = false, action: @escaping (WinCaptionAction) -> Void) {
        self.isZoomed = isZoomed
        self.action = action
    }

    public var body: some View {
        HStack(spacing: 0) {
            CaptionButton(kind: .close, isZoomed: isZoomed, label: "关闭") { action(.close) }
            CaptionButton(kind: .maximize, isZoomed: isZoomed, label: isZoomed ? "还原" : "最大化") { action(.maximize) }
            CaptionButton(kind: .minimize, isZoomed: isZoomed, label: "最小化") { action(.minimize) }
        }
        .frame(height: WinMetrics.captionBarHeight)
    }
}

private struct CaptionButton: View {
    let kind: WinCaptionAction
    let isZoomed: Bool
    let label: String
    let action: () -> Void

    @State private var isHovering = false
    @State private var isPressed = false

    var body: some View {
        Button(action: action) {
            glyph
                .frame(width: WinMetrics.captionButtonWidth, height: WinMetrics.captionBarHeight)
                .background(background)
                .contentShape(Rectangle())
        }
        .buttonStyle(PressReporting(isPressed: $isPressed))
        .onHover { isHovering = $0 }
        .animation(.easeOut(duration: 0.08), value: isHovering)
        .accessibilityLabel(label)
        .help(label)
    }

    @ViewBuilder
    private var glyph: some View {
        switch kind {
        case .close:
            CloseGlyph()
                .stroke(glyphColor, lineWidth: 1)
                .frame(width: 10, height: 10)
        case .maximize:
            if isZoomed {
                RestoreGlyph()
                    .stroke(glyphColor, lineWidth: 1)
                    .frame(width: 11, height: 11)
            } else {
                Rectangle()
                    .strokeBorder(glyphColor, lineWidth: 1)
                    .frame(width: 10, height: 10)
            }
        case .minimize:
            Rectangle()
                .fill(glyphColor)
                .frame(width: 10, height: 1)
        }
    }

    private var glyphColor: Color {
        if kind == .close && (isHovering || isPressed) { return .white }
        return WinColor.textPrimary
    }

    private var background: Color {
        if kind == .close {
            if isPressed { return WinColor.closePressed }
            return isHovering ? WinColor.closeHover : .clear
        }
        if isPressed { return WinColor.subtleFillPressed }
        return isHovering ? WinColor.subtleFillHover : .clear
    }
}

private struct CloseGlyph: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.minX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.move(to: CGPoint(x: rect.maxX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        return path
    }
}

private struct RestoreGlyph: Shape {
    func path(in rect: CGRect) -> Path {
        let inset: CGFloat = 3
        var path = Path()
        path.addRect(
            CGRect(
                x: rect.minX + 0.5,
                y: rect.minY + inset + 0.5,
                width: rect.width - inset - 1,
                height: rect.height - inset - 1
            )
        )
        path.move(to: CGPoint(x: rect.minX + inset + 0.5, y: rect.minY + inset))
        path.addLine(to: CGPoint(x: rect.minX + inset + 0.5, y: rect.minY + 0.5))
        path.addLine(to: CGPoint(x: rect.maxX - 0.5, y: rect.minY + 0.5))
        path.addLine(to: CGPoint(x: rect.maxX - 0.5, y: rect.maxY - inset - 0.5))
        path.addLine(to: CGPoint(x: rect.maxX - inset, y: rect.maxY - inset - 0.5))
        return path
    }
}
