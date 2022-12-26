//
//  ViewModel.swift
//  LocationModule
//
//  Created by Jose on 23/12/2022.
//

import Foundation
import Combine

final class ViewModel: ObservableObject {
    
    @Published var myPoint = MyPoint.init()
    @Published var hasError: String = ""
    
    let locationManager = MyLocationManager.init()
    var subscriptions: Set<AnyCancellable> = []
    
    
    // MARK: User interface Publishers
    var myPointPublisher: AnyPublisher<MyPoint, Never> {
        $myPoint
            .eraseToAnyPublisher()
    }
    
    var latitudePublisher: AnyPublisher<String?, Never> {
        myPointPublisher
            .map{String(format: "%0.6f", $0.latitude)}
            .eraseToAnyPublisher()
    }
    
    var longitudePublisher: AnyPublisher<String?, Never> {
        myPointPublisher
            .map{String(format: "%0.6f", $0.longitude)}
            .eraseToAnyPublisher()
    }
    
    var speedPublisher: AnyPublisher<String?, Never> {
        myPointPublisher
            .filter{$0.speed > 0}
            .map{String(format: "%0.1f mts/sec", $0.speed)}
            .eraseToAnyPublisher()
    }
    
    var coursePublisher: AnyPublisher<String?, Never> {
        myPointPublisher
            .filter{$0.course >= 0}
            .map{String(format: "%0.0f°", $0.course)}
            .eraseToAnyPublisher()
    }
    
    var accuracyPublisher: AnyPublisher<String?, Never> {
        myPointPublisher
            .map{"\($0.hdop) mts."}
            .eraseToAnyPublisher()
    }
    
    var timestampPublisher: AnyPublisher<String?, Never> {
        myPointPublisher
            .map{String(format: "%0.0f", $0.timestamp.timeIntervalSince1970)}
            .eraseToAnyPublisher()
    }
    
    // MARK: - Functions
    public func startLocationManager() {
        locationManager.requestAlwaysLocationAuthorization()
        locationManager.startLocationUpdates()
        // Setup bindings
        setupLocationBindings()
    }
    
    // MARK: Private
    private func setupLocationBindings() {
        locationManager.$myLocation
            .compactMap{$0}
            .sink { [weak self] location in
                self?.myPoint = location
            }
            .store(in: &subscriptions)
        
        locationManager.$myError
            .compactMap{$0}
            .sink { [weak self] error in
                self?.hasError = error.localizedDescription
            }
            .store(in: &subscriptions)
        
        locationManager.$myAuthorisation
            .compactMap{$0}
            .sink { [weak self] status in
                switch status {
                case .inUse:
                    self?.hasError = NSLocalizedString("change-to-always", comment: "")
                case .notAllowed:
                    self?.hasError = NSLocalizedString("app-not-allowed", comment: "")
                case .always:
                    self?.hasError = ""
                case .unknown: break
                }
            }
            .store(in: &subscriptions)
    }
}
