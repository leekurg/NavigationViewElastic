//
//  UIApplication+Extensions.swift
//  NavigationViewElastic
//
//  Created by Илья Аникин on 29.10.2024.
//

import SwiftUI

extension UIApplication {
    var _keyWindow: UIWindow? {
        self.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap(\.windows)
            .first { $0.isKeyWindow }
    }
    
    var keyWindowIntefaceOrientation: UIInterfaceOrientation {
        self._keyWindow?.windowScene?.interfaceOrientation ?? .portrait
    }
    
    func keyWindowInsets() -> EdgeInsets {
        self._keyWindow?.safeAreaInsets.toSwiftUIInsets ?? EdgeInsets()
    }
}
