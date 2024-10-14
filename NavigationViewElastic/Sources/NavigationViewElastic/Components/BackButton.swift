//
//  BackButton.swift
//  
//
//  Created by Илья Аникин on 31.08.2023.
//

import SwiftUI

public extension NVE {
    struct BackButton: View {
        private let titleKey: LocalizedStringKey?
        private let insets: EdgeInsets
        private let action: (() -> Void)?

        @Environment(\.presentationMode) var presentationMode
        @Environment(\.layoutDirection) private var layoutDirection

        public init(_ titleKey: LocalizedStringKey? = nil, insets: Insets = .nve, action: (() -> Void)? = nil) {
            self.action = action
            self.titleKey = titleKey
            self.insets = insets.insets
        }

        public var body: some View {
            Button(action: onTap) {
                HStack(spacing: 5) {
                    Image(systemName: layoutDirection == .leftToRight ? "chevron.left" : "chevron.right")
                        .font(.system(size: 17, weight: .semibold))

                    Text(titleKey ?? "Back")
                }
                .padding(insets)
            }
        }

        private func onTap() {
            if let _ = action {
                action?()
            } else {
                presentationMode.wrappedValue.dismiss()
            }
        }
    }
}

public extension NVE.BackButton {
    enum Insets {
        case nve
        case system
        case manual(insets: EdgeInsets)

        var insets: EdgeInsets {
            switch self {
            case .nve: .init(top: 5, leading: 12, bottom: 5, trailing: 5)
            case .system: .init(top: 5, leading: 0, bottom: 5, trailing: 5)
            case .manual(let insets): insets
            }
        }
    }
}

#Preview {
    NVE.BackButton(insets: .system)
        .border(.gray)
}
