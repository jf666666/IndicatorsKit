//
//  View+indicatorOverlay.swift
//  IndicatorsKit
//
//  Created by royal on 17/07/2022.
//

import SwiftUI

public extension View {
	func indicatorOverlay(model: Indicators, alignment: Alignment = .top) -> some View {
		overlay(IndicatorsOverlay(model: model), alignment: alignment)
	}
}
