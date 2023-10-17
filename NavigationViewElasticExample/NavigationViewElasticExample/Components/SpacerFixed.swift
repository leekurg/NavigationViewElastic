//
//  SpacerFixed.swift
//  NavigationViewElasticExample
//
//  Created by Илья Аникин on 17.10.2023.
//

import SwiftUI

struct SpacerFixed: View {
    private let height: CGFloat?

    init(_ height: CGFloat? = nil) {
        self.height = height
    }

    var body: some View {
        Color.clear.frame(height: height)
    }
}

#Preview {
    SpacerFixed(10)
        .border(.red)
}
