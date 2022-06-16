import SwiftUI

struct RPCStatusView: View {
    @ObservedObject var rpcObservable: DiscordRPCObservable
    
    private let artworkSize: CGFloat = 64
    
    var noArtwork: some View {
        Image("NoArtwork")
            .resizable()
            .frame(width: self.artworkSize, height: self.artworkSize)
    }

    var body: some View {
        HStack {
            if let artworkURL: String = self.rpcObservable.artwork.url {
                AsyncImage(url: URL(string: artworkURL)) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                    case .failure(let error):
                        self.noArtwork
                            .onAppear {
                                print(error)
                            }
                    default:
                        ProgressView()
                    }
                }
                .frame(width: self.artworkSize, height: self.artworkSize)
            } else {
                self.noArtwork
            }
            VStack(alignment: .leading) {
                Group {
                    Text(self.rpcObservable.rpcData.name ?? "Unknown track")
                        .help(self.rpcObservable.rpcData.name ?? "Unknown track")
                        .bold()
                    Text(self.rpcObservable.rpcData.album ?? "Unknown album")
                        .help(self.rpcObservable.rpcData.album ?? "Unknown album")
                    Text(self.rpcObservable.rpcData.artist ?? "Unknown artist")
                        .help(self.rpcObservable.rpcData.artist ?? "Unknown artist")
                }
                .lineLimit(1)
                
                HStack {
                    switch self.rpcObservable.rpcData.state {
                    case .playing:
                        Image(systemName: "play.fill")
                            .help("Playing")
                    case .paused:
                        Image(systemName: "pause.fill")
                            .help("Paused")
                    case .stopped:
                        Image(systemName: "stop.fill")
                            .help("Stopped")
                    }
                    if self.rpcObservable.isDiscordConnected {
                        Image(systemName: "network")
                            .help("Connected to Discord")
                    } else {
                        Image(systemName: "bolt.horizontal.circle")
                            .help("Disconnected from Discord")
                    }
                }
            }
        }

        Button(action: {
            if self.rpcObservable.isDiscordConnected {
                self.rpcObservable.disconnectFromDiscord()
            } else {
                self.rpcObservable.connectToDiscord()
            }
        }) {
            HStack {
                Spacer()
                if self.rpcObservable.isDiscordConnected {
                    Text("Disconnect from Discord")
                } else {
                    Text("Connect to Discord")
                }
                Spacer()
            }
        }
        .padding(.top)
    }
}
