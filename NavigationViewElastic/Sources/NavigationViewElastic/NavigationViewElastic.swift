//
//  Created by Илья Аникин on 20.07.2023.
//

import SwiftUI
import Foundation

/// Custom view with navigation bar. Provides a scrollable container for user's content and container
/// to present user's subtitle content.
///
/// Created to mimic system navigation bar with ability to add custom content in the bottom of bar.
/// Also provide *onRefresh* method suitable for UDF-like using.
///
public struct NavigationViewElastic<C: View, S: View, P: View>: View {
    let title: String
    let blurStyle: UIBlurEffect.Style
    @ViewBuilder let content: () -> C
    @ViewBuilder let subtitleContent: () -> S
    @ViewBuilder let trailingBarItem: () -> P
    let stopRefreshing: Binding<Bool>
    let onRefresh: (() -> Void)?

    public init(
        title: String = "",
        blurStyle: UIBlurEffect.Style = .systemMaterial,
        content: @escaping () -> C,
        subtitleContent: @escaping () -> S = { EmptyView() },
        trailingBarItem: @escaping () -> P = { EmptyView() },
        stopRefreshing: Binding<Bool> = .constant(false),
        onRefresh: (() -> Void)? = nil
    ) {
        self.title = title
        self.blurStyle = blurStyle
        self.content = content
        self.subtitleContent = subtitleContent
        self.trailingBarItem = trailingBarItem
        self.stopRefreshing = stopRefreshing
        self.onRefresh = onRefresh
    }

    private let largeTitleSupposedHeight: CGFloat = 40
    private let largeTitleAdditionalTopPadding: CGFloat = 20
    private let navigationViewLargeTitleTopPadding: CGFloat = 40
    private let navigationViewLargeTitleBottomPadding: CGFloat = 5
    private let progressTriggeringOffset: CGFloat = 20
    private let progressViewTargetHeight: CGFloat = 60

    @State private var navigationViewSize: CGSize = .zero
    @State private var scrollOffset = CGPoint.zero
    @State private var isRefreshing: Bool = false

    @Environment(\.colorScheme) var colorScheme

    public var body: some View {
        ZStack(alignment: .top) {
            ScrollViewObservable(showsIndicators: false, offset: $scrollOffset) {
                content()
                    .padding(.top, navigationViewSize.height + titleTopPaddingBlock)
            }
            .onChange(of: scrollOffset) { offset in
                guard onRefresh != nil else { return }

                if scrollOffset.isScrolledDown(progressViewTargetHeight + progressTriggeringOffset) {
                    if !isRefreshing {
                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    }
                    isRefreshing = true
                }
            }
            .onChange(of: stopRefreshing.wrappedValue) { stop in
                if stop {
                    withAnimation(.easeIn(duration: 0.3)) {
                        isRefreshing = false
                    }
                }
            }
            .onChange(of: isRefreshing) { refreshing in
                if refreshing { onRefresh?() }
            }

            navigationView
        }
        .ignoresSafeArea(.container, edges: .top)
    }
}

//// MARK: - Public API
public extension NavigationViewElastic {
    func refreshable(stopRefreshing: Binding<Bool>, onRefresh: @escaping () -> Void) -> Self {
        NavigationViewElastic(
            title: self.title,
            blurStyle: self.blurStyle,
            content: self.content,
            subtitleContent: self.subtitleContent,
            trailingBarItem: self.trailingBarItem,
            stopRefreshing: stopRefreshing,
            onRefresh: onRefresh
        )
    }

    func navigationTitle(_ title: String) -> Self {
        NavigationViewElastic(
            title: title,
            blurStyle: self.blurStyle,
            content: self.content,
            subtitleContent: self.subtitleContent,
            trailingBarItem: self.trailingBarItem,
            stopRefreshing: self.stopRefreshing,
            onRefresh: self.onRefresh
        )
    }

