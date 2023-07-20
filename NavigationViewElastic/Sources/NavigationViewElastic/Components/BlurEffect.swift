//
//  BlurEffect.swift
//  
//
//  Created by Илья Аникин on 20.07.2023.
//

import SwiftUI

struct BlurEffect: UIViewRepresentable {
    @State var style: UIBlurEffect.Style = .regular

    func makeUIView(context: Context) -> UIVisualEffectView {
        return UIVisualEffectView(effect: UIBlurEffect(style: style))
    }
    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {
    }
}
