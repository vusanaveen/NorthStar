import Foundation

/// WGS84 point + helpers — port of Android `dash/nav/GeoPoint.kt`.
public struct GeoPoint: Equatable, Sendable {
    public let lat: Double
    public let lng: Double

    public init(lat: Double, lng: Double) {
        self.lat = lat
        self.lng = lng
    }

    private static let earthKm = 6371.0

    public static func distMeters(_ a: GeoPoint, _ b: GeoPoint) -> Double {
        let dLat = (b.lat - a.lat) * .pi / 180
        let dLng = (b.lng - a.lng) * .pi / 180
        let s = sin(dLat / 2) * sin(dLat / 2)
            + cos(a.lat * .pi / 180) * cos(b.lat * .pi / 180)
            * sin(dLng / 2) * sin(dLng / 2)
        return 2 * earthKm * 1000 * atan2(sqrt(s), sqrt(1 - s))
    }

    /// Initial bearing a→b in degrees [0,360).
    public static func bearing(_ a: GeoPoint, _ b: GeoPoint) -> Double {
        let lat1 = a.lat * .pi / 180
        let lat2 = b.lat * .pi / 180
        let dLng = (b.lng - a.lng) * .pi / 180
        let y = sin(dLng) * cos(lat2)
        let x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(dLng)
        var deg = atan2(y, x) * 180 / .pi
        deg = (deg + 360).truncatingRemainder(dividingBy: 360)
        return deg
    }

    /// Nearest point on segment a→b plus fraction t∈[0,1].
    public static func projectOnSegment(_ p: GeoPoint, _ a: GeoPoint, _ b: GeoPoint) -> (GeoPoint, Double) {
        let latRef = a.lat * .pi / 180
        func x(_ g: GeoPoint) -> Double { g.lng * .pi / 180 * cos(latRef) }
        func y(_ g: GeoPoint) -> Double { g.lat * .pi / 180 }
        let ax = x(a), ay = y(a)
        let bx = x(b), by = y(b)
        let px = x(p), py = y(p)
        let dx = bx - ax, dy = by - ay
        let len2 = dx * dx + dy * dy
        let t: Double
        if len2 == 0 {
            t = 0
        } else {
            t = max(0, min(1, ((px - ax) * dx + (py - ay) * dy) / len2))
        }
        let proj = GeoPoint(
            lat: a.lat + (b.lat - a.lat) * t,
            lng: a.lng + (b.lng - a.lng) * t
        )
        return (proj, t)
    }
}
