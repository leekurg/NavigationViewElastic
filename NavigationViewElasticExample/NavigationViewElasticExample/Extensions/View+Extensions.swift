//
//  View+Extensions.swift
//  NavigationViewElasticExample
//
//  Created by Илья Аникин on 20.07.2023.
//

import SwiftUI

extension View {
    func paddingWhen(_ edges: Edge.Set = .all, _ length: CGFloat? = nil, when condition: () -> Bool) -> some View {
        Group {
            if !condition() {
                self
            }
            else {
                self.padding(edges, length)
            }
        }
    }

    func eraseToAnyView() -> AnyView {
        AnyView(self)
    }
}
