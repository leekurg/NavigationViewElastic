//
//  ActivityIndicator.swift
//  
//
//  Created by Илья Аникин on 20.07.2023.
//

import SwiftUI

struct ActivityIndicator: UIViewRepresentable {
    typealias UIView = UIActivityIndicatorView

    var isAnimating: Bool
    private var configuration: (Self.UIView) -> Void

    init(
        isAnimating: Bool,
        configuration: @escaping (Self.UIView) -> Void = { _ in }
    ) {
        self.isAnimating = isAnimating
        self.configuration = configuration
    }

    func makeUIView(context: UIViewRepresentableContext<Self>) -> UIView { UIView() }
    func updateUIView(_ uiView: UIView, context: UIViewRepresentableContext<Self>) {
        isAnimating ? uiView.startAnimating() : uiView.stopAnimating()
        configuration(uiView)
    }
}

extension View where Self == ActivityIndicator {
    func configure(_ configuration: @escaping (Self.UIView) -> Void) -> Self {
        Self.init(isAnimating: self.isAnimating, configuration: configuration)
    }
}

#Preview {
    ActivityIndicator(isAnimating: true)
}
