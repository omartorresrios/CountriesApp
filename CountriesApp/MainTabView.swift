//
//  MainTabView.swift
//  CountriesApp
//
//  Created by Omar Torres on 6/8/24.
//

import SwiftUI
import SwiftData

struct MainTabView: View {
	let modelContainer: ModelContainer
	let dataSource: CountriesDataSource
	
	@MainActor
	init() {
		do {
			modelContainer = try ModelContainer(for: CountryDataItem.self)
		} catch {
			fatalError("Couldn't create ModelContainer for CountryDataItem")
		}
		let dataSourceHTTPClient = CountriesDataSourceURLSessionHTTPClient()
		dataSource = CountriesDataSource(httpClient: dataSourceHTTPClient, modelContainer: modelContainer)
	}
	
	var body: some View {
		TabView {
			CountriesView(httpClient: CountriesURLSessionHTTPClient(),
						  dataSource: dataSource)
				
				.tabItem {
					Label("Search", systemImage: "magnifyingglass")
				}
			Bookmarksview()
				
				.tabItem {
					Label("Saved", systemImage: "bookmark.fill")
				}
		}
		.modelContainer(modelContainer)
	}
}

#Preview {
	MainTabView()
}
