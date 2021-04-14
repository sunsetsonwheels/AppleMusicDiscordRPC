__author__ = 'jkelol111'
__copyright__ = 'Copyright (C) 2021-present jkelol111.'
__license__ = 'GNU General Public License Version 3'
__version__ = '1.1.0'

import pypresence
import applescript
import time
import colorama
import enum
import dataclasses
import traceback

@enum.unique
class iTunesPlaybackState(str, enum.Enum):
    playing: str = "playing"
    paused: str = "paused"
    stopped: str = "stopped"

@dataclasses.dataclass
class iTunesPlaybackInformation:
    track: str = "Loading track"
    artist: str = "Loading artist"
    state: iTunesPlaybackState = iTunesPlaybackState["stopped"]
    version: str = "Loading version"

colorama.init(autoreset=True)

print(f"{colorama.Style.BRIGHT}{colorama.Fore.GREEN}AppleMusicDiscordPresence v{__version__}. {__copyright__}")
print(f"{colorama.Fore.YELLOW}Licenced to you under the {__license__}.")
print("")

print("Connecting to Discord...")
RPC = pypresence.Presence("785053859915366401")
RPC.connect()
print(f"{colorama.Fore.GREEN}Connected successfully to Discord!\n")

def quit_rpc():
    RPC.clear()
    RPC.close()
    exit()

try:
    start_config = iTunesPlaybackInformation()

    while True:
        new_config = iTunesPlaybackInformation(track=applescript.tell.app("Music", "name of current track as string").out,
                                                artist=applescript.tell.app("Music", "artist of current track as string").out,
                                                state=iTunesPlaybackState[applescript.tell.app("Music", "player state as string").out],
                                                version=applescript.tell.app("Music", "version as string").out)

        if new_config.state is iTunesPlaybackState.stopped:
            new_config.track = "Not playing anything"
            new_config.artist = "Idling"
        elif new_config.state in [iTunesPlaybackState.playing, iTunesPlaybackState.paused]:
            if new_config.track == "":
                new_config.track = "Couldn't get track"
            if new_config.artist == "":
                new_config.artist = "Couldn't get artist"
        else:
            new_config.track = "Unknown player state"
            new_config.artist = "Unknown player state"
            new_config.state = iTunesPlaybackState("stopped")

        try:
            if new_config != start_config:
                print(f"{colorama.Fore.YELLOW}{start_config.track}, {start_config.artist}, {start_config.state.value.capitalize()}{colorama.Style.RESET_ALL} --> {colorama.Fore.GREEN}{new_config.track}, {new_config.artist}, {new_config.state.value.capitalize()}")
                RPC.update(details=new_config.track,
                            state=new_config.artist,
                            small_image=new_config.state.value,
                            small_text=new_config.state.value.capitalize(),
                            large_image="applemusic_large",
                            large_text="Apple Music " + new_config.version)
                start_config = new_config
        except:
            print(f"{colorama.Fore.RED}Failed to update Rich Presence! Exception:")
            traceback.print_exc()
            print(f"{colorama.Fore.RED}Couldn't continue, quitting!")
            quit_rpc()
        time.sleep(15)
except KeyboardInterrupt:
    print(f"\n{colorama.Fore.YELLOW}Keyboard interrupt caught, exiting...")
    quit_rpc()