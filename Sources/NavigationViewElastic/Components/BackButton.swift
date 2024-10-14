//
//  BackButton.swift
//  
//
//  Created by Илья Аникин on 31.08.2023.
//

import SwiftUI

public extension NVE {
    struct BackButton: View {
        let title: String?
        let action: (() -> Void)?

        @Environment(\.presentationMode) var presentationMode

        public init(title: String? = nil, action: (() -> Void)? = nil) {
            self.action = action
            self.title = title
        }

        public var body: some View {
            Button(action: onTap) {
                HStack(spacing: 5) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 22, weight: .medium))

                    Text(title ?? "Back")
                }
                .padding(.init(top: 5, leading: 12, bottom: 5, trailing: 5))
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

#Preview {
    NVE.BackButton()
}
