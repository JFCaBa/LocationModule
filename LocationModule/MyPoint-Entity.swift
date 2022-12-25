//
//  MyPoint-Entity.swift
//  LocationModule
//
//  Created by Jose on 23/12/2022.
//

import Foundation
import CoreLocation

public struct MyPoint: Codable {
    public var latitude : Float = 0
    public var longitude : Float = 0
    public var speed : Float = 0
    public var course : Float = 0
    public var hdop : Int = 0
    public var timestamp : Date = Date.init()
    
    init() { }
    
    init(location: CLLocation) {
        self.latitude = Float(location.coordinate.latitude)
        self.longitude = Float(location.coordinate.longitude)
        self.speed = Float(location.speed)
        self.course = Float(location.course)
        self.hdop = Int(location.horizontalAccuracy)
        self.timestamp = location.timestamp
    }
}
