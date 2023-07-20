//
//  Clamp.swift
//  
//
//  Created by Илья Аникин on 20.07.2023.
//

import Foundation

func clamp<T: Comparable>(_ value: T, min: T? = nil, max: T? = nil) -> T {
    var clamped = value
    if let min = min {
        clamped = clamped < min ? min : clamped
    }

    if let max = max {
        clamped = clamped > max ? max : clamped
    }

    return clamped
}
