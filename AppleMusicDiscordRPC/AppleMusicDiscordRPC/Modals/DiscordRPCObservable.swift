import SwiftUI
import ScriptingBridge
import SwordRPC
import os

class DiscordRPCObservable: ObservableObject {
    private struct iTunesQueryResults: Decodable {
        let artworkUrl100: String
    }

    private struct iTunesQueryResponse: Decodable {
        let resultCount: Int
        let results: [iTunesQueryResults]
    }

    enum AMPlayerStates: String {
        case playing = "playing"
        case paused = "paused"
        case stopped = "stopped"
    }

    struct DiscordRPCData {
        var name: String?
        var artist: String?
        var album: String?
        var totalTime: Double?
        var state: AMPlayerStates
    }

    struct AMArtwork {
        var album: String?
        var url: String?
    }

    @Published var rpcData: DiscordRPCData = DiscordRPCData(state: .stopped)
    @Published var artwork: AMArtwork = AMArtwork()

    @Published var isDiscordConnected: Bool = false
    @Published var isChangingConnectionStatus: Bool = true

    @AppStorage("showAlbumArt") var showAlbumArt: Bool = true
    
    private let nc: DistributedNotificationCenter = DistributedNotificationCenter.default()
    private var ncObserver: NSObjectProtocol = NSObject()
    private let AMApp: MusicApplication? = SBApplication(bundleIdentifier: "com.apple.Music")
    
    private var rpc: SwordRPC = SwordRPC(appId: "785053859915366401")

