import SwiftUI

/// WinUI 的单行输入框：底边描边在获得焦点时变成 2pt 主题色。
public struct WinTextBox: View {
    private let placeholder: String
    @Binding private var text: String

    @Environment(\.isEnabled) private var isEnabled
    @FocusState private var isFocused: Bool

    public init(placeholder: String = "", text: Binding<String>) {
        self.placeholder = placeholder
        self._text = text
    }

    public var body: some View {
        TextField(placeholder, text: $text)
            .textFieldStyle(.plain)
            .font(WinText.body)
            .foregroundStyle(isEnabled ? WinColor.textPrimary : WinColor.textDisabled)
            .focused($isFocused)
            .padding(.horizontal, 11)
            .frame(height: WinMetrics.controlHeight)
            .background(WinInputBackground(isFocused: isFocused, isEnabled: isEnabled))
    }
}

/// WinUI 的多行输入框。
public struct WinTextArea: View {
    @Binding private var text: String
    private let height: CGFloat

    @Environment(\.isEnabled) private var isEnabled
    @FocusState private var isFocused: Bool

    public init(text: Binding<String>, height: CGFloat = 72) {
        self._text = text
        self.height = height
    }

    public var body: some View {
        TextEditor(text: $text)
            .font(WinText.body)
            .foregroundStyle(isEnabled ? WinColor.textPrimary : WinColor.textDisabled)
            .scrollContentBackground(.hidden)
            .focused($isFocused)
            .padding(.horizontal, 7)
            .padding(.vertical, 6)
            .frame(height: height)
            .background(WinInputBackground(isFocused: isFocused, isEnabled: isEnabled))
    }
}

private struct WinInputBackground: View {
    let isFocused: Bool
    let isEnabled: Bool

    var body: some View {
        ZStack(alignment: .bottom) {
            shape.fill(fill)
            Rectangle()
                .fill(isFocused ? WinColor.accent : WinColor.controlStrongStroke)
                .frame(height: isFocused ? 2 : 1)
        }
        .clipShape(shape)
        .overlay(shape.strokeBorder(WinColor.controlStroke, lineWidth: 1))
        .animation(.easeOut(duration: 0.1), value: isFocused)
    }

    private var shape: RoundedRectangle {
        RoundedRectangle(cornerRadius: WinMetrics.controlCornerRadius)
    }

    private var fill: Color {
        guard isEnabled else { return WinColor.controlFillDisabled }
        return isFocused ? WinColor.controlFillInputActive : WinColor.controlFill
    }
}
