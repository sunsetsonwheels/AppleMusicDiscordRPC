import SwiftUI

struct PreferencesView: View {
    @EnvironmentObject var rpcObservable: DiscordRPCObservable

    @AppStorage("showAlbumArt") var showAlbumArt: Bool = true
    
    var body: some View {
        Form {
            Toggle(isOn: self.$showAlbumArt) {
                Text("Show album art")
            }
            Text("Disabling this will display Apple Music's logo instead.")
            Text("We recommend disabling if you have a slow network connection.")
        }
        .padding(20)
        .onChange(of: self.showAlbumArt) { _ in
            self.rpcObservable.setRPC()
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

struct PreferencesView_Previews: PreviewProvider {
    static var previews: some View {
        PreferencesView()
    }
}
