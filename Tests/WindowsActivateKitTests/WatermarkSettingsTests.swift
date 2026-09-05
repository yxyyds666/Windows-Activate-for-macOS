import XCTest
@testable import WindowsActivateKit

final class WatermarkSettingsTests: XCTestCase {
    func testDefaultsMatchWindowsWatermark() {
        let settings = WatermarkSettings()
        XCTAssertTrue(settings.isEnabled)
        XCTAssertEqual(settings.preset, .activateWindows)
        XCTAssertEqual(settings.corner, .bottomTrailing)
        XCTAssertEqual(settings.overlayLevel, .aboveEverything)
        XCTAssertTrue(settings.showsOnAllDisplays)
        XCTAssertTrue(settings.avoidsDockAndMenuBar)
    }

    func testSanitizedClampsOutOfRangeValues() {
        var settings = WatermarkSettings()
        settings.opacity = 4
        settings.fontScale = 0.01
        settings.horizontalMargin = -30
        settings.verticalMargin = 9_000

        let sanitized = settings.sanitized()
        XCTAssertEqual(sanitized.opacity, WatermarkSettings.opacityRange.upperBound)
        XCTAssertEqual(sanitized.fontScale, WatermarkSettings.fontScaleRange.lowerBound)
        XCTAssertEqual(sanitized.horizontalMargin, WatermarkSettings.marginRange.lowerBound)
        XCTAssertEqual(sanitized.verticalMargin, WatermarkSettings.marginRange.upperBound)
    }

    /// sanitized() 只夹取数值，不再悄悄把 preset 改回预设：
    /// 否则界面上显示“自定义文案”，磁盘里已经变成 Windows 11 / 10，重启后用户的选择就丢了。
    func testSanitizedKeepsCustomPresetWhenTextIsEmpty() {
        var settings = WatermarkSettings()
        settings.preset = .custom
        XCTAssertEqual(settings.sanitized().preset, .custom)
    }

    /// 自定义文案两栏都空着时，显示上回落到预设文案，不会出现一块空白水印。
    func testEmptyCustomTextFallsBackToPresetWording() {
        var settings = WatermarkSettings()
        settings.preset = .custom
        let text = settings.resolvedText(preferredLanguages: ["zh-Hans-CN"])
        XCTAssertEqual(text.title, "激活 Windows")
        XCTAssertEqual(text.subtitle, "转到“设置”以激活 Windows。")
    }

    func testSanitizedCapsOverlongCustomText() {
        var settings = WatermarkSettings()
        settings.customTitle = String(repeating: "标", count: 500)
        settings.customSubtitle = String(repeating: "文", count: 2_000)

        let sanitized = settings.sanitized()
        XCTAssertEqual(sanitized.customTitle.count, WatermarkSettings.maxCustomTitleLength)
        XCTAssertEqual(sanitized.customSubtitle.count, WatermarkSettings.maxCustomSubtitleLength)
    }

    func testCodableRoundTrip() throws {
        var settings = WatermarkSettings()
        settings.preset = .notGenuine
        settings.language = .english
        settings.opacity = 0.4
        settings.corner = .topLeading

        let data = try JSONEncoder().encode(settings)
        let decoded = try JSONDecoder().decode(WatermarkSettings.self, from: data)
        XCTAssertEqual(decoded, settings)
    }

    func testDecodingUsesDefaultsForMissingKeys() throws {
        let json = Data(#"{"opacity":0.5}"#.utf8)
        let decoded = try JSONDecoder().decode(WatermarkSettings.self, from: json)
        XCTAssertEqual(decoded.opacity, 0.5)
        XCTAssertEqual(decoded.preset, WatermarkSettings().preset)
        XCTAssertEqual(decoded.verticalMargin, WatermarkSettings().verticalMargin)
    }

    func testPresetTextMatchesWindowsWording() {
        let chinese = WatermarkPreset.activateWindows.text(language: .simplifiedChinese)
        XCTAssertEqual(chinese.title, "激活 Windows")
        XCTAssertEqual(chinese.subtitle, "转到“设置”以激活 Windows。")

        let english = WatermarkPreset.activateWindows.text(language: .english)
        XCTAssertEqual(english.title, "Activate Windows")
        XCTAssertEqual(english.subtitle, "Go to Settings to activate Windows.")

        let windows7 = WatermarkPreset.notGenuine.text(language: .simplifiedChinese)
        XCTAssertEqual(windows7.title, "Windows 7")
        XCTAssertTrue(windows7.subtitle.contains("不是正版"))
    }

    func testResolvedTextFollowsLanguageSetting() {
        var settings = WatermarkSettings()
        settings.language = .system
        XCTAssertEqual(settings.resolvedText(preferredLanguages: ["zh-Hans-CN"]).title, "激活 Windows")
        XCTAssertEqual(settings.resolvedText(preferredLanguages: ["en-US"]).title, "Activate Windows")

        settings.language = .english
        XCTAssertEqual(settings.resolvedText(preferredLanguages: ["zh-Hans-CN"]).title, "Activate Windows")
    }

    func testResolvedTextUsesCustomStrings() {
        var settings = WatermarkSettings()
        settings.preset = .custom
        settings.customTitle = "激活 macOS"
        settings.customSubtitle = "去“系统设置”里激活。"

        let text = settings.resolvedText(preferredLanguages: ["zh-Hans-CN"])
        XCTAssertEqual(text.title, "激活 macOS")
        XCTAssertEqual(text.subtitle, "去“系统设置”里激活。")
    }
}
