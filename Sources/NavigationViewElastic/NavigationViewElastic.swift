//
//  Created by Илья Аникин on 20.07.2023.
//

import Foundation
import SwiftUI

/// Namespace for additional components
public enum NVE { }

/// Custom view with navigation bar. Provides a scrollable container for user's content and container
/// to present user's subtitle content.
///
/// Created to mimic system navigation bar with ability to add custom content in the bottom of bar.
/// Also provide *onRefresh* method suitable for UDF-like using.
///
/// KNOWN ISSUE: On iOS 17 when pulling for refresh, main content might be stuttering.
/// It happens in underlying ScrollView when it's content changed to other view with different height.
/// 
public struct NavigationViewElastic<C: View, S: View, L: View, T: View>: View {
    private var barStyle: AnyShapeStyle
    let config: NavigationViewConfig
    @ViewBuilder let content: () -> C
    @ViewBuilder let subtitleContent: () -> S
    @ViewBuilder let leadingBarItem: () -> L
    @ViewBuilder let trailingBarItem: () -> T
    private var stopRefreshing: Binding<Bool>
    private var onRefresh: (() -> Void)?

    @State private var title: String?

    public init(
        barStyle: AnyShapeStyle = AnyShapeStyle(.bar),
        config: NavigationViewConfig = .default,
        @ViewBuilder content: @escaping () -> C,
        @ViewBuilder subtitleContent: @escaping () -> S = { EmptyView() },
        @ViewBuilder leadingBarItem: @escaping () -> L = { EmptyView() },
        @ViewBuilder trailingBarItem: @escaping () -> T = { EmptyView() },
        stopRefreshing: Binding<Bool> = .constant(false),
        onRefresh: (() -> Void)? = nil
    ) {
        self.barStyle = barStyle
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
    /// Determines that swipe down gesture is released and component is
    /// ready to next swipe. Used to prevent multiple refreshes during one swipe.
    @State private var isLockedForRefresh: Bool = false

    @Environment(\.colorScheme) var colorScheme

    public var body: some View {
        ZStack(alignment: .top) {
            ScrollViewObservable(showsIndicators: false, offset: $scrollOffset) {
                VStack(spacing: 0) {    //VStack wrapper for ability to add spacing on content's top (occured on iOS 17)
                    content()
                }
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.top, navigationViewSize.height + extraHeightToCover)
				.onPreferenceChange(TitleKey.self) { newTitle in title = newTitle }
            }
            .onChange(of: scrollOffset) { offset in
                guard onRefresh != nil else { return }
                if isLockedForRefresh && scrollOffset.y >= 0 { isLockedForRefresh = false }

                if scrollOffset.isScrolledDown(config.progress.triggeringOffset) && !isLockedForRefresh {
                    if !isRefreshing {
                        UIImpactFeedbackGenerator(style: .rigid).impactOccurred()
                    }
                    isRefreshing = true
                    isLockedForRefresh = true
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
                backgroundStyle: barStyle,
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
                ? config.largeTitle.topPadding
                : config.largeTitle.topPadding
                    + config.largeTitle.supposedHeight
    }
}

// MARK: - Public API
public extension NavigationViewElastic {
    func refreshable(stopRefreshing: Binding<Bool>, onRefresh: @escaping () -> Void) -> Self {
        with(self) { copy in
            copy.stopRefreshing = stopRefreshing
            copy.onRefresh = onRefresh
        }
    }

    func barStyle<Bar: ShapeStyle>(_ style: Bar) -> Self {
        with(self) { copy in
            copy.barStyle = AnyShapeStyle(style)
        }
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
