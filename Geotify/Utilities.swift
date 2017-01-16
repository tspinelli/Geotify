//
//  Utilities.swift
//  Geotify
//
//  Created by Ken Toh on 3/3/15.
//  Copyright (c) 2015 Ken Toh. All rights reserved.
//

import UIKit
import MapKit

// MARK: Helper Functions

func showSimpleAlertWithTitle(_ title: String!, message: String, viewController: UIViewController) {
  let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
  let action = UIAlertAction(title: "OK", style: .cancel, handler: nil)
  alert.addAction(action)
  viewController.present(alert, animated: true, completion: nil)
}

func zoomToUserLocationInMapView(_ mapView: MKMapView) {
  if let coordinate = mapView.userLocation.location?.coordinate {
    let region = MKCoordinateRegionMakeWithDistance(coordinate, 1000, 1000)
    mapView.setRegion(region, animated: true)
  }
}
