import SwiftUI

struct MiscView: View {
    @ObservedObject var rpcObservable: DiscordRPCObservable
    
    var body: some View {
        HStack {
            Spacer()

            Button(action: {
                NSApp.orderFrontStandardAboutPanel(nil)
            }) {
                Image(systemName: "info.circle")
            }
            .keyboardShortcut("i")

            Button(action: {
                self.rpcObservable.disconnectFromDiscord()
                NSApp.terminate(nil)
            }) {
                Image(systemName: "power")
            }
            .keyboardShortcut("q")
        }
    }
}
