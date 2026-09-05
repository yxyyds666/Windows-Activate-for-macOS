import AppKit
import SwiftUI

/// WinUI 的下拉框：闭合状态完全自绘，展开后用原生菜单（可以画到窗口之外，并带勾选标记）。
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

    @Environment(\.isEnabled) private var isEnabled
    @Environment(\.winUIRendersOffscreen) private var rendersOffscreen
    @StateObject private var anchor = ComboBoxAnchor()
    @State private var isHovering = false

    public init(selection: Binding<Value>, options: [Option], width: CGFloat = 190) {
        self._selection = selection
        self.options = options
        self.width = width
    }

    public var body: some View {
        Button(action: present) {
            HStack(spacing: 10) {
                Text(currentTitle)
                    .font(WinText.body)
                    .foregroundStyle(isEnabled ? WinColor.textPrimary : WinColor.textDisabled)
                    .lineLimit(1)
                Spacer(minLength: 0)
                WinIcon("chevron.down", size: 9, weight: .semibold)
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
            .background(anchorView)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .onHover { isHovering = $0 }
        .animation(.easeOut(duration: 0.09), value: isHovering)
        .accessibilityValue(currentTitle)
    }

    @ViewBuilder
    private var anchorView: some View {
        // 离屏渲染不支持 NSViewRepresentable，生成截图时直接跳过。
        if !rendersOffscreen {
            ComboBoxAnchorView(anchor: anchor)
        }
    }

    private var shape: RoundedRectangle {
        RoundedRectangle(cornerRadius: WinMetrics.controlCornerRadius)
    }

    private var background: Color {
        guard isEnabled else { return WinColor.controlFillDisabled }
        return isHovering ? WinColor.controlFillHover : WinColor.controlFill
    }

    private var currentTitle: String {
        options.first { $0.value == selection }?.title ?? ""
    }

    private func present() {
        guard isEnabled else { return }
        let target = MenuActionTarget { index in
            guard options.indices.contains(index) else { return }
            selection = options[index].value
        }
        let menu = NSMenu()
        menu.items = options.enumerated().map { index, option in
            let item = NSMenuItem(
                title: option.title,
                action: #selector(MenuActionTarget.fire(_:)),
                keyEquivalent: ""
            )
            item.target = target
            item.tag = index
            item.state = option.value == selection ? .on : .off
            return item
        }
        anchor.present(menu: menu, retaining: target)
    }
}

/// 记住下拉框对应的 AppKit 视图，用来把菜单弹在控件正下方。
final class ComboBoxAnchor: ObservableObject {
    weak var view: NSView?
    private var retained: AnyObject?

    func present(menu: NSMenu, retaining target: AnyObject) {
        guard let view else { return }
        retained = target
        menu.minimumWidth = view.bounds.width
        menu.popUp(positioning: nil, at: NSPoint(x: 0, y: 0), in: view)
    }
}

private struct ComboBoxAnchorView: NSViewRepresentable {
    let anchor: ComboBoxAnchor

    func makeNSView(context: Context) -> NSView {
        let view = PassthroughView()
        anchor.view = view
        return view
    }

    func updateNSView(_ nsView: NSView, context: Context) {
        anchor.view = nsView
    }

    /// 不参与命中测试，点击照样交给 SwiftUI 的按钮。
    private final class PassthroughView: NSView {
        override func hitTest(_ point: NSPoint) -> NSView? { nil }
    }
}

final class MenuActionTarget: NSObject {
    private let handler: (Int) -> Void

    init(handler: @escaping (Int) -> Void) {
        self.handler = handler
        super.init()
    }

    @objc func fire(_ sender: NSMenuItem) {
        handler(sender.tag)
    }
}
