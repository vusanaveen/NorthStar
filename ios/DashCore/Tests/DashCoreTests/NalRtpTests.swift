import XCTest
@testable import DashCore

final class NalRtpTests: XCTestCase {
    func testSplitAnnexB() {
        let data = Data([0, 0, 0, 1, 0x67, 0x42, 0x00, 0x29, 0, 0, 1, 0x68, 0xCE])
        let nals = NalUtils.splitAnnexB(data)
        XCTAssertEqual(nals.count, 2)
        XCTAssertEqual(nals[0].first, 0x67)
        XCTAssertEqual(nals[1].first, 0x68)
    }

    func testSpsRewrite() {
        let sps = Data([0x67, 0x42, 0xC0, 0x29])
        let out = NalUtils.rewriteSpsConstraintIfNeeded(sps)
        XCTAssertEqual([UInt8](out), [0x67, 0x42, 0x00, 0x29])
    }

    func testRtpSingleNalEmitsOnePacket() {
        var packets: [Data] = []
        let rtp = RtpPacketizer { packets.append($0) }
        rtp.packetize(nal: Data([0x65, 0x00, 0x01]), endOfAU: true, wallClockMs: 1000)
        XCTAssertEqual(packets.count, 1)
        XCTAssertEqual(packets[0].count, 12 + 3)
        // marker bit set
        XCTAssertEqual(packets[0][1] & 0x80, 0x80)
    }
}
