//
//  SwiftUIView.swift
//  NavigationViewElastic
//
//  Created by Илья Аникин on 06.11.2024.
//

import SwiftUI

// MARK: - Roll transition
struct RollModifier: ViewModifier, Animatable {
    var angle: Angle

    init(angle: Angle? = nil) {
        self.angle = angle ?? .degrees(0)
    }

    var animatableData: Angle {
        get { angle }
        set { angle = newValue }
    }

    func body(content: Content) -> some View {
        content.rotationEffect(angle)
    }
}

extension AnyTransition {
    static func roll(_ angle: Angle) -> Self {
        AnyTransition.modifier(
            active: RollModifier(angle: angle), identity: RollModifier()
        )
    }
}

// MARK: - Scale transition
struct ScaleModifier: ViewModifier {
    let x: CGFloat
    let y: CGFloat
    let anchor: UnitPoint

    func body(content: Content) -> some View {
        content.scaleEffect(x: x, y: y, anchor: anchor)
    }
}

extension AnyTransition {
    static func scale(x: CGFloat? = 1, y: CGFloat? = 1, anchor: UnitPoint = .center) -> Self {
        AnyTransition.modifier(
            active: ScaleModifier(x: x ?? 1, y: y ?? 1, anchor: anchor),
            identity: ScaleModifier(x: 1, y: 1, anchor: anchor)
        )
    }
}
