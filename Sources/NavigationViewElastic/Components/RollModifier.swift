//
//  RollModifier.swift
//  
//
//  Created by Илья Аникин on 29.08.2023.
//

import SwiftUI

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
