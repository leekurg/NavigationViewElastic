//
//  BackgroundSizeReader.swift
//  
//
//  Created by Илья Аникин on 20.07.2023.
//

import SwiftUI

struct BackgroundSizeReader: ViewModifier {
    @Binding var size: CGSize
    let firstValueOnly: Bool

    func body(content: Content) -> some View {
        content
            .background(
                GeometryReader { geometry in
                    Color.clear.preference(
                        key: SizePreferenceKey.self,
                        value: geometry.size
                    )
                }
            )
            .onPreferenceChange(SizePreferenceKey.self) { size in
                if !firstValueOnly {
                    self.size = size
                } else if self.size == .zero {
                    self.size = size
                }
            }
    }
}

struct SizePreferenceKey: SwiftUI.PreferenceKey {
    static var defaultValue: CGSize { .zero }

    static func reduce(value: inout CGSize, nextValue: () -> CGSize) { }
}

extension View {
    func backgroundSizeReader(size: Binding<CGSize>, firstValueOnly: Bool = false) -> some View {
        self.modifier(BackgroundSizeReader(size: size, firstValueOnly: firstValueOnly))
    }
}
