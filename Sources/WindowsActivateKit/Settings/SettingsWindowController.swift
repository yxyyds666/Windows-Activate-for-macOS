import AppKit
import Combine
import SwiftUI

/// 设置窗口。用无边框窗口自己画标题栏：Windows 的 × / □ / ─ 紧贴左上角，
/// 而不是 macOS 的红绿灯，也没有系统标题栏留下的那段左边距。
@MainActor
public final class SettingsWindowController: NSObject, NSWindowDelegate {
    private let store: SettingsStore
    private let onClose: () -> Void
    let window: SettingsWindow
    private let chrome: WindowChromeModel
    private var themeObserver: AnyCancellable?

    public init(store: SettingsStore, onClose: @escaping () -> Void = {}) {
        self.store = store
        self.onClose = onClose
        self.chrome = WindowChromeModel()
        self.window = SettingsWindow(
            contentRect: NSRect(x: 0, y: 0, width: 780, height: 560),
            styleMask: [.borderless, .closable, .miniaturizable, .resizable, .fullSizeContentView],
            backing: .buffered,
            defer: false
        )
        super.init()

        chrome.onCaptionAction = { [weak self] action in self?.perform(action) }
        configure()
        themeObserver = store.$settings
            .map(\.theme)
            .removeDuplicates()
            .sink { [weak self] theme in self?.apply(theme: theme) }
    }

    public func show() {
        apply(theme: store.settings.theme)
        if !window.isVisible {
            centerOnScreenUnderPointer()
        }
        window.makeKeyAndOrderFront(nil)
        // 从菜单栏应用切成普通应用的瞬间系统可能拒绝激活请求，
        // 这里再强制排到最前，保证窗口不会藏在别的窗口后面。
        window.orderFrontRegardless()
        window.invalidateShadow()
        chrome.isZoomed = window.isZoomed
    }

    /// 出现在鼠标所在的那块屏幕上；`NSWindow.center()` 认的是系统的主屏，多屏时容易跑到另一台显示器。
    private func centerOnScreenUnderPointer() {
        let pointer = NSEvent.mouseLocation
        let screen = NSScreen.screens.first { $0.frame.contains(pointer) }
            ?? NSScreen.main
            ?? NSScreen.screens.first
        guard let area = screen?.visibleFrame else {
            window.center()
            return
        }
        let size = window.frame.size
        window.setFrameOrigin(
            NSPoint(x: area.midX - size.width / 2, y: area.midY - size.height / 2)
        )
    }

    private func configure() {
        window.title = AppInfo.displayName
        window.isOpaque = false
        window.backgroundColor = .clear
        window.hasShadow = true
        window.isMovableByWindowBackground = false
        window.isReleasedWhenClosed = false
        window.tabbingMode = .disallowed
        window.minSize = NSSize(width: 720, height: 520)
        window.delegate = self

        let hosting = NSHostingView(rootView: rootView)
        hosting.safeAreaRegions = []
        window.contentView = hosting
    }

    private var rootView: some View {
        SettingsView(store: store, chrome: chrome)
            .clipShape(RoundedRectangle(cornerRadius: WinMetrics.windowCornerRadius))
            .overlay(
                RoundedRectangle(cornerRadius: WinMetrics.windowCornerRadius)
                    .strokeBorder(WinColor.windowBorder, lineWidth: 1)
            )
    }

    private func perform(_ action: WinCaptionAction) {
        switch action {
        case .close: window.performClose(nil)
        case .maximize: window.zoom(nil)
        case .minimize: window.miniaturize(nil)
        }
    }

    private func apply(theme: InterfaceTheme) {
        switch theme {
        case .system: window.appearance = nil
        case .light: window.appearance = NSAppearance(named: .aqua)
        case .dark: window.appearance = NSAppearance(named: .darkAqua)
        }
    }

    public func windowWillClose(_ notification: Notification) {
        onClose()
    }

    public func windowDidResize(_ notification: Notification) {
        chrome.isZoomed = window.isZoomed
        window.invalidateShadow()
    }
}

/// 无边框窗口默认不能成为主窗口，也不响应 performClose，这里补回来。
final class SettingsWindow: NSWindow {
    override var canBecomeKey: Bool { true }
    override var canBecomeMain: Bool { true }

    override func performClose(_ sender: Any?) {
        guard delegate?.windowShouldClose?(self) ?? true else { return }
        close()
    }
}

/// 标题栏状态：最大化时把 □ 换成还原字形。
@MainActor
public final class WindowChromeModel: ObservableObject {
    @Published public var isZoomed = false
    public var showsCaptionButtons: Bool
    public var onCaptionAction: (WinCaptionAction) -> Void

    public init(showsCaptionButtons: Bool = true) {
        self.showsCaptionButtons = showsCaptionButtons
        self.onCaptionAction = { _ in }
    }
}
