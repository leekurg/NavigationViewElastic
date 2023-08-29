//
//  NavigationBarView.swift
//
//
//  Created by Илья Аникин on 25.08.2023.
//

import SwiftUI

struct NavigationBarView<S: View, T: View>: View {
    let title: String
    let blurStyle: UIBlurEffect.Style
    let config: NavigationViewConfig
    let scrollOffset: CGFloat
    let isRefreshable: Bool
    let isRefreshing: Bool
    let largeTitleLayerSize: Binding<CGSize>
    @ViewBuilder let subtitleContent: () -> S
    @ViewBuilder let trailingBarItem: () -> T

    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        ZStack(alignment: .top) {
            largeTitleLayer

            smallTitleLayer

            progressView
                .padding(.top, config.largeTitle.topPadding + 10)
        }
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
                    startRevealOffset: config.progress.startRevealOffset,
                    revealedOffset: config.progress.revealedOffset,
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
            Color.clear
                .frame(height: scrollFactor)

            VStack(spacing: 0) {
                Text(title)
                    .lineLimit(1)
                    .font(.system(size: 32, weight: .bold)) //Do not change, a lot of depends on text size!
                    .scaleEffect(largeTitleScale, anchor: .bottomLeading)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .opacity(largeTitleOpacity)
                    .padding(
                        .init(
                            top: config.largeTitle.topPadding,
                            leading: 20,
                            bottom: config.largeTitle.bottomPadding,
                            trailing: 10
                        )
                    )

                subtitleContent()

                if isIntersectionWithContent {
                    Divider()
                }
            }
            .backgroundSizeReader(size: largeTitleLayerSize, firstValueOnly: true)
        }
        .background(largeTitleBackground)
    }

    // MARK: - small title
    var smallTitleLayer: some View {
        ZStack {
            HStack { Text(title).lineLimit(1) }
                .font(.system(size: 17, weight: .semibold))
                .opacity(smallTitleOpacity)
                .frame(maxWidth: UIScreen.width * 0.5)
                .animation(.easeIn(duration: 0.2), value: smallTitleOpacity)

            HStack {
                Spacer()

                trailingBarItem()
                    .frame(maxWidth: UIScreen.width * 0.25, maxHeight: 30, alignment: .trailing)
                    .clipped()
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.bottom, 7)
        .frame(
            height: config.largeTitle.topPadding +
            config.largeTitle.supposedHeight +
            config.largeTitle.bottomPadding,
            alignment: .bottom
        )
        .background(smallTitleBackground)
    }
}

// MARK: - Computed props
private extension NavigationBarView {
    var smallTitleOpacity: CGFloat {
        isReadyToCollapse ? 1 : 0
    }

    @ViewBuilder
    var smallTitleBackground: some View {
        if isIntersectionWithContent {
            Color.clear
        } else {
            colorScheme == .dark ? Color.black : Color.white
        }
    }

    var largeTitleOpacity: CGFloat {
        isReadyToCollapse ? 0 : 1
    }

    @ViewBuilder
    var largeTitleBackground: some View {
        if isIntersectionWithContent {
            BlurEffect(style: blurStyle)
                .allowsHitTesting(false)    //fix blur intercepting some touches
        } else {
            colorScheme == .dark ? Color.black : Color.white
        }
    }

    var largeTitleScale: CGFloat {
        guard !isRefreshable else { return 1.0 }

        return scrollOffset.isScrolledUp() ? 1.0 : clamp((-scrollOffset + 1000) / 1000.0, min: 1.0, max: 1.2 )
    }

    var scrollFactor: CGFloat {
        if scrollOffset.isScrolledUp() {
            return reduceScrollUpOffset(offsetY: scrollOffset, heightToCover: config.largeTitle.heightToCover)
        } else {
            return config.largeTitle.heightToCover + -scrollOffset
        }
    }

    var isProgressVisible: Bool {
        guard isRefreshable else { return false }

        if isRefreshing {
            return !isReadyToCollapse
        }

        return scrollOffset.isScrolledDown(1)
    }

    var isIntersectionWithContent: Bool {
        scrollFactor.isZero
    }

    var isReadyToCollapse: Bool {
        scrollFactor < config.largeTitle.additionalTopPadding
    }
}

// MARK: - Service func
private extension NavigationBarView {
    func reduceScrollUpOffset(offsetY: CGFloat, heightToCover: CGFloat) -> CGFloat {
        let offset = clamp(offsetY, min: 0, max: heightToCover)
        return clamp(heightToCover - offset, min: 0)
    }
}
