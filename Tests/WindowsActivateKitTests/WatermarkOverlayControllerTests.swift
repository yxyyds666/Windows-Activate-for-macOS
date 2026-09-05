import AppKit
import XCTest
@testable import WindowsActivateKit

/// 覆盖层对激活状态的反应：真的创建、真的收走 NSWindow。
@MainActor
final class WatermarkOverlayControllerTests: XCTestCase {
    override func setUp() {
        super.setUp()
        _ = NSApplication.shared
    }

    func testOverlayAppearsOnEveryScreenAndDisappearsAfterActivation() {
        let controller = WatermarkOverlayController()
        var settings = WatermarkSettings()

        controller.apply(settings)
        XCTAssertEqual(controller.overlayCount, NSScreen.screens.count)

        settings.activation = ActivationState(isActivated: true, productKey: "AAAAA", activatedAt: Date())
        controller.apply(settings)
        XCTAssertEqual(controller.overlayCount, 0, "激活之后不应再有水印窗口")

        settings.activation = ActivationState()
        controller.apply(settings)
        XCTAssertEqual(controller.overlayCount, NSScreen.screens.count, "取消激活后水印要回来")
    }

    func testDisablingWatermarkRemovesOverlays() {
        let controller = WatermarkOverlayController()
        var settings = WatermarkSettings()
        controller.apply(settings)

        settings.isEnabled = false
        controller.apply(settings)
        XCTAssertEqual(controller.overlayCount, 0)
    }

    func testSingleDisplayModeUsesOneOverlay() {
        let controller = WatermarkOverlayController()
        var settings = WatermarkSettings()
        settings.showsOnAllDisplays = false
        controller.apply(settings)

        XCTAssertEqual(controller.overlayCount, min(1, NSScreen.screens.count))
    }

    /// 设置窗口里换主题、在密钥框里敲字都会走到 apply，
    /// 和水印无关的改动不该把每块屏幕上的窗口重排一遍。
    func testUnchangedSettingsSkipRelayout() {
        let controller = WatermarkOverlayController()
        var settings = WatermarkSettings()

        controller.apply(settings)
        XCTAssertEqual(controller.refreshCount, 1, "第一次应用必须真的贴上去")

        controller.apply(settings)
        controller.apply(settings)
        XCTAssertEqual(controller.refreshCount, 1, "值没变就不该重排")

        settings.theme = .dark
        controller.apply(settings)
        XCTAssertEqual(controller.refreshCount, 1, "只影响设置窗口的字段也不该重排")

        settings.opacity = 0.3
        controller.apply(settings)
        XCTAssertEqual(controller.refreshCount, 2, "水印相关的改动要重排")
    }
}
