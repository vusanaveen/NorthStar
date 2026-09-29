import XCTest
@testable import DashCore

final class K1GPacketTests: XCTestCase {
    func testBuildHasMagicAndPatchesSeq() {
        let tlv = Tlv(type: 0x06, sub: 0x06, bytes: [0x01])
        let pkt = K1GPacket.build(tlv)
        let bytes = [UInt8](pkt)
        XCTAssertGreaterThanOrEqual(bytes.count, 18)
        // "K1G " at fixed offset in outgoing header
        let magic = Array(bytes[12..<16])
        XCTAssertEqual(magic, [0x4B, 0x31, 0x47, 0x20])
        let patched = [UInt8](K1GPacket.patchSeq(pkt, seq: 0x2A))
        XCTAssertEqual(patched[16], 0x2A)
        let outer = (Int(patched[0]) << 8) | Int(patched[1])
        XCTAssertEqual(outer, patched.count)
    }

    func testParseIncoming() {
        // Minimal fake: outer_len, seg_count=1, 4 reserved, then one TLV 07 00 len=2 val=AB CD
        var raw: [UInt8] = [
            0x00, 0x0E, // outer len placeholder (will not be validated strictly)
            0x00, 0x01, // seg count 1
            0, 0, 0, 0, // ignored
            0x07, 0x00, 0x00, 0x02, 0xAB, 0xCD,
        ]
        raw[0] = UInt8((raw.count >> 8) & 0xFF)
        raw[1] = UInt8(raw.count & 0xFF)
        let tlvs = K1GPacket.parseIncoming(Data(raw))
        XCTAssertEqual(tlvs.count, 1)
        XCTAssertEqual(tlvs[0].type, 0x07)
        XCTAssertEqual(tlvs[0].sub, 0x00)
        XCTAssertEqual([UInt8](tlvs[0].value), [0xAB, 0xCD])
    }
}
