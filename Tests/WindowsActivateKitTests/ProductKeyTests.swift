import XCTest
@testable import WindowsActivateKit

final class ProductKeyTests: XCTestCase {
    func testFormatsInputIntoFiveGroupsOfFive() {
        XCTAssertEqual(
            ProductKey.format("aaaaabbbbbcccccdddddeeeee"),
            "AAAAA-BBBBB-CCCCC-DDDDD-EEEEE"
        )
    }

    func testKeepsPartialInputUsable() {
        XCTAssertEqual(ProductKey.format("abc"), "ABC")
        XCTAssertEqual(ProductKey.format("abcdef"), "ABCDE-F")
        XCTAssertEqual(ProductKey.format(""), "")
    }

    func testIgnoresExistingSeparatorsAndSpaces() {
        XCTAssertEqual(
            ProductKey.format("aaaaa-bbbbb ccccc-ddddd eeeee"),
            "AAAAA-BBBBB-CCCCC-DDDDD-EEEEE"
        )
    }

    func testTruncatesBeyondTwentyFiveCharacters() {
        let formatted = ProductKey.format(String(repeating: "x", count: 40))
        XCTAssertEqual(formatted, "XXXXX-XXXXX-XXXXX-XXXXX-XXXXX")
    }

    /// 怎么输都能激活，所以中文和符号也照收，不会被吃掉。
    func testAcceptsAnyCharacters() {
        XCTAssertEqual(ProductKey.format("随便输点什么"), "随便输点什-么")
        XCTAssertFalse(ProductKey.format("!@#$%^").isEmpty)
    }

    /// 只留分段形状的掩码：磁盘上不会留下用户真正输进去的字符。
    func testMaskedKeepsShapeButNotContent() {
        XCTAssertEqual(
            ProductKey.masked("aaaaabbbbbcccccdddddeeeee"),
            "•••••-•••••-•••••-•••••-•••••"
        )
        XCTAssertEqual(ProductKey.masked("abcdef"), "•••••-•")
        XCTAssertEqual(ProductKey.masked(""), "")
    }

    func testMaskedDropsOriginalCharacters() {
        let masked = ProductKey.masked("MYREAL-LICENSE-KEY99")
        XCTAssertFalse(masked.contains("M"))
        XCTAssertFalse(masked.contains("9"))
        XCTAssertEqual(Set(masked), Set("•-"))
    }
}
