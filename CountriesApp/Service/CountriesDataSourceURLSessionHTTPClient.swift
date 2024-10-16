//
//  CountriesDataSourceURLSessionHTTPClient.swift
//  CountriesApp
//
//  Created by Omar Torres on 6/10/24.
//

import Foundation

protocol CountriesDataSourceHTTPClient {
	func getAllCountries() async throws -> [Country]
}

final class CountriesDataSourceURLSessionHTTPClient: CountriesDataSourceHTTPClient {
	
	func getAllCountries() async throws -> [Country] {
		do {
			let url = URL(string: "https://restcountries.com/v3.1/all")!
			let request = URLRequest(url: url)
			let (data, _) = try await URLSession.shared.data(for: request)
			let countries = try JSONDecoder().decode([Country].self, from: data)
			return countries
		} catch {
			throw error
		}
	}
}
