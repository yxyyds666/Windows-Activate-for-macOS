import AppKit

/// 承载水印的透明面板：不抢焦点、不吃鼠标事件、跟随所有桌面空间。
final class WatermarkWindow: NSPanel {
    init() {
        super.init(
            contentRect: NSRect(x: 0, y: 0, width: 320, height: 90),
            styleMask: [.borderless, .nonactivatingPanel],
            backing: .buffered,
            defer: false
        )
        isOpaque = false
        backgroundColor = .clear
        hasShadow = false
        ignoresMouseEvents = true
        isMovableByWindowBackground = false
        isFloatingPanel = true
        becomesKeyOnlyIfNeeded = true
        hidesOnDeactivate = false
        isReleasedWhenClosed = false
        animationBehavior = .none
        // 跟随所有空间、不随窗口循环切换，并且允许出现在别的应用的全屏空间上。
        collectionBehavior = [.canJoinAllSpaces, .stationary, .fullScreenAuxiliary, .ignoresCycle]
        // Windows 的水印同样会被截图录到，所以保持默认的可共享状态。
        sharingType = .readOnly
    }

    override var canBecomeKey: Bool { false }
    override var canBecomeMain: Bool { false }
}
