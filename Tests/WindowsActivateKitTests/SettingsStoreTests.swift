import XCTest
@testable import WindowsActivateKit

@MainActor
final class SettingsStoreTests: XCTestCase {
    private var defaults: UserDefaults!
    private let suite = "com.windowsactivate.tests"

    override func setUp() {
        super.setUp()
        UserDefaults().removePersistentDomain(forName: suite)
        defaults = UserDefaults(suiteName: suite)
    }

    override func tearDown() {
        UserDefaults().removePersistentDomain(forName: suite)
        defaults = nil
        super.tearDown()
    }

    func testChangesArePersistedAndReloaded() {
        let store = SettingsStore(defaults: defaults, storageKey: "settings")
        store.settings.opacity = 0.33
        store.settings.corner = .topTrailing

        let reloaded = SettingsStore(defaults: defaults, storageKey: "settings")
        XCTAssertEqual(reloaded.settings.opacity, 0.33)
        XCTAssertEqual(reloaded.settings.corner, .topTrailing)
    }

    func testPersistedValuesAreSanitized() {
        let store = SettingsStore(defaults: defaults, storageKey: "settings")
        store.settings.fontScale = 99

        let reloaded = SettingsStore(defaults: defaults, storageKey: "settings")
        XCTAssertEqual(reloaded.settings.fontScale, WatermarkSettings.fontScaleRange.upperBound)
    }

    func testSelectingCustomPresetPrefillsCurrentText() {
        let store = SettingsStore(defaults: defaults, storageKey: "settings")
        store.settings.language = .english
        store.selectPreset(.custom)

        XCTAssertEqual(store.settings.preset, .custom)
        XCTAssertEqual(store.settings.customTitle, "Activate Windows")
        XCTAssertEqual(store.settings.customSubtitle, "Go to Settings to activate Windows.")
    }

    func testSelectingCustomPresetKeepsUserEditedText() {
        let store = SettingsStore(defaults: defaults, storageKey: "settings")
        store.settings.customTitle = "我的文案"
        store.settings.customSubtitle = "副标题"
        store.selectPreset(.custom)

        XCTAssertEqual(store.settings.customTitle, "我的文案")
        XCTAssertEqual(store.settings.customSubtitle, "副标题")
    }

    func testResetRestoresDefaults() {
        let store = SettingsStore(defaults: defaults, storageKey: "settings")
        store.settings.isEnabled = false
        store.settings.opacity = 0.2
        store.reset()

        XCTAssertEqual(store.settings, WatermarkSettings())
    }
}
