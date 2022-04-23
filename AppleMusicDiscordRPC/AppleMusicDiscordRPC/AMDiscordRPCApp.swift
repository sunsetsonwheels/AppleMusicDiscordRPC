import SwiftUI

enum AppView {
    case rpcStatus
    case preferences
}

@main
struct AMDiscordRPCApp: App {
    @StateObject private var rpcObservable: DiscordRPCObservable = DiscordRPCObservable()

    @State private var selectedView: AppView? = .rpcStatus
    
    var body: some Scene {
        WindowGroup {
            RootNavigationView(selectedView: self.$selectedView)
                .environmentObject(self.rpcObservable)
                .onReceive(NotificationCenter.default.publisher(for: NSApplication.willTerminateNotification)) { output in
                    self.rpcObservable.disconnectFromDiscord()
                }
        }
        .commands {
            CommandGroup(replacing: .appSettings) {
                Button("Preferences...") {
                    self.selectedView = .preferences
                }
                .keyboardShortcut(",")
            }
            CommandGroup(replacing: .newItem) {}
            CommandGroup(replacing: .help) {}
        }
    }
}
