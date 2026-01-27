//
//  NavigationBarView.swift
//
//
//  Created by Илья Аникин on 25.08.2023.
//

import SwiftUI

struct NavigationBarView<S: View, L: View, T: View>: View {
    let title: String?
    let titleDisplayMode: NVE.PreferredTitleDisplayMode
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
        .preference(key: TitleDisplayModeChangedKey.self, value: titleDisplayState)
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
            VStack(spacing: 0) {
                VStack {
                    if largeTitleOpacity > 0, let title {
                        Text(title)
                            .scaleEffect(largeTitleScale, anchor: .bottomLeading)
                            .opacity(largeTitleOpacity)
                            .applyIfiOS26 { view in
                                view
                                    .blur(radius: largeTitleBlur)
                                    .transition(
                                        .asymmetric(
                                            insertion: .opacity.animation(.linear(duration: 0.2)),
                                            removal: .identity
                                        )
                                    )
                            }
                    } else {
                        Text(" ").hidden()
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .lineLimit(1)
                .font(.system(size: 32, weight: .bold)) //Do not change, a lot of depends on text size!
                .padding(
                    .init(
                        top: config.largeTitle.topEdgeInset,
                        leading: 20,
                        bottom: config.largeTitle.bottomPadding,
                        trailing: 10
                    )
                )
                
                subtitleContent()
                    .applyIfiOS26 { $0.padding(.top, 5) }
                    .transition(.scale(y: 0, anchor: .top).combined(with: .blur))
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
        .apply { view in
            if #available(iOS 26, *) {
                view.background(
                    Rectangle().fill(.clear)
                        .frame(width: UIScreen.main.bounds.width)
                        .padding(.horizontal, 10)
                        .glassEffect(.regular, in: Rectangle())
                        .ignoresSafeArea()
                        .opacity(barBackgroundOpacity)
                )
            } else {
                view.background(barStyle.opacity(barBackgroundOpacity))
            }
        }
        .offset(y: scrollFactor)
        .frame(maxHeight: .infinity, alignment: .top)
        .applyIfNotiOS26 { view in
            view.reverseMask(alignment: .top) {
                if !isReadyToCollapse {
                    Rectangle()
                        .frame(
                            height: safeAreaInsets.top
                                + config.smallTitle.supposedHeight
                                + config.largeTitle.topEdgeInset
                                + config.smallTitle.bottomPadding
                                + config.smallTitle.topPadding(for: orientation)
                        )
                }
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

                Spacer()

                trailingBarItem()
                    .frame(maxWidth: UIScreen.width * 0.25, maxHeight: 30, alignment: .trailing)
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: config.smallTitle.supposedHeight)
        .padding(.top, config.smallTitle.topPadding(for: orientation))
    }
}

// MARK: - Computed props
private extension NavigationBarView {
    var smallTitleOpacity: CGFloat {
        if isRefreshable {
            return isReadyToCollapse ? 1 : 0
        }

        if titleDisplayMode == .large || (titleDisplayMode == .auto && !orientation.isLandscape) {
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

    var largeTitleScale: CGFloat {
        guard !isRefreshable else { return 1.0 }

        return scrollOffset.isScrolledUp() ? 1.0 : clamp((-scrollOffset + 1000) / 1000.0, min: 1.0, max: 1.2 )
    }
    
    var largeTitleBlur: CGFloat {
        if #unavailable(iOS 26) {
            return 0
        }
        
        guard scrollOffset.isScrolledUp() else {
            return 0.0
        }
        
        let threshold = config.largeTitle.topPadding
            + safeAreaInsets.top
            + config.smallTitle.bottomPadding
        
        let progress = min(max(scrollOffset / threshold, 0), 1)
        
        return 15 * (exp(progress) - 1) / (exp(1) - 1) // normalized exp
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
    
    var titleDisplayState: NVE.TitleDisplayMode {
        switch (titleDisplayMode, orientation.isLandscape) {
        case (.auto, true): .inline
        case (.auto, false): isReadyToCollapse ? .inline : .large
        case (.large, _): isReadyToCollapse ? .inline : .large
        case (.inline, _): .inline
        }
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
