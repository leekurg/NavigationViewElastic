//
//  EdgeInsets+Extensions.swift
//  NavigationViewElastic
//
//  Created by Илья Аникин on 29.10.2024.
//

import SwiftUI

extension EdgeInsets {
    func ignoring(_ edges: Edge.Set) -> EdgeInsets {
        EdgeInsets(
            top: edges.contains(.top) ? 0 : self.top,
            leading: edges.contains(.leading) ? 0 : self.leading,
            bottom: edges.contains(.bottom) ? 0 : self.bottom,
            trailing: edges.contains(.trailing) ? 0 : self.trailing
        )
    }
}
