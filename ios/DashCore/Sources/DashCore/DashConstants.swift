import Foundation

/// Wire constants matching Android `DashSocket` / `DashEncoder` / `DashConfig`.
public enum DashConstants {
    public static let dashIP = "192.168.1.1"
    public static let broadcastIP = "192.168.1.255"
    public static let controlPort: UInt16 = 2000
    public static let rxPort: UInt16 = 2002
    public static let rtpPort: UInt16 = 5000

    public static let ssidPrefix = "RE_"
    public static let defaultWifiPassword = "12345678"

    public static let videoWidth = 526
    public static let videoHeight = 300
    public static let activeFps = 4
    public static let idleFps = 2
    public static let activeBitrate = 200_000
    public static let idleBitrate = 100_000

    public static let hostname = "Northstar"
}
