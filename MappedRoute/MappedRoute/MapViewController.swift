//
//  MapViewController.swift
//  MappedRoute
//
//  Created by Hridayedeep Gupta on 16/03/22.
//

import UIKit
import MapKit

class MapViewController: UIViewController {

    @IBOutlet private var activityIndicator: UIActivityIndicatorView!
    @IBOutlet private var mapView: MKMapView!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupMap()
        showRoute()
    }

    private func setupMap() {
        mapView.delegate = self
        mapView.mapType = .hybrid
    }

    private func showRoute() {
        mapView.addAnnotations(Locations.allCases.map { $0.getAnnotation() })
        showRouteOnMap(from: Self.Kochi, to: Self.Coimbatore)
        showRouteOnMap(from: Self.Coimbatore, to: Self.Madurai)
        showRouteOnMap(from: Self.Madurai, to: Self.Munnar)
        showRouteOnMap(from: Self.Munnar, to: Self.Kochi)
    }
}

extension MapViewController: MKMapViewDelegate {
    func showRouteOnMap(from pickupCoordinate: CLLocationCoordinate2D, to destinationCoordinate: CLLocationCoordinate2D) {

        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: MKPlacemark(coordinate: pickupCoordinate, addressDictionary: nil))
        request.destination = MKMapItem(placemark: MKPlacemark(coordinate: destinationCoordinate, addressDictionary: nil))
        request.requestsAlternateRoutes = true
        request.transportType = .automobile

        Task {
            activityIndicator.startAnimating()
            let directions = MKDirections(request: request)

            let response = try await directions.calculate()
            activityIndicator.stopAnimating()
            activityIndicator.isHidden = true
            drawRoute(with: response.routes.first)
        }
    }

    private func drawRoute(with route: MKRoute?) {
        guard let route = route else { return }
        //show on map
        mapView.addOverlay(route.polyline)
        //set the map area to show the route
        let padding = UIEdgeInsets.init(top: 80.0, left: 20.0, bottom: 100.0, right: 20.0)
        mapView.setVisibleMapRect(route.polyline.boundingMapRect, edgePadding: padding, animated: true)
    }

    //this delegate function is for displaying the route overlay and styling it
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay)
        renderer.strokeColor = .orange
        renderer.lineWidth = 5.0
        return renderer
    }
}

extension MapViewController {
    static let Kochi = Locations.Kochi.coordinates2D
    static let Coimbatore = Locations.Coimbatore.coordinates2D
    static let Madurai = Locations.Madurai.coordinates2D
    static let Munnar = Locations.Munnar.coordinates2D

    enum Locations: String, CaseIterable {
        case Kochi, Coimbatore, Madurai, Munnar

        var coordinates2D: CLLocationCoordinate2D {
            switch self {
            case .Kochi:
                return CLLocationCoordinate2D(latitude: 9.931233, longitude: 76.267303)
            case .Coimbatore:
                return CLLocationCoordinate2D(latitude: 11.017363, longitude: 76.958885)
            case .Madurai:
                return CLLocationCoordinate2D(latitude: 9.9252, longitude: 78.1198)
            case .Munnar:
                return CLLocationCoordinate2D(latitude: 10.089167, longitude: 77.059723)
            }
        }

        /// Returns the annotation/ icon for the checkpoint, with a corresponding name
        func getAnnotation() -> MKPointAnnotation {
            let annotation = MKPointAnnotation()
            annotation.title = self.rawValue
            annotation.coordinate = self.coordinates2D
            return annotation
        }
    }
}
