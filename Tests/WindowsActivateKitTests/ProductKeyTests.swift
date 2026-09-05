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

    func testCompletionOnlyDependsOnLength() {
        XCTAssertFalse(ProductKey.isComplete("abc"))
        XCTAssertTrue(ProductKey.isComplete("aaaaa-bbbbb-ccccc-ddddd-eeeee"))
    }
}
