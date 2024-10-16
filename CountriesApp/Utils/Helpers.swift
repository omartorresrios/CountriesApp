//
//  Helpers.swift
//  CountriesApp
//
//  Created by Omar Torres on 6/7/24.
//

import SwiftUI

extension Image {
	func applyModifiers(width: CGFloat?, height: CGFloat?, contentMode: ContentMode) -> some View {
		self
			.resizable()
			.aspectRatio(contentMode: contentMode)
			.frame(width: width, height: height)
			.clipped()
   }
}

extension View {
	func convertItToCard() -> some View {
		self
			.background(
				RoundedRectangle(cornerRadius: 15)
					.fill(Color.white)
					.shadow(color: .gray, radius: 2, x: 0, y: 2)
			)
	}
}
