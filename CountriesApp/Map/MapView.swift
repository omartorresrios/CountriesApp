//
//  MapView.swift
//  CountriesApp
//
//  Created by Omar Torres on 6/10/24.
//

import SwiftUI
import MapKit

struct MapView: View {
	@StateObject var locationManager = LocationManager()
	@State var position: MapCameraPosition
	
	init(position: MapCameraPosition) {
		_position = State(initialValue: position)
	}
	
    var body: some View {
		VStack {
			if locationManager.errorMessage.isEmpty {
				Map(position: $position)
			} else {
				Text(locationManager.errorMessage)
			}
		}
		.onChange(of: locationManager.location) {
			let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
			position = MapCameraPosition.region(MKCoordinateRegion(center: locationManager.location,
																   span: span))
		}
    }
}


#Preview {
	MapView(position: .region(MKCoordinateRegion()))
}
