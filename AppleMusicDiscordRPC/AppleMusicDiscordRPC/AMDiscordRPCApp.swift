import SwiftUI

enum AppView {
    case rpcStatus
    case preferences
}

@main
struct AMDiscordRPCApp: App {
    @StateObject private var rpcObservable: DiscordRPCObservable = DiscordRPCObservable()
    @StateObject private var sparkleObservable: SparkleObservable = SparkleObservable()

    @State private var selectedView: AppView? = .rpcStatus
    
    var body: some Scene {
        WindowGroup {
            RootNavigationView(
                selectedView: self.$selectedView,
                rpcObservable: self.rpcObservable,
                sparkleObservable: self.sparkleObservable
            )
            .onReceive(NotificationCenter.default.publisher(for: NSApplication.didBecomeActiveNotification)) { _ in
                NSWindow.allowsAutomaticWindowTabbing = false
                NSApp.mainWindow?.standardWindowButton(.zoomButton)?.isEnabled = false
            }
            .onReceive(NotificationCenter.default.publisher(for: NSApplication.willTerminateNotification)) { _ in
                self.rpcObservable.disconnectFromDiscord()
            }
        }
        .commands {
            CommandGroup(after: .appInfo) {
                Button("Check for Updates...") {
                    self.sparkleObservable.checkForUpdates()
                }
                .disabled(!self.sparkleObservable.canCheckForUpdates)
            }
            CommandGroup(replacing: .appSettings) {
                Button("Preferences...") {
                    self.selectedView = .preferences
                }
                .keyboardShortcut(",")
            }
            CommandGroup(replacing: .newItem) {}
            CommandGroup(replacing: .sidebar) {}
            CommandGroup(replacing: .help) {
                Link("Open-source on GitHub", destination: URL(string: "https://github.com/jkelol111/AppleMusicDiscordRPC")!)
            }
        }
    }
}
