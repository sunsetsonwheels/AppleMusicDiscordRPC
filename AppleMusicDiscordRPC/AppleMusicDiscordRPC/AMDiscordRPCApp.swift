import SwiftUI

@main
struct AMDiscordRPCApp: App {
    @StateObject var rpcObservable: DiscordRPCObservable = DiscordRPCObservable()
    
    var body: some Scene {
        WindowGroup {
            ContentView().environmentObject(self.rpcObservable)
        }.commands {
            CommandGroup(replacing: .newItem) {}
            CommandGroup(replacing: .help) {}
        }

        Settings {
            SettingsView().environmentObject(self.rpcObservable)
        }
    }
}
