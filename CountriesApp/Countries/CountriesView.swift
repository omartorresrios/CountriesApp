//
//  CountriesView.swift
//  CountriesApp
//
//  Created by Omar Torres on 6/5/24.
//

import SwiftUI
import SwiftData
import Combine

struct CountriesView: View {
	@State private var viewModel: CountriesViewModel
	@State var searchText = ""
	private let navigationTitle = "Countries"
	private let searchPrompt = "Search"
	
	@MainActor
	init(httpClient: CountriesHTTPClient,
		 dataSource: CountriesDataSource) {
		_viewModel = State(initialValue: CountriesViewModel(countriesHTTPClient: httpClient,
															dataSource: dataSource))
	}
	
	var body: some View {
		NavigationStack {
			VStack(alignment: .leading) {
				if viewModel.isLoading {
					ProgressView()
				} else if !viewModel.searchErrorMessage.isEmpty {
					errorMessageView(viewModel.searchErrorMessage)
				} else if !viewModel.errorMessage.isEmpty {
					errorMessageView(viewModel.errorMessage)
				} else {
					countriesList
						.searchable(text: $searchText, prompt: searchPrompt)
				}
			}
			.navigationBarTitleDisplayMode(.inline)
			.navigationTitle(navigationTitle)
		}
		.onChange(of: searchText) {
			viewModel.triggerSearch(with: searchText)
		}
	}
	
	@MainActor
	private var countriesList: some View {
		List(viewModel.filteredCountries) { country in
			CountryItemView(country: country, isLoading: $viewModel.isFlagLoading)
				.onAppear {
					viewModel.downloadFlagImage(for: country)
				}
				.listRowSeparator(.hidden)
				.background(
					NavigationLink(destination: CountryDetailsView(country: country)) {
						EmptyView()
					}.opacity(0)
				)
				
		}
		.listStyle(.sidebar)
		.listRowSpacing(10)
	}
	
	private func errorMessageView(_ message: String) -> some View {
		VStack {
			Text(message)
		}
	}
}

#Preview {
	let config = ModelConfiguration(isStoredInMemoryOnly: true)
	let container = try! ModelContainer(for: CountryDataItem.self,
										configurations: config)
	return CountriesView(httpClient: CountriesURLSessionHTTPClient(),
						 dataSource: CountriesDataSource(httpClient: CountriesDataSourceURLSessionHTTPClient(),
														 modelContainer: container))
}
