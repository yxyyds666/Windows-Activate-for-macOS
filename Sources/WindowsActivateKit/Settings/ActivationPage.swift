import SwiftUI

/// “激活”分页：照 Windows 11 设置里的激活页排布，输入任何卡密都会激活成功。
struct ActivationPage: View {
    @ObservedObject var store: SettingsStore

    @State private var keyInput = ""
    @State private var isActivating = false
    @State private var message: String?

    private var activation: ActivationState { store.settings.activation }

    var body: some View {
        VStack(spacing: 4) {
            stateCard

            if let message {
                Text(message)
                    .font(WinText.caption)
                    .foregroundStyle(WinColor.success)
                    .padding(.horizontal, 4)
                    .padding(.top, 4)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }

            if activation.isActivated {
                WinSettingsCard(
                    systemImage: "arrow.counterclockwise",
                    title: "取消激活",
                    subtitle: "把水印放回桌面右下角"
                ) {
                    Button("取消激活") {
                        store.deactivate()
                        message = nil
                        keyInput = ""
                    }
                    .buttonStyle(WinButtonStyle())
                }
            } else {
                WinSettingsCard(
                    systemImage: "key",
                    title: "输入产品密钥",
                    subtitle: "25 位密钥，格式 \(ProductKey.placeholder)",
                    placement: .below
                ) {
                    HStack(spacing: 10) {
                        WinTextBox(placeholder: ProductKey.placeholder, text: keyBinding)
                        Button(isActivating ? "正在激活…" : "激活") { activate() }
                            .buttonStyle(WinButtonStyle(.accent))
                            .disabled(keyInput.isEmpty || isActivating)
                    }
                }
            }

            WinSectionHeader("说明")

            WinSettingsCard(
                systemImage: "exclamationmark.circle",
                title: "任何密钥都会激活成功",
                subtitle: "这里不做任何校验，输什么都能过——它只负责把桌面上那块水印收起来。真正的 Windows 请通过正规渠道购买授权。"
            ) {
                EmptyView()
            }
        }
        .onAppear { message = nil }
    }

    private var stateCard: some View {
        HStack(spacing: 16) {
            WinIcon(activation.isActivated ? "checkmark.seal.fill" : "xmark.seal.fill", size: 26)
                .foregroundStyle(activation.isActivated ? WinColor.success : WinColor.danger)
                .frame(width: 30, height: 30)
            VStack(alignment: .leading, spacing: 3) {
                Text("激活状态")
                    .font(WinText.bodyStrong)
                    .foregroundStyle(WinColor.textPrimary)
                Text(activation.isActivated ? "Windows 已激活" : "Windows 未激活")
                    .font(WinText.body)
                    .foregroundStyle(WinColor.textSecondary)
                if activation.isActivated {
                    Text(detailText)
                        .font(WinText.caption)
                        .foregroundStyle(WinColor.textTertiary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            Spacer(minLength: 0)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(shape.fill(WinColor.cardBackground))
        .overlay(shape.strokeBorder(WinColor.cardStroke, lineWidth: 1))
    }

    private var detailText: String {
        var parts: [String] = []
        if !activation.productKey.isEmpty {
            parts.append("产品密钥 \(activation.productKey)")
        }
        if let time = activation.activatedAtDescription {
            parts.append("激活时间 \(time)")
        }
        return parts.joined(separator: " · ")
    }

    private var shape: RoundedRectangle {
        RoundedRectangle(cornerRadius: WinMetrics.controlCornerRadius)
    }

    private var keyBinding: Binding<String> {
        Binding(
            get: { keyInput },
            set: { keyInput = ProductKey.format($0) }
        )
    }

    private func activate() {
        let key = keyInput
        isActivating = true
        message = nil
        Task { @MainActor in
            // 装模作样地等一下，像真的在联网校验。
            try? await Task.sleep(nanoseconds: 1_100_000_000)
            store.activate(with: key)
            isActivating = false
            keyInput = ""
            message = "激活成功。Windows 已激活，水印已经收起来了。"
        }
    }
}
