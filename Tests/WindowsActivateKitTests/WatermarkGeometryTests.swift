import XCTest
@testable import WindowsActivateKit

final class WatermarkGeometryTests: XCTestCase {
    private let screen = CGRect(x: 0, y: 0, width: 1440, height: 900)
    private let content = CGSize(width: 300, height: 80)

    func testBottomTrailingKeepsMarginsFromTheCorner() {
        let frame = WatermarkGeometry.frame(
            contentSize: content,
            anchor: screen,
            corner: .bottomTrailing,
            horizontalMargin: 26,
            verticalMargin: 22
        )
        // AppKit 坐标系原点在左下角。
        XCTAssertEqual(frame.maxX, screen.maxX - 26)
        XCTAssertEqual(frame.minY, screen.minY + 22)
    }

    func testTopLeadingAnchorsToTheOtherCorner() {
        let frame = WatermarkGeometry.frame(
            contentSize: content,
            anchor: screen,
            corner: .topLeading,
            horizontalMargin: 40,
            verticalMargin: 30
        )
        XCTAssertEqual(frame.minX, screen.minX + 40)
        XCTAssertEqual(frame.maxY, screen.maxY - 30)
    }

    func testRespectsAnchorOffsetOfSecondDisplay()  {
        let secondary = CGRect(x: 1440, y: -200, width: 1920, height: 1080)
        let frame = WatermarkGeometry.frame(
            contentSize: content,
            anchor: secondary,
            corner: .bottomTrailing,
            horizontalMargin: 10,
            verticalMargin: 10
        )
        XCTAssertEqual(frame.maxX, secondary.maxX - 10)
        XCTAssertEqual(frame.minY, secondary.minY + 10)
    }

    func testOversizedContentStaysInsideAnchor() {
        let tiny = CGRect(x: 0, y: 0, width: 200, height: 60)
        let frame = WatermarkGeometry.frame(
            contentSize: content,
            anchor: tiny,
            corner: .bottomTrailing,
            horizontalMargin: 26,
            verticalMargin: 22
        )
        XCTAssertEqual(frame.width, tiny.width)
        XCTAssertEqual(frame.height, tiny.height)
        XCTAssertEqual(frame.minX, tiny.minX)
        XCTAssertEqual(frame.minY, tiny.minY)
    }

    func testMarginLargerThanScreenIsClamped() {
        let frame = WatermarkGeometry.frame(
            contentSize: content,
            anchor: screen,
            corner: .bottomTrailing,
            horizontalMargin: 5_000,
            verticalMargin: 5_000
        )
        XCTAssertGreaterThanOrEqual(frame.minX, screen.minX)
        XCTAssertLessThanOrEqual(frame.maxY, screen.maxY)
    }
}
