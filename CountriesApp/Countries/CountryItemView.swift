//
//  CountryItemView.swift
//  CountriesApp
//
//  Created by Omar Torres on 6/6/24.
//

import SwiftUI

struct CountryItemView: View {
	private let country: CountryDataItem
	@Binding var isLoading: Bool
	
	init(country: CountryDataItem,
		 isLoading: Binding<Bool> = .constant(false)) {
		self.country = country
		_isLoading = isLoading
	}
	
	var body: some View {
		HStack(alignment: .top, spacing: 10) {
			HStack(spacing: 10) {
				flagImage
				VStack(alignment: .leading) {
					Text(country.name.common)
						.font(.system(size: 15, weight: .bold))
					Text(country.name.official)
						.font(.system(size: 15, weight: .regular))
					if let capital = country.capital?.first {
						Text(capital)
							.font(.system(size: 12))
							.foregroundStyle(.gray)
					}
				}
			}
			Spacer()
			bookmarkIcon
		}
	}
	
	private var flagImage: some View {
		VStack {
			if isLoading {
				ProgressView()
					.frame(width: 90, height: 50)
			} else if let flagImage = country.flagImageData,
					  let flagUIImage = UIImage(data: flagImage) {
				VStack(alignment: .leading, spacing: 15) {
					Image(uiImage: flagUIImage)
						.applyModifiers(width: 90, height: 50, contentMode: .fill)
				}
			}
		}
	}
	
	private var bookmarkIcon: some View {
		country.bookmarked ?
		Image(systemName: "bookmark.fill")
			.renderingMode(.template)
			.foregroundColor(.blue)
		: Image(systemName: "bookmark")
			.renderingMode(.template)
			.foregroundColor(.blue)
	}
}

#Preview {
	CountryItemView(country: .sampleCountryData, isLoading: .constant(false))
}
