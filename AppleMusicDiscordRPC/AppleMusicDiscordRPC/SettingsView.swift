import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var rpcObservable: DiscordRPCObservable

    @AppStorage("TopText") var topText: TextSetting = .name
    @AppStorage("BottomText") var bottomText: TextSetting = .artist
    @AppStorage("LargeImageHoverText") var largeImageHoverText: TextSetting = .album
    @AppStorage("ShowLargeImage") var showLargeImage: Bool = true
    @AppStorage("ShowVersionOnLargeImageHover") var showVersionOnLargeImageHover: Bool = true
    @AppStorage("ShowPlaybackState") var showPlaybackState: Bool = true
    @AppStorage("ShowRemainingTime") var showRemainingTime: Bool = true
    
    var radioButtons: some View {
        ForEach(TextSetting.allCases, id: \.self, content: { item in
            Text(item.rawValue).tag(item)
        })
    }
    
    var body: some View {
        TabView {
            Form {
                Picker("Top text: ", selection: self.$topText) {
                    self.radioButtons
                }
                Picker("Bottom text: ", selection: self.$bottomText) {
                    self.radioButtons
                }
                Picker("Apple Music logo hover text: ", selection: self.$largeImageHoverText) {
                    self.radioButtons
                }.disabled(!self.showLargeImage)
            }.tabItem {
                Label("Text displays", systemImage: "text.justifyleft")
            }
            Form {
                Toggle(isOn: self.$showLargeImage) {
                    Text("Show Apple Music logo")
                }
                Toggle(isOn: self.$showVersionOnLargeImageHover) {
                    Text("Show version on Apple Music logo hover")
                }.disabled(!self.showLargeImage)
                Toggle(isOn: self.$showPlaybackState) {
                    Text("Show playback state")
                }.disabled(!self.showLargeImage)
                Toggle(isOn: self.$showRemainingTime) {
                    Text("Show remaining time")
                }
            }.tabItem {
                Label("Other displays", systemImage: "rectangle.badge.checkmark")
            }
        }.padding(20)
        .frame(width: 420, height: 150)
        .onChange(of: self.topText) { _ in
            self.rpcObservable.setRPC()
        }
        .onChange(of: self.bottomText) { _ in
            self.rpcObservable.setRPC()
        }
        .onChange(of: self.largeImageHoverText) { _ in
            self.rpcObservable.setRPC()
        }
        .onChange(of: self.showLargeImage) { _ in
            self.rpcObservable.setRPC()
        }
        .onChange(of: self.showVersionOnLargeImageHover) { _ in
            self.rpcObservable.setRPC()
        }
        .onChange(of: self.showPlaybackState) { _ in
            self.rpcObservable.setRPC()
        }
        .onChange(of: self.showRemainingTime) { _ in
            self.rpcObservable.setRPC()
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