    private let logger: Logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "DiscordRPCObservable")
    private let jsond: JSONDecoder = JSONDecoder()
    
    func setRPC() {
        if isDiscordConnected {
            var presence: RichPresence = RichPresence()
            
            presence.details = self.rpcData.name
            presence.state = self.rpcData.artist
            
            if self.rpcData.state == .playing,
               let playerPosition: Double = self.AMApp?.playerPosition,
               let totalTime: Double = self.rpcData.totalTime {
                let currentTime: Date = Date()
                presence.timestamps.start = currentTime
                presence.timestamps.end = currentTime + (totalTime - playerPosition)
            }
            
            presence.assets.smallText = self.rpcData.state.rawValue.capitalized
            presence.assets.smallImage = self.rpcData.state.rawValue
            
            presence.assets.largeText = self.rpcData.album
            if self.showAlbumArt,
               let name: String = self.rpcData.name,
               let album: String = self.rpcData.album,
               let artist: String = self.rpcData.artist {
                if self.artwork.album == album {
                    self.logger.info("Album identical, not replacing artwork URL.")
                    presence.assets.largeImage = self.artwork.url
                    self.rpc.setPresence(presence)
                    return
                }
                self.logger.info("Fetching artwork for: \(name, privacy: .public), \(album, privacy: .public), \(artist, privacy: .public)")
                let encodedTerms: String = "\(name) \(album) \(artist)".addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
                if let url: URL = URL(string: "https://itunes.apple.com/search?term=\(encodedTerms)&media=music&entity=song&limit=1") {
                    var request: URLRequest = URLRequest(url: url)
                    request.timeoutInterval = 2
                    URLSession.shared.dataTask(
                        with: request,
                        completionHandler: { data, response, error in
                            if let error = error {
                                self.logger.error("Unable to fetch artwork: \(error.localizedDescription, privacy: .public)")
                                presence.assets.largeImage = "applemusic_large"
                                self.artwork.url = nil
                                self.rpc.setPresence(presence)
                            }
                            if let data = data {
                                if let iTunesResponse: iTunesQueryResponse = try? self.jsond.decode(iTunesQueryResponse.self, from: data) {
                                    if iTunesResponse.resultCount > 0 {
                                        let artworkURL: String = iTunesResponse.results.first!.artworkUrl100.replacingOccurrences(of: "100x100bb", with: "512x512")
                                        self.logger.info("Fetched artwork: \(artworkURL, privacy: .public)")
                                        presence.assets.largeImage = artworkURL
                                        DispatchQueue.main.async {
                                            self.artwork.album = album
                                            self.artwork.url = artworkURL
                                        }
                                    } else {
                                        self.logger.warning("No artwork found. Setting default image.")
                                        presence.assets.largeImage = "applemusic_large"
                                        self.artwork.url = nil
                                    }
                                    self.rpc.setPresence(presence)
                                } else {
                                    self.logger.warning("Could not parse iTunes response. Setting default image.")
                                    presence.assets.largeImage = "applemusic_large"
                                    self.artwork.url = nil
                                    self.rpc.setPresence(presence)
                                }
                            } else {
                                self.logger.warning("No artwork found. Setting default image.")
                                presence.assets.largeImage = "applemusic_large"
                                self.artwork.url = nil
                                self.rpc.setPresence(presence)
                            }
                        }
                    )
                    .resume()
                } else {
                    self.logger.warning("Can't form iTunes search URL. Setting default image.")
                    presence.assets.largeImage = "applemusic_large"
                    self.artwork.url = nil
                    self.rpc.setPresence(presence)
                }
            } else {
                presence.assets.largeImage = "applemusic_large"
                self.artwork.url = nil
                self.rpc.setPresence(presence)
            }
        }
    }
    
    func manuallyUpdateRPCData () {
        let currentAMTrack: MusicTrack? = self.AMApp?.currentTrack
        self.rpcData.name = currentAMTrack?.name
        self.rpcData.artist = currentAMTrack?.artist
        self.rpcData.album = currentAMTrack?.album

        switch self.AMApp?.playerState {
        case .playing?,
             .fastForwarding?,
             .rewinding?:
            self.rpcData.state = .playing
        case .paused?:
            self.rpcData.state = .paused
        case .stopped?:
            self.rpcData.state = .stopped
        default:
            self.rpcData.state = .stopped
        }

        self.rpcData.totalTime = currentAMTrack?.finish
    }
    
    func listenAMNotifications() {
        self.ncObserver = nc.addObserver(
            forName: NSNotification.Name("com.apple.Music.playerInfo"),
            object: nil,
            queue: nil
        ) { notification in
            self.logger.log("Received Apple Music notification: \(notification, privacy: .public)")
            self.rpcData.name = notification.userInfo?[AnyHashable("Name")] as? String
            self.rpcData.artist = notification.userInfo?[AnyHashable("Artist")] as? String
            self.rpcData.album = notification.userInfo?[AnyHashable("Album")] as? String
            self.rpcData.state = AMPlayerStates(rawValue: (notification.userInfo?[AnyHashable("Player State")] as? String)?.lowercased() ?? "stopped") ?? .stopped
            self.rpcData.totalTime = self.AMApp?.currentTrack?.finish
            self.setRPC()
        }
        self.logger.log("Listening for Apple Music notifications.")
    }
    
    func unsubAMNotifications() {
        nc.removeObserver(
            self.ncObserver,
            name: NSNotification.Name("com.apple.Music.playerInfo"),
            object: nil
        )
    }
    
    func newSwordRPC() {
        self.rpc = SwordRPC(appId: "785053859915366401")
        self.rpc.onConnect { _ in
            DispatchQueue.main.async {
                self.isDiscordConnected = true
                // Manually get the player states at first start before notifications init.
                self.manuallyUpdateRPCData()
                self.setRPC()
                self.listenAMNotifications()
                self.isChangingConnectionStatus = false
            }
            self.logger.log("Connected to Discord RPC.")
        }
        self.rpc.onDisconnect { _,_,_ in
            DispatchQueue.main.async {
                self.unsubAMNotifications()
                self.isDiscordConnected = false
                self.isChangingConnectionStatus = false
            }
            self.logger.log("Disconnected from Discord RPC.")
        }
    }
    
    func connectToDiscord() {
        if !isDiscordConnected {
            self.isChangingConnectionStatus = true
            self.newSwordRPC()
            self.isDiscordConnected = self.rpc.connect()
        }
    }
    
    func disconnectFromDiscord() {
        if isDiscordConnected {
            self.isChangingConnectionStatus = true
            self.rpc.disconnect()
        }
    }
    
    init() {
        self.logger.log("Initialize.")
        self.newSwordRPC()
        self.isDiscordConnected = self.rpc.connect()
    }
}
