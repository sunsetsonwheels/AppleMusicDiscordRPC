import AppKit
import ScriptingBridge
import SwordRPC
import os

enum AMPlayerStates: String {
    case playing = "playing"
    case paused = "paused"
    case stopped = "stopped"
}

struct DiscordRPCData {
    var track: String?
    var artist: String?
    var album: String?
    var startTime: Double?
    var totalTime: Double?
    var state: AMPlayerStates
}

class DiscordRPCObservable: ObservableObject {
    @Published var rpcData: DiscordRPCData = DiscordRPCData(state: .stopped)
    @Published var isDiscordConnected: Bool = false
    @Published var isChangingConnectionStatus: Bool = true
    public var notPlayingText: String = "Not playing anything."
    public var unknownAlbumText: String = "Unknown album"
    
    private let nc: DistributedNotificationCenter = DistributedNotificationCenter.default()
    private var ncObserver: NSObjectProtocol = NSObject()
    private let AMApp: MusicApplication? = SBApplication(bundleIdentifier: "com.apple.Music")
    private var AMAppVersion: String?
    
    private var rpc: SwordRPC = SwordRPC(appId: "785053859915366401")

    private let logger: Logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "AMRPCObservable")
    
    func setRPC() {
        if isDiscordConnected {
            var presence: RichPresence = RichPresence()

            var currentTrack: String = self.rpcData.track ?? self.notPlayingText
            if currentTrack.isEmpty {
                currentTrack = self.notPlayingText
            }
            presence.details = currentTrack

            var currentArtist: String = self.rpcData.artist ?? self.notPlayingText
            if currentArtist.isEmpty {
                currentArtist = self.notPlayingText
            }
            presence.state = currentArtist

            presence.assets.smallText = self.rpcData.state.rawValue.capitalized
            presence.assets.smallImage = self.rpcData.state.rawValue
            if self.rpcData.state == .playing &&
                self.rpcData.startTime != nil &&
                self.rpcData.totalTime != nil
            {
                let currentTime: Date = Date()
                presence.timestamps.start = currentTime
                presence.timestamps.end = currentTime + (self.rpcData.totalTime! - self.rpcData.startTime!)
            }
            
            presence.assets.largeText = "\(self.rpcData.album ?? self.unknownAlbumText), Apple Music \(self.AMAppVersion ?? "")"
            presence.assets.largeImage = "applemusic_large"

            self.rpc.setPresence(presence)
        }
    }
    
    func manuallyUpdateRPCData () {
        let currentAMTrack: MusicTrack? = self.AMApp?.currentTrack
        self.rpcData.track = currentAMTrack?.name
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
        
        self.rpcData.startTime = self.AMApp?.playerPosition
        self.rpcData.totalTime = currentAMTrack?.finish
        
        self.AMAppVersion = self.AMApp?.version
    }
    
    func listenAMNotifications() {
        self.ncObserver = nc.addObserver(
            forName: NSNotification.Name("com.apple.Music.playerInfo"),
            object: nil,
            queue: nil
        ) { notification in
            self.logger.log("Received Apple Music notification: \(notification, privacy: .public)")
            self.rpcData.track = notification.userInfo?[AnyHashable("Name")] as? String
            self.rpcData.artist = notification.userInfo?[AnyHashable("Artist")] as? String
            self.rpcData.album = notification.userInfo?[AnyHashable("Album")] as? String
            self.rpcData.state = AMPlayerStates(rawValue: (notification.userInfo?[AnyHashable("Player State")] as? String)?.lowercased() ?? "stopped") ?? .stopped
            self.rpcData.startTime = self.AMApp?.playerPosition
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
