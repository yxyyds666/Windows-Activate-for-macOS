import SwiftUI

/// 设置窗口的根视图：顶部是 Windows 式标题栏，左侧导航，右侧内容区。
public struct SettingsView: View {
    @ObservedObject private var store: SettingsStore
    @ObservedObject private var chrome: WindowChromeModel

    @State private var selection: String
    @Environment(\.winUIRendersOffscreen) private var rendersOffscreen

    public init(
        store: SettingsStore,
        chrome: WindowChromeModel,
        initialPage: SettingsPage = .general
    ) {
        self.store = store
        self.chrome = chrome
        self._selection = State(initialValue: initialPage.id)
    }

    public var body: some View {
        ZStack {
            MicaBackdrop()
            VStack(spacing: 0) {
                captionBar
                HStack(alignment: .top, spacing: 0) {
                    WinNavigationPane(items: SettingsPage.navigationItems, selection: $selection)
                    contentArea
                }
            }
        }
        .frame(minWidth: 720, minHeight: 520)
    }

    /// 标题栏：左侧是徽标与标题（同时是拖动区，双击最大化），
    /// 最小化 / 最大化 / 关闭按 Windows 的排布放在右上角。
    private var captionBar: some View {
        HStack(spacing: 0) {
            ZStack(alignment: .leading) {
                if !rendersOffscreen {
                    WindowDragArea()
                }
                HStack(spacing: 8) {
                    WinFlagBadge(size: 12)
                    Text(AppInfo.displayName)
                        .font(WinText.caption)
                        .foregroundStyle(WinColor.textPrimary)
                }
                .padding(.leading, 12)
                .allowsHitTesting(false)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            if chrome.showsCaptionButtons {
                WinCaptionButtons(isZoomed: chrome.isZoomed) { chrome.onCaptionAction($0) }
            }
        }
        .frame(height: WinMetrics.captionBarHeight)
    }

    private var contentArea: some View {
        scroller
            .background(WinColor.layerFill)
            .clipShape(UnevenRoundedRectangle(cornerRadii: .init(topLeading: WinMetrics.overlayCornerRadius)))
            .overlay(
                UnevenRoundedRectangle(cornerRadii: .init(topLeading: WinMetrics.overlayCornerRadius))
                    .strokeBorder(WinColor.cardStroke, lineWidth: 1)
            )
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    /// ImageRenderer 不会渲染 ScrollView 里的内容，所以生成截图时换成普通竖排。
    @ViewBuilder
    private var scroller: some View {
        if rendersOffscreen {
            pageContent
                .frame(maxHeight: .infinity, alignment: .top)
        } else {
            ScrollView { pageContent }
        }
    }

    private var pageContent: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(currentPage.title)
                .font(WinText.subtitle)
                .foregroundStyle(WinColor.textPrimary)
                .padding(.bottom, 10)
            page
        }
        .padding(.horizontal, 26)
        .padding(.top, 20)
        .padding(.bottom, 26)
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var currentPage: SettingsPage {
        SettingsPage(rawValue: selection) ?? .general
    }

    @ViewBuilder
    private var page: some View {
        switch currentPage {
        case .general: GeneralPage(store: store)
        case .activation: ActivationPage(store: store)
        case .watermark: WatermarkPage(store: store)
        case .position: PositionPage(store: store)
        case .about: AboutPage(store: store)
        }
    }
}
