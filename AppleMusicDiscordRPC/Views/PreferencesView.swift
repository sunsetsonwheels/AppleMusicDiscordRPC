import SwiftUI

struct PreferencesView: View {
    @ObservedObject var rpcObservable: DiscordRPCObservable
    @ObservedObject var sparkleObservable: SparkleObservable

    @AppStorage("showAlbumArt") private var showAlbumArt: Bool = true
    @AppStorage("showPlaybackIndicator") private var showPlaybackIndicator: Bool = true
    @AppStorage("SUEnableAutomaticChecks") private var shouldCheckUpdates: Bool = false
    
    private func setRPC(b: Bool) {
        DispatchQueue.main.async {
            self.rpcObservable.setRPC()
        }
    }
    
    var body: some View {
        Toggle("Show album art", isOn: self.$showAlbumArt)
            .onChange(of: self.showAlbumArt, perform: self.setRPC)
        Toggle("Show playback indicator", isOn: self.$showPlaybackIndicator)
            .onChange(of: self.showPlaybackIndicator, perform: self.setRPC)
        Toggle("Automatically check for updates", isOn: self.$shouldCheckUpdates)
            .onChange(of: self.shouldCheckUpdates) { _ in
                DispatchQueue.main.async {
                    self.sparkleObservable.automaticallyCheckForUpdates = self.shouldCheckUpdates
                }
            }
        Button(action: {
            self.sparkleObservable.checkForUpdates()
        }) {
            HStack {
                Spacer()
                Text("Check for updates")
                Spacer()
            }
        }
        .disabled(!self.sparkleObservable.canCheckForUpdates)
    }
}
