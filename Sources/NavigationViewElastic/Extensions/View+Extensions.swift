//
//  View+Extensions.swift
//  NavigationViewElastic
//
//  Created by Илья Аникин on 26.10.2024.
//

import SwiftUI

extension View {
    /// Masks a **mask** ``View`` out of this view.
    @inlinable func reverseMask<Mask: View>(
        alignment: Alignment = .center,
        @ViewBuilder _ mask: () -> Mask
    ) -> some View {
        self.mask(
            Rectangle()
                .overlay(alignment: alignment) {
                    mask()
                        .blendMode(.destinationOut)
                }
        )
    }
}
