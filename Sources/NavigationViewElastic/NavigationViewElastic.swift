//
//  Created by Илья Аникин on 20.07.2023.
//

import Foundation
import SwiftUI

/// Namespace for additional components
public enum NVE { }

/// Container with navigation bar and scrollable area, mimic of system's *NavigationStack* with ability to
/// add user's content to the bottom of the navigation bar.
///
/// Provides a vertical scrollable area for user's content and a variety of customizations for navigation bar, API
/// for programmatically scrolling.
///
/// - Important: **Known Issue:** If the content height of ``NavigationViewElastic`` is insufficient,
/// scrolling may appear **stuttery**.
/// To prevent this issue, ensure that ``NavigationViewElastic`` has enough content to fully occupy
/// the available space, providing a smooth scrolling experience.
///
public struct NavigationViewElastic<C: View, S: View, L: View, T: View>: View {
    @ViewBuilder let content: () -> C
    @ViewBuilder let subtitleContent: () -> S
    @ViewBuilder let leadingBarItem: () -> L
    @ViewBuilder let trailingBarItem: () -> T
    private var scrollToAnchor: Binding<NVE.ScrollAnchor?>
    private var stopRefreshing: Binding<Bool>
    private var onRefresh: (() -> Void)?

    public init(
        @ViewBuilder content: @escaping () -> C,
        @ViewBuilder subtitleContent: @escaping () -> S = { EmptyView() },
        @ViewBuilder leadingBarItem: @escaping () -> L = { EmptyView() },
        @ViewBuilder trailingBarItem: @escaping () -> T = { EmptyView() },
        scrollToAnchor: Binding<NVE.ScrollAnchor?> = .constant(.none),
        stopRefreshing: Binding<Bool> = .constant(false),
        onRefresh: (() -> Void)? = nil
    ) {
        self.content = content
        self.subtitleContent = subtitleContent
        self.leadingBarItem = leadingBarItem
        self.trailingBarItem = trailingBarItem
        self.scrollToAnchor = scrollToAnchor
        self.stopRefreshing = stopRefreshing
        self.onRefresh = onRefresh
    }

    @Environment(\.nveConfig) var config

    @StateObject private var orientationDetector = OrientationDetector(
        filter: [.portrait, .landscapeLeft, .landscapeRight]
    )

    @State private var title: String?
    @State private var titleDisplayMode: NVE.PreferredTitleDisplayMode = .auto
    @State private var navigationViewSize: CGSize = .zero
    @State private var scrollOffset = CGPoint.zero
    @State private var isRefreshing: Bool = false
    @State private var contentSize: CGSize = .zero
    /// Determines that swipe down gesture is released and component is
    /// ready to next swipe. Used to prevent multiple refreshes during one swipe.
    @State private var isLockedForRefresh: Bool = false

