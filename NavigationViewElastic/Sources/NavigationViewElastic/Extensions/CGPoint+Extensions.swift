//
//  CGPoint+Extensions.swift
//  
//
//  Created by Илья Аникин on 20.07.2023.
//

import Foundation

extension CGPoint {
    func isScrolledDown(_ beyond: CGFloat = 0) -> Bool {
        self.y <= -beyond
    }

    func isScrolledUp(_ beyond: CGFloat = 0) -> Bool {
        self.y > beyond
    }
}
