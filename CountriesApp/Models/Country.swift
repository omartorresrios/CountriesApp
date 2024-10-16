//
//  Country.swift
//  CountriesApp
//
//  Created by Omar Torres on 6/6/24.
//

import UIKit

struct Country: Decodable, Identifiable, Equatable {
	static func == (lhs: Country, rhs: Country) -> Bool {
		lhs.id == rhs.id
	}
	
	var id: String {
		name.common
	}
	let name: Name
	let capital: [String]?
	let flags: Flags
	let region: String
	let subregion: String?
	let languages: [String: String]?
	let currencies: [String: Currency]?
	let population: Int
	let capitalInfo: CapitalInfo?
	let car: Car
	let coatOfArms: CoatOfArms
	let timezones: [String]
	
	func countryDataItem(languages: String? = nil, currencies: String? = nil) -> CountryDataItem {
		CountryDataItem(name: NameData(common: name.common,
									   official: name.official),
						capital: capital,
						flags: FlagsData(png: flags.png),
						region: region,
						subregion: subregion,
						languages: languages,
						currencies: currencies,
						population: population, 
						capitalInfo: CapitalInfoData(latlng: capitalInfo?.latlng),
						car: CarData(side: car.side),
						coatOfArms: CoatOfArmsData(png: coatOfArms.png),
						timezones: timezones)
	}
}

struct Name: Decodable {
	let common: String
	let official: String
}

struct Flags: Decodable {
	let png: String
}

struct Currency: Decodable {
	let name: String
	let symbol: String?
}

struct CapitalInfo: Decodable {
	let latlng: [Double]?
}

struct Car: Decodable {
	let side: String
}

struct CoatOfArms: Decodable {
	let png: String?
}

extension Country {
	static let sampleCountry = Country(name: Name(common: "Ireland",
												  official: "Republic of Ireland"),
									   capital: ["Dublin"],
									   flags: Flags(png: "https://flagcdn.com/w320/ie.png"),
									   region: "Europe",
									   subregion: "Northern Europe",
									   languages: ["eng": "English", "gle": "Irish"],
									   currencies: ["EUR": Currency(name: "Euro",
																	symbol: "€")],
									   population: 4994724,
									   capitalInfo: CapitalInfo(latlng: [-45, -55]),
									   car: Car(side: "left"),
									   coatOfArms: CoatOfArms(png: "https://mainfacts.com/media/images/coats_of_arms/ie.png"),
									   timezones: ["UTC"])
	
	static let samplePeruCountry = Country(name: Name(common: "Peru",
												  official: "Republic of Peru"),
										   capital: ["Lima"],
										   flags: Flags(png: "https://flagcdn.com/w320/pe.png"),
										   region: "Americas",
										   subregion: "South America",
										   languages: ["aym": "Aymara", "que": "Quechua", "spa": "Spanish"],
										   currencies: ["PEN": Currency(name: "Peruvian sol",
																		symbol: "S/.")],
										   population: 32971846,
										   capitalInfo: CapitalInfo(latlng: [-45, -55]),
										   car: Car(side: "right"),
										   coatOfArms: CoatOfArms(png: "https://mainfacts.com/media/images/coats_of_arms/pe.png"),
										   timezones: ["UTC-05:00"])
	
}
