import SwiftUI

@main
struct AMDiscordRPCApp: App {
    @StateObject private var rpcObservable: DiscordRPCObservable = DiscordRPCObservable()
    @StateObject private var sparkleObservable: SparkleObservable = SparkleObservable()
    
    var body: some Scene {
        MenuBarExtra("Apple Music Discord RPC", systemImage: "music.note") {
            MenuBarView(
                rpcObservable: self.rpcObservable,
                sparkleObservable: self.sparkleObservable
            )
        }
        .menuBarExtraStyle(.window)
    }
}
