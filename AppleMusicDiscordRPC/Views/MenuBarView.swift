import SwiftUI

struct MenuBarView: View {
    @ObservedObject var rpcObservable: DiscordRPCObservable
    @ObservedObject var sparkleObservable: SparkleObservable

    var body: some View {
        VStack(alignment: .leading) {
            RPCStatusView(rpcObservable: self.rpcObservable)
            Divider()
            PreferencesView(
                rpcObservable: self.rpcObservable,
                sparkleObservable: self.sparkleObservable
            )
            InfoView(
                rpcObservable: self.rpcObservable
            )
        }
        .padding()
        .onReceive(NotificationCenter.default.publisher(for: NSApplication.willTerminateNotification)) { _ in
            self.rpcObservable.disconnectFromDiscord()
        }
    }
}
