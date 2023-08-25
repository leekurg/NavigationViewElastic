//
//  File.swift
//  
//
//  Created by Илья Аникин on 25.08.2023.
//

import Foundation

extension CGFloat {
    func isScrolledDown(_ beyond: CGFloat = 0) -> Bool {
        self <= -beyond
    }

    func isScrolledUp(_ beyond: CGFloat = 0) -> Bool {
        self > beyond
    }
}
