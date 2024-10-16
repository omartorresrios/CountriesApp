//
//  CountryDataItem.swift
//  CountriesApp
//
//  Created by Omar Torres on 6/7/24.
//

import Foundation
import SwiftData

@Model
final class CountryDataItem {
	@Attribute(.unique)
	var name: NameData
	
	var capital: [String]?
	var flags: FlagsData
	var region: String
	var subregion: String?
	var languages: String?
	var currencies: String?
	var population: Int
	var capitalInfo: CapitalInfoData?
	var car: CarData
	var coatOfArms: CoatOfArmsData
	var timezones: [String]
	var bookmarked: Bool
	
	@Attribute(.externalStorage)
	var flagImageData: Data?
	@Attribute(.externalStorage)
	var coatOfArmsData: Data?
	
	init(name: NameData,
		 capital: [String]?,
		 flags: FlagsData,
		 region: String,
		 subregion: String?,
		 languages: String?,
		 currencies: String?,
		 population: Int,
		 capitalInfo: CapitalInfoData?,
		 car: CarData,
		 coatOfArms: CoatOfArmsData,
		 timezones: [String],
		 bookmarked: Bool = false,
		 flagImageData: Data? = nil,
		 coatOfArmsData: Data? = nil) {
		self.name = name
		self.capital = capital
		self.flags = flags
		self.region = region
		self.subregion = subregion
		self.languages = languages
		self.currencies = currencies
		self.population = population
		self.capitalInfo = capitalInfo
		self.car = car
		self.coatOfArms = coatOfArms
		self.timezones = timezones
		self.bookmarked = bookmarked
		self.flagImageData = flagImageData
		self.coatOfArmsData = coatOfArmsData
	}
	
	func toggleBookMarked() {
		bookmarked.toggle()
	}
	
	func setFlagImage(data: Data) {
		flagImageData = data
	}
}

@Model
class NameData {
	let common: String
	let official: String
	
	init(common: String, official: String) {
		self.common = common
		self.official = official
	}
}
@Model
class FlagsData {
	let png: String
	
	init(png: String) {
		self.png = png
	}
}

@Model
class CapitalInfoData {
	let latlng: [Double]?
	
	init(latlng: [Double]?) {
		self.latlng = latlng
	}
}

@Model
class CarData {
	let side: String
	
	init(side: String) {
		self.side = side
	}
}
@Model
class CoatOfArmsData {
	let png: String?
	
	init(png: String?) {
		self.png = png
	}
}

extension CountryDataItem {
	static let sampleCountryData = CountryDataItem(name: NameData(common: "Ireland",
																  official: "Republic of Ireland"),
												   capital: ["Dublin"],
												   flags: FlagsData(png: "https://flagcdn.com/w320/ie.png"),
												   region: "Europe",
												   subregion: "Northern Europe",
												   languages: "English, Irish",
												   currencies: "",
												   population: 4994724, 
												   capitalInfo: CapitalInfoData(latlng: [-34, -54]),
												   car: CarData(side: "left"),
												   coatOfArms: CoatOfArmsData(png: "https://mainfacts.com/media/images/coats_of_arms/ie.png"),
												   timezones: ["UTC"],
												   bookmarked: false,
												   flagImageData: nil,
												   coatOfArmsData: Data())
	
	static let samplePeruCountryData = CountryDataItem(name: NameData(common: "Peru",
																	  official: "Republic of Peru"),
													   capital: ["Lima"],
													   flags: FlagsData(png: "https://flagcdn.com/w320/pe.png"),
													   region: "Americas",
													   subregion: "South America",
													   languages: "Spanish, Quechua",
													   currencies: "",
													   population: 32971846,
													   capitalInfo: CapitalInfoData(latlng: [-34, -54]),
													   car: CarData(side: "right"),
													   coatOfArms: CoatOfArmsData(png: "https://mainfacts.com/media/images/coats_of_arms/pe.png"),
													   timezones: ["UTC-05:00"],
													   bookmarked: false,
													   flagImageData: Data(),
													   coatOfArmsData: Data())
	
}
