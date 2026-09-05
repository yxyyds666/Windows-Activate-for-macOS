import CoreGraphics

/// 水印窗口的位置计算。抽成纯函数，方便单元测试四个角与边距的行为。
public enum WatermarkGeometry {
    /// - Parameters:
    ///   - contentSize: 水印内容的理想尺寸。
    ///   - anchor: 锚定区域（整块屏幕或去掉程序坞、菜单栏后的可见区域）。
    ///   - corner: 贴靠的角。
    /// - Returns: AppKit 坐标系（原点在左下角）中的窗口位置。
    public static func frame(
        contentSize: CGSize,
        anchor: CGRect,
        corner: WatermarkCorner,
        horizontalMargin: CGFloat,
        verticalMargin: CGFloat
    ) -> CGRect {
        let width = min(contentSize.width.rounded(.up), anchor.width)
        let height = min(contentSize.height.rounded(.up), anchor.height)

        let rawX = corner.isTrailing
            ? anchor.maxX - horizontalMargin - width
            : anchor.minX + horizontalMargin
        let rawY = corner.isBottom
            ? anchor.minY + verticalMargin
            : anchor.maxY - verticalMargin - height

        let x = rawX.clamped(to: anchor.minX...max(anchor.minX, anchor.maxX - width))
        let y = rawY.clamped(to: anchor.minY...max(anchor.minY, anchor.maxY - height))

        return CGRect(x: x.rounded(), y: y.rounded(), width: width, height: height)
    }
}
