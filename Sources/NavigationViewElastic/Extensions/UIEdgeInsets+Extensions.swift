//
//  UIEdgeInsets+Extensions.swift
//  NavigationViewElastic
//
//  Created by Илья Аникин on 29.10.2024.
//

import SwiftUI

extension UIEdgeInsets {
    var toSwiftUIInsets: EdgeInsets {
        EdgeInsets(top: top, leading: left, bottom: bottom, trailing: right)
    }
}
