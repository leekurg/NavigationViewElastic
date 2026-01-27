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
    enum PreferredTitleDisplayMode {
        /// Title of the ``NavigationViewElastic`` in portrait orientation will be shown
        /// as a large text, and in landscape orientation as a small text.
        case auto
        /// Title of the ``NavigationViewElastic`` initially will be shown as a large text.
        case large
        /// Title of the ``NavigationViewElastic`` will be shown as a small text.
        case inline
    }
    
    enum TitleDisplayMode {
        /// Title of the ``NavigationViewElastic`` is displaying as a large text.
        case large
        /// Title of the ``NavigationViewElastic`` is displaying as a small text.
        case inline
    }
    
    enum ScrollAnchor {
        case topInline
        case topLarge
        case bottom
    }
}

public extension View {
    /// Set the title display mode on the parent ``NavigationElasticView``.
    func nveTitleDisplayMode(_ mode: NVE.PreferredTitleDisplayMode? = .auto) -> some View {
        preference(key: PreferredTitleDisplayModeKey.self, value: mode ?? .auto)
    }
}

struct PreferredTitleDisplayModeKey: PreferenceKey {
    static var defaultValue: NVE.PreferredTitleDisplayMode = .auto

    static func reduce(value: inout NVE.PreferredTitleDisplayMode, nextValue: () -> NVE.PreferredTitleDisplayMode) {
        value = nextValue()
    }
}

// MARK: - Display mode changed
struct TitleDisplayModeChangedKey: PreferenceKey {
    static var defaultValue: NVE.TitleDisplayMode = .inline

    static func reduce(value: inout NVE.TitleDisplayMode, nextValue: () -> NVE.TitleDisplayMode) {
        value = nextValue()
    }
}

// MARK: - Scroll rect changed
public struct NVEScrollRectPreferenceKey: SwiftUI.PreferenceKey {
    public static var defaultValue: CGRect { .zero }

    public static func reduce(value: inout CGRect, nextValue: () -> CGRect) { }
}
