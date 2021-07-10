import SwiftUI

@main
struct AppleMusicRichPresenceApp: App {

    var body: some Scene {
        WindowGroup {
            ContentView()
        }.commands {
            CommandGroup(replacing: .newItem) {}
            CommandGroup(replacing: .help) {}
        }
    }
}
