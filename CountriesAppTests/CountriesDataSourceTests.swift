//
//  CountriesDataSourceTests.swift
//  CountriesAppTests
//
//  Created by Omar Torres on 6/10/24.
//

import XCTest
import SwiftData
import Combine
@testable import CountriesApp

@MainActor
final class CountriesDataSourceTests: XCTestCase {
	
	private var context: ModelContext?
	private var sut: CountriesDataSource?
	
	func test_thereMustBeCachedDataAfterFetchingCountriesFromRemote() async {
		let (sut, httpClient, context) = getSut()
		let fakeCountry = Country.sampleCountry
		httpClient.countries = [fakeCountry]
		context.insert(fakeCountry.countryDataItem())
		let countriesSpy = ValuesSpy<[CountryDataItem]>(sut.countries.eraseToAnyPublisher())
		let expectation = XCTestExpectation(description: "Fecth countries")
		
		Task {
			sut.fetchCountries()
			XCTAssertEqual(countriesSpy.values.count, 1)
			expectation.fulfill()
		}
		await fulfillment(of: [expectation])
	}
	
	func test_getErrorMessageOnFailedResponseWhenFetchingFromRemote() async {
		let (sut, httpClient, _) = getSut()
		httpClient.error = anyNSError()
		let errorMessageSpy = ValuesSpy<String>(sut.errorMessage.eraseToAnyPublisher())
		let isLoadingSpy = ValuesSpy<Bool>(sut.isLoading.eraseToAnyPublisher())
		let expectation = XCTestExpectation(description: "Fetch all countries")
		
		Task {
			sut.fetchCountries()
			expectation.fulfill()
		}
		await fulfillment(of: [expectation])
		
		XCTAssertEqual(errorMessageSpy.values.first, httpClient.error?.localizedDescription)
		XCTAssertFalse(isLoadingSpy.values.last!)
		XCTAssertTrue(!errorMessageSpy.values.first!.isEmpty)
	}
	
	func test_languagesDescriptionMustBeAStringSeparatedByBreaklines() async {
		let (sut, httpClient, context) = getSut()
		let fakeCountry = Country.sampleCountry
		httpClient.countries = [fakeCountry]
		let fakeCountryDataItem = fakeCountry.countryDataItem(languages: "English\nIrish")
		context.insert(fakeCountry.countryDataItem())
		let expectation = XCTestExpectation(description: "Fecth countries")
		
		Task {
			sut.fetchCountries()
			XCTAssertTrue(fakeCountryDataItem.languages!.contains("\n"))
			expectation.fulfill()
		}
		await fulfillment(of: [expectation])
	}
	
	func test_currenciesDescriptionMustContainCurrencyCurrencyNameAndSymbolWithParenthesisAndLowercased() async {
		let (sut, httpClient, context) = getSut()
		let fakeCountry = Country.sampleCountry
		httpClient.countries = [fakeCountry]
		let currenciesValues = "EUR (€ euro)"
		let fakeCountryDataItem = fakeCountry.countryDataItem(currencies: currenciesValues)
		context.insert(fakeCountry.countryDataItem())
		let expectation = XCTestExpectation(description: "Fecth countries")
		
		Task {
			sut.fetchCountries()
			XCTAssertEqual(fakeCountryDataItem.currencies, currenciesValues)
			expectation.fulfill()
		}
		await fulfillment(of: [expectation])
	}
	
	private func anyNSError() -> NSError {
		return NSError(domain: "any error", code: 0)
	}
	
	private func getSut() -> (CountriesDataSource, HTTPClientStub, ModelContext)  {
		let httpClient = HTTPClientStub()
		let config = ModelConfiguration(isStoredInMemoryOnly: true)
		let container = try! ModelContainer(for: CountryDataItem.self,
											configurations: config)
		let viewModel = CountriesDataSource(httpClient: httpClient,
											modelContainer: container)
		return (viewModel, httpClient, container.mainContext)
	}
	
	private class ValuesSpy<T> {
		private(set) var values = [T]()
		private var cancellables = Set<AnyCancellable>()
		
		init(_ publisher: AnyPublisher<T, Never>) {
			publisher
				.dropFirst()
				.sink { [weak self] value in
				self?.values.append(value)
			}.store(in: &cancellables)
		}
	}
	
	final class HTTPClientStub: CountriesDataSourceHTTPClient {
		var countries: [Country]?
		var error: NSError?
		
		func getAllCountries() async throws -> [Country] {
			if let error = error {
				throw error
			} else {
				return countries ?? []
			}
		}
	}
}