    func blurStyle(_ blurStyle: UIBlurEffect.Style) -> Self {
        NavigationViewElastic(
            title: self.title,
            blurStyle: blurStyle,
            content: self.content,
            subtitleContent: self.subtitleContent,
            trailingBarItem: self.trailingBarItem,
            stopRefreshing: self.stopRefreshing,
            onRefresh: self.onRefresh
        )
    }
}

// MARK: - Internal views
private extension NavigationViewElastic {
    var progressView: some View {
        ActivityIndicator(isAnimating: isRefreshing) {
            $0.hidesWhenStopped = false
            $0.style = .large
        }
        .frame(maxWidth: .infinity)
        .opacity(progressAppearFactor)
        .opacity(1 - smallTitleOpacity)
        .rotationEffect(.degrees(progressAppearFactor * 180))
        .scaleEffect(clamp(progressAppearFactor - 0.2, min: 0.2))
    }

    var navigationView: some View {
        ZStack(alignment: .top) {
            largeTitleLayer

            smallTitleLayer

            progressView
                .padding(.top, navigationViewLargeTitleTopPadding + 10)
        }
    }

    // MARK: - large title
    var largeTitleLayer: some View {
        VStack(spacing: 0) {
            Color.clear
                .frame(height: titleTopPaddingBlock)

            VStack(spacing: 0) {
                Text(title)
                    .lineLimit(1)
                    .font(.system(size: 32, weight: .bold)) //Do not change, a lot of depends on text size!
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .opacity(largeTitleOpacity)
                    .padding(
                        .init(
                            top: navigationViewLargeTitleTopPadding,
                            leading: 20,
                            bottom: navigationViewLargeTitleBottomPadding,
                            trailing: 10
                        )
                    )

                subtitleContent()

                if scrollOffset.isScrolledUp() {
                    Divider()
                }
            }
            .backgroundSizeReader(size: $navigationViewSize, firstValueOnly: true)
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
            height: navigationViewLargeTitleTopPadding +
            largeTitleSupposedHeight +
            navigationViewLargeTitleBottomPadding,
            alignment: .bottom
        )
        .background(smallTitleBackground)
    }
}

// MARK: - Computed props
private extension NavigationViewElastic {
    var smallTitleOpacity: CGFloat {
        titleTopPaddingBlock < largeTitleAdditionalTopPadding ? 1 : 0
    }

    @ViewBuilder
    var smallTitleBackground: some View {
        if titleTopPaddingBlock < largeTitleAdditionalTopPadding {
            Color.clear
        } else {
            if colorScheme == .dark {
                Color.black
            } else {
                Color.white
            }
        }
    }

    var largeTitleOpacity: CGFloat {
        titleTopPaddingBlock < largeTitleAdditionalTopPadding ? 0 : 1
    }

    @ViewBuilder
    var largeTitleBackground: some View {
        if titleTopPaddingBlock < largeTitleAdditionalTopPadding {
            BlurEffect(style: blurStyle)
                .allowsHitTesting(false)    //fix blur intercepting some touches
        } else {
            colorScheme == .dark ? Color.black : Color.white
        }
    }

    var titleTopPaddingBlock: CGFloat {
        // Padding to lower large title a bit to give it some upper space
        let heightToCover = largeTitleSupposedHeight + largeTitleAdditionalTopPadding
        if scrollOffset.isScrolledDown() {
            var offset = -scrollOffset.y
            offset = onRefresh != nil ? offset / 2 : offset
            return heightToCover + offset
        } else {
            let offset = clamp(
                scrollOffset.y, min: 0,
                max: heightToCover * 2
            )
            return clamp(heightToCover - offset / 2, min: 0)
        }
    }

    var progressAppearFactor: Double {
        guard onRefresh != nil else { return 0 }
        guard !isRefreshing else { return 1 }
        guard scrollOffset.isScrolledDown() else { return 0 }

        var offset: Double = clamp(
            -scrollOffset.y,
            min: progressTriggeringOffset,
            max: progressTriggeringOffset + progressViewTargetHeight
        )
        offset -= progressTriggeringOffset
        let opacity = clamp(offset / progressViewTargetHeight, min: 0, max: 1)

        return opacity
    }
}
