//
//  CountriesURLSessionHTTPClient.swift
//  CountriesApp
//
//  Created by Omar Torres on 6/6/24.
//

import Foundation

protocol CountriesHTTPClient {
	func getFlagImageData(with urlString: String) async throws -> Data
}

final class CountriesURLSessionHTTPClient: CountriesHTTPClient {
	
	func getFlagImageData(with urlString: String) async throws -> Data {
		do {
			let url = URL(string: urlString)!
			let request = URLRequest(url: url)
			let (data, _) = try await URLSession.shared.data(for: request)
			return data
		} catch {
			throw error
		}
	}
}
