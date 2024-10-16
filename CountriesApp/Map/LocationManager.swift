//
//  LocationManager.swift
//  CountriesApp
//
//  Created by Omar Torres on 6/11/24.
//

import Foundation
import MapKit

final class LocationManager: NSObject, ObservableObject, MKMapViewDelegate, CLLocationManagerDelegate {
	private var locationManager = CLLocationManager()
	@Published var location = CLLocationCoordinate2D()
	@Published var errorMessage = ""
	@Published var isLocationDenied = false
	
	override init() {
		super.init()
		locationManager.delegate = self
		locationManager.requestWhenInUseAuthorization()
		locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
	}
	
	func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
		checkAuthorization()
	}
	
	func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
		guard let currentLocation = locations.last else { return }
		location = CLLocationCoordinate2D(latitude: currentLocation.coordinate.latitude,
										  longitude: currentLocation.coordinate.longitude)
	}
	
	func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
		errorMessage = error.localizedDescription
	}
	
	func checkAuthorization() {
		switch locationManager.authorizationStatus {
		case .notDetermined:
			locationManager.requestWhenInUseAuthorization()
		case .denied:
			print("Denied. Request again maybe.")
		case .authorizedAlways, .authorizedWhenInUse:
			locationManager.requestLocation()
		default: break
		}
	}
}

extension CLLocationCoordinate2D: Equatable {
	public static func == (lhs: CLLocationCoordinate2D, rhs: CLLocationCoordinate2D) -> Bool {
		return lhs.latitude == rhs.latitude && lhs.longitude == rhs.longitude
	}
}
