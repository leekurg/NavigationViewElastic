//
//  View+Extensions.swift
//  NavigationViewElasticExample
//
//  Created by Илья Аникин on 20.07.2023.
//

import SwiftUI

extension View {
    func paddingWhen(_ edges: Edge.Set = .all, _ length: CGFloat? = nil, when condition: () -> Bool) -> some View {
        self.padding(edges, condition() ? length : 0)
    }

    func eraseToAnyView() -> AnyView {
        AnyView(self)
    }
}
