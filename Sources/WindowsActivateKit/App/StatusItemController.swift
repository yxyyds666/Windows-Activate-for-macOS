import AppKit

/// 菜单栏里的四格 Windows 图标及其菜单。
@MainActor
public final class StatusItemController: NSObject, NSMenuDelegate {
    private let statusItem: NSStatusItem
    private let store: SettingsStore
    private let openSettings: () -> Void

    public init(store: SettingsStore, openSettings: @escaping () -> Void) {
        self.store = store
        self.openSettings = openSettings
        self.statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        super.init()

        statusItem.button?.image = Self.flagImage()
        statusItem.button?.toolTip = AppInfo.displayName
        let menu = NSMenu()
        menu.delegate = self
        statusItem.menu = menu
    }

    public func menuNeedsUpdate(_ menu: NSMenu) {
        menu.removeAllItems()

        if store.settings.activation.isActivated {
            let activated = NSMenuItem(title: "已激活，水印已隐藏", action: nil, keyEquivalent: "")
            activated.isEnabled = false
            menu.addItem(activated)

            let deactivate = NSMenuItem(title: "取消激活", action: #selector(deactivate), keyEquivalent: "")
            deactivate.target = self
            menu.addItem(deactivate)
        } else {
            let toggle = NSMenuItem(title: "显示桌面水印", action: #selector(toggleWatermark), keyEquivalent: "")
            toggle.target = self
            toggle.state = store.settings.isEnabled ? .on : .off
            menu.addItem(toggle)
        }

        menu.addItem(.separator())

        let settings = NSMenuItem(title: "设置…", action: #selector(showSettings), keyEquivalent: ",")
        settings.target = self
        menu.addItem(settings)

        menu.addItem(.separator())

        let quit = NSMenuItem(title: "退出 \(AppInfo.displayName)", action: #selector(quit), keyEquivalent: "q")
        quit.target = self
        menu.addItem(quit)
    }

    @objc private func toggleWatermark() {
        store.settings.isEnabled.toggle()
    }

    @objc private func deactivate() {
        store.deactivate()
    }

    @objc private func showSettings() {
        openSettings()
    }

    @objc private func quit() {
        NSApp.terminate(nil)
    }

    /// 菜单栏用的单色 Windows 徽标。
    private static func flagImage(side: CGFloat = 15) -> NSImage {
        let image = NSImage(size: NSSize(width: side, height: side), flipped: false) { _ in
            let gap = side * 0.12
            let tile = (side - gap) / 2
            let origins: [(CGFloat, CGFloat)] = [
                (0, 0), (tile + gap, 0), (0, tile + gap), (tile + gap, tile + gap)
            ]
            NSColor.black.setFill()
            for (x, y) in origins {
                let rect = NSRect(x: x, y: y, width: tile, height: tile)
                NSBezierPath(roundedRect: rect, xRadius: side * 0.05, yRadius: side * 0.05).fill()
            }
            return true
        }
        image.isTemplate = true
        return image
    }
}
