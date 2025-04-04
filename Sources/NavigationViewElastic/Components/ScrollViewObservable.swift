//
//  ScrollViewObservable.swift
//  
//
//  Created by Илья Аникин on 20.07.2023.
//

import SwiftUI

/// ScrollView with ability to receive updates when scroll value changes.
///
/// ## Scroll observing
/// Updates a binding *offset* when scrolling happens. Alternativelly, you can use
/// ``NVEScrollRectPreferenceKey`` to receive scroll updates up the view hierarchy.
///
/// ## Programatical scroll
/// Provides a biding **scrollToAnchor** to programmatically scroll to content's edges with
/// optional offset. Scrolling hapens the moment you set binding, immidiatly after scroll animation begins
/// the binding will be nilled out.
///
public struct ScrollViewObservable<Content: View>: View {
    private let axes: Axis.Set
    private let showsIndicators: Bool
    private var offset: Binding<CGPoint>?
    @Binding var scrollToAnchor: ScrollRelativeAnchor?
    @ViewBuilder var content: () -> Content

    @State private var scrollFrame: CGSize = .zero
    @State private var contentRect: CGRect = .zero

    private let coordinateSpaceName = UUID()
    private let contentId = "contentId"

    public init(
        axes: Axis.Set = [.vertical],
        showsIndicators: Bool = true,
        offset: Binding<CGPoint>? = nil,
        scrollToAnchor: Binding<ScrollRelativeAnchor?> = .constant(.none),
        content: @escaping () -> Content
    ) {
        self.axes = axes
        self.showsIndicators = showsIndicators
        self.offset = offset
        self._scrollToAnchor = scrollToAnchor
        self.content = content
    }

    public var body: some View {
        GeometryReader { geometry in
            ScrollViewReader { proxy in
                ScrollView(axes, showsIndicators: showsIndicators) {
                    PositionObservingView(
                        coordinateSpace: .named(coordinateSpaceName),
                        rect: Binding(
                            get: { contentRect },
                            set: { newRect in
                                contentRect = newRect

                                if let offset {
                                    offset.wrappedValue = CGPoint(x: -newRect.origin.x, y: -newRect.origin.y)
                                }
                            }
                        ),
                        content: content
                    )
                    .id(contentId)
                }
                .onChange(of: scrollToAnchor) { anchor in
                    if let anchor {
                        let unitPoint: UnitPoint

                        let scrollMaxV = clamp(contentRect.height - scrollFrame.height, min: 1)
                        let scrollMaxH = clamp(contentRect.width - scrollFrame.width, min: 1)

                        switch anchor {
                        case .top(let offset):
                            unitPoint = UnitPoint(x: 0.5, y: offset / scrollMaxV)
                        case .bottom(let offset):
                            unitPoint = UnitPoint(x: 0.5, y: (scrollMaxV - offset) / scrollMaxV)
                        case .leading(let offset):
                            unitPoint = UnitPoint(x: offset / scrollMaxH, y: 0.5)
                        case .trailing(let offset):
                            unitPoint = UnitPoint(x: (scrollMaxH - offset) / scrollMaxH, y: 0.5)
                        case .unitPoint(let value):
                            unitPoint = value
                        case .offset(let x, let y):
                            unitPoint = UnitPoint(x: x / scrollMaxH, y: y / scrollMaxV)
                        }

                        withAnimation(.spring) {
                            proxy.scrollTo(contentId, anchor: unitPoint)
                        }

                        scrollToAnchor = nil
                    }
                }
            }
            .onChange(of: geometry.size) { size in
                scrollFrame = size
            }
            .onAppear {
                scrollFrame = geometry.size
            }
        }
        .coordinateSpace(name: coordinateSpaceName)
    }
}

/// Scroll anchor provides ability to scroll to edge with given offset.
public enum ScrollRelativeAnchor: Equatable {
    case top(offset: CGFloat)
    case bottom(offset: CGFloat)
    case leading(offset: CGFloat)
    case trailing(offset: CGFloat)
    case unitPoint(UnitPoint)
    case offset(x: CGFloat, y: CGFloat)
}

private struct PositionObservingView<Content: View>: View {
    var coordinateSpace: CoordinateSpace
    @Binding var rect: CGRect
    @ViewBuilder var content: () -> Content

    var body: some View {
        content()
            .background(
                GeometryReader { geometry in
                    Color.clear
                        .preference(
                            key: NVEScrollRectPreferenceKey.self,
                            value: geometry.frame(in: coordinateSpace)
                        )
                }
            )
            .onPreferenceChange(NVEScrollRectPreferenceKey.self) { rect in
                self.rect = rect
            }
    }
}

// MARK: - Preview
struct ScrollView_Proxy<Content: View>: View {
    let axes: Axis.Set
    @State var offset: CGPoint = .zero
    @State var rect: CGRect = .zero
    @State var scrollTo: ScrollRelativeAnchor? = nil
    @ViewBuilder var content: () -> Content

    var body: some View {
        ZStack(alignment: .top) {
            ScrollViewObservable(axes: axes, offset: $offset, scrollToAnchor: $scrollTo) {
                content()
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.top, 100)
            }
            .onChange(of: offset) { value in
                print("offset: \(offset.y)")
            }
            .onPreferenceChange(NVEScrollRectPreferenceKey.self) { rect in
                print("rect.origin.y: \(rect.origin.y)")
            }
        }
        .ignoresSafeArea(.container, edges: .top)
        .overlay(alignment: .bottom) {
            scrollControls
        }
    }

    private var scrollControls: some View {
        VStack {
            HStack {
                Button("top") {
                    scrollTo = .top(offset: 0)
                }
                Button("bottom") {
                    scrollTo = .bottom(offset: 0)
                }
                Button("leading") {
                    scrollTo = .leading(offset: 0)
                }
                Button("trailing") {
                    scrollTo = .trailing(offset: 0)
                }
            }

            HStack {
                let unitPoint = UnitPoint(x: 0.1, y: 0.1)
                Button("unitPoint \(unitPoint.x.formatted()) \(unitPoint.y.formatted())") {
                    scrollTo = .unitPoint(unitPoint)
                }
            }
            .border(.gray)

            HStack {
                let offset = CGSize(width: 10, height: 350)
                Button("offset \(offset.width.formatted()) \(offset.height.formatted())") {
                    scrollTo = .offset(x: offset.width, y: offset.height)
                }
            }
            .border(.gray)
        }
        .buttonStyle(.bordered)
        .padding(10)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20))
    }
}

#Preview("Vertical") {
    ScrollView_Proxy(axes: .vertical) {
        LazyVStack {
            ForEach(1...20, id: \.self) { id in
                SampleCard()
                    .frame(height: 150)
            }
        }
        .border(.green)
        .padding(.horizontal)
    }
}

#Preview("Horizontal") {
    ScrollView_Proxy(axes: .horizontal) {
        LazyHStack {
            ForEach(1...20, id: \.self) { id in
                SampleCard()
                    .frame(width: 300, height: 150)
            }
        }
        .border(.green)
        .padding(.horizontal)
    }
}

#Preview("VH") {
    ScrollView_Proxy(axes: [.horizontal, .vertical]) {
        LazyVStack {
            ForEach(1...20, id: \.self) { id in
                SampleCard()
                    .frame(width: 600, height: 150)
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
    }
}
