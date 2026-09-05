import SwiftUI

struct PositionPage: View {
    @ObservedObject var store: SettingsStore

    var body: some View {
        VStack(spacing: 4) {
            WatermarkPreviewCard(settings: store.settings)
                .padding(.bottom, 10)

            WinSettingsCard(
                systemImage: "arrow.up.left.and.arrow.down.right",
                title: "贴靠位置",
                subtitle: "Windows 的水印在右下角"
            ) {
                WinComboBox(
                    selection: $store.settings.corner,
                    options: WatermarkCorner.allCases.map { .init($0, $0.displayName) },
                    width: 150
                )
            }

            WinSettingsCard(systemImage: "arrow.left.and.right", title: "水平边距", placement: .below) {
                WinSlider(
                    value: $store.settings.horizontalMargin,
                    in: WatermarkSettings.marginRange,
                    step: 1
                ) { "\(Int($0)) pt" }
            }

            WinSettingsCard(systemImage: "arrow.up.and.down", title: "垂直边距", placement: .below) {
                WinSlider(
                    value: $store.settings.verticalMargin,
                    in: WatermarkSettings.marginRange,
                    step: 1
                ) { "\(Int($0)) pt" }
            }

            WinSettingsCard(
                systemImage: "dock.rectangle",
                title: "避开程序坞与菜单栏",
                subtitle: "像 Windows 的水印避开任务栏那样，从可用区域算边距"
            ) {
                Toggle("避开程序坞与菜单栏", isOn: $store.settings.avoidsDockAndMenuBar)
                    .toggleStyle(WinToggleStyle())
            }
        }
    }
}
