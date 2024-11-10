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
/// Provides a vertical scrollable area for user's content and a variety of customizations for navigation bar.
///
/// - Important: On **iOS 17** when pulling for refresh, main content might be stuttering.
/// It happens in underlying `ScrollView` when it's content changed to other view with different height.
///
public struct NavigationViewElastic<C: View>: View {
    @Binding var path: NavigationPath
    @ViewBuilder let content: () -> C
    private var stopRefreshing: Binding<Bool>
    private var onRefresh: (() -> Void)?

    public init(
        path: Binding<NavigationPath> = .constant(.init()),
        @ViewBuilder content: @escaping () -> C,
        stopRefreshing: Binding<Bool> = .constant(false),
        onRefresh: (() -> Void)? = nil
    ) {
        self._path = path
        self.content = content
        self.stopRefreshing = stopRefreshing
        self.onRefresh = onRefresh
    }

    @Environment(\.nveConfig) var config

    @StateObject private var orientationDetector = OrientationDetector(
        filter: [.portrait, .landscapeLeft, .landscapeRight]
    )

    @State private var title: String?
    @State private var titleDisplayMode: NVE.TitleDisplayMode = .auto
    @State private var toolbar: Toolbar?
    @State private var subtitleContent: AnyView?

    @State private var navigationViewSize: CGSize = .zero
    @State private var scrollOffset = CGPoint.zero
    @State private var isRefreshing: Bool = false
    /// Determines that swipe down gesture is released and component is
    /// ready to next swipe. Used to prevent multiple refreshes during one swipe.
    @State private var isLockedForRefresh: Bool = false

    public var body: some View {
        NavigationStack(path: $path) {
            ZStack(alignment: .top) {
                ScrollViewObservable(showsIndicators: false, offset: $scrollOffset) {
                    VStack(spacing: 0) {    //VStack wrapper for ability to add spacing on content's top (occured on iOS 17)
                        content()
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
                    .onPreferenceChange(TitleDisplayModeKey.self) { newMode in titleDisplayMode = newMode }
                }
                .onChange(of: scrollOffset) { offset in
                    guard onRefresh != nil else { return }
                    if isLockedForRefresh && scrollOffset.y >= 0 { isLockedForRefresh = false }
                    
                    let triggeringOffset = config.progress(
                        for: orientationDetector.interfaceOrientation
                    ).triggeringOffset
                    
                    if scrollOffset.isScrolledDown(triggeringOffset) && !isLockedForRefresh
                    {
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
                    toolbar: toolbar
                )
            }
            .ignoresSafeArea(.container, edges: [.top, .horizontal])
            .toolbar(.hidden, for: .navigationBar)
        }
        .onPreferenceChange(ToolbarSubtitleKey.self) { subtitle in
            subtitleContent = subtitle?.anyView
        }
        .onPreferenceChange(ToolbarKey.self) { toolbar in
            self.toolbar = toolbar
        }
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
    func refreshable(stopRefreshing: Binding<Bool>, onRefresh: @escaping () -> Void) -> Self {
        with(self) { copy in
            copy.stopRefreshing = stopRefreshing
            copy.onRefresh = onRefresh
        }
    }
}

#if DEBUG
#Preview {
    ProxyView()
}
#endif
