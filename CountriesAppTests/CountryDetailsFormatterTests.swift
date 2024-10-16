//
//  CountryDetailsFormatterTests.swift
//  CountriesAppTests
//
//  Created by Omar Torres on 6/7/24.
//

import XCTest
@testable import CountriesApp

@MainActor
final class CountryDetailsFormatterTests: XCTestCase {
	
	func test_populationDescriptionMustBeFormatted() {
		let (sut, _) = getSut()
		
		let description = sut.populationDescription(population: 4354400)
		
		XCTAssertTrue(description.contains(","))
	}
	
	func test_carDriverDescriptionMustBeUppercased() {
		let (sut, _) = getSut()
		
		let description = sut.carDriverDescription(side: "right")
		
		XCTAssertEqual(description, "RIGHT")
	}
	
	func test_timezonesDescriptionMustHaveCommas() {
		let (sut, _) = getSut()
		
		let description = sut.timezonesDescription(timezones: ["UTC", "UTC-5"])
		
		XCTAssertTrue(description.contains(","))
	}
	
	func test_carIconOpacityMustBe1IfDescriptionAndSideAreTheSame() {
		let (sut, _) = getSut()
		
		let description = sut.carIconOpacity(with: "left", for: .left)
		
		XCTAssertEqual(description, 1)
	}
	
	func test_carTextOpacityMustBe0IfDescriptionAndSideAreNotTheSame() {
		let (sut, _) = getSut()
		
		let description = sut.carIconOpacity(with: "left", for: .right)
		
		XCTAssertEqual(description, 0)
	}
	
	func test_carTextOpacityMustBe1IfDescriptionAndSideAreTheSame() {
		let (sut, _) = getSut()
		
		let description = sut.carIconOpacity(with: "left", for: .left)
		
		XCTAssertEqual(description, 1)
	}
	
	func test_carIconOpacityMustBe01IfDescriptionAndSideAreNotTheSame() {
		let (sut, _) = getSut()
		
		let description = sut.carTextOpacity(with: "left", for: .right)
		
		XCTAssertEqual(description, 0.1)
	}
	
	func test_coatOfArmsImageDataMustHaveDataOnSuccessfulResponse() async {
		let (sut, httpClient) = getSut()
		httpClient.data = Data("any data".utf8)
		let country = CountryDataItem.samplePeruCountryData
		let expectation = XCTestExpectation(description: "Download coat of arms image")
		
		Task {
			sut.downloadCoatOfArmsImage(for: country)
			expectation.fulfill()
		}
		await fulfillment(of: [expectation])
		
		XCTAssertNotNil(country.coatOfArmsData)
	}
	
	private func getSut() -> (CountryDetailsViewModel, HTTPClientStub) {
		let httpClient = HTTPClientStub()
		let viewModel = CountryDetailsViewModel(httpClient: httpClient)
		return (viewModel, httpClient)
	}
	
	final class HTTPClientStub: CountryDetailsHTTPClient {
		var data: Data?
		var error: NSError?
		
		func getCoatOfArmsData(with urlString: String) async throws -> Data {
			if let error = error {
				throw error
			} else {
				return data ?? Data()
			}
		}
	}
}
