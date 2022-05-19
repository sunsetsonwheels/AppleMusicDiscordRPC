import SwiftUI

struct PreferencesView: View {
    @ObservedObject var rpcObservable: DiscordRPCObservable
    @ObservedObject var sparkleObservable: SparkleObservable

    @AppStorage("showAlbumArt") private var showAlbumArt: Bool = true
    @AppStorage("SUEnableAutomaticChecks") private var shouldCheckUpdates: Bool = false
    
    var body: some View {
        Form {
            Toggle(isOn: self.$showAlbumArt) {
                Text("Show album art")
            }
            Text("Disabling this will display Apple Music's logo instead. Disable if you have a slow connection.")
            Toggle(isOn: self.$shouldCheckUpdates) {
                Text("Automatically check for updates")
            }
            Text("Checks and downloads updates automatically from GitHub.")
        }
        .padding(20)
        .onChange(of: self.showAlbumArt) { _ in
            DispatchQueue.main.async {
                self.rpcObservable.setRPC()
            }
        }
        .onChange(of: self.shouldCheckUpdates) { _ in
            DispatchQueue.main.async {
                self.sparkleObservable.automaticallyCheckForUpdates = self.shouldCheckUpdates
            }
        }
        .toolbar {
            ToolbarItem {
                Button("Reset") {
                    self.showAlbumArt = true
                }
            }
        }
        .navigationSubtitle("Preferences")
    }
}
