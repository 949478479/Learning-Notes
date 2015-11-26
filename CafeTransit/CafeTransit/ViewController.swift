/*
* Copyright (c) 2015 Razeware LLC
*
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included in
* all copies or substantial portions of the Software.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
* AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
* OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
* THE SOFTWARE.
*/

import UIKit
import MapKit

class ViewController: UIViewController {

    @IBOutlet private var mapView: MKMapView!
    private var currentUserLocation: CLLocationCoordinate2D?
    private lazy var locationManager: CLLocationManager = {
        let locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        return locationManager
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        configureMapView()
        showAnnotations()
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        requestUserLocation()
    }
}

// MARK: - MKMapViewDelegate
extension ViewController: MKMapViewDelegate {

    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation)
        -> MKAnnotationView? {

        guard let annotation = annotation as? CoffeeShopPin else {
            return nil
        }

        let identifier = String(CoffeeShopPinDetailView)

        var annotationView: MKPinAnnotationView! = mapView.dequeueReusableAnnotationViewWithIdentifier(identifier)
            as? MKPinAnnotationView

        if annotationView == nil {
            annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            annotationView.canShowCallout = true
        } else {
            annotationView.annotation = annotation
        }

        if annotation.coffeeshop.rating.value == 5 {
            annotationView.pinTintColor = UIColor(red: 1, green: 0.79, blue: 0, alpha: 1)
        } else {
            annotationView.pinTintColor = UIColor(red:0.419, green:0.266, blue:0.215, alpha:1)
        }


        let detailView = CoffeeShopPinDetailView.instantiateFromNib()
        detailView.coffeeShop = annotation.coffeeshop
        annotationView.detailCalloutAccessoryView = detailView

        return annotationView
    }

    func mapView(mapView: MKMapView, didSelectAnnotationView view: MKAnnotationView) {
        if let detailView = view.detailCalloutAccessoryView as? CoffeeShopPinDetailView {
            detailView.currentUserLocation = currentUserLocation
        }
    }
}

// MARK: - CLLocationManagerDelegate
extension ViewController: CLLocationManagerDelegate {

    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        currentUserLocation = locations.first?.coordinate
        print(currentUserLocation)
    }

    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print("Error finding location: " + error.localizedDescription)
    }
}

private extension ViewController {

    func configureMapView() {
        mapView.showsScale = true
    }

    func showAnnotations() {
        let annotations = CoffeeShop.allCoffeeShops().map { CoffeeShopPin(coffeeshop: $0) }
        mapView.showAnnotations(annotations, animated: false)
    }

    func requestUserLocation() {
        if CLLocationManager.authorizationStatus() == .AuthorizedWhenInUse {
            locationManager.requestLocation()
        } else {
            locationManager.requestWhenInUseAuthorization()
        }
    }
}
