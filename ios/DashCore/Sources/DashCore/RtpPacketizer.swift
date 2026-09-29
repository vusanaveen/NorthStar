import Foundation

/// RFC 6184 H.264 RTP packetizer — port of Android `RtpPacketizer.kt`.
/// No STAP-A; FU-A only; marker on last packet of AU; PT 96; max payload 1380.
public final class RtpPacketizer: @unchecked Sendable {
    public static let maxPayload = 1380
    public static let payloadType = 96

    private var seq: UInt16
    private let ssrc: UInt32
    private let tsBase: UInt32
    private let onPacket: (Data) -> Void

    public init(onPacket: @escaping (Data) -> Void) {
        self.onPacket = onPacket
        self.seq = UInt16.random(in: 0...UInt16.max)
        self.ssrc = UInt32.random(in: 0...UInt32.max)
        self.tsBase = UInt32.random(in: 0...UInt32.max)
    }

    /// Packetize one NAL (no start code).
    public func packetize(nal: Data, endOfAU: Bool, wallClockMs: Int64) {
        let ts = tsBase &+ UInt32(truncatingIfNeeded: wallClockMs &* 90)
        if nal.count <= Self.maxPayload {
            emit(payload: nal, marker: endOfAU, ts: ts)
        } else {
            fuA(nal: nal, endOfAU: endOfAU, ts: ts)
        }
    }

    private func fuA(nal: Data, endOfAU: Bool, ts: UInt32) {
        let bytes = [UInt8](nal)
        guard let first = bytes.first else { return }
        let nalType = Int(first) & 0x1F
        let fuInd = UInt8((Int(first) & 0xE0) | 28)
        var offset = 1
        var isFirst = true
        while offset < bytes.count {
            let remaining = bytes.count - offset
            let chunkLen = min(Self.maxPayload - 2, remaining)
            let isLast = chunkLen >= remaining
            let fuHeader = UInt8(
                (isFirst ? 0x80 : 0) | (isLast ? 0x40 : 0) | nalType
            )
            var payload = Data(capacity: 2 + chunkLen)
            payload.append(fuInd)
            payload.append(fuHeader)
            payload.append(contentsOf: bytes[offset..<(offset + chunkLen)])
            emit(payload: payload, marker: isLast && endOfAU, ts: ts)
            offset += chunkLen
            isFirst = false
        }
    }

    private func emit(payload: Data, marker: Bool, ts: UInt32) {
        var pkt = Data(capacity: 12 + payload.count)
        pkt.append(0x80)
        pkt.append(UInt8((marker ? 0x80 : 0x00) | (Self.payloadType & 0x7F)))
        pkt.append(UInt8((seq >> 8) & 0xFF))
        pkt.append(UInt8(seq & 0xFF))
        pkt.append(UInt8((ts >> 24) & 0xFF))
        pkt.append(UInt8((ts >> 16) & 0xFF))
        pkt.append(UInt8((ts >> 8) & 0xFF))
        pkt.append(UInt8(ts & 0xFF))
        pkt.append(UInt8((ssrc >> 24) & 0xFF))
        pkt.append(UInt8((ssrc >> 16) & 0xFF))
        pkt.append(UInt8((ssrc >> 8) & 0xFF))
        pkt.append(UInt8(ssrc & 0xFF))
        pkt.append(payload)
        seq &+= 1
        onPacket(pkt)
    }
}
