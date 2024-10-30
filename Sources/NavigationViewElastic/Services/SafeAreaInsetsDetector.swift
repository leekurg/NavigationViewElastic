//
//  SafeAreaInsetsDetector.swift
//  NavigationViewElastic
//
//  Created by Илья Аникин on 29.10.2024.
//

import Combine
import SwiftUI

/// Detects device orientation change and emits *safeAreaInsets* of app's first key window
/// with **1 ms** delay after orientation change.
///
final class SafeAreaInsetsDetector: ObservableObject {
    @Published var insets: EdgeInsets = UIApplication.shared.keyWindowInsets()
    
    private var cancellables: Set<AnyCancellable> = []
    
    init() {
        NotificationCenter.default
            .publisher(for: UIDevice.orientationDidChangeNotification)
            .map { _ in UIDevice.current.orientation }
            .filter { orientation in
                switch orientation {
                case .portrait, .landscapeLeft, .landscapeRight: true
                default: false
                }
            }
            // Delayed to allow clients fetch new orientation value directly from UIDevice
            .delay(for: .milliseconds(1), scheduler: RunLoop.main)
            .map { _ in UIApplication.shared.keyWindowInsets() }
            .removeDuplicates()
            .sink { [weak self] newInsets in
                self?.insets = newInsets
                print("🟡insets detected: \(self?.insets.top ?? -1)")
            }
            .store(in: &cancellables)
    }
}
