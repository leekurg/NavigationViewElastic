//
//  NavigationViewConfig.swift
//  
//
//  Created by Илья Аникин on 20.09.2023.
//

import Foundation

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

    public static var `default` = Self()
}

public extension NavigationViewConfig {
    /// Bar configuration scheme:
    /// -------------
    /// ```
    ///                      screen top edge
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
    struct LargeTitleConfig {
        /// Approximated large title text height
        let supposedHeight: CGFloat
        /// Padding from top screen edge to top edge of small title block.
        let topEdgeInset: CGFloat
        /// Padding from top edge of large title block to title text itself.
        let topPadding: CGFloat
        /// Padding from bottom edge of large title block to subtitle content.
        let bottomPadding: CGFloat
        /// A threshold determines how to change bar's background opacity when it is collapsing.
        let backgroundOpacityThreshold: CGFloat

        public init(
            supposedHeight: CGFloat = 40,
            topEdgeInset: CGFloat = 40,
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
