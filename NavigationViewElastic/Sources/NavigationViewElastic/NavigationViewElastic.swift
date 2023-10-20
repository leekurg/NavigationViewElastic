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
    let blurStyle: UIBlurEffect.Style
    let config: NavigationViewConfig
    @ViewBuilder let content: () -> C
    @ViewBuilder let subtitleContent: () -> S
    @ViewBuilder let leadingBarItem: () -> L
    @ViewBuilder let trailingBarItem: () -> T
    let stopRefreshing: Binding<Bool>
    let onRefresh: (() -> Void)?

    @State private var title: String?

    public init(
        blurStyle: UIBlurEffect.Style = .systemMaterial,
        config: NavigationViewConfig = .init(),
        @ViewBuilder content: @escaping () -> C,
        @ViewBuilder subtitleContent: @escaping () -> S = { EmptyView() },
        @ViewBuilder leadingBarItem: @escaping () -> L = { EmptyView() },
        @ViewBuilder trailingBarItem: @escaping () -> T = { EmptyView() },
        stopRefreshing: Binding<Bool> = .constant(false),
        onRefresh: (() -> Void)? = nil
    ) {
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
                .padding(.top, navigationViewSize.height + extraHeightToCover)
				.onPreferenceChange(TitleKey.self) { newTitle in
                	title = newTitle
                }
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
                extraHeightToCover: extraHeightToCover,
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

    var extraHeightToCover: CGFloat {
        return title == nil
                ? config.largeTitle.additionalTopPadding
                : config.largeTitle.additionalTopPadding
                    + config.largeTitle.supposedHeight
    }
}

// MARK: - Public API
public extension NavigationViewElastic {
    func refreshable(stopRefreshing: Binding<Bool>, onRefresh: @escaping () -> Void) -> Self {
        Self(
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

// MARK: - Preferences
public extension View {
    func navigationElasticTitle(_ title: String? = nil) -> some View {
        preference(key: TitleKey.self, value: title)
    }
}

private struct TitleKey: PreferenceKey {
    static var defaultValue: String? = nil

    static func reduce(value: inout String?, nextValue: () -> String?) {
        value = value ?? nextValue()
    }
}

fileprivate extension NVE {
    static let logger = Logger(subsystem: "NVE", category: "NavigationViewElastic")
}
