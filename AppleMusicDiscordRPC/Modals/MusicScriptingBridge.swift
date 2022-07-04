// Generated from SwiftScripting Python scripts &
// Simplified for the scope of this app.
// https://github.com/tingraldi/SwiftScripting

import ScriptingBridge

@objc public protocol SBObjectProtocol: NSObjectProtocol {
    func get() -> Any!
}

@objc public protocol SBApplicationProtocol: SBObjectProtocol {
    func activate()
    var delegate: SBApplicationDelegate! { get set }
    var isRunning: Bool { get }
}

// MARK: MusicEPlS
@objc public enum MusicEPlS : AEKeyword {
    case stopped = 0x6b505353 /* 'kPSS' */
    case playing = 0x6b505350 /* 'kPSP' */
    case paused = 0x6b505370 /* 'kPSp' */
    case fastForwarding = 0x6b505346 /* 'kPSF' */
    case rewinding = 0x6b505352 /* 'kPSR' */
}

// MARK: MusicItem
@objc public protocol MusicItem: SBObjectProtocol {
    @objc optional var name: String { get } // the name of the item
}
extension SBObject: MusicItem {}

// MARK: MusicTrack
@objc public protocol MusicTrack: MusicItem {
    @objc optional var album: String { get } // the album name of the track
    @objc optional var artist: String { get } // the artist/source of the track
    @objc optional var finish: Double { get } // the stop time of the track in seconds
}
extension SBObject: MusicTrack {}

// MARK: MusicApplication
@objc public protocol MusicApplication: SBApplicationProtocol {
    @objc optional var currentTrack: MusicTrack { get } // the current targeted track
    @objc optional var playerState: MusicEPlS { get } // is the player stopped, paused, or playing?
    @objc optional var playerPosition: Double { get } // the player’s position within the currently playing track in seconds.
}
extension SBApplication: MusicApplication {}
