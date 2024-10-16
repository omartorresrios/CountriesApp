//
//  CountriesDataSource.swift
//  CountriesApp
//
//  Created by Omar Torres on 6/10/24.
//

import Foundation
import SwiftData
import Combine

final class CountriesDataSource {
	private(set) var modelContext: ModelContext
	private let httpClient: CountriesDataSourceHTTPClient
	var countries = CurrentValueSubject<[CountryDataItem], Never>([])
	var isLoading = CurrentValueSubject<Bool, Never>(false)
	var errorMessage = CurrentValueSubject<String, Never>("")
	private let failedToLoadCountries = "There was an error trying to load the cuntries. Please try again."
	let descriptor = FetchDescriptor<CountryDataItem>()
	
	@MainActor
	init(httpClient: CountriesDataSourceHTTPClient, modelContainer: ModelContainer) {
		self.httpClient = httpClient
		self.modelContext = modelContainer.mainContext
		fetchCountries()
	}
	
	func fetchCountries() {
		do {
			let cachedCountries = try modelContext.fetch(descriptor)
			if cachedCountries.isEmpty {
				fetchAllCountriesFromRemote()
			} else {
				fetchCountriesFromCache()
			}
		} catch {
			errorMessage.send(failedToLoadCountries)
		}
	}
	
	private func fetchAllCountriesFromRemote() {
		isLoading.send(true)
		Task {
			do {
				let countries = try await httpClient.getAllCountries()
				cacheCountries(countries)
				isLoading.send(false)
			} catch {
				isLoading.send(false)
				errorMessage.send(error.localizedDescription)
			}
		}
	}
	
	private func fetchCountriesFromCache() {
		return fetchCountriesFromContext()
	}
	
	private func fetchCountriesFromContext() {
		do {
			countries.send(try modelContext.fetch(descriptor))
		} catch {
			errorMessage.send(failedToLoadCountries)
		}
	}
	
	private func cacheCountries(_ countries: [Country]) {
		countries.forEach { country in
			let languagesDescription = languagesDescription(languages: country.languages?.values)
			let currenciesDescription = currenciesDescription(currencies: country.currencies)
			let countryDataItem = country.countryDataItem(languages: languagesDescription,
														  currencies: currenciesDescription)
			modelContext.insert(countryDataItem)
		}
		do {
			self.countries.send(try modelContext.fetch(descriptor))
		} catch {
			errorMessage.send(failedToLoadCountries)
		}
	}
	
	private func languagesDescription(languages: Dictionary<String, String>.Values? = nil) -> String? {
		if let languages = languages {
			let languageValues = languages.map { "\($0)" }.map { "\u{2022} \($0)" }
			return joined(for: languageValues, with: "\n")
		} else {
			return nil
		}
	}
	
	private func currenciesDescription(currencies: [String: Currency]? = nil) -> String? {
		if let currencies = currencies {
			let currencyValues = currencies.map { "\($0.key) (\($0.value.symbol ?? "") \($0.value.name.lowercased()))" }
			return joined(for: currencyValues, with: ", ")
		} else {
			return nil
		}
	}
	
	private func joined(for values: [String], with separator: String) -> String {
		values.joined(separator: separator)
	}
}
