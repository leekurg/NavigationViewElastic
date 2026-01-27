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
        private let action: (() -> Void)?
        
        @Environment(\.presentationMode) var presentationMode

        public init(_ titleKey: LocalizedStringKey? = nil, action: (() -> Void)? = nil) {
            self.action = action
            self.titleKey = titleKey
        }

        public var body: some View {
            if #available(iOS 26, *) {
                iOS26(titleKey, action: onTap)
            } else {
                iOS15(titleKey, action: onTap)
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
        private let titleKey: LocalizedStringKey?
        private let action: () -> Void

        @Environment(\.nveConfig.backButton) var config
        @Environment(\.layoutDirection) private var layoutDirection

        public init(_ titleKey: LocalizedStringKey?, action: @escaping () -> Void) {
            self.titleKey = titleKey
            self.action = action
        }

        public var body: some View {
            Button(action: action) {
                Image(systemName: layoutDirection == .leftToRight ? "chevron.left" : "chevron.right")
                    .font(font)
                    .frame(width: size?.width, height: size?.height)
                
                if let titleKey { Text(titleKey) }
            }
            .apply { view in
                if config.context == .standalone {
                    view
                        .buttonStyle(.glass)
                        .padding(config.insets.insets)
                } else {
                    view
                }
            }
        }
        
        private var font: Font? {
            config.context == .standalone
                ? .system(size: 21, weight: .regular)
                : .system(size: 17, weight: .regular)
        }
        
        private var size: CGSize? {
            config.context == .standalone ? CGSize(width: 20, height: 30) : nil
        }
    }
    
    struct iOS15: View {
        private let titleKey: LocalizedStringKey?
        private let action: () -> Void

        @Environment(\.nveConfig.backButton) var config
        @Environment(\.layoutDirection) private var layoutDirection

        public init(_ titleKey: LocalizedStringKey?, action: @escaping () -> Void) {
            self.action = action
            self.titleKey = titleKey
        }

        public var body: some View {
            Button(action: action) {
                HStack(spacing: 6) {
                    Image(systemName: layoutDirection == .leftToRight ? "chevron.left" : "chevron.right")
                        .font(.system(size: 22, weight: .medium))
                        .scaledToFit()

                    Text(titleKey ?? "Back")
                }
                .padding(config.insets.insets)
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
            case .nve:
                if #available(iOS 26, *) {
                    .init(top: 7, leading: 15, bottom: 5, trailing: 5)
                } else {
                    .init(top: 5, leading: 8, bottom: 5, trailing: 5)
                }
            case .system: .init(top: 5, leading: 0, bottom: 5, trailing: 5)
            case .manual(let insets): insets
            }
        }
    }
    
    enum Context {
        /// Button is used as standalone view
        case standalone
        /// Button is used as embedded view, for example, as ``SwiftUICore/ToolbarItem``.
        case embedded
    }
}

#Preview {
    NavigationView {
        ScrollView(.vertical) {
            Rectangle().fill(.orange).frame(height: 200)
            Rectangle().fill(.indigo).frame(height: 200)
            Rectangle().fill(.gray.opacity(0.5)).frame(height: 200)
        }
        .navigationTitle("Title")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                NVE.BackButton("NVE")
                    .nveConfig { $0.backButton.context = .embedded }
            }
        }
    }
    .overlay {
        HStack {
            NVE.BackButton()
                .border(.gray)

            NVE.BackButton("Back")
                .border(.gray)
            
            NVE.BackButton()
                .nveConfig { $0.backButton.context = .embedded }
                .border(.gray)
        }
    }
}
