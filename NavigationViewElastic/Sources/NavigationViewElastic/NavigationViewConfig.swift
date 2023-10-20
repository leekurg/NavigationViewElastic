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
}

public extension NavigationViewConfig {
    struct LargeTitleConfig {
        let supposedHeight: CGFloat
        let topPadding: CGFloat
        let additionalTopPadding: CGFloat
        let bottomPadding: CGFloat

        public init(
            supposedHeight: CGFloat = 40, //approximated .largteTitle font height
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
