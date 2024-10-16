//
//  CountriesViewModel.swift
//  CountriesApp
//
//  Created by Omar Torres on 6/6/24.
//

import Foundation
import Combine
import SwiftData

@Observable
@MainActor
final class CountriesViewModel {
	@ObservationIgnored
	private let dataSource: CountriesDataSource
	private let httpClient: CountriesHTTPClient
	var searchText = CurrentValueSubject<String, Never>("")
	var searchResult = ""
	var countries: [CountryDataItem] = []
	var isLoading = false
	var isFlagLoading = false
	var errorMessage = ""
	var searchErrorMessage = ""
	private var cancellables = Set<AnyCancellable>()
	
	init(countriesHTTPClient: CountriesHTTPClient,
		 dataSource: CountriesDataSource) {
		self.dataSource = dataSource
		self.httpClient = countriesHTTPClient
		bindingSubscriptions()
	}
	
	private func bindingSubscriptions() {
		dataSource.countries
			.receive(on: DispatchQueue.main)
			.sink { [weak self] countries in
				self?.countries = countries
			}.store(in: &cancellables)
		
		dataSource.isLoading
			.receive(on: DispatchQueue.main)
			.sink { [weak self] isLoading in
				self?.isLoading = isLoading
			}.store(in: &cancellables)
		
		dataSource.errorMessage
			.receive(on: DispatchQueue.main)
			.sink { [weak self] message in
				self?.errorMessage = message
			}.store(in: &cancellables)
		
		searchText
			.debounce(for: .seconds(0.5), scheduler: DispatchQueue.main)
			.removeDuplicates()
			.sink { [weak self] searchText in
				guard let self else { return }
				self.searchResult = searchText
			}.store(in: &cancellables)
	}
	
	func triggerSearch(with text: String) {
		searchText.send(text)
	}
	
	var filteredCountries: [CountryDataItem] {
		guard searchResult.count > 2 else { return countries }
		var descriptor = FetchDescriptor<CountryDataItem>()
		descriptor.predicate = #Predicate {
			$0.name.common.contains(searchResult)
		}
		if let filteredCountries = try? dataSource.modelContext.fetch(descriptor) {
			return filteredCountries
		} else {
			searchErrorMessage = "Couldn't get the search results. Please try again."
			return []
		}
	}
	
	func downloadFlagImage(for country: CountryDataItem) {
		if country.flagImageData == nil {
			isFlagLoading = true
			Task {
				do {
					let flagImageData = try await httpClient.getFlagImageData(with: country.flags.png)
					country.flagImageData = flagImageData
					isFlagLoading = false
				} catch {
					errorMessage = error.localizedDescription
					isFlagLoading = false
				}
			}
		}
	}
}
