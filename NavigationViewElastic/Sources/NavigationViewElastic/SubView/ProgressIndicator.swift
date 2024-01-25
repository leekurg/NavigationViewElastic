//
//  SwiftUIView.swift
//  
//
//  Created by Илья Аникин on 26.08.2023.
//

import SwiftUI

struct ProgressIndicator: View {
    let offset: CGFloat
    let isAnimating: Bool
    let startRevealOffset: CGFloat
    let revealedOffset: CGFloat
    let isShowingLocked: Bool

    @State private var indicatorSize: CGSize = .zero

    var body: some View {
        ActivityIndicator(isAnimating: isAnimating) {
            $0.style = .large
            $0.hidesWhenStopped = false
            $0.color = .init(white: 0.8, alpha: 1)
        }
        .rotationEffect(isAnimating ? .degrees(180) : .degrees(0))
        .animation(
            .interactiveSpring(response: 1.5, dampingFraction: 1.3, blendDuration: 1.5),
            value: isAnimating
        )
        .backgroundSizeReader(size: $indicatorSize)
        .mask {
            if !isShowingLocked {
                PieView(
                    diameter: pieDiameter,
                    offset: clampedOffset,
                    startRevealOffset: startRevealOffset,
                    revealedOffset: revealedOffset
                )
                .frame(width: pieDiameter, height: pieDiameter)
            } else {
                Circle()
            }
        }
    }

    var clampedOffset: CGFloat {
        clamp(-offset, min: 0)
    }

    var pieDiameter: CGFloat {
        indicatorSize.width + 10
    }
}

struct PieView: View {
    let diameter: CGFloat
    let offset: CGFloat
    let startRevealOffset: CGFloat
    let revealedOffset: CGFloat

    private let startPoint: CGPoint

    init(
        diameter: CGFloat,
        offset: CGFloat,
        startRevealOffset: CGFloat,
        revealedOffset: CGFloat
    ) {
        self.diameter = diameter
        self.offset = offset

        if startRevealOffset > revealedOffset {
            self.startRevealOffset = 30
            self.revealedOffset = 150
        } else {
            self.startRevealOffset = startRevealOffset
            self.revealedOffset = revealedOffset
        }

        self.startPoint = .init(x: diameter / 2, y: diameter / 2)
    }

    var body: some View {
        Path { path in
           path.move(to: startPoint)
           path.addArc(
            center: startPoint,
            radius: diameter / 2,
            startAngle: startAngle,
            endAngle: .degrees(0),
            clockwise: true
           )
        }
        .blur(radius: 5)
        .rotationEffect(.degrees(-90))
    }

    private var startAngle: Angle {
        guard offset > startRevealOffset else { return .degrees(0) }

        let degrees = clamp(offset * 3 - startRevealOffset * 3, min: 0, max: 360)
        return .degrees(degrees)
    }
}

struct ProgressIndicator_Proxy: View {
    @State var scrollOffset = CGPoint.zero

    var body: some View {
        ZStack(alignment: .top) {
            ScrollViewObservable(offset: $scrollOffset) {
                VStack {
                    Color.clear
                        .frame(height: 100)
                    ForEach(1...3, id: \.self) { _ in
                        Color.blue
                            .frame(height: 500)
                            .cornerRadius(16)
                    }
                }
                .padding(.horizontal)
            }

            navigationBar
        }
        .edgesIgnoringSafeArea(.top)
    }

    var navigationBar: some View {
        VStack {
            ProgressIndicator(
                offset: scrollOffset.y,
                isAnimating: false,
                startRevealOffset: 30,
                revealedOffset: 150,
                isShowingLocked: false
            )
            .onChange(of: scrollOffset) { value in
                print(value)
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: 100, alignment: .bottom)
        .background(.regularMaterial)
    }
}

struct ProgressIndicator_Previews: PreviewProvider {
    static var previews: some View {
        ProgressIndicator_Proxy()
    }
}
