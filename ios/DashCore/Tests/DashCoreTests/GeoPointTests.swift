import XCTest
@testable import DashCore

final class GeoPointTests: XCTestCase {
    func testDistanceSanity() {
        let a = GeoPoint(lat: 28.6139, lng: 77.2090) // Delhi-ish
        let b = GeoPoint(lat: 28.7041, lng: 77.1025)
        let d = GeoPoint.distMeters(a, b)
        XCTAssertGreaterThan(d, 10_000)
        XCTAssertLessThan(d, 50_000)
    }

    func testBearingRange() {
        let a = GeoPoint(lat: 0, lng: 0)
        let b = GeoPoint(lat: 0, lng: 1)
        let br = GeoPoint.bearing(a, b)
        XCTAssertGreaterThanOrEqual(br, 0)
        XCTAssertLessThan(br, 360)
    }
}
