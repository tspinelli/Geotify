//
//  AddGeotificationViewController.swift
//  Geotify
//
//  Created by Ken Toh on 24/1/15.
//  Copyright (c) 2015 Ken Toh. All rights reserved.
//

import UIKit
import MapKit

protocol AddGeotificationsViewControllerDelegate {
  func addGeotificationViewController(_ controller: AddGeotificationViewController, didAddCoordinate coordinate: CLLocationCoordinate2D,
    radius: Double, identifier: String, note: String, eventType: EventType)
}

class AddGeotificationViewController: UITableViewController {

  @IBOutlet var addButton: UIBarButtonItem!
  @IBOutlet var zoomButton: UIBarButtonItem!

  @IBOutlet weak var eventTypeSegmentedControl: UISegmentedControl!
  @IBOutlet weak var radiusTextField: UITextField!
  @IBOutlet weak var noteTextField: UITextField!
  @IBOutlet weak var mapView: MKMapView!

  var delegate: AddGeotificationsViewControllerDelegate!

  override func viewDidLoad() {
    super.viewDidLoad()

    navigationItem.rightBarButtonItems = [addButton, zoomButton]
    addButton.isEnabled = false

    tableView.tableFooterView = UIView()
  }

  @IBAction func textFieldEditingChanged(_ sender: UITextField) {
    addButton.isEnabled = !radiusTextField.text!.isEmpty && !noteTextField.text!.isEmpty
  }

  @IBAction func onCancel(_ sender: AnyObject) {
    dismiss(animated: true, completion: nil)
  }

  @IBAction fileprivate func onAdd(_ sender: AnyObject) {
    let coordinate = mapView.centerCoordinate
    let radius = (radiusTextField.text! as NSString).doubleValue
    let identifier = UUID().uuidString
    let note = noteTextField.text
    let eventType = (eventTypeSegmentedControl.selectedSegmentIndex == 0) ? EventType.onEntry : EventType.onExit
    delegate!.addGeotificationViewController(self, didAddCoordinate: coordinate, radius: radius, identifier: identifier, note: note!, eventType: eventType)
  }

  @IBAction fileprivate func onZoomToCurrentLocation(_ sender: AnyObject) {
    zoomToUserLocationInMapView(mapView)
  }
}
