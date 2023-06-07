//
//  IndicatorsOverlay.swift
//  IndicatorsKit
//
//  Created by royal on 17/07/2022.
//

import SwiftUI

public struct IndicatorsOverlay: View {
	@ObservedObject var model: Indicators

	@State var isExpanded: Bool = false
	@State var dragOffset: CGSize = .zero

	let dragInWrongDirectionMultiplier: Double = 0.015
	let dragThreshold: Double = 20
	let transition: AnyTransition = .asymmetric(insertion: .move(edge: .top), removal: .move(edge: .top).combined(with: .opacity))
	let animation: Animation = .interpolatingSpring(mass: 0.5, stiffness: 45, damping: 45, initialVelocity: 15)

	public init(model: Indicators) {
		self.model = model
	}

	var dragGesture: some Gesture {
		DragGesture()
			.onChanged {
				dragOffset.width = $0.translation.width * dragInWrongDirectionMultiplier
				dragOffset.height = $0.translation.height < 0 ? $0.translation.height : $0.translation.height * dragInWrongDirectionMultiplier
			}
			.onEnded {
				dragOffset = .zero

				if $0.translation.height < dragThreshold {
					// dismiss
					model.dismiss()
				} else if $0.translation.height > 0 {
					// toggle expansion if possible
					if let indicator = model.activeIndicator,
					   indicator.expandedText != nil {
						#if canImport(UIKit)
						UIImpactFeedbackGenerator(style: .soft).impactOccurred()
						#endif

						isExpanded.toggle()
						isExpanded ? model.timer?.invalidate() : model.updateTimer()
					}
				}
			}
	}

	public var body: some View {
		ZStack {
			if let indicator = model.activeIndicator {
				IndicatorView(indicator: indicator, isExpanded: $isExpanded)
					.shadow(color: .black.opacity(0.115), radius: 10, x: 0, y: 0)
					.offset(dragOffset)
					.gesture(dragGesture)
					.transition(transition)
					.animation(animation, value: isExpanded)
			}
		}
		.frame(maxHeight: .infinity, alignment: .top)
		.padding(.horizontal)
		.padding(.top, 5)
		.animation(animation, value: model.activeIndicator != nil)
		.animation(animation, value: dragOffset)
	}
}

struct IndicatorsOverlay_Previews: PreviewProvider {
	static var previews: some View {
		var model: Indicators {
			let model = Indicators()
			model.display(.init(id: "", icon: nil, headline: "Headline", dismissType: .manual))
			return model
		}

		return Text("")
			.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
			.indicatorOverlay(model: model)
	}
}
