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
    let config: NavigationViewConfig
    @ViewBuilder let content: () -> C
    @ViewBuilder let subtitleContent: () -> S
    @ViewBuilder let trailingBarItem: () -> P
    let stopRefreshing: Binding<Bool>
    let onRefresh: (() -> Void)?

    public init(
        title: String = "",
        blurStyle: UIBlurEffect.Style = .systemMaterial,
        config: NavigationViewConfig = .init(),
        @ViewBuilder content: @escaping () -> C,
        @ViewBuilder subtitleContent: @escaping () -> S = { EmptyView() },
        @ViewBuilder trailingBarItem: @escaping () -> P = { EmptyView() },
        stopRefreshing: Binding<Bool> = .constant(false),
        onRefresh: (() -> Void)? = nil
    ) {
        self.title = title
        self.blurStyle = blurStyle
        self.config = config
        self.content = content
        self.subtitleContent = subtitleContent
        self.trailingBarItem = trailingBarItem
        self.stopRefreshing = stopRefreshing
        self.onRefresh = onRefresh
    }

    @State private var navigationViewSize: CGSize = .zero
    @State private var scrollOffset = CGPoint.zero
    @State private var isRefreshing: Bool = false

    @Environment(\.colorScheme) var colorScheme

    public var body: some View {
        ZStack(alignment: .top) {
            ScrollViewObservable(showsIndicators: false, offset: $scrollOffset) {
                content()
                    .padding(.top, navigationViewSize.height + config.heightToCover)
            }
            .onChange(of: scrollOffset) { offset in
                guard onRefresh != nil else { return }

                if scrollOffset.isScrolledDown(config.progressViewTargetHeight + config.progressTriggeringOffset) {
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

            NavigationBarView(
                title: title,
                blurStyle: blurStyle,
                config: config,
                scrollOffset: scrollOffset.y,
                isRefreshable: onRefresh != nil,
                isRefreshing: isRefreshing,
                largeTitleLayerSize: $navigationViewSize,
                subtitleContent: subtitleContent,
                trailingBarItem: trailingBarItem
            )
        }
        .ignoresSafeArea(.container, edges: .top)
    }
}

// MARK: - Public API
public extension NavigationViewElastic {
    func refreshable(stopRefreshing: Binding<Bool>, onRefresh: @escaping () -> Void) -> Self {
        Self(
            title: self.title,
            blurStyle: self.blurStyle,
            config: self.config,
            content: self.content,
            subtitleContent: self.subtitleContent,
            trailingBarItem: self.trailingBarItem,
            stopRefreshing: stopRefreshing,
            onRefresh: onRefresh
        )
    }

    func navigationTitle(_ title: String) -> Self {
        Self(
            title: title,
            blurStyle: self.blurStyle,
            config: self.config,
            content: self.content,
            subtitleContent: self.subtitleContent,
            trailingBarItem: self.trailingBarItem,
            stopRefreshing: self.stopRefreshing,
            onRefresh: self.onRefresh
        )
    }

    func blurStyle(_ blurStyle: UIBlurEffect.Style) -> Self {
        Self(
            title: self.title,
            blurStyle: blurStyle,
            config: self.config,
            content: self.content,
            subtitleContent: self.subtitleContent,
            trailingBarItem: self.trailingBarItem,
            stopRefreshing: self.stopRefreshing,
            onRefresh: self.onRefresh
        )
    }
}

// MARK: - Config
public struct NavigationViewConfig {
    let largeTitleSupposedHeight: CGFloat
    let navigationViewLargeTitleTopPadding: CGFloat
    let navigationViewLargeTitleBottomPadding: CGFloat
    let largeTitleAdditionalTopPadding: CGFloat
    let progressTriggeringOffset: CGFloat
    let progressViewTargetHeight: CGFloat

    var heightToCover: CGFloat { self.largeTitleSupposedHeight + self.largeTitleAdditionalTopPadding }

    public init(
        largeTitleSupposedHeight: CGFloat = 40,
        navigationViewLargeTitleTopPadding: CGFloat = 40,
        navigationViewLargeTitleBottomPadding: CGFloat = 5,
        largeTitleAdditionalTopPadding: CGFloat = 15,
        progressTriggeringOffset: CGFloat = 30,
        progressViewTargetHeight: CGFloat = 60
    ) {
        self.largeTitleSupposedHeight = largeTitleSupposedHeight
        self.navigationViewLargeTitleTopPadding = navigationViewLargeTitleTopPadding
        self.navigationViewLargeTitleBottomPadding = navigationViewLargeTitleBottomPadding
        self.largeTitleAdditionalTopPadding = largeTitleAdditionalTopPadding
        self.progressTriggeringOffset = progressTriggeringOffset
        self.progressViewTargetHeight = progressViewTargetHeight
    }
}