    public var body: some View {
        ZStack(alignment: .top) {
            let scrollTo = Binding<ScrollRelativeAnchor?>(
                get: {
                    switch scrollToAnchor.wrappedValue {
                    case .topInline: { switch titleDisplayMode {
                        case .inline: .top(offset: 0)
                        default: .top(offset: config.smallTitle.supposedHeight + 1)
                        }
                    }()
                    case .topLarge: .top(offset: 0)
                    case .bottom: .bottom(offset: 0)
                    case .none: .none
                    }
                },
                set: { _ in
                    scrollToAnchor.wrappedValue = nil
                }
            )

            ScrollViewObservable(
                showsIndicators: false,
                offset: $scrollOffset,
                scrollToAnchor: scrollTo
            ) {
                VStack(spacing: 0) {    //VStack wrapper for ability to add spacing on content's top (occured on iOS 17)
                    VStack(spacing: 0) {
                        content()
                    }
                }
                .onChange(of: contentSize) {
                    print("content h: \($0.height)")
                }
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(
                    .top,
                    navigationViewSize.height
                        + extraHeightToCover
                        + orientationDetector.insets.top
                        + config.smallTitle.topPadding(
                            for: orientationDetector.interfaceOrientation
                        )
                )
                .padding(orientationDetector.insets.ignoring([config.contentIgnoresSafeAreaEdges, .vertical]))
				.onPreferenceChange(TitleKey.self) { newTitle in title = newTitle }
                .onPreferenceChange(PreferredTitleDisplayModeKey.self) { newMode in titleDisplayMode = newMode }
            }
            .onChange(of: scrollOffset) { offset in
                guard onRefresh != nil else { return }
                if isLockedForRefresh && scrollOffset.y >= 0 { isLockedForRefresh = false }

                let triggeringOffset = config.progress(
                    for: orientationDetector.interfaceOrientation
                ).triggeringOffset

                if scrollOffset.isScrolledDown(triggeringOffset) && !isLockedForRefresh {
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
                titleDisplayMode: titleDisplayMode,
                orientation: orientationDetector.interfaceOrientation,
                safeAreaInsets: orientationDetector.insets,
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
        .ignoresSafeArea(.container, edges: [.top, .horizontal])
    }

    var extraHeightToCover: CGFloat {
        if title == nil { return 0 }

        return switch titleDisplayMode {
        case .auto:
            orientationDetector.interfaceOrientation.isLandscape
                ? 0
                : config.largeTitle.topPadding + config.largeTitle.supposedHeight
        case .large:
            config.largeTitle.topPadding + config.largeTitle.supposedHeight
        case .inline:
            0
        }
    }
}

// MARK: - Public API
public extension NavigationViewElastic {
    /// Set up a corresponding ``NavigationViewElastic`` with a *refreshable* closure that will be called on *pull-to-refresh* gesture.
    ///
    /// - Parameters:
    ///  - stopRefreshing - binding allows to programmatically stop refreshing process and switch
    ///  from *refreshing* state to *idle* state.
    ///  - onRefresh - a closure to run when  *pull-to-refresh* gesture triggered.
    ///
    func refreshable(stopRefreshing: Binding<Bool>, onRefresh: @escaping () -> Void) -> Self {
        with(self) { copy in
            copy.stopRefreshing = stopRefreshing
            copy.onRefresh = onRefresh
        }
    }

    /// Set up a corresponding ``NavigationViewElastic`` programmatic scroll feature.
    ///
    /// You provide a binding, and scroll happens when you set a non-nil value to it. Immidiatly after scroll begins
    /// the binding will be nilled out.
    ///
    func scrollableToAnchor(to anchor: Binding<NVE.ScrollAnchor?>) -> Self {
        with(self) { copy in
            copy.scrollToAnchor = anchor
        }
    }
}

public extension View {
    /// Sets up an observation for scroll **rect** position changes within the corresponding ``NavigationViewElastic``
    /// and triggers the provided **perform** closure whenever the value changes.
    ///
    /// - Important: Avoid performing heavy computations within the **perform** closure, as it will be called
    /// frequently during fast scrolling, which could impact performance.
    ///
    func onNveScrollRectChanged(_ perform: @escaping (CGRect) -> Void) -> some View {
        onPreferenceChange(NVEScrollRectPreferenceKey.self, perform: perform)
    }

    /// Sets up an observation for scroll value position changes within the corresponding ``NavigationViewElastic``
    /// and triggers the provided **perform** closure whenever the value changes.
    ///
    /// - Note: Coordinates are inverted to provide convenient output.
    ///
    /// - Important: Avoid performing heavy computations within the **perform** closure, as it will be called
    /// frequently during fast scrolling, which could impact performance.
    ///
    func onNveScrollPositionChanged(_ perform: @escaping (CGPoint) -> Void) -> some View {
        onPreferenceChange(NVEScrollRectPreferenceKey.self) { rect in
            perform(CGPoint(x: -rect.origin.x, y: -rect.origin.y))
        }
    }

    /// Configures the corresponding ``NavigationViewElastic`` to observe title display mode changes
    /// based on user interactions.
    ///
    /// The provided **perform** closure is triggered each time the title display mode changes between
    /// ``NVE/TitleDisplayMode/large`` and ``NVE/TitleDisplayMode/inline`` due to user interactions.
    ///
    /// ## Note:
    /// **perform** will not be called if any of the following conditions are met:
    /// 1. The title display mode is explicitly set to ``NVE/TitleDisplayMode/inline`` using
    ///    ``nveTitleDisplayMode(_:)``.
    /// 2. The title display mode is set to ``NVE/TitleDisplayMode/auto`` via ``nveTitleDisplayMode(_:)``
    ///    **and** the device's orientation is *landscape*.
    ///
    func onNveTitleDisplayModeChanged(_ perform: @escaping (NVE.TitleDisplayMode) -> Void) -> some View {
        onPreferenceChange(TitleDisplayModeChangedKey.self, perform: perform)
    }
}

#if DEBUG
#Preview {
    ProxyView()
}
#endif
