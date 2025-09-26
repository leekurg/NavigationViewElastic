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

extension View {
    /// Apply to this `View` a transformation defined within **transform** block.
    func apply<Content: View>(@ViewBuilder _ transform: (Self) -> Content) -> some View {
        transform(self)
    }
    
    /// Apply to this `View` a transformations defined within **transform** block if **iOS 26** and above detected.
    /// Otherwise, **transform2** block will be applied.
    @ViewBuilder
    func applyIfiOS26<ThenView: View, ElseView: View>(
        then transform: ((Self) -> ThenView)? = nil,
        otherwise transform2: ((Self) -> ElseView)? = nil
    ) -> some View {
        if #available(iOS 26, *) {
            if let transform {
                transform(self)
            } else {
                self
            }
        } else {
            if let transform2 {
                transform2(self)
            } else {
                self
            }
        }
    }
    
    /// Apply to this `View` a transformations defined within **transform** block if **iOS 26** and above detected.
    /// Otherwise, this view will not be modified.
    @ViewBuilder
    func applyIfiOS26<ThenView: View>(_ transform: (Self) -> ThenView) -> some View {
        if #available(iOS 26, *) {
            transform(self)
        } else {
            self
        }
    }

    /// Apply to this `View` a transformations defined within **transform** block iOS version is below **iOS 26**.
    /// Otherwise, this view will not be modified.
    @ViewBuilder
    func applyIfNotiOS26<Content: View>(_ transform: @escaping (Self) -> Content) -> some View {
        if #available(iOS 26, *) {
            self
        } else {
            transform(self)
        }
    }
}
