import AsyncAlgorithms
import CoreLocation
import Foundation
import Combine
import MapKit

@available(iOS 16.1, *)
@MainActor
struct LocationClient: Sendable{
  private let _distanceStream: @MainActor @Sendable () throws -> AsyncThrowingStream<CLLocation, Error>
  private let _cancelStream: @MainActor @Sendable () -> Void
  private let _locationDistance: @Sendable (CLLocation, MKMapItem) async throws -> Double
  
  init(
    distanceStream: @MainActor @Sendable @escaping () throws -> AsyncThrowingStream<CLLocation, Error>,
    cancelStream: @MainActor @Sendable @escaping () -> Void,
    locationDistance: @Sendable @escaping (CLLocation, MKMapItem) async throws -> Double
  ) {
    self._distanceStream = distanceStream
    self._cancelStream = cancelStream
    self._locationDistance = locationDistance
  }
  
  /// 행사장과 거리를 좌표를 통한 직선 거리를 계산하는 게 아닌, 지도상 존재하는 길을 토대로 계산되는 값입니다.
  /// 추가적으로 값이 500m 보다 작게 되면 해당 스트림을 종료하도록 구현했습니다.
  /// 새로운 행사장을 추가하실 땐 ConferenceVenue 케이스를 추가하면 됩니다.
  func distanceStream(venue: ConferenceVenue) throws -> AsyncThrowingStream<Double, Error> {
    try _distanceStream()
      .map { location in
        try await _locationDistance(location, venue.mapItem)
      }
      .filter { distance in
        if distance <= 0.5 {
          await _cancelStream()
          return false
        }
        return true
      }
      .eraseToThrowingStream()
  }
}

@available(iOS 16.1, *)
extension LocationClient {
  @MainActor
  static let live: LocationClient = {
    let manager = LocationManager()
    manager.checkAuthorizationStatus()
    return .init(
      distanceStream: {
        try manager
          .locationStream()
          .throttle(for: .seconds(3), latest: true)
          .eraseToThrowingStream()
      },
      cancelStream: { manager.subject.send(completion: .finished) },
      locationDistance: { location, mapItem in
        let request = MKDirections.Request()
        request.source = .init(placemark: .init(coordinate: location.coordinate))
        request.destination = mapItem
        let directions = MKDirections(request: request)
        let response = try await directions.calculate()
        guard 
          let distance = response.routes.first?.distance
        else { throw _Error.missingData }
        return distance / 1000 /// km
      }
    )
  }()
}

@MainActor
private final class LocationManager: NSObject, CLLocationManagerDelegate {
  private let manager: CLLocationManager
  let subject: PassthroughSubject<CLLocation, Error> = .init()
  
  override init() {
    self.manager = CLLocationManager()
    super.init()
    configure()
  }
  
  func checkAuthorizationStatus() {
    switch manager.authorizationStatus {
    case .authorizedWhenInUse, .authorizedAlways:
      manager.startUpdatingLocation()
    case .notDetermined:
      manager.requestAlwaysAuthorization()
    default:
      break
    }
  }
  
  func locationStream() throws -> AsyncThrowingStream<CLLocation, Error> {
    let isAuthorized = manager.authorizationStatus != .restricted && manager.authorizationStatus != .denied
    guard isAuthorized else { throw _Error.denied }
    return subject
      .handleEvents(
        receiveCancel: { [weak self] in
          self?.manager.stopUpdatingLocation()
        }
      )
      .eraseToAnyPublisher()
      .stream
  }
  
  private func configure() {
    manager.delegate = self
    manager.allowsBackgroundLocationUpdates = true
    manager.showsBackgroundLocationIndicator = true
  }
  
  //MARK: - CLLocationManagerDelegate
  /// CLLocationManagerDelegate의 경우,  LocationManager가 MainActor에서 호출될 걸 보장하기 때문에
  /// MainActor.assumeIsolated를 사용해서 처리하게 됐습니다.
  /// 다른 곳에서도 MainActor.assumeIsolated을 사용하실 때 MainActor를 보장하지 못한다면 fatalError가 발생할 수 있습니다.
  nonisolated
  func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
    MainActor.assumeIsolated {
      switch self.manager.authorizationStatus {
      case .authorizedAlways, .authorizedWhenInUse:
        self.manager.startUpdatingLocation()
      case .denied, .restricted:
        subject.send(completion: .failure(_Error.denied))
      default:
        break
      }
    }
  }
  
  nonisolated
  func locationManager(
    _ manager: CLLocationManager,
    didUpdateLocations locations: [CLLocation]
  ) {
    MainActor.assumeIsolated {
      guard let location = locations.first else {
        subject.send(completion: .failure(_Error.missingData))
        return
      }
      subject.send(location)
    }
  }
  
  nonisolated
  func locationManager(
    _ manager: CLLocationManager,
    didFailWithError error: any Error
  ) {
    MainActor.assumeIsolated { subject.send(completion: .failure(error)) }
  }
}

private enum _Error: Error {
  case denied
  case missingData
}

private extension ConferenceVenue {
  var mapItem: MKMapItem {
    switch self {
    case .kofst:
      return .init(
        placemark: .init(
          coordinate: .init(
            latitude: 37.5007029,
            longitude: 127.0307453
          )
        )
      )
    }
  }
}
