//
//  CountriesViewModelTests.swift
//  CountriesAppTests
//
//  Created by Omar Torres on 6/7/24.
//

import XCTest
import Combine
import SwiftData
@testable import CountriesApp

@MainActor
final class CountriesViewModelTests: XCTestCase {
	
	func test_flagImageDataMustHaveDataOnSuccessfulResponse() async {
		let (sut, httpClient, context) = getSut()
		httpClient.data = Data("any data".utf8)
		let country = CountryDataItem.samplePeruCountryData
		context.insert(country)
		let expectation = XCTestExpectation(description: "Download flag image")
		
		Task {
			sut.downloadFlagImage(for: country)
			expectation.fulfill()
		}
		await fulfillment(of: [expectation])
		
		XCTAssertNotNil(country.flagImageData)
	}
	
	func test_getErrorOnFailedFlagImageRequestResponse() async {
		let (sut, httpClient, context) = getSut()
		httpClient.error = anyNSError()
		let country = CountryDataItem.samplePeruCountryData
		country.flagImageData = nil
		context.insert(country)
		let expectation = XCTestExpectation(description: "Download flag image")
		
		Task {
			sut.downloadFlagImage(for: country)
			expectation.fulfill()
		}
		await fulfillment(of: [expectation])
		
		XCTAssertEqual(sut.errorMessage, httpClient.error?.localizedDescription)
	}
	
	func test_isValidSearchMustBeFalseIfSearchResultIsLessThan3Characters() {
		let (sut, _, context) = getSut()
		let country = CountryDataItem.samplePeruCountryData
		context.insert(country)
		let searchTextSpy = SearchTextSpy(sut.searchText.eraseToAnyPublisher())
		
		sut.triggerSearch(with: "peru")
		
		XCTAssertEqual(searchTextSpy.values, ["peru"])
	}
	
	private func getSut() -> (CountriesViewModel, HTTPClientStub, ModelContext)  {
		let httpClient = HTTPClientStub()
		let config = ModelConfiguration(isStoredInMemoryOnly: true)
		let container = try! ModelContainer(for: CountryDataItem.self,
											configurations: config)
		let countriesDataSourceHttpClient = CountriesDataSourceURLSessionHTTPClient()
		let dataSource = CountriesDataSource(httpClient: countriesDataSourceHttpClient,
											 modelContainer: container)
		let viewModel = CountriesViewModel(countriesHTTPClient: httpClient,
										   dataSource: dataSource)
		return (viewModel, httpClient, container.mainContext)
	}
	
	private func anyNSError() -> NSError {
		return NSError(domain: "any error", code: 0)
	}
	
	private class SearchTextSpy {
		private(set) var values = [String]()
		private var cancellables = Set<AnyCancellable>()
		
		init(_ publisher: AnyPublisher<String, Never>) {
			publisher
				.dropFirst()
				.sink { [weak self] value in
				self?.values.append(value)
			}.store(in: &cancellables)
		}
	}
	
	final class HTTPClientStub: CountriesHTTPClient {
		var data: Data?
		var error: NSError?
		
		func getFlagImageData(with urlString: String) async throws -> Data {
			if let error = error {
				throw error
			} else {
				return data ?? Data()
			}
		}
	}
}
