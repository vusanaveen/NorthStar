import Foundation

/// K1G TLV — mirrors Android `dash/protocol/K1GPacket.kt`.
public struct Tlv: Equatable, Sendable {
    public let type: UInt8
    public let sub: UInt8
    public let value: Data

    public init(type: UInt8, sub: UInt8, value: Data = Data()) {
        self.type = type
        self.sub = sub
        self.value = value
    }

    public init(type: Int, sub: Int, bytes: [UInt8]) {
        self.type = UInt8(type & 0xFF)
        self.sub = UInt8(sub & 0xFF)
        self.value = Data(bytes)
    }
}

/// K1G packet framing for Tripper dash (fw 11.63 / better-dash).
public enum K1GPacket {
    private static let magic: [UInt8] = [0x4B, 0x31, 0x47, 0x20] // "K1G "
    private static let fixed: [UInt8] = [
        0x00, 0x00, 0x00, 0x00,
        0x02, 0x01, 0x00, 0x05,
        0x4B, 0x31, 0x47, 0x20,
    ]

    /// Build an outgoing app→dash packet. Seq left 0; call `patchSeq` at send time.
    public static func build(_ tlvs: [Tlv]) -> Data {
        let segCount = 1 + tlvs.count
        var out = Data()
        out.append(contentsOf: [0, 0]) // outer_len placeholder
        out.append(UInt8((segCount >> 8) & 0xFF))
        out.append(UInt8(segCount & 0xFF))
        out.append(contentsOf: fixed)
        out.append(0) // seq placeholder
        for tlv in tlvs {
            out.append(tlv.type)
            out.append(tlv.sub)
            out.append(UInt8((tlv.value.count >> 8) & 0xFF))
            out.append(UInt8(tlv.value.count & 0xFF))
            out.append(tlv.value)
        }
        var bytes = [UInt8](out)
        bytes[0] = UInt8((bytes.count >> 8) & 0xFF)
        bytes[1] = UInt8(bytes.count & 0xFF)
        return Data(bytes)
    }

    public static func build(_ tlvs: Tlv...) -> Data { build(tlvs) }

    /// Patch rolling seq byte (right after "K1G ") and refresh outer_len.
    public static func patchSeq(_ pkt: Data, seq: Int) -> Data {
        var out = [UInt8](pkt)
        if let k = indexOfMagic(out), k + 4 < out.count {
            out[k + 4] = UInt8(seq & 0xFF)
        }
        out[0] = UInt8((out.count >> 8) & 0xFF)
        out[1] = UInt8(out.count & 0xFF)
        return Data(out)
    }

    /// Parse dash→app packet. TLV segments start at offset 8.
    public static func parseIncoming(_ data: Data) -> [Tlv] {
        let bytes = [UInt8](data)
        guard bytes.count >= 8 else { return [] }
        let segCount = (Int(bytes[2]) << 8) | Int(bytes[3])
        var tlvs: [Tlv] = []
        var i = 8
        var n = 0
        while n < segCount && i + 4 <= bytes.count {
            let type = bytes[i]
            let sub = bytes[i + 1]
            let len = (Int(bytes[i + 2]) << 8) | Int(bytes[i + 3])
            i += 4
            let end = min(i + len, bytes.count)
            tlvs.append(Tlv(type: type, sub: sub, value: Data(bytes[i..<end])))
            i = end
            n += 1
        }
        return tlvs
    }

    private static func indexOfMagic(_ b: [UInt8]) -> Int? {
        guard b.count >= 4 else { return nil }
        for i in 0...(b.count - 4) {
            if b[i] == magic[0], b[i + 1] == magic[1],
               b[i + 2] == magic[2], b[i + 3] == magic[3] {
                return i
            }
        }
        return nil
    }
}

public extension String {
    /// Hex string → bytes (`"4B31"` or `"4B 31"`).
    func hexToData() -> Data {
        let clean = replacingOccurrences(of: " ", with: "")
        var data = Data()
        var idx = clean.startIndex
        while idx < clean.endIndex {
            let next = clean.index(idx, offsetBy: 2, limitedBy: clean.endIndex) ?? clean.endIndex
            if let byte = UInt8(clean[idx..<next], radix: 16) {
                data.append(byte)
            }
            idx = next
        }
        return data
    }
}
