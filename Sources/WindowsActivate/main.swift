import AppKit
import WindowsActivateKit

// 先把水印贴到桌面上；菜单栏图标与设置窗口在后续步骤接入。
MainActor.assumeIsolated {
    let app = NSApplication.shared
    app.setActivationPolicy(.accessory)

    let store = SettingsStore()
    let overlay = WatermarkOverlayController()
    overlay.apply(store.settings)

    app.run()
}
