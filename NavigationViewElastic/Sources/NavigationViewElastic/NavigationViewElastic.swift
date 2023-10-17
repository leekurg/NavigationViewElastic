//
//  Created by Илья Аникин on 20.07.2023.
//

import SwiftUI
import Foundation
import OSLog

/// Namespace for additional components
public enum NVE { }

/// Custom view with navigation bar. Provides a scrollable container for user's content and container
/// to present user's subtitle content.
///
/// Created to mimic system navigation bar with ability to add custom content in the bottom of bar.
/// Also provide *onRefresh* method suitable for UDF-like using.
///
public struct NavigationViewElastic<C: View, S: View, L: View, T: View>: View {
    let title: String
    let blurStyle: UIBlurEffect.Style
    let config: NavigationViewConfig
    @ViewBuilder let content: () -> C
    @ViewBuilder let subtitleContent: () -> S
    @ViewBuilder let leadingBarItem: () -> L
    @ViewBuilder let trailingBarItem: () -> T
    let stopRefreshing: Binding<Bool>
    let onRefresh: (() -> Void)?

    public init(
        title: String = "",
        blurStyle: UIBlurEffect.Style = .systemMaterial,
        config: NavigationViewConfig = .init(),
        @ViewBuilder content: @escaping () -> C,
        @ViewBuilder subtitleContent: @escaping () -> S = { EmptyView() },
        @ViewBuilder leadingBarItem: @escaping () -> L = { EmptyView() },
        @ViewBuilder trailingBarItem: @escaping () -> T = { EmptyView() },
        stopRefreshing: Binding<Bool> = .constant(false),
        onRefresh: (() -> Void)? = nil
    ) {
        self.title = title
        self.blurStyle = blurStyle
        self.config = config
        self.content = content
        self.subtitleContent = subtitleContent
        self.leadingBarItem = leadingBarItem
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
                VStack(spacing: 0) {    //VStack wrapper for ability to add spacing on content's top (occured on iOS 17)
                    content()
                }
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.top, navigationViewSize.height + config.largeTitle.heightToCover)
            }
            .onChange(of: scrollOffset) { offset in
                guard onRefresh != nil else { return }

                if scrollOffset.isScrolledDown(config.progress.triggeringOffset) {
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
                leadingBarItem: leadingBarItem,
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
            leadingBarItem: self.leadingBarItem,
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
            leadingBarItem: self.leadingBarItem,
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
            leadingBarItem: self.leadingBarItem,
            trailingBarItem: self.trailingBarItem,
            stopRefreshing: self.stopRefreshing,
            onRefresh: self.onRefresh
        )
    }
}

// MARK: - Config
public struct NavigationViewConfig {
    let largeTitle: LargeTitleConfig
    let progress: ProgressConfig

    public init(
        largeTitleConfig: LargeTitleConfig = .init(),
        progress: ProgressConfig = .init()
    ) {
        self.largeTitle = largeTitleConfig
        self.progress = progress
    }
}

public extension NavigationViewConfig {
    struct LargeTitleConfig {
        let supposedHeight: CGFloat
        let topPadding: CGFloat
        let additionalTopPadding: CGFloat
        let bottomPadding: CGFloat

        var heightToCover: CGFloat { self.supposedHeight + self.additionalTopPadding }

        public init(
            supposedHeight: CGFloat = 40,
            topPadding: CGFloat = 40,
            additionalTopPadding: CGFloat = 15,
            bottomPadding: CGFloat = 5
        ) {
            self.supposedHeight = supposedHeight
            self.topPadding = topPadding
            self.additionalTopPadding = additionalTopPadding
            self.bottomPadding = bottomPadding
        }
    }

    struct ProgressConfig {
        let startRevealOffset: CGFloat
        let revealedOffset: CGFloat
        let triggeringOffset: CGFloat

        public init(
            startRevealOffset: CGFloat = 30,
            revealedOffset: CGFloat = 110
        ) {
            self.startRevealOffset = startRevealOffset
            self.revealedOffset = revealedOffset
            self.triggeringOffset = revealedOffset + 15
        }
    }
}

fileprivate extension NVE {
    static let logger = Logger(subsystem: "NVE", category: "NavigationViewElastic")
}
