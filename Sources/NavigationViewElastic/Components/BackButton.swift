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
        private let insets: Insets
        private let action: (() -> Void)?
        
        @Environment(\.presentationMode) var presentationMode

        public init(_ titleKey: LocalizedStringKey? = nil, insets: Insets = .nve, action: (() -> Void)? = nil) {
            self.action = action
            self.titleKey = titleKey
            self.insets = insets
        }

        public var body: some View {
            if #available(iOS 26, *) {
                iOS26(insets: insets, action: onTap)
            } else {
                iOS15(titleKey, insets: insets, action: onTap)
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

private extension NVE.BackButton {
    @available(iOS 26, *)
    struct iOS26: View {
        private let insets: EdgeInsets
        private let action: () -> Void

        @Environment(\.layoutDirection) private var layoutDirection

        public init(insets: Insets, action: @escaping () -> Void) {
            self.action = action
            self.insets = insets.insets
        }

        public var body: some View {
            Button(action: action) {
                Image(systemName: layoutDirection == .leftToRight ? "chevron.left" : "chevron.right")
                    .font(.system(size: 25, weight: .regular))
                    .frame(width: 25, height: 35)
            }
            .buttonStyle(.glass)
        }
    }
    
    struct iOS15: View {
        private let titleKey: LocalizedStringKey?
        private let insets: EdgeInsets
        private let action: () -> Void

        @Environment(\.layoutDirection) private var layoutDirection

        public init(_ titleKey: LocalizedStringKey?, insets: Insets, action: @escaping () -> Void) {
            self.action = action
            self.titleKey = titleKey
            self.insets = insets.insets
        }

        public var body: some View {
            Button(action: action) {
                HStack(spacing: 6) {
                    Image(systemName: layoutDirection == .leftToRight ? "chevron.left" : "chevron.right")
                        .font(.system(size: 22, weight: .medium))
                        .scaledToFit()

                    Text(titleKey ?? "Back")
                }
                .padding(insets)
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
            case .nve: .init(top: 5, leading: 8, bottom: 5, trailing: 5)
            case .system: .init(top: 5, leading: 0, bottom: 5, trailing: 5)
            case .manual(let insets): insets
            }
        }
    }
}

#Preview {
    ScrollView(.vertical) {
        Rectangle().fill(.orange).frame(height: 200)
        Rectangle().fill(.indigo).frame(height: 200)
        Rectangle().fill(.gray.opacity(0.5)).frame(height: 200)
    }
    .overlay {
        NVE.BackButton(insets: .system)
            .border(.gray)
    }
}
