// Generated from SwiftScripting Python scripts &
// Simplified for the scope of this app.
// https://github.com/tingraldi/SwiftScripting

import ScriptingBridge
import SwiftUI

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
    @objc optional func id() -> Int // the id of the item
    @objc optional var name: String { get } // the name of the item
    @objc optional var persistentID: String { get } // the id of the item as a hexadecimal string. This id does not change over time.
}
extension SBObject: MusicItem {}

// MARK: MusicArtwork
@objc public protocol MusicArtwork: MusicItem {
    @objc optional var data: NSImage { get } // data for this artwork, in the form of a picture
    @objc optional var objectDescription: String { get } // description of artwork as a string
    @objc optional var kind: Int { get } // kind or purpose of this piece of artwork
    @objc optional var rawData: Data { get } // data for this artwork, in original format
}
extension SBObject: MusicArtwork {}

// MARK: MusicTrack
@objc public protocol MusicTrack: MusicItem {
    @objc optional var album: String { get } // the album name of the track
    @objc optional var artist: String { get } // the artist/source of the track
    @objc optional var finish: Double { get } // the stop time of the track in seconds
    @objc optional func artworks() -> Array<MusicArtwork>
}
extension SBObject: MusicTrack {}

// MARK: MusicApplication
@objc public protocol MusicApplication: SBApplicationProtocol {
    @objc optional var currentTrack: MusicTrack { get } // the current targeted track
    @objc optional var playerState: MusicEPlS { get } // is the player stopped, paused, or playing?
    @objc optional var playerPosition: Double { get } // the player’s position within the currently playing track in seconds.
}
extension SBApplication: MusicApplication {}
