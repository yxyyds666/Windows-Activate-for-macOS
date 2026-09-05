import AppKit
import Combine

/// 应用主控：菜单栏图标常驻，设置窗口按需打开，水印跟着设置实时更新。
@MainActor
public final class AppController: NSObject, NSApplicationDelegate {
    private static let hasLaunchedKey = "hasLaunchedBefore"

    private let store: SettingsStore
    private let defaults: UserDefaults
    private let overlay = WatermarkOverlayController()
    private var statusItem: StatusItemController?
    private var settingsWindow: SettingsWindowController?
    private var settingsObserver: AnyCancellable?

    public init(store: SettingsStore? = nil, defaults: UserDefaults = .standard) {
        self.store = store ?? SettingsStore(defaults: defaults)
        self.defaults = defaults
        super.init()
    }

    public func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)
        MainMenuBuilder.install()

        statusItem = StatusItemController(store: store) { [weak self] in
            self?.showSettings()
        }

        // @Published 在订阅时会立刻投递当前值，所以这一次订阅已经把水印贴上去了。
        settingsObserver = store.$settings.sink { [weak self] settings in
            self?.overlay.apply(settings)
        }

        // 第一次启动时把设置窗口打开，否则用户只看到水印，不知道去哪里关。
        if !defaults.bool(forKey: Self.hasLaunchedKey) {
            defaults.set(true, forKey: Self.hasLaunchedKey)
            showSettings()
        }
    }

    @objc public func showSettingsWindow(_ sender: Any?) {
        showSettings()
    }

    public func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        showSettings()
        return true
    }

    public func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        false
    }

    private func showSettings() {
        if settingsWindow == nil {
            settingsWindow = SettingsWindowController(store: store) { [weak self] in
                self?.settingsWindowDidClose()
            }
        }
        // 打开设置时切成普通应用，这样有菜单栏和 Dock 图标；关掉后再退回后台。
        NSApp.setActivationPolicy(.regular)
        settingsWindow?.show()
        NSApp.activate()
    }

    private func settingsWindowDidClose() {
        NSApp.setActivationPolicy(.accessory)
    }
}
