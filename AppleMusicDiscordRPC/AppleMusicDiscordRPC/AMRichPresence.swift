import AppKit
import ScriptingBridge
import SwordRPC
import os

// MARK: iTunes Scripting Bridge

@objc fileprivate protocol iTunesTrack {
    @objc optional var name: String { get }
    @objc optional var artist: String { get }
}

extension SBObject: iTunesTrack {}

@objc fileprivate enum iTunesEPlS: NSInteger {
    case iTunesEPlSStopped = 0x6b505353
    case iTunesEPlSPlaying = 0x6b505350
    case iTunesEPlSPaused = 0x6b505370
    case iTunesEPlSFastForwarding = 0x6b505346
    case iTunesEPlSRewinding = 0x6b505352
}

@objc fileprivate protocol iTunesApplication {
    @objc optional var currentTrack: iTunesTrack { get }
    @objc optional var playerState: iTunesEPlS { get }
    @objc optional var version: String { get }
}

extension SBApplication: iTunesApplication {}

// MARK: Apple Music RPC

enum AMPlayerStates: String {
    case playing = "playing"
    case paused = "paused"
    case stopped = "stopped"
}

struct AMRPCData {
    var track: String
    var artist: String
    var state: AMPlayerStates
}

class AMRPCObservable: ObservableObject {
    @Published var rpcData: AMRPCData = AMRPCData(
        track: "Not playing anything.",
        artist: "Not playing anything.",
        state: .stopped
    )
    @Published var isDiscordConnected: Bool = false
    @Published var isChangingConnectionStatus: Bool = true
    
    private let nc: DistributedNotificationCenter = DistributedNotificationCenter.default()
    private var ncObserver: NSObjectProtocol = NSObject()
    private let AMApp: iTunesApplication? = SBApplication(bundleIdentifier: "com.apple.Music")
    private var AMAppVersion: String = ""
    
    private var rpc: SwordRPC = SwordRPC(appId: "785053859915366401")

    private let logger: Logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "AMRPCObservable")
    
    func setRPC() {
        if isDiscordConnected {
            var presence = RichPresence()
            presence.details = self.rpcData.track
            presence.state = self.rpcData.artist
            presence.assets.largeText = "Apple Music \(self.AMAppVersion)"
            presence.assets.largeImage = "applemusic_large"
            presence.assets.smallText = self.rpcData.state.rawValue.capitalized
            presence.assets.smallImage = self.rpcData.state.rawValue
            self.rpc.setPresence(presence)
        }
    }
    
    func manuallyUpdateRPCData () {
        let currentAMTrack: iTunesTrack? = self.AMApp?.currentTrack
        self.rpcData.track = currentAMTrack?.name ?? "Not playing anything."
        self.rpcData.artist = currentAMTrack?.artist ?? "Not playing anything."

        switch self.AMApp?.playerState {
        case .iTunesEPlSPlaying?,
             .iTunesEPlSFastForwarding?,
             .iTunesEPlSRewinding?:
            self.rpcData.state = .playing
        case .iTunesEPlSPaused?:
            self.rpcData.state = .paused
        case .iTunesEPlSStopped?:
            self.rpcData.state = .stopped
        default:
            self.rpcData.state = .stopped
        }
        
        self.AMAppVersion = self.AMApp?.version ?? ""
    }
    
    func listenAMNotifications() {
        self.ncObserver = nc.addObserver(
            forName: NSNotification.Name("com.apple.Music.playerInfo"),
            object: nil,
            queue: nil
        ) { notification in
            self.logger.log("Received Apple Music notification: \(notification, privacy: .public)")
            self.rpcData.track = String(describing: notification.userInfo?[AnyHashable("Name")] ?? "Not playing anything.")
            self.rpcData.artist = String(describing: notification.userInfo?[AnyHashable("Artist")] ?? "Not playing anything.")
            self.rpcData.state = AMPlayerStates(rawValue: String(describing: notification.userInfo?[AnyHashable("Player State")] ?? "stopped").lowercased())!
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
