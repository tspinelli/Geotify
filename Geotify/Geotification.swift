//
//  Geotification.swift
//  Geotify
//
//  Created by Ken Toh on 24/1/15.
//  Copyright (c) 2015 Ken Toh. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

let kGeotificationLatitudeKey = "latitude"
let kGeotificationLongitudeKey = "longitude"
let kGeotificationRadiusKey = "radius"
let kGeotificationIdentifierKey = "identifier"
let kGeotificationNoteKey = "note"
let kGeotificationEventTypeKey = "eventType"

enum EventType: Int {
  case onEntry = 0
  case onExit
}

class Geotification: NSObject, NSCoding, MKAnnotation {
  var coordinate: CLLocationCoordinate2D
  var radius: CLLocationDistance
  var identifier: String
  var note: String
  var eventType: EventType

  var title: String? {
    if note.isEmpty {
      return "No Note"
    }
    return note
  }

  var subtitle: String? {
    let eventTypeString = eventType == .onEntry ? "On Entry" : "On Exit"
    return "Radius: \(radius)m - \(eventTypeString)"
  }

  init(coordinate: CLLocationCoordinate2D, radius: CLLocationDistance, identifier: String, note: String, eventType: EventType) {
    self.coordinate = coordinate
    self.radius = radius
    self.identifier = identifier
    self.note = note
    self.eventType = eventType
  }

  // MARK: NSCoding

  required init?(coder decoder: NSCoder) {
    let latitude = decoder.decodeDouble(forKey: kGeotificationLatitudeKey)
    let longitude = decoder.decodeDouble(forKey: kGeotificationLongitudeKey)
    coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    radius = decoder.decodeDouble(forKey: kGeotificationRadiusKey)
    identifier = decoder.decodeObject(forKey: kGeotificationIdentifierKey) as! String
    note = decoder.decodeObject(forKey: kGeotificationNoteKey) as! String
    eventType = EventType(rawValue: decoder.decodeInteger(forKey: kGeotificationEventTypeKey))!
  }

  func encode(with coder: NSCoder) {
    coder.encode(coordinate.latitude, forKey: kGeotificationLatitudeKey)
    coder.encode(coordinate.longitude, forKey: kGeotificationLongitudeKey)
    coder.encode(radius, forKey: kGeotificationRadiusKey)
    coder.encode(identifier, forKey: kGeotificationIdentifierKey)
    coder.encode(note, forKey: kGeotificationNoteKey)
    coder.encodeCInt(Int32(eventType.rawValue), forKey: kGeotificationEventTypeKey)
  }
}
