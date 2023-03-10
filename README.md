![Apple Music Discord RPC icon](/icon-resized.png)

# Apple Music Discord RPC
Discord Rich Presence for Apple Music on macOS.

- *No AppleScript polling!*
- *100% SwiftUI!*

## Requirements
To run this app, you will need:
- macOS Ventura 13.0 and above.

To build this app, you will need:
- Xcode 14.1 and above.

## Installation
1. Download the [latest release](https://github.com/jkelol111/AppleMusicDiscordRPC/releases/latest). (`AppleMusicDiscordRPC-x.y.z-b.zip`, not the source code)
2. Decompress the ZIP archive.
3. Copy `Apple Music Discord RPC.app` to `/Applications`

## Usage
1. Have Discord and Music.app open.
2. Launch `Apple Music Discord RPC.app`

## Known issues
- Album art may not match the one in Music.app
  - **Causes**: This is because we're searching the track using the iTunes API and picking the first result.
  - **Resolution**: None yet. If there's a way to take the artwork directly from Music.app and set it for Discord, let me know.
- Skipping/changing tracks too often leads to RPC not being updated temporarily.
  - **Causes**: Discord rate-limits RPC updates, so does iTunes' API.
  - **Resolution**: Try pausing the track, waiting a second, then playing again.

## Build instructions
1. Go to Apple Music Discord RPC.xcodeproj ->  Apple Music Discord RPC target -> Signing and Capabilities and configure it to your desired account.
2. Click the Play button and pray.
3. ???
4. If it works, horray!

## Credits
Icons by Flaticons. They can be found in this project @ `discord-icons`.

App icon created using Canva.

SwordRPC originally by @Azoy. Addtional functionality added by @PKBeam.

Music.app ScriptingBridge code generated using @tingraldi's SwiftScripting, which I forked.

## Notice of Non-Affiliation and Disclaimer
We are not affiliated, associated, authorized, endorsed by, or in any way officially connected with Apple, Discord, or any of its subsidiaries or its affiliates.

The names Apple Music and Discord as well as related names, marks, emblems and images are registered trademarks of their respective owners.

## Generating `appcast.xml` (ignore unless you're me?)
1. Look for Sparkle in the Xcode sidebar, right click it and choose 'Show in Finder'
2. In the Finder window, navigate to `../artifacts/sparkle/bin`
3. Open a terminal in above directory and run `./generate_appcast /path/to/folder/with/built/zips`
4. Fix the path of the new update to the GitHub Release.
5. Copy the new `appcast.xml` to the repository root.
6. Push the changes to `main` for publishing.

Once you already have that new `appcast.xml` in step 3, keep it in the same directory for future use.
