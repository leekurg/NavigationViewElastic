//
//  Created by Илья Аникин on 20.07.2023.
//

import SwiftUI
import Foundation

/// Custom navigation bar
/// Was created to imitate system bar with ability to add custom content in the bottom of bar
/// `content` and `subtitleContent` is not `() -> Content` that was made to prevent their content redrawing during scrolling
///
/// NOTE: Suggest to use main content embeded in LazyStack
public struct NavigationViewElastic: View {
    let title: String
    let blurStyle: UIBlurEffect.Style
    let content: AnyView
    let subtitleContent: AnyView
    let primaryActionLabel: AnyView?
    let stopRefreshing: Binding<Bool>
    let onRefresh: (() -> Void)?

    public init(
        title: String,
        blurStyle: UIBlurEffect.Style = .regular,
        content: AnyView,
        subtitleContent: AnyView,
        primaryActionLabel: AnyView? = nil,
        stopRefreshing: Binding<Bool> = .constant(false),
        onRefresh: (() -> Void)? = nil
    ) {
        self.title = title
        self.blurStyle = blurStyle
        self.content = content
        self.subtitleContent = subtitleContent
        self.primaryActionLabel = primaryActionLabel
        self.stopRefreshing = stopRefreshing
        self.onRefresh = onRefresh
    }


    private let largeTitleSupposedHeight: CGFloat = 40
    private let largeTitleAdditionalTopPadding: CGFloat = 20
    private let navigationViewLargeTitleTopPadding: CGFloat = 40
    private let navigationViewLargeTitleBottomPadding: CGFloat = 10
//    private let progressTriggeringOffset: CGFloat = getProgressOffsetForScreenSize(targetOffset: 30)
//    private let progressViewTargetHeight: CGFloat = getProgressHeightForScreenSize(targetHeight: 60)
    private let progressTriggeringOffset: CGFloat = 30
    private let progressViewTargetHeight: CGFloat = 60

    @State private var navigationViewSize: CGSize = .zero
    @State private var scrollOffset = CGPoint.zero
    @State private var isRefreshing: Bool = false

    @Environment(\.colorScheme) var colorScheme

    public var body: some View {
        ZStack(alignment: .top) {
            ScrollViewObservable(showsIndicators: false, offset: $scrollOffset) {
                VStack(spacing: 0) {
                    progressView

                    content
                }
                .animation(.easeInOut(duration: 0.3), value: progressPanelHeight)
                .padding(.top, navigationViewSize.height + titleTopPaddingBlock)
            }
            .onChange(of: scrollOffset) { offset in
                if scrollOffset.isScrolledDown(progressViewTargetHeight + progressTriggeringOffset) {
                    if !isRefreshing {
                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    }
                    isRefreshing = true
                }
            }
            .onChange(of: stopRefreshing.wrappedValue) { stop in
                if stop {
                    isRefreshing = false
                    print("Stop refresh received!!!")
                }
            }
            .onChange(of: isRefreshing) { refreshing in
                if refreshing { onRefresh?() }
            }
//            .onChange(of: navigationViewLargeTitleSize) { value in
//                print("title h: \(value.height)")
//            }

            navigationView
        }
        .ignoresSafeArea(.container, edges: .top)
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
        .frame(height: progressPanelHeight)
        .opacity(progressOpacity)
    }

    var navigationView: some View {
        ZStack(alignment: .top) {
            largeTitleLayer

            smallTitleLayer
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
                    .padding(   // TODO: move paddings set to private let
                        .init(
                            top: navigationViewLargeTitleTopPadding,
                            leading: 20,
                            bottom: navigationViewLargeTitleBottomPadding,
                            trailing: 10
                        )
                    )

                subtitleContent

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
        ZStack(alignment: .top) {
            HStack { Text(title).lineLimit(1) }
                .font(.system(size: 17, weight: .semibold))
                .opacity(smallTitleOpacity)
                .frame(maxWidth: UIScreen.width * 0.5)
                .animation(.easeIn(duration: 0.2), value: smallTitleOpacity)

            HStack {
                Spacer()

                primaryActionLabel
            }
            .padding(.trailing, 10)
        }
        .padding(.top, navigationViewLargeTitleTopPadding)
        .frame(maxWidth: .infinity)
        .frame(
            height: navigationViewLargeTitleTopPadding +
            largeTitleSupposedHeight +
            navigationViewLargeTitleBottomPadding
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
            BlurEffect(style: .systemMaterial)
        } else {
            if colorScheme == .dark {
                Color.black
            } else {
                Color.white
            }
        }
    }

    var titleTopPaddingBlock: CGFloat {
        // Padding to lower large title a bit to give it some upper space
        let heightToCover = largeTitleSupposedHeight + largeTitleAdditionalTopPadding
        if scrollOffset.isScrolledDown() {
            var blockHeight = heightToCover + (-scrollOffset.y)

            if onRefresh != nil {
                blockHeight = clamp(blockHeight, max: heightToCover + 20)
            }
//            print("titleTopPaddingBlock: \(blockHeight)")
            return blockHeight
        } else {
            let offset = clamp(
                scrollOffset.y, min: 0,
                max: heightToCover * 2
            )
            let blockHeight = clamp(heightToCover - offset / 2, min: 0)
//            print("titleTopPaddingBlock: \(blockHeight))")
            return blockHeight
        }
    }

    var progressOpacity: Double {
        let triggeringOffset = progressTriggeringOffset + 30

        guard !isRefreshing else { return progressViewTargetHeight }
        guard scrollOffset.isScrolledDown(triggeringOffset) else { return 0 }

        var offset: Double = -clamp(
            scrollOffset.y,
            min: -(triggeringOffset + progressViewTargetHeight),
            max: -(triggeringOffset + 1)
        )
        offset -= triggeringOffset
        let opacity = clamp(offset / progressViewTargetHeight, min: 0, max: 1)

        return opacity
    }

    var progressPanelHeight: CGFloat {
        guard !isRefreshing else { return progressViewTargetHeight }
        guard scrollOffset.isScrolledDown(progressTriggeringOffset) else { return 0 }

        var offset: Double = -clamp(
            scrollOffset.y,
            min: -(progressTriggeringOffset + progressViewTargetHeight),
            max: -(progressTriggeringOffset + 1)
        )
        offset -= progressTriggeringOffset

        return offset
    }

    static func getProgressOffsetForScreenSize(
        targetOffset: CGFloat,
        targetScreenHeight: CGFloat = 800
    ) -> CGFloat {
        targetOffset * UIScreen.height / targetScreenHeight
    }

    static func getProgressHeightForScreenSize(
        targetHeight: CGFloat,
        targetScreenHeight: CGFloat = 800
    ) -> CGFloat {
        targetHeight * UIScreen.height / targetScreenHeight
    }
}
