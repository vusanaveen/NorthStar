import Foundation

/// Annex-B / AVCC helpers for bridging MediaCodec-style and VideoToolbox-style H.264.
public enum NalUtils {
    /// Split Annex-B by 0x000001 / 0x00000001 start codes into raw NALs (no start code).
    public static func splitAnnexB(_ data: Data) -> [Data] {
        let b = [UInt8](data)
        var nals: [Data] = []
        var i = 0
        var start = -1
        while i + 3 <= b.count {
            let is3 = b[i] == 0 && b[i + 1] == 0 && b[i + 2] == 1
            let is4 = i + 4 <= b.count && b[i] == 0 && b[i + 1] == 0 && b[i + 2] == 0 && b[i + 3] == 1
            if is4 || is3 {
                let sc = is4 ? 4 : 3
                if start >= 0 {
                    nals.append(Data(b[start..<i]))
                }
                i += sc
                start = i
                continue
            }
            i += 1
        }
        if start >= 0 && start < b.count {
            nals.append(Data(b[start..<b.count]))
        }
        return nals.filter { !$0.isEmpty }
    }

    /// Convert length-prefixed AVCC access unit to raw NAL list.
    public static func splitAVCC(_ data: Data) -> [Data] {
        let b = [UInt8](data)
        var nals: [Data] = []
        var i = 0
        while i + 4 <= b.count {
            let len = (Int(b[i]) << 24) | (Int(b[i + 1]) << 16) | (Int(b[i + 2]) << 8) | Int(b[i + 3])
            i += 4
            guard len > 0, i + len <= b.count else { break }
            nals.append(Data(b[i..<(i + len)]))
            i += len
        }
        return nals
    }

    /// Dash-critical: rewrite SPS constraint byte at index 2 to 0x00 when present
    /// (matches Android `NalProcessor` behaviour for Tripper whitelist).
    public static func rewriteSpsConstraintIfNeeded(_ nal: Data) -> Data {
        guard nal.count > 3 else { return nal }
        let nalType = nal[0] & 0x1F
        guard nalType == 7 else { return nal } // SPS
        var out = [UInt8](nal)
        out[2] = 0x00
        return Data(out)
    }
}
