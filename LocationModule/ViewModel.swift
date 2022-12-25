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
    
    // MARK: Functions
    func startLocationManager() {
        locationManager.delegate = self
        locationManager.requestAlwaysLocationAuthorization()
        locationManager.startLocationUpdates()
    }
}

// MARK: - Location delegate
extension ViewModel: LocationDelegate {
    func didChangeLocation(_ location: MyPoint) {
        myPoint = location
    }
    
    func didFail(_ error: Error) {
        hasError = error.localizedDescription
    }
    
    func didChangeAuthorisationStatus(_ status: MyLocationAuthorisationStatus) {
        switch status {
        case .inUse:
            hasError = NSLocalizedString("change-to-always", comment: "")
        case .notAllowed:
            hasError = NSLocalizedString("app-not-allowed", comment: "")
        case .always:
            hasError = ""
        }
    }
}
