import XCTest
@testable import DashCoreTests

fileprivate extension GeoPointTests {
    @available(*, deprecated, message: "Not actually deprecated. Marked as deprecated to allow inclusion of deprecated tests (which test deprecated functionality) without warnings")
    static nonisolated(unsafe) let __allTests__GeoPointTests = [
        ("testBearingRange", testBearingRange),
        ("testDistanceSanity", testDistanceSanity)
    ]
}

fileprivate extension K1GPacketTests {
    @available(*, deprecated, message: "Not actually deprecated. Marked as deprecated to allow inclusion of deprecated tests (which test deprecated functionality) without warnings")
    static nonisolated(unsafe) let __allTests__K1GPacketTests = [
        ("testBuildHasMagicAndPatchesSeq", testBuildHasMagicAndPatchesSeq),
        ("testParseIncoming", testParseIncoming)
    ]
}

fileprivate extension NalRtpTests {
    @available(*, deprecated, message: "Not actually deprecated. Marked as deprecated to allow inclusion of deprecated tests (which test deprecated functionality) without warnings")
    static nonisolated(unsafe) let __allTests__NalRtpTests = [
        ("testRtpSingleNalEmitsOnePacket", testRtpSingleNalEmitsOnePacket),
        ("testSplitAnnexB", testSplitAnnexB),
        ("testSpsRewrite", testSpsRewrite)
    ]
}
@available(*, deprecated, message: "Not actually deprecated. Marked as deprecated to allow inclusion of deprecated tests (which test deprecated functionality) without warnings")
func __DashCoreTests__allTests() -> [XCTestCaseEntry] {
    return [
        testCase(GeoPointTests.__allTests__GeoPointTests),
        testCase(K1GPacketTests.__allTests__K1GPacketTests),
        testCase(NalRtpTests.__allTests__NalRtpTests)
    ]
}