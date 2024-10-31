//
//  NVEConfigModifier.swift
//  NavigationViewElastic
//
//  Created by Илья Аникин on 31.10.2024.
//

import SwiftUI

public extension View {
    /// Mutates an environmental config for ``NavigationViewElastic``.
    ///
    /// Changes made to config will be applied to all ``NavigationViewElastic`` views
    /// down the view hierarchy.
    ///
    @ViewBuilder func nveConfig(_ mutation: @escaping (inout NVE.Config) -> Void) -> some View {
        modifier(NVEConfigModifier(mutation))
    }
}

struct NVEConfigModifier: ViewModifier {
    @Environment(\.nveConfig) var config

    private let mutation: (inout NVE.Config) -> Void

    init(_ mutation: @escaping (inout NVE.Config) -> Void) {
        self.mutation = mutation
    }

    func body(content: Content) -> some View {
        content
            .environment(\.nveConfig, with(config, mutation))
    }
}

extension EnvironmentValues {
    var nveConfig: NVE.Config {
        get { self[NVEConfigKey.self] }
        set { self[NVEConfigKey.self] = newValue }
    }
}

struct NVEConfigKey: EnvironmentKey {
    static let defaultValue: NVE.Config = .default
}

