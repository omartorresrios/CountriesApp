//
//  CountryDetailsViewModel.swift
//  CountriesApp
//
//  Created by Omar Torres on 6/7/24.
//

import SwiftUI

@MainActor
class CountryDetailsViewModel: ObservableObject {
	private let httpClient: CountryDetailsHTTPClient
	@Published var isLoading = false
	
	init(httpClient: CountryDetailsHTTPClient) {
		self.httpClient = httpClient
	}
	
	func populationDescription(population: Int) -> String {
		return "\(population.formatted())"
	}
	
	func carDriverDescription(side: String) -> String {
		return side.uppercased()
	}
	
	func timezonesDescription(timezones: [String]) -> String {
		return joined(for: timezones, with: ", ")
	}
	
	func bookmarkIcon(bookmarked: Bool) -> Image {
		bookmarked ? Image(systemName: "bookmark.fill") : Image(systemName: "bookmark")
	}
	
	func carIconOpacity(with description: String, for side: DriverSide) -> Double {
		description.uppercased() == side.rawValue ? 1 : 0
	}
	
	func carTextOpacity(with description: String, for side: DriverSide) -> Double {
		description.uppercased() == side.rawValue ? 1 : 0.1
	}
	
	func downloadCoatOfArmsImage(for country: CountryDataItem) {
		if country.coatOfArmsData == nil, let coatOfArmsUrlString = country.coatOfArms.png {
			isLoading = true
			Task {
				do {
					let coatOfArmsData = try await httpClient.getCoatOfArmsData(with: coatOfArmsUrlString)
					await MainActor.run {
						country.coatOfArmsData = coatOfArmsData
						isLoading = false
					}
				} catch {
					isLoading = false
				}
			}
		}
	}
	
	private func joined(for values: [String], with separator: String) -> String {
		values.joined(separator: separator)
	}
}
