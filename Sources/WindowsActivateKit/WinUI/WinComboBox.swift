import SwiftUI

/// WinUI 的下拉框：闭合状态完全按 Windows 11 绘制，展开后沿用系统菜单。
public struct WinComboBox<Value: Hashable>: View {
    public struct Option: Identifiable {
        public let value: Value
        public let title: String
        public var id: Value { value }

        public init(_ value: Value, _ title: String) {
            self.value = value
            self.title = title
        }
    }

    @Binding private var selection: Value
    private let options: [Option]
    private let width: CGFloat

    public init(selection: Binding<Value>, options: [Option], width: CGFloat = 190) {
        self._selection = selection
        self.options = options
        self.width = width
    }

    public var body: some View {
        Menu {
            ForEach(options) { option in
                Button {
                    selection = option.value
                } label: {
                    if option.value == selection {
                        Label(option.title, systemImage: "checkmark")
                    } else {
                        Text(option.title)
                    }
                }
            }
        } label: {
            ComboLabel(title: currentTitle, width: width)
        }
        .menuStyle(.borderlessButton)
        .menuIndicator(.hidden)
        .frame(width: width)
    }

    private var currentTitle: String {
        options.first { $0.value == selection }?.title ?? ""
    }

    private struct ComboLabel: View {
        let title: String
        let width: CGFloat

        @Environment(\.isEnabled) private var isEnabled
        @State private var isHovering = false

        var body: some View {
            HStack(spacing: 10) {
                Text(title)
                    .font(WinText.body)
                    .foregroundStyle(isEnabled ? WinColor.textPrimary : WinColor.textDisabled)
                    .lineLimit(1)
                Spacer(minLength: 0)
                Image(systemName: "chevron.down")
                    .font(.system(size: 9, weight: .semibold))
                    .foregroundStyle(isEnabled ? WinColor.textSecondary : WinColor.textDisabled)
            }
            .padding(.horizontal, 11)
            .frame(width: width, height: WinMetrics.controlHeight)
            .background(shape.fill(background))
            .overlay(
                shape.strokeBorder(
                    LinearGradient(
                        colors: [WinColor.controlStroke, WinColor.controlStrokeSecondary],
                        startPoint: .top,
                        endPoint: .bottom
                    ),
                    lineWidth: 1
                )
            )
            .contentShape(Rectangle())
            .onHover { isHovering = $0 }
            .animation(.easeOut(duration: 0.09), value: isHovering)
        }

        private var shape: RoundedRectangle {
            RoundedRectangle(cornerRadius: WinMetrics.controlCornerRadius)
        }

        private var background: Color {
            guard isEnabled else { return WinColor.controlFillDisabled }
            return isHovering ? WinColor.controlFillHover : WinColor.controlFill
        }
    }
}
