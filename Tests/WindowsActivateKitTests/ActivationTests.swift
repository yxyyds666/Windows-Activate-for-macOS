import XCTest
@testable import WindowsActivateKit

@MainActor
final class ActivationTests: XCTestCase {
    private var defaults: UserDefaults!
    private let suite = "com.windowsactivate.tests.activation"

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

    private func makeStore() -> SettingsStore {
        SettingsStore(defaults: defaults, storageKey: "settings")
    }

    func testWatermarkVisibleByDefault() {
        XCTAssertTrue(WatermarkSettings().showsWatermark)
        XCTAssertFalse(WatermarkSettings().activation.isActivated)
    }

    func testActivatingHidesWatermark() {
        let store = makeStore()
        store.activate(with: "aaaaabbbbbcccccdddddeeeee")

        XCTAssertTrue(store.settings.activation.isActivated)
        XCTAssertFalse(store.settings.showsWatermark)
        XCTAssertNotNil(store.settings.activation.activatedAt)
    }

    /// 输入框长得就是 Windows 的正版密钥框，用户可能真的贴进一把有效密钥，
    /// 所以只记掩码，原文不写进 UserDefaults。
    func testProductKeyIsNeverStoredInClearText() {
        let store = makeStore()
        store.activate(with: "MYREAL-LICENSE-KEY42")

        let stored = store.settings.activation.productKey
        // 去掉连字符后是 18 个字符，分成 5+5+5+3。
        XCTAssertEqual(stored, "•••••-•••••-•••••-•••")
        XCTAssertFalse(stored.contains("MYREAL"))
        XCTAssertFalse(stored.contains("42"))

        let raw = defaults.data(forKey: "settings").flatMap { String(data: $0, encoding: .utf8) } ?? ""
        XCTAssertFalse(raw.isEmpty, "设置应当已经落盘")
        XCTAssertFalse(raw.uppercased().contains("MYREAL"), "落盘内容里不应出现密钥原文")
    }

    /// 无论输入什么都能激活，这是这个项目故意做成的行为。
    func testAnyKeyActivates() {
        for key in ["1", "随便", "!!!", "not a real key at all"] {
            let store = makeStore()
            store.activate(with: key)
            XCTAssertTrue(store.settings.activation.isActivated, "密钥 \(key) 应当也能激活")
        }
    }

    func testDeactivatingBringsWatermarkBack() {
        let store = makeStore()
        store.activate(with: "abcde")
        store.deactivate()

        XCTAssertFalse(store.settings.activation.isActivated)
        XCTAssertTrue(store.settings.showsWatermark)
        XCTAssertEqual(store.settings.activation.productKey, "")
        XCTAssertNil(store.settings.activation.activatedAt)
    }

    func testActivationSurvivesRelaunch() {
        let store = makeStore()
        store.activate(with: "aaaaabbbbb")

        let reloaded = makeStore()
        XCTAssertTrue(reloaded.settings.activation.isActivated)
        XCTAssertEqual(reloaded.settings.activation.productKey, "•••••-•••••")
        XCTAssertFalse(reloaded.settings.showsWatermark)
    }

    func testDisabledWatermarkStaysHiddenRegardlessOfActivation() {
        var settings = WatermarkSettings()
        settings.isEnabled = false
        XCTAssertFalse(settings.showsWatermark)
    }

    /// 老版本存下来的配置里没有 activation 字段，解码后应当是“未激活”。
    func testDecodingLegacySettingsDefaultsToNotActivated() throws {
        let json = Data(#"{"isEnabled":true,"opacity":0.62}"#.utf8)
        let decoded = try JSONDecoder().decode(WatermarkSettings.self, from: json)
        XCTAssertFalse(decoded.activation.isActivated)
        XCTAssertTrue(decoded.showsWatermark)
    }
}
