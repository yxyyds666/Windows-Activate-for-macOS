import AppKit
import Combine
import SwiftUI

/// 设置窗口：隐藏 macOS 的红绿灯，把 Windows 的 × / □ / ─ 放进标题栏左上角。
@MainActor
public final class SettingsWindowController: NSObject, NSWindowDelegate {
    private let store: SettingsStore
    private let onClose: () -> Void
    private let window: NSWindow
    private let captionModel = CaptionModel()
    private var themeObserver: AnyCancellable?

    public init(store: SettingsStore, onClose: @escaping () -> Void = {}) {
        self.store = store
        self.onClose = onClose
        self.window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 780, height: 560),
            styleMask: [.titled, .closable, .miniaturizable, .resizable, .fullSizeContentView],
            backing: .buffered,
            defer: false
        )
        super.init()
        configure()
        themeObserver = store.$settings
            .map(\.theme)
            .removeDuplicates()
            .sink { [weak self] theme in self?.apply(theme: theme) }
    }

    public func show() {
        apply(theme: store.settings.theme)
        if !window.isVisible {
            window.center()
        }
        window.makeKeyAndOrderFront(nil)
        captionModel.isZoomed = window.isZoomed
    }

    private func configure() {
        window.title = AppInfo.displayName
        window.titleVisibility = .hidden
        window.titlebarAppearsTransparent = true
        window.isOpaque = false
        window.backgroundColor = .clear
        window.isReleasedWhenClosed = false
        window.tabbingMode = .disallowed
        window.minSize = NSSize(width: 720, height: 520)
        window.delegate = self

        // 红绿灯藏起来，位置留给 Windows 风格的标题栏按钮。
        for button: NSWindow.ButtonType in [.closeButton, .miniaturizeButton, .zoomButton] {
            window.standardWindowButton(button)?.isHidden = true
        }

        installCaptionButtons()
        installContent()
    }

    /// 按钮放在标题栏附件里：既能点，又保留系统的拖动、双击最大化和缩放边框。
    private func installCaptionButtons() {
        let accessory = NSTitlebarAccessoryViewController()
        accessory.layoutAttribute = .leading
        let host = NSHostingView(
            rootView: CaptionAccessory(model: captionModel) { [weak self] action in
                self?.perform(action)
            }
        )
        host.frame = NSRect(
            x: 0,
            y: 0,
            width: 3 * WinMetrics.captionButtonWidth,
            height: WinMetrics.captionBarHeight
        )
        accessory.view = host
        window.addTitlebarAccessoryViewController(accessory)
    }

    private func installContent() {
        let hosting = NSHostingView(rootView: SettingsView(store: store))
        hosting.safeAreaRegions = []
        window.contentView = hosting
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
        captionModel.isZoomed = window.isZoomed
    }

    public func windowDidEndLiveResize(_ notification: Notification) {
        captionModel.isZoomed = window.isZoomed
    }
}

@MainActor
private final class CaptionModel: ObservableObject {
    @Published var isZoomed = false
}

private struct CaptionAccessory: View {
    @ObservedObject var model: CaptionModel
    let action: (WinCaptionAction) -> Void

    var body: some View {
        WinCaptionButtons(isZoomed: model.isZoomed, action: action)
    }
}
