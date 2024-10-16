//
//  BookmarksView.swift
//  CountriesApp
//
//  Created by Omar Torres on 6/8/24.
//

import SwiftUI
import SwiftData

struct Bookmarksview: View {
	@Environment(\.modelContext) private var modelContext
	@Query(filter: #Predicate<CountryDataItem> {
		$0.bookmarked
	}) private var countries: [CountryDataItem]
	
	var body: some View {
		VStack {
			if countries.isEmpty {
				Text("You don't have any countries saved yet.")
			} else {
				List(countries) { country in
					CountryItemView(country: country)
						.listRowSeparator(.hidden)
				}
				.listStyle(.sidebar)
				.listRowSpacing(10)
			}
		}
		
	}
}

#Preview {
	Bookmarksview()
}

