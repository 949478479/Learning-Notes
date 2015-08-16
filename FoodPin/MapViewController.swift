//
//  MapViewController.swift
//  FoodPin
//
//  Created by 从今以后 on 15/8/16.
//  Copyright (c) 2015年 从今以后. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController {

    var restaurant: Restaurant!

    @IBOutlet private weak var mapView: MKMapView!

    override func viewDidLoad() {
        super.viewDidLoad()

        CLGeocoder().geocodeAddressString(restaurant.location) { placemarks, error in

            if let error = error {
                println(error)
                return
            }

            if let placemarks = placemarks as? [CLPlacemark], placemark = placemarks.first {

                let annotation        = MKPointAnnotation()
                annotation.title      = self.restaurant.name
                annotation.subtitle   = self.restaurant.type
                annotation.coordinate = placemark.location.coordinate

                self.mapView.showAnnotations([annotation], animated: true)
                self.mapView.selectAnnotation(annotation, animated: true)
            }
        }
    }
}

extension MapViewController: MKMapViewDelegate {

    func mapView(mapView: MKMapView!,
        viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView! {

        if annotation is MKUserLocation {
            return nil
        }

        var annotationView = mapView.dequeueReusableAnnotationViewWithIdentifier("MyPin")

        if annotationView == nil {

            let leftIconView = UIImageView(frame: CGRect(x: 0, y: 0, width: 53, height: 53))
            leftIconView.contentMode = .ScaleAspectFill

            annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "MyPin")
            annotationView.canShowCallout = true
            annotationView.leftCalloutAccessoryView = leftIconView

        } else {
            annotationView.annotation = annotation
        }

        (annotationView.leftCalloutAccessoryView as! UIImageView).image = UIImage(named: restaurant.thumbnail)

        return annotationView
    }
}