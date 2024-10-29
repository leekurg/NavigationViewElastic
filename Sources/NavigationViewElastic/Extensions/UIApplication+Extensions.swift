//
//  UIApplication+Extensions.swift
//  NavigationViewElastic
//
//  Created by Илья Аникин on 29.10.2024.
//

import SwiftUI

extension UIApplication {
    func keyWindowInsets() -> EdgeInsets {
        let keyWindow = self.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap(\.windows)
            .first { $0.isKeyWindow }

        return keyWindow?.safeAreaInsets.toSwiftUIInsets ?? EdgeInsets()
    }
}
