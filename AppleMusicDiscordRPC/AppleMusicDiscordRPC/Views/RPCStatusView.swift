import SwiftUI

struct RPCStatusView: View {
    @ObservedObject var rpcObservable: DiscordRPCObservable
    
    var noArtwork: some View {
        Image("NoArtwork")
            .resizable()
            .frame(width: 256, height: 256)
    }

    var body: some View {
        VStack {
            if #available(macOS 12.0, *) {
                if let artworkURL: String = self.rpcObservable.artwork.url {
                    AsyncImage(url: URL(string: artworkURL)) { image in
                        image
                            .resizable()
                    } placeholder: {
                        self.noArtwork
                    }
                    .frame(width: 256, height: 256)
                    .contextMenu {
                        Button("Copy artwork link...") {
                            NSPasteboard.general.setString(artworkURL, forType: .URL)
                        }
                    }
                } else {
                    self.noArtwork
                }
            } else {
                self.noArtwork
            }
            Text(verbatim: rpcObservable.rpcData.name ?? "Unknown track")
                .bold()
            Text(verbatim: rpcObservable.rpcData.album ?? "Unknown album")
            Text(verbatim: rpcObservable.rpcData.artist ?? "Unknown artist")
            
        }
        .toolbar {
            ToolbarItem {
                Button(action: {
                    if self.rpcObservable.isDiscordConnected {
                        self.rpcObservable.disconnectFromDiscord()
                    } else {
                        self.rpcObservable.connectToDiscord()
                    }
                }) {
                    if self.rpcObservable.isDiscordConnected {
                        Label("Disconnect from Discord", systemImage: "network")
                    } else {
                        Label("Connect to Discord", systemImage: "bolt.horizontal.circle")
                    }
                }
                .disabled(self.rpcObservable.isChangingConnectionStatus)
            }
            ToolbarItem {
                Button(action: {}) {
                    switch self.rpcObservable.rpcData.state {
                    case .playing:
                        Label("Playing", systemImage: "play.fill")
                    case .paused:
                        Label("Paused", systemImage: "pause.fill")
                    case .stopped:
                        Label("Stopped", systemImage: "stop.fill")
                    }
                }
                .disabled(true)
            }
        }
        .navigationSubtitle("Status")
        .padding()
    }
}
