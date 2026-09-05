import SwiftUI

/// WinUI 的开关：40×20 的胶囊，右侧带“开/关”文字，悬停时滑块变大、按下时压扁。
public struct WinToggleStyle: ToggleStyle {
    private let showsStateLabel: Bool

    public init(showsStateLabel: Bool = true) {
        self.showsStateLabel = showsStateLabel
    }

    public func makeBody(configuration: Configuration) -> some View {
        Content(configuration: configuration, showsStateLabel: showsStateLabel)
    }

    private struct Content: View {
        let configuration: ToggleStyleConfiguration
        let showsStateLabel: Bool

        @Environment(\.isEnabled) private var isEnabled
        @State private var isHovering = false
        @State private var isPressed = false

        private let trackWidth: CGFloat = 40
        private let trackHeight: CGFloat = 20

        var body: some View {
            Button {
                configuration.isOn.toggle()
            } label: {
                HStack(spacing: 12) {
                    track
                    if showsStateLabel {
                        Text(configuration.isOn ? "开" : "关")
                            .font(WinText.body)
                            .foregroundStyle(isEnabled ? WinColor.textPrimary : WinColor.textDisabled)
                            .frame(width: 18, alignment: .leading)
                    }
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(PressReporting(isPressed: $isPressed))
            .onHover { isHovering = $0 }
            .accessibilityRepresentation {
                Toggle(isOn: configuration.$isOn) { configuration.label }
            }
        }

        private var track: some View {
            ZStack {
                Capsule().fill(trackFill)
                Capsule()
                    .fill(knobFill)
                    .frame(width: knobWidth, height: knobHeight)
                    .offset(x: knobOffset)
            }
            .frame(width: trackWidth, height: trackHeight)
            .overlay(Capsule().strokeBorder(trackStroke, lineWidth: 1))
            .animation(.easeOut(duration: 0.13), value: configuration.isOn)
            .animation(.easeOut(duration: 0.1), value: isHovering)
            .animation(.easeOut(duration: 0.1), value: isPressed)
        }

        private var knobWidth: CGFloat {
            if isPressed { return 17 }
            return isHovering ? 14 : 12
        }

        private var knobHeight: CGFloat {
            isPressed ? 14 : knobWidth
        }

        private var knobOffset: CGFloat {
            let distance = trackWidth / 2 - 4 - knobWidth / 2
            return configuration.isOn ? distance : -distance
        }

        private var trackFill: Color {
            guard isEnabled else { return WinColor.controlFillDisabled }
            if configuration.isOn {
                if isPressed { return WinColor.accentPressed }
                return isHovering ? WinColor.accentHover : WinColor.accent
            }
            if isPressed { return WinColor.controlFillPressed }
            return isHovering ? WinColor.controlFillHover : WinColor.controlAltFill
        }

        private var trackStroke: Color {
            guard isEnabled else { return WinColor.controlStroke }
            return configuration.isOn ? .clear : WinColor.controlStrongStroke
        }

        private var knobFill: Color {
            guard isEnabled else { return WinColor.textDisabled }
            return configuration.isOn ? WinColor.toggleKnobOn : WinColor.toggleKnobOff
        }
    }
}

/// 把按钮的按下状态反馈给外层视图，同时不改变外观。
struct PressReporting: ButtonStyle {
    @Binding var isPressed: Bool

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .onChange(of: configuration.isPressed) { _, newValue in
                isPressed = newValue
            }
    }
}
