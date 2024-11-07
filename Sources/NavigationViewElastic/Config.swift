//
//  Config.swift
//  
//
//  Created by Илья Аникин on 20.09.2023.
//

import Foundation
import SwiftUI

// MARK: - Config
public extension NVE {
    struct Config {
        /// Parameters for large title layer.
        public var largeTitle: LargeTitle
        /// Parameters for small title layer.
        public var smallTitle: SmallTitle
        /// Parameters for refresh progress indication in portrait orientation.
        public var progressPortrait: Progress
        /// Parameters for refresh progress indication in landscape orientation.
        public var progressLandscape: Progress
        /// Style of bar in collapsed state
        public var barCollapsedStyle: AnyShapeStyle
        /// A threshold determines how to change bar's background opacity when it is collapsing.
        public var barOpacityThreshold: CGFloat
        /// Collection of safe area edges to be ignored by the content
        /// within scrollable area.
        public var contentIgnoresSafeAreaEdges: Edge.Set
        /// This animation applied to the internal ``ScrollView`` when **subtitleContent**
        /// size is changing.
        public var subtitleSizeChangeAnimation: Animation?

        public init(
            largeTitleConfig: LargeTitle = .default,
            smallTitleConfig: SmallTitle = .default,
            progressPortrait: Progress = .portrait,
            progressLandscape: Progress = .landscape,
            barCollapsedStyle: AnyShapeStyle = AnyShapeStyle(.bar),
            barOpacityThreshold: CGFloat = 10,
            contentIgnoresSafeAreaEdges: Edge.Set = [],
            subtitleSizeChangeAnimation: Animation? = .spring
        ) {
            self.largeTitle = largeTitleConfig
            self.smallTitle = smallTitleConfig
            self.progressPortrait = progressPortrait
            self.progressLandscape = progressLandscape
            self.barCollapsedStyle = barCollapsedStyle
            self.barOpacityThreshold = barOpacityThreshold
            self.contentIgnoresSafeAreaEdges = contentIgnoresSafeAreaEdges
            self.subtitleSizeChangeAnimation = subtitleSizeChangeAnimation
        }

        public static var `default` = Self()

        func progress(for orientation: UIInterfaceOrientation) -> Progress {
            switch orientation {
            case .portrait: return progressPortrait
            case .landscapeLeft, .landscapeRight: return progressLandscape
            default: return .portrait
            }
        }
    }
}

public extension NVE.Config {
    /// Bar configuration scheme:
    /// -------------
    /// ```
    ///                    safe area top edge
    /// |--------------------------------------------------------|
    /// |        [topEdgeInset + smallTitle.topPadding]          |
    /// |--------------------------------------------------------|
    /// | leading item      small title block      trailing item |
    /// |--------------------------------------------------------|
    /// |                      [topPadding]                      |
    /// |--------------------------------------------------------|
    /// |             large title block [supposedHeight]         |
    /// |--------------------------------------------------------|
    /// |                    [bottomPadding]                     |
    /// |--------------------------------------------------------|
    /// |                    subtitle content                    |
    /// |--------------------------------------------------------|
    /// ```
    ///
    struct LargeTitle {
        /// Approximated large title text height
        public var supposedHeight: CGFloat
        /// Padding from safe area top edge to top edge of small title block.
        public var topEdgeInset: CGFloat
        /// Padding from top edge of large title block to title text itself.
        public var topPadding: CGFloat
        /// Padding from bottom edge of large title block to subtitle content.
        public var bottomPadding: CGFloat

        public init(
            supposedHeight: CGFloat = 40,
            topEdgeInset: CGFloat = 0,
            topPadding: CGFloat = 0,
            bottomPadding: CGFloat = 0
        ) {
            self.supposedHeight = supposedHeight
            self.topEdgeInset = topEdgeInset
            self.topPadding = topPadding
            self.bottomPadding = bottomPadding
        }

        public static let `default` = Self()
    }
    
    struct SmallTitle {
        /// Padding from top edge of small title block to title text itself in portrait orientation.
        public var topPaddingPortrait: CGFloat
        /// Padding from top edge of small title block to title text itself in portrait orientation.
        public var topPaddingLandscape: CGFloat
        /// Padding from bottom edge of small title block.
        public var bottomPadding: CGFloat
        
        public init(
            topPaddingPortrait: CGFloat = 0,
            topPaddingLandscape: CGFloat = 7,
            bottomPadding: CGFloat = 10
        ) {
            self.topPaddingPortrait = topPaddingPortrait
            self.topPaddingLandscape = topPaddingLandscape
            self.bottomPadding = bottomPadding
        }
        
        /// Returns orientation dependent top padding.
        func topPadding(for orientation: UIInterfaceOrientation) -> CGFloat {
            switch orientation {
            case .portrait: topPaddingPortrait
            case .landscapeLeft, .landscapeRight: topPaddingLandscape
            default: topPaddingPortrait
            }
        }
        
        public static let `default` = Self()
    }

    struct Progress {
        /// Scroll offset when progress indicator begins to appear.
        public var startRevealOffset: CGFloat
        /// Scroll offset when progress indicator is fully appeared.
        public var revealedOffset: CGFloat
        /// Scroll offset when refreshable action should be triggered.
        public var triggeringOffset: CGFloat

        public init(
            startRevealOffset: CGFloat,
            revealedOffset: CGFloat,
            triggerThreshold: CGFloat
        ) {
            if startRevealOffset >= revealedOffset {
                self.startRevealOffset = Self.portrait.startRevealOffset
                self.revealedOffset = Self.portrait.revealedOffset
            } else {
                self.startRevealOffset = startRevealOffset
                self.revealedOffset = revealedOffset
            }

            self.triggeringOffset = revealedOffset + triggerThreshold
        }

        public static let portrait = Self(startRevealOffset: 30, revealedOffset: 110, triggerThreshold: 15)
        public static let landscape = Self(startRevealOffset: 20, revealedOffset: 60, triggerThreshold: 5)
    }
}
