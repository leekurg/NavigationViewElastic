//
//  Color+Extensions.swift
//  NavigationViewElasticExample
//
//  Created by Илья Аникин on 20.07.2023.
//

import SwiftUI

extension Color {
    static var standartColors: [Color] = [
        .red,
        .orange,
        .yellow,
        .green,
        .blue,
        .purple,
        .pink
    ]

    static var lastRandomColor = Color.white

    static var random: Color {
        var color = standartColors.randomElement()!

        if color == lastRandomColor {
            color = standartColors.randomElement()!
            lastRandomColor = color
            return color
        } else {
            lastRandomColor = color
            return color
        }
    }
}
