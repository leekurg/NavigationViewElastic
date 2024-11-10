//
//  Toolbar.swift
//  NavigationViewElastic
//
//  Created by Илья Аникин on 09.11.2024.
//

import SwiftUI

public struct Toolbar: Equatable {
    let id: AnyHashable
    let leading: Toolbar.Item?
    let trailing: Toolbar.Item?
    
    init(leading: Toolbar.Item? = nil, trailing: Toolbar.Item? = nil) {
        self.id = UUID()
        self.leading = leading
        self.trailing = trailing
    }
    
    public static func == (lhs: Toolbar, rhs: Toolbar) -> Bool {
        lhs.id == rhs.id
    }
}

public extension Toolbar {
    enum Placement {
        case leading
        case trailing
    }

    struct Item {
        let placement: Toolbar.Placement
        let content: AnyView
        
        public init<Content: View>(placement: Toolbar.Placement, content: () -> Content) {
            self.placement = placement
            self.content = AnyView(content())
        }
    }
}

@resultBuilder public struct ToolbarBuilder {
    public static func buildBlock(_ components: Toolbar.Item...) -> Toolbar {
        Toolbar(
            leading: components.filter { $0.placement == .leading }.first,
            trailing: components.filter { $0.placement == .trailing }.first
        )
    }
}
