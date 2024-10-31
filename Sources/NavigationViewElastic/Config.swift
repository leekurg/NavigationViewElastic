//
//  Config.swift
//  
//
//  Created by Илья Аникин on 20.09.2023.
//

import Foundation

// MARK: - Config
public extension NVE {
    struct Config {
        /// Parameters for large title layer.
        var largeTitle: LargeTitle
        /// Parameters for refresh progress indication in portrait orientation.
        var progressPortrait: Progress
        /// Parameters for refresh progress indication in landscape orientation.
        var progressLandscape: Progress

        public init(
            largeTitleConfig: LargeTitle = .default,
            progressPortrait: Progress = .portrait,
            progressLandscape: Progress = .landscape
        ) {
            self.largeTitle = largeTitleConfig
            self.progressPortrait = progressPortrait
            self.progressLandscape = progressLandscape
        }

        public static var `default` = Self()

        public func progressFor(_ isLandscape: Bool) -> Progress {
            isLandscape ? progressLandscape : progressPortrait
        }
    }
}

public extension NVE.Config {
    /// Bar configuration scheme:
    /// -------------
    /// ```
    ///                    safe area top edge
    /// |--------------------------------------------------------|
    /// |                    [topEdgeInset]                      |
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
        var supposedHeight: CGFloat
        /// Padding from safe area top edge to top edge of small title block.
        var topEdgeInset: CGFloat
        /// Padding from top edge of large title block to title text itself.
        var topPadding: CGFloat
        /// Padding from bottom edge of large title block to subtitle content.
        var bottomPadding: CGFloat
        /// A threshold determines how to change bar's background opacity when it is collapsing.
        var backgroundOpacityThreshold: CGFloat

        public init(
            supposedHeight: CGFloat = 40,
            topEdgeInset: CGFloat = 0,
            topPadding: CGFloat = 15,
            bottomPadding: CGFloat = 5,
            backgroundOpacityThreshold: CGFloat = 10
        ) {
            self.supposedHeight = supposedHeight
            self.topEdgeInset = topEdgeInset
            self.topPadding = topPadding
            self.bottomPadding = bottomPadding
            self.backgroundOpacityThreshold = backgroundOpacityThreshold
        }

        public static let `default` = Self()
    }

    struct Progress {
        /// Scroll offset when progress indicator begins to appear.
        var startRevealOffset: CGFloat
        /// Scroll offset when progress indicator is fully appeared.
        var revealedOffset: CGFloat
        /// Scroll offset when refreshable action should be triggered.
        var triggeringOffset: CGFloat

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
