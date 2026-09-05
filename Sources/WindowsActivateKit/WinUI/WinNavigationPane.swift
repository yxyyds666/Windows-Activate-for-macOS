import SwiftUI

public struct WinNavigationItem: Identifiable, Equatable {
    public let id: String
    public let title: String
    public let systemImage: String

    public init(id: String, title: String, systemImage: String) {
        self.id = id
        self.title = title
        self.systemImage = systemImage
    }
}

/// WinUI 的左侧导航面板：选中项左边是 3pt 的主题色指示条。
public struct WinNavigationPane: View {
    private let items: [WinNavigationItem]
    @Binding private var selection: String

    public init(items: [WinNavigationItem], selection: Binding<String>) {
        self.items = items
        self._selection = selection
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            ForEach(items) { item in
                Row(item: item, isSelected: item.id == selection) {
                    selection = item.id
                }
            }
            Spacer(minLength: 0)
        }
        .padding(.horizontal, 5)
        .padding(.top, 6)
        .frame(width: WinMetrics.navigationPaneWidth, alignment: .topLeading)
    }

    private struct Row: View {
        let item: WinNavigationItem
        let isSelected: Bool
        let action: () -> Void

        @State private var isHovering = false
        @State private var isPressed = false

        var body: some View {
            Button(action: action) {
                HStack(spacing: 14) {
                    Image(systemName: item.systemImage)
                        .font(.system(size: 15, weight: .regular))
                        .foregroundStyle(WinColor.textPrimary)
                        .frame(width: 16, height: 16)
                    Text(item.title)
                        .font(WinText.body)
                        .foregroundStyle(WinColor.textPrimary)
                    Spacer(minLength: 0)
                }
                .padding(.leading, 13)
                .padding(.trailing, 10)
                .frame(height: 36)
                .background(shape.fill(background))
                .overlay(alignment: .leading) {
                    if isSelected {
                        Capsule()
                            .fill(WinColor.accent)
                            .frame(width: 3, height: 16)
                            .padding(.leading, 3)
                    }
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(PressReporting(isPressed: $isPressed))
            .onHover { isHovering = $0 }
            .animation(.easeOut(duration: 0.09), value: isHovering)
            .accessibilityAddTraits(isSelected ? [.isButton, .isSelected] : .isButton)
        }

        private var shape: RoundedRectangle {
            RoundedRectangle(cornerRadius: WinMetrics.controlCornerRadius)
        }

        private var background: Color {
            if isPressed { return WinColor.subtleFillPressed }
            if isSelected { return isHovering ? WinColor.controlFillHover : WinColor.cardBackground }
            return isHovering ? WinColor.subtleFillHover : .clear
        }
    }
}
