import SwiftUI

/// WinUI 的按钮：标准与强调两种变体，尺寸和悬停反馈都照 Windows 11 来。
public struct WinButtonStyle: ButtonStyle {
    public enum Variant {
        case standard
        case accent
    }

    private let variant: Variant

    public init(_ variant: Variant = .standard) {
        self.variant = variant
    }

    public func makeBody(configuration: Configuration) -> some View {
        Content(variant: variant, configuration: configuration)
    }

    private struct Content: View {
        let variant: Variant
        let configuration: ButtonStyleConfiguration

        @Environment(\.isEnabled) private var isEnabled
        @State private var isHovering = false

        var body: some View {
            configuration.label
                .font(WinText.body)
                .foregroundStyle(foreground)
                .padding(.horizontal, 12)
                .frame(minHeight: WinMetrics.controlHeight)
                .background(shape.fill(background))
                .overlay(shape.strokeBorder(border, lineWidth: 1))
                .contentShape(Rectangle())
                .onHover { isHovering = $0 }
                .animation(.easeOut(duration: 0.09), value: isHovering)
        }

        private var shape: RoundedRectangle {
            RoundedRectangle(cornerRadius: WinMetrics.controlCornerRadius)
        }

        private var foreground: Color {
            guard isEnabled else { return WinColor.textDisabled }
            switch variant {
            case .standard: return WinColor.textPrimary
            case .accent: return WinColor.textOnAccent
            }
        }

        private var background: Color {
            switch variant {
            case .standard:
                guard isEnabled else { return WinColor.controlFillDisabled }
                if configuration.isPressed { return WinColor.controlFillPressed }
                return isHovering ? WinColor.controlFillHover : WinColor.controlFill
            case .accent:
                guard isEnabled else { return WinColor.accentDisabled }
                if configuration.isPressed { return WinColor.accentPressed }
                return isHovering ? WinColor.accentHover : WinColor.accent
            }
        }

        /// WinUI 的按钮描边是上浅下深的渐变，用来做出一点“抬起”的层次。
        private var border: LinearGradient {
            switch variant {
            case .standard:
                return LinearGradient(
                    colors: isEnabled
                        ? [WinColor.controlStroke, WinColor.controlStrokeSecondary]
                        : [WinColor.controlStroke, WinColor.controlStroke],
                    startPoint: .top,
                    endPoint: .bottom
                )
            case .accent:
                return LinearGradient(
                    colors: isEnabled
                        ? [Color.white.opacity(0.08), Color.black.opacity(0.14)]
                        : [.clear, .clear],
                    startPoint: .top,
                    endPoint: .bottom
                )
            }
        }
    }
}
