//
//  Manager.swift
//  LocationModule
//
//  Created by Jose on 23/12/2022.
//

import UIKit
import CoreLocation
import Combine

public enum MyLocationAuthorisationStatus {
    case notAllowed
    case always
    case inUse
    case unknown
}

class MyLocationManager: NSObject {
    
    @Published var myLocation = MyPoint()
    @Published var myAuthorisation: MyLocationAuthorisationStatus = .unknown
    @Published var myError: Error!
    
    private var backgroundTask: UIBackgroundTaskIdentifier = UIBackgroundTaskIdentifier.invalid
    private var locationManager: CLLocationManager = CLLocationManager()
    
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
            myLocation = loc
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error.localizedDescription)
        myError = error
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .notDetermined, .restricted, .denied:
            print("No access")
            myAuthorisation = .notAllowed
        case .authorizedWhenInUse:
            print("In use")
            myAuthorisation = .inUse
        case .authorizedAlways:
            print("Always")
            myAuthorisation = .always
        @unknown default:
            print("Error")
            myAuthorisation = .notAllowed
        }
    }
}

