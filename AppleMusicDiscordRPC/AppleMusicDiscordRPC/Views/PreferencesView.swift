import SwiftUI

struct PreferencesView: View {
    @ObservedObject var rpcObservable: DiscordRPCObservable
    @ObservedObject var sparkleObservable: SparkleObservable

    @AppStorage("showAlbumArt") private var showAlbumArt: Bool = true
    @AppStorage("SUEnableAutomaticChecks") private var shouldCheckUpdates: Bool = false
    
    var body: some View {
        Toggle(isOn: self.$showAlbumArt) {
            Text("Show album art")
        }
        .onChange(of: self.showAlbumArt) { _ in
            DispatchQueue.main.async {
                self.rpcObservable.setRPC()
            }
        }

        Toggle(isOn: self.$shouldCheckUpdates) {
            Text("Automatically check for updates")
        }
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
