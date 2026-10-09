import CoreLocation
import Foundation

#if swift(>=5.10)
extension CLLocationCoordinate2D: @retroactive Identifiable {
    public var id: String {
        "\(latitude)-\(longitude)"
    }
}
#else
extension CLLocationCoordinate2D: Identifiable {
    public var id: String {
        "\(latitude)-\(longitude)"
    }
}
#endif
