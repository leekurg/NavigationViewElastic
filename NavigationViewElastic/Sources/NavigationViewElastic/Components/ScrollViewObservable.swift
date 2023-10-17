//
//  ScrollViewObservable.swift
//  
//
//  Created by Илья Аникин on 20.07.2023.
//

import SwiftUI

struct ScrollViewObservable<Content: View>: View {
    var axes: Axis.Set = [.vertical]
    var showsIndicators = true
    @Binding var offset: CGPoint
    @ViewBuilder var content: () -> Content

    private let coordinateSpaceName = UUID()

    var body: some View {
        ScrollView(axes, showsIndicators: showsIndicators) {
            PositionObservingView(
                coordinateSpace: .named(coordinateSpaceName),
                position: Binding(
                    get: { offset },
                    set: { newOffset in
                        offset = CGPoint(x: -newOffset.x, y: -newOffset.y)
                    }
                ),
                content: content
            )
        }
        .coordinateSpace(name: coordinateSpaceName)
    }
}

private struct PositionObservingView<Content: View>: View {
    var coordinateSpace: CoordinateSpace
    @Binding var position: CGPoint
    @ViewBuilder var content: () -> Content

    var body: some View {
        content()
            .background(
                GeometryReader { geometry in
                    Color.clear.preference(
                        key: PreferenceKey.self,
                        value: geometry.frame(in: coordinateSpace).origin
                    )
                }
            )
            .onPreferenceChange(PreferenceKey.self) { position in
                self.position = position
            }
    }
}

private extension PositionObservingView {
    struct PreferenceKey: SwiftUI.PreferenceKey {
        static var defaultValue: CGPoint { .zero }

        static func reduce(value: inout CGPoint, nextValue: () -> CGPoint) { }
    }
}

struct ScrollView_Proxy<Content: View>: View {
    @State var offset: CGPoint = .zero
    @ViewBuilder var content: () -> Content

    var body: some View {
        ZStack(alignment: .top) {
            ScrollViewObservable(offset: $offset) {
                content()
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.top, 100)
            }
            .onChange(of: offset) { value in
                print("offset: \(offset.y)")
            }
        }
        .ignoresSafeArea(.container, edges: .top)
    }
}

#Preview {
    ScrollView_Proxy() {
        LazyVStack {
            ForEach(1...20, id: \.self) { id in
                SampleCard()
            }
        }
        .border(.green)
        .padding(.horizontal)
    }
}

fileprivate struct SampleCard: View {
    var body: some View {
        RoundedRectangle(cornerRadius: 15)
            .fill(.red)
            .frame(height: 150)
    }
}
