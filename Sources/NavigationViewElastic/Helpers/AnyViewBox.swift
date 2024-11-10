//
//  AnyViewBox.swift
//  NavigationViewElastic
//
//  Created by Илья Аникин on 09.11.2024.
//

import SwiftUI

struct AnyViewBox: Equatable {
    let id: AnyHashable
    let anyView: AnyView
    
    init<Content: View>(content: () -> Content) {
        self.id = UUID()
        self.anyView = AnyView(content())
    }

    static func == (lhs: AnyViewBox, rhs: AnyViewBox) -> Bool {
        lhs.id == rhs.id
    }
}
