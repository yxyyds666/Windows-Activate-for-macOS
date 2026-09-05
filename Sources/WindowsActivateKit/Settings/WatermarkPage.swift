import SwiftUI

struct WatermarkPage: View {
    @ObservedObject var store: SettingsStore

    var body: some View {
        VStack(spacing: 4) {
            WatermarkPreviewCard(settings: store.settings)
                .padding(.bottom, 10)

            WinSettingsCard(
                systemImage: "text.quote",
                title: "文案预设",
                subtitle: "逐字照抄对应版本 Windows 的原文"
            ) {
                WinComboBox(
                    selection: presetBinding,
                    options: WatermarkPreset.allCases.map { .init($0, $0.displayName) },
                    width: 170
                )
            }

            WinSettingsCard(
                systemImage: "globe",
                title: "文案语言",
                subtitle: "自定义文案时此项不生效"
            ) {
                WinComboBox(
                    selection: $store.settings.language,
                    options: WatermarkLanguage.allCases.map { .init($0, $0.displayName) },
                    width: 150
                )
            }
            .disabled(store.settings.preset == .custom)

            if store.settings.preset == .custom {
                WinSettingsCard(systemImage: "textformat", title: "标题", placement: .below) {
                    WinTextBox(placeholder: "激活 Windows", text: $store.settings.customTitle)
                }

                WinSettingsCard(
                    systemImage: "text.alignleft",
                    title: "正文",
                    subtitle: "可以换行，会跟标题一起右对齐",
                    placement: .below
                ) {
                    WinTextArea(text: $store.settings.customSubtitle, height: 68)
                }
            }

            WinSectionHeader("外观")

            WinSettingsCard(systemImage: "circle.lefthalf.filled", title: "不透明度", placement: .below) {
                WinSlider(
                    value: $store.settings.opacity,
                    in: WatermarkSettings.opacityRange,
                    step: 0.01
                ) { "\(Int(($0 * 100).rounded()))%" }
            }

            WinSettingsCard(systemImage: "textformat.size", title: "文字大小", placement: .below) {
                WinSlider(
                    value: $store.settings.fontScale,
                    in: WatermarkSettings.fontScaleRange,
                    step: 0.05
                ) { "\(Int(($0 * 100).rounded()))%" }
            }

            WinSettingsCard(
                systemImage: "square.filled.on.square",
                title: "文字阴影",
                subtitle: "Windows 原版没有阴影，浅色壁纸上开着更容易看清"
            ) {
                Toggle("文字阴影", isOn: $store.settings.showsShadow)
                    .toggleStyle(WinToggleStyle())
            }
        }
    }

    private var presetBinding: Binding<WatermarkPreset> {
        Binding(
            get: { store.settings.preset },
            set: { store.selectPreset($0) }
        )
    }
}
