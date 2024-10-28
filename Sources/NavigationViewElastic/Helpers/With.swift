//
//  With.swift
//  NavigationViewElastic
//
//  Created by Илья Аникин on 27.10.2024.
//

/// Createa a mutable copy of value and perform `mutate` on it.
func with<T>(_ value: T, _ mutate: (inout T) -> ()) -> T {
    var copy = value
    mutate(&copy)
    return copy
}
