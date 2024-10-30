//
//  PreferenceKey.swift
//  NavigationViewElastic
//
//  Created by Илья Аникин on 30.10.2024.
//

import SwiftUI

// MARK: - Title
public extension View {
    /// Set the title of the parent ``NavigationElasticView``.
    func nveTitle(_ title: String? = nil) -> some View {
        preference(key: TitleKey.self, value: title)
    }
}

struct TitleKey: PreferenceKey {
    static var defaultValue: String? = nil

    static func reduce(value: inout String?, nextValue: () -> String?) {
        value = value ?? nextValue()
    }
}

// MARK: - Display mode
public extension NVE {
    enum TitleDisplayMode {
        /// Title of the ``NavigationViewElastic`` initially will be shown as a large text.
        case large
        /// Title of the ``NavigationViewElastic`` will be shown as a small text.
        case inline
    }
}

public extension View {
    /// Set the title display mode on the parent ``NavigationElasticView``.
    func nveTitleDisplayMode(_ mode: NVE.TitleDisplayMode? = .large) -> some View {
        preference(key: TitleDisplayModeKey.self, value: mode ?? .large)
    }
}

struct TitleDisplayModeKey: PreferenceKey {
    static var defaultValue: NVE.TitleDisplayMode = .large

    static func reduce(value: inout NVE.TitleDisplayMode, nextValue: () -> NVE.TitleDisplayMode) {
        value = nextValue()
    }
}
