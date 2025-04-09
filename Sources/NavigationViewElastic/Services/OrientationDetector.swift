//
//  OrientationDetector.swift
//  NavigationViewElastic
//
//  Created by Илья Аникин on 30.10.2024.
//

import Combine
import SwiftUI

/// Detects the interface orientation change and publishes related data, such as
/// current interface orientation value and safe area insets of key window.
///
/// You can specify a set of orientation variants to track. By default, all orientations are tracked.
///
final class OrientationDetector: ObservableObject {
    @Published var insets: EdgeInsets = UIApplication.shared.keyWindowInsets()
    @Published var interfaceOrientation: UIInterfaceOrientation = UIApplication.shared.keyWindowIntefaceOrientation

    private var cancellables: Set<AnyCancellable> = []

    /// Specify a set of orientation variants to track. By default, all orientations are tracked.
    init(filter: [UIDeviceOrientation] = []) {
        let deviceOrientationPublisher = NotificationCenter.default
            .publisher(for: UIDevice.orientationDidChangeNotification)
            .map { _ in UIDevice.current.orientation }
            .filter { filter.isEmpty || filter.contains($0) }
            .eraseToAnyPublisher()
        
        deviceOrientationPublisher
            .compactMap { _ in UIApplication.shared.keyWindowIntefaceOrientation }
            .removeDuplicates()
            .sink { [weak self] in self?.interfaceOrientation = $0 }
            .store(in: &cancellables)
        
        deviceOrientationPublisher
            // Delayed to allow clients fetch new orientation value directly from UIDevice.
            // Scheduled to DispatchQueue.main because RunLoop.main could be busy with scroll events
            // during scroll, and insets will not be updated until scroll events is processed (scrolling is stopped).
            .delay(for: .milliseconds(1), scheduler: DispatchQueue.main)
            .map { _ in UIApplication.shared.keyWindowInsets() }
            .removeDuplicates()
            .sink { [weak self] in self?.insets = $0 }
            .store(in: &cancellables)
    }
}
