import SwiftUI

struct GeneralPage: View {
    @ObservedObject var store: SettingsStore

    @State private var launchAtLogin = false
    @State private var launchMessage: String?

    var body: some View {
        VStack(spacing: 4) {
            WinSettingsCard(
                systemImage: "eye",
                title: "显示桌面水印",
                subtitle: "关掉就立刻从所有屏幕上收走水印"
            ) {
                Toggle("显示桌面水印", isOn: $store.settings.isEnabled)
                    .toggleStyle(WinToggleStyle())
            }

            WinSettingsCard(
                systemImage: "power",
                title: "登录时自动启动",
                subtitle: LaunchAtLogin.isAvailable ? "开机后自动把水印贴回桌面" : "命令行运行时不可用，需要先打包成 .app"
            ) {
                Toggle("登录时自动启动", isOn: launchBinding)
                    .toggleStyle(WinToggleStyle())
                    .disabled(!LaunchAtLogin.isAvailable)
            }

            if let launchMessage {
                Text(launchMessage)
                    .font(WinText.caption)
                    .foregroundStyle(WinColor.textSecondary)
                    .padding(.horizontal, 4)
                    .padding(.top, 2)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }

            WinSectionHeader("显示方式")

            WinSettingsCard(
                systemImage: "square.3.layers.3d",
                title: "显示层级",
                subtitle: store.settings.overlayLevel.detail
            ) {
                WinComboBox(
                    selection: $store.settings.overlayLevel,
                    options: OverlayLevel.allCases.map { .init($0, $0.displayName) },
                    width: 200
                )
            }

            WinSettingsCard(
                systemImage: "display.2",
                title: "在所有显示器上显示",
                subtitle: "关掉后只在主显示器显示"
            ) {
                Toggle("在所有显示器上显示", isOn: $store.settings.showsOnAllDisplays)
                    .toggleStyle(WinToggleStyle())
            }

            WinSectionHeader("设置界面")

            WinSettingsCard(
                systemImage: "paintpalette",
                title: "界面主题",
                subtitle: "只影响这个设置窗口"
            ) {
                WinComboBox(
                    selection: $store.settings.theme,
                    options: InterfaceTheme.allCases.map { .init($0, $0.displayName) },
                    width: 150
                )
            }
        }
        .onAppear { launchAtLogin = LaunchAtLogin.isEnabled }
    }

    private var launchBinding: Binding<Bool> {
        Binding(
            get: { launchAtLogin },
            set: { newValue in
                do {
                    try LaunchAtLogin.set(newValue)
                    launchMessage = nil
                } catch {
                    launchMessage = error.localizedDescription
                }
                launchAtLogin = LaunchAtLogin.isEnabled
            }
        )
    }
}
