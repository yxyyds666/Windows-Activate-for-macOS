import AppKit
import XCTest
@testable import WindowsActivateKit

/// 设置窗口的外观契约：不要 macOS 的红绿灯，关闭动作要走自绘的标题栏按钮。
@MainActor
final class SettingsWindowTests: XCTestCase {
    private let suite = "com.windowsactivate.tests.window"

    private func makeStore() -> SettingsStore {
        UserDefaults().removePersistentDomain(forName: suite)
        return SettingsStore(defaults: UserDefaults(suiteName: suite)!, storageKey: "settings")
    }

    override func setUp() {
        super.setUp()
        _ = NSApplication.shared
    }

    func testWindowIsBorderlessWithoutTrafficLights() {
        let controller = SettingsWindowController(store: makeStore())
        let window = controller.window

        XCTAssertTrue(window.styleMask.contains(.borderless))
        XCTAssertFalse(window.styleMask.contains(.titled))
        XCTAssertNil(window.standardWindowButton(.closeButton))
        XCTAssertNil(window.standardWindowButton(.miniaturizeButton))
        XCTAssertNil(window.standardWindowButton(.zoomButton))
    }

    func testBorderlessWindowStillAcceptsKeyboardInput() {
        let controller = SettingsWindowController(store: makeStore())
        XCTAssertTrue(controller.window.canBecomeKey)
        XCTAssertTrue(controller.window.canBecomeMain)
    }

    func testWindowIsTransparentForMicaBackground() {
        let controller = SettingsWindowController(store: makeStore())
        XCTAssertFalse(controller.window.isOpaque)
        XCTAssertEqual(controller.window.backgroundColor, .clear)
        XCTAssertTrue(controller.window.hasShadow)
        XCTAssertEqual(controller.window.minSize, NSSize(width: 720, height: 520))
    }

    /// 无边框窗口默认会忽略 performClose，这里确认重写生效并回调了关闭处理。
    func testClosingWindowNotifiesOwner() {
        var closed = false
        let controller = SettingsWindowController(store: makeStore()) { closed = true }
        controller.window.performClose(nil)
        XCTAssertTrue(closed)
        XCTAssertFalse(controller.window.isVisible)
    }

    func testThemeSettingDrivesWindowAppearance() {
        let store = makeStore()
        let controller = SettingsWindowController(store: store)

        store.settings.theme = .dark
        XCTAssertEqual(controller.window.appearance?.name, .darkAqua)

        store.settings.theme = .light
        XCTAssertEqual(controller.window.appearance?.name, .aqua)

        store.settings.theme = .system
        XCTAssertNil(controller.window.appearance)
    }
}
