//
//  NavigationBarView.swift
//
//
//  Created by Илья Аникин on 25.08.2023.
//

import SwiftUI

struct NavigationBarView<S: View, L: View, T: View>: View {
    let title: String?
    let titleDisplayMode: NVE.TitleDisplayMode
    let orientation: UIInterfaceOrientation
    let safeAreaInsets: EdgeInsets
    let extraHeightToCover: CGFloat
    let scrollOffset: CGFloat
    let isRefreshable: Bool
    let isRefreshing: Bool
    let largeTitleLayerSize: Binding<CGSize>
    @ViewBuilder let subtitleContent: () -> S
    @ViewBuilder let leadingBarItem: () -> L
    @ViewBuilder let trailingBarItem: () -> T

    @Environment(\.nveConfig) var config
    @Environment(\.nveConfig.barCollapsedStyle) var barStyle

    @State private var smallTitleSize: CGSize = .zero
    @State private var isAppeared = false

    var body: some View {
        ZStack(alignment: .top) {
            largeTitleLayer

            smallTitleLayer
                .padding(safeAreaInsets.ignoring(.bottom))

            progressView
                .padding(
                    .top,
                    safeAreaInsets.top
                    + config.largeTitle.topEdgeInset
                    + config.smallTitle.topPadding(for: orientation)
                )
        }
        .onAppear {
            isAppeared = true
        }
//        .overlay(alignment: .bottom) {
//            VStack {
//                HStack {
//                    Text("scroll: \(scrollOffset, specifier: "%.1f")")
//                    Text("factor: \(scrollFactor, specifier: "%.1f")")
//                }
//                Text("isReadyToCollapse: \(isReadyToCollapse)")
//                Text("isIntersectionWithContent: \(isIntersectionWithContent)")
//            }
//            .padding()
//            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 10))
//        }
    }
}

// MARK: - Internal Views
private extension NavigationBarView {
    @ViewBuilder
    var progressView: some View {
        VStack {
            if isProgressVisible {
                ProgressIndicator(
                    offset: scrollOffset,
                    isAnimating: isRefreshing,
                    startRevealOffset: config.progress(for: orientation).startRevealOffset,
                    revealedOffset: config.progress(for: orientation).revealedOffset,
                    isShowingLocked: isRefreshing
                )
                .scaleEffect(0.8)
                .transition(
                    .asymmetric(
                        insertion: .identity,
                        removal: .roll(.degrees(-180))
                            .combined(with: .scale(scale: 0.1))
                            .combined(with: .opacity)
                    )
                )
            }
        }
        .animation(.easeIn(duration: 0.2), value: isProgressVisible)
    }

    // MARK: - large title
    var largeTitleLayer: some View {
        VStack(spacing: 0) {
            Group {
                Text(title ?? " ")
                    .lineLimit(1)
                    .font(.system(size: 32, weight: .bold)) //Do not change, a lot of depends on text size!
                    .scaleEffect(largeTitleScale, anchor: .bottomLeading)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .opacity(largeTitleOpacity)
                    .padding(
                        .init(
                            top: config.largeTitle.topEdgeInset,
                            leading: 20,
                            bottom: config.largeTitle.bottomPadding,
                            trailing: 10
                        )
                    )
                
                subtitleContent()
                    .transition(.scale(y: 0, anchor: .top).combined(with: .opacity))
            }
            .padding(safeAreaInsets.ignoring(.vertical))

            Divider().opacity(barBackgroundOpacity)
        }
        .backgroundSizeReader(
            size: largeTitleLayerSize.animation(
                isAppeared ? config.subtitleSizeChangeAnimation : nil
            )
        )
        .padding(.top, config.smallTitle.topPadding(for: orientation))
        .background(barStyle.opacity(barBackgroundOpacity))
        .offset(y: scrollFactor)
        .frame(maxHeight: .infinity, alignment: .top)
        .reverseMask(alignment: .top) {
            if !isReadyToCollapse {
                Rectangle()
                    .frame(
                        height: safeAreaInsets.top
                            + smallTitleSize.height
                            + config.largeTitle.topEdgeInset
                            + config.smallTitle.bottomPadding
                            + config.smallTitle.topPadding(for: orientation)
                    )
            }
        }
    }

    // MARK: - small title
    var smallTitleLayer: some View {
        ZStack {
            if let title = title {
                HStack { Text(title).lineLimit(1) }
                    .font(.system(size: 17, weight: .semibold))
                    .opacity(smallTitleOpacity)
                    .frame(maxWidth: UIScreen.width * 0.5)
                    .animation(.easeIn(duration: 0.2), value: smallTitleOpacity)
            }

            HStack {
                leadingBarItem()
                    .frame(maxWidth: UIScreen.width * 0.25, maxHeight: 30, alignment: .leading)
                    .clipped()

                Spacer()

                trailingBarItem()
                    .frame(maxWidth: UIScreen.width * 0.25, maxHeight: 30, alignment: .trailing)
                    .clipped()
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: config.smallTitle.supposedHeight)
        .clipped()
        .backgroundSizeReader(size: $smallTitleSize)
        .padding(.top, config.smallTitle.topPadding(for: orientation))
    }
}

// MARK: - Computed props
private extension NavigationBarView {
    var smallTitleOpacity: CGFloat {
        if isRefreshable {
            return isReadyToCollapse ? 1 : 0
        }

        if titleDisplayMode == .large || (titleDisplayMode == .auto && !orientation.isLandscape)  {
            return isReadyToCollapse ? 1 : 0
        }

        return 1
    }

    var largeTitleOpacity: CGFloat {
        switch titleDisplayMode {
        case .auto:
            isReadyToCollapse
                ? 0
                : (orientation.isLandscape ? 0 : 1)
        case .large: isReadyToCollapse ? 0 : 1
        case .inline: 0
        }
    }

    var largeTitleBackground: AnyShapeStyle {
        isIntersectionWithContent ? barStyle : AnyShapeStyle(.clear)
    }

    var largeTitleScale: CGFloat {
        guard !isRefreshable else { return 1.0 }

        return scrollOffset.isScrolledUp() ? 1.0 : clamp((-scrollOffset + 1000) / 1000.0, min: 1.0, max: 1.2 )
    }

    var scrollFactor: CGFloat {
        let newValue: CGFloat
        let heightToCover = extraHeightToCover + safeAreaInsets.top

        if scrollOffset.isScrolledUp() {
            let offset = clamp(scrollOffset, min: 0, max: heightToCover)
            newValue = clamp(heightToCover - offset, min: safeAreaInsets.top)
        } else {
            newValue = heightToCover - scrollOffset
        }

        return newValue
    }

    var isProgressVisible: Bool {
        guard isRefreshable else { return false }

        if isRefreshing {
            return isReadyToCollapse ? (title == nil) : true
        }

        return scrollOffset.isScrolledDown(1)
    }

    var isIntersectionWithContent: Bool {
        scrollFactor <= safeAreaInsets.top
    }

    var isReadyToCollapse: Bool {
        scrollFactor <= config.largeTitle.topPadding
            + safeAreaInsets.top
            + config.smallTitle.bottomPadding
    }

    var barBackgroundOpacity: CGFloat {
        if !isIntersectionWithContent { return 0 }

        return clamp(
            abs(scrollOffset - extraHeightToCover) / config.barOpacityThreshold,
            min: 0,
            max: 1
        )
    }
}

#if DEBUG
#Preview {
    ProxyView()
        .nveConfig { config in
//            config.largeTitle.topPadding = 20
//            config.largeTitle.bottomPadding = 20
        }
}
#endif
