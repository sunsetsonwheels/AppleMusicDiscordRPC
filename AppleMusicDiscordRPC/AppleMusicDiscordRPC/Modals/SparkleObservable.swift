import SwiftUI
import Sparkle

// Adapted from:
// https://github.com/writefreely/writefreely-swiftui-multiplatform/blob/main/macOS/Settings/MacUpdatesViewModel.swift

class SparkleObservable: ObservableObject {
    @Published var canCheckForUpdates: Bool = true
    private let updaterController: SPUStandardUpdaterController
    
    var automaticallyCheckForUpdates: Bool {
        get {
            return updaterController.updater.automaticallyChecksForUpdates
        }
        set(newValue) {
            updaterController.updater.automaticallyChecksForUpdates = newValue
        }
    }
    
    init() {
        self.updaterController = SPUStandardUpdaterController(
            startingUpdater: true,
            updaterDelegate: nil,
            userDriverDelegate: nil
        )

        self.updaterController.updater.publisher(for: \.canCheckForUpdates)
            .assign(to: &self.$canCheckForUpdates)
        
        if self.automaticallyCheckForUpdates {
            self.updaterController.updater.checkForUpdatesInBackground()
        }
    }

    func checkForUpdates() {
        updaterController.checkForUpdates(nil)
    }
}
