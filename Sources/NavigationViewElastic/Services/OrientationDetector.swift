//
//  OrientationDetector.swift
//  NavigationViewElastic
//
//  Created by Илья Аникин on 30.10.2024.
//

import Combine
import SwiftUI

/// Detects the device orientation change and publishes its current value.
///
/// You can specify a set of orientation variants to track.
final class OrientationDetector: ObservableObject {
    @Published var orientation: UIDeviceOrientation = UIDevice.current.orientation

    private var cancellables: Set<AnyCancellable> = []

    /// You can specify a set of orientation variants to track.
    init(filter: [UIDeviceOrientation] = []) {
        NotificationCenter.default
            .publisher(for: UIDevice.orientationDidChangeNotification)
            .map { _ in UIDevice.current.orientation }
            .filter { filter.contains($0) }
            .removeDuplicates()
            .sink { [weak self] in
                self?.orientation = $0
            }
            .store(in: &cancellables)
    }
}
