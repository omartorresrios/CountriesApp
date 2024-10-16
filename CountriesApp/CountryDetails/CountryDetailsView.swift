//
//  CountryDetailsView.swift
//  CountriesApp
//
//  Created by Omar Torres on 6/5/24.
//

import SwiftUI
import MapKit

enum DriverSide: String {
	case left = "LEFT"
	case right = "RIGHT"
}

struct CountryDetailsView: View {
	@StateObject var viewModel: CountryDetailsViewModel
	private let country: CountryDataItem
	private let mapPosition: MapCameraPosition
	
	init(country: CountryDataItem) {
		let viewModel = CountryDetailsViewModel(httpClient: CountryDetailsURLSessionHTTPClient())
		_viewModel = StateObject(wrappedValue: viewModel)
		self.country = country
		mapPosition = MapCameraPosition.region(MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: country.capitalInfo?.latlng?.first ?? 0.0, longitude: country.capitalInfo?.latlng?.last ?? 0.0), span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)))
	}
	
	var body: some View {
		ScrollView {
			VStack(spacing: 15) {
				flagView
				cardSectionsView
			}
		}
		.padding(.top)
		.navigationTitle(country.name.common)
		.toolbar {
			Button {
				country.toggleBookMarked()
			} label: {
				viewModel.bookmarkIcon(bookmarked: country.bookmarked)
			}
		}
		.onAppear {
			viewModel.downloadCoatOfArmsImage(for: country)
		}
	}
	
	private var flagView: some View {
		ZStack(alignment: .bottomLeading) {
			VStack {
				if let flagImage = country.flagImageData,
				   let flagUIImage = UIImage(data: flagImage) {
					Image(uiImage: flagUIImage)
						.applyModifiers(width: nil, height: nil, contentMode: .fit)
				}
			}
			.frame(maxWidth: .infinity)
			
			NavigationStack {
				NavigationLink {
					MapView(position: mapPosition)
				} label: {
					tappableCountryNameView
				}
			}
			.alignmentGuide(.bottom, computeValue: { dimension in dimension[VerticalAlignment.center] })
		}
	}
	
	private var tappableCountryNameView: some View {
		VStack(alignment: .center) {
			Text(country.name.common)
				.font(.system(size: 30, weight: .heavy))
				.foregroundStyle(.black)
			Text(country.name.official)
				.font(.system(size: 20, weight: .medium))
				.foregroundStyle(.gray)
		}
		.padding(.vertical, 5)
		.padding(.horizontal, 15)
		.convertItToCard()
		.padding(.leading)
	}
	
	private var cardSectionsView: some View {
		VStack(spacing: 15) {
			HStack {
				detailItem(title: "Region", description: country.region)
				Divider()
				if let subregion = country.subregion {
					detailItem(title: "Subregion", description: subregion)
				}
				Divider()
				if let capital = country.capital?.first {
					detailItem(title: "Capital", description: capital)
				}
			}
			.padding()
			.convertItToCard()
			.padding(.horizontal)
			.frame(maxWidth: .infinity)
			
			HStack(spacing: 20) {
				let timezonesDescription = viewModel.timezonesDescription(timezones: country.timezones)
				detailItem(title: "Timezone(s)", description: timezonesDescription, maxHeight: .infinity)
					.padding()
					.convertItToCard()
					
				let populationDescription = viewModel.populationDescription(population: country.population)
				detailItem(title: "Population", description: populationDescription, maxHeight: .infinity)
					.padding()
					.convertItToCard()
			}
			.padding(.horizontal)
			.fixedSize(horizontal: false, vertical: true)
			
			HStack(spacing: 20) {
				if let languages = country.languages {
					detailItem(title: "Languages", description: languages, maxHeight: .infinity)
						.padding()
						.convertItToCard()
				}
				if let currencies = country.currencies {
					detailItem(title: "Currencies", description: currencies, maxHeight: .infinity)
						.padding()
						.convertItToCard()
				}
			}
			.padding(.horizontal)
			.fixedSize(horizontal: false, vertical: true)
			
			HStack(spacing: 20) {
				let carDriverDescription = viewModel.carDriverDescription(side: country.car.side)
				carDetailItem(title: "Car Driver Side", description: carDriverDescription, maxHeight: .infinity)
					.padding()
					.convertItToCard()
					
				if country.coatOfArms.png != nil {
					if viewModel.isLoading {
						ProgressView()
							.frame(width: 50, height: 50)
					} else if let coatOfArmsData = country.coatOfArmsData,
							  let coatOfArmsUIImage = UIImage(data: coatOfArmsData) {
						VStack(alignment: .center, spacing: 15) {
							detailItem(title: "Coat of Arms")
							Image(uiImage: coatOfArmsUIImage)
								.applyModifiers(width: 50, height: 50, contentMode: .fit)
						}
						.padding()
						.convertItToCard()
					}
				}
			}
			.padding(.horizontal)
			.fixedSize(horizontal: false, vertical: true)
		}
	}
	
	private func detailItem(title: String,
							description: String? = nil,
							maxHeight: CGFloat? = nil) -> some View {
		VStack(alignment: .center, spacing: 5) {
			Text(title)
				.font(.system(size: 15, weight: .bold))
			if let description = description {
				Text(description)
					.font(.system(size: 18, weight: .medium))
					.foregroundStyle(.gray)
			}
		}
		.frame(maxWidth: .infinity, maxHeight: maxHeight)
	}
	
	private func carDetailItem(title: String, 
							   description: String,
							   maxHeight: CGFloat? = nil) -> some View {
		VStack(alignment: .center, spacing: 5) {
			Text(title)
				.font(.system(size: 15, weight: .bold))
			HStack {
				HStack {
					Image(systemName: "car.circle")
						.opacity(viewModel.carIconOpacity(with: description, for: .left))
					Text(DriverSide.left.rawValue)
						.font(.system(size: 16, weight: .medium))
						.opacity(viewModel.carTextOpacity(with: description, for: .left))
				}
				HStack {
					Image(systemName: "car.circle")
						.opacity(viewModel.carIconOpacity(with: description, for: .right))
					Text(DriverSide.right.rawValue)
						.font(.system(size: 16, weight: .medium))
						.opacity(viewModel.carTextOpacity(with: description, for: .right))
				}
			}
		}
		.frame(maxWidth: .infinity, maxHeight: maxHeight)
	}
}

#Preview {
	CountryDetailsView(country: .sampleCountryData)
}
