//
//  Manager.swift
//  LocationModule
//
//  Created by Jose on 23/12/2022.
//

import UIKit
import CoreLocation

public enum MyLocationAuthorisationStatus {
    case notAllowed
    case always
    case inUse
}

public protocol LocationDelegate: AnyObject {
    func didChangeLocation(_ location: MyPoint)
    func didFail(_ error: Error)
    func didChangeAuthorisationStatus(_ status: MyLocationAuthorisationStatus)
}

class MyLocationManager: NSObject {
    
    private var backgroundTask: UIBackgroundTaskIdentifier = UIBackgroundTaskIdentifier.invalid
    private var locationManager: CLLocationManager = CLLocationManager()
    public weak var delegate: LocationDelegate?
    
    //MARK: - Initializers
    override init() {
        super.init()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        locationManager.delegate = self;
        locationManager.pausesLocationUpdatesAutomatically = false
        locationManager.allowsBackgroundLocationUpdates = true
        
        // If phone is charging use BestForNavigation (following Apple guidelines)
        // This mode takes more power and should be used just when charging or full charged
        if isPhoneCharging() {
            locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        }
        else {
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
        }
        
        locationManager.distanceFilter  = kCLDistanceFilterNone
    }
    
    //MARK: - Public functions
    func requestAlwaysLocationAuthorization() {
        locationManager.stopUpdatingLocation()
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    func startMonitoringSignificantLocationChanges() {
        backgroundTask = UIApplication.shared.beginBackgroundTask { [weak self] in
            self?.endBackgroundTask()
        }
        assert(backgroundTask != UIBackgroundTaskIdentifier.invalid)
        
        locationManager.stopMonitoringSignificantLocationChanges()
        locationManager.stopUpdatingLocation()
        locationManager.startMonitoringSignificantLocationChanges()
    }
    
    func startLocationUpdates() {
        backgroundTask = UIApplication.shared.beginBackgroundTask { [weak self] in
            self?.endBackgroundTask()
        }
        assert(backgroundTask != UIBackgroundTaskIdentifier.invalid)
        
        locationManager.stopMonitoringSignificantLocationChanges()
        locationManager.startUpdatingLocation();
    }
    
//    public func isLocationServicesEnabled() -> Bool{
//        if CLLocationManager.locationServicesEnabled() {
//            let manager = CLLocationManager()
//            switch manager.authorizationStatus {
//            case .notDetermined, .restricted, .denied:
//                print("No access")
//                return false
//            case .authorizedWhenInUse:
//                return false
//            case .authorizedAlways:
//                print("Access")
//                return true
//            @unknown default:
//                print("Error")
//                return false
//            }
//        } else {
//            print("Location services are not enabled")
//        }
//        return false
//    }
    
    //MARK: - Private functions
    fileprivate func endBackgroundTask() {
        print("\n\n\nBackground task ended.\n\n\n")
        UIApplication.shared.endBackgroundTask(backgroundTask)
        backgroundTask = UIBackgroundTaskIdentifier.invalid
    }
    
    fileprivate func isPhoneCharging() -> Bool{
        UIDevice.current.isBatteryMonitoringEnabled = true
        let state = UIDevice.current.batteryState
        
        if state == .charging || state == .full {
            return true
        }
        
        return false
    }
    
    fileprivate func fixCachedLocationUpdates(){
        locationManager.requestLocation()
    }
    
    fileprivate func isValidLocation(_ location: CLLocation) -> Bool {
        // Check Accuracy
        if location.horizontalAccuracy < 70 {
            return true
        }
        
        // Check age
        let age = location.timestamp.timeIntervalSince(Date.init())
        if abs(age) < 5
        {
            fixCachedLocationUpdates()
            return true
        }
        
        return false
    }
}

// MARK: - LocationManager delegates
extension MyLocationManager: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]){
        let latestLocation: CLLocation = locations[locations.count - 1]
        if isValidLocation(latestLocation) {
            let loc = MyPoint.init(location: latestLocation)
            DispatchQueue.main.async {
                self.delegate?.didChangeLocation(loc)
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error.localizedDescription)
        DispatchQueue.main.async {
            self.delegate?.didFail(error)
        }
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .notDetermined, .restricted, .denied:
            print("No access")
            delegate?.didChangeAuthorisationStatus(.notAllowed)
        case .authorizedWhenInUse:
            print("In use")
            delegate?.didChangeAuthorisationStatus(.inUse)
        case .authorizedAlways:
            print("Always")
            delegate?.didChangeAuthorisationStatus(.always)
        @unknown default:
            print("Error")
            delegate?.didChangeAuthorisationStatus(.notAllowed)
        }
    }
}

