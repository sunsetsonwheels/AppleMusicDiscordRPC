__author__ = 'jkelol111'
__copyright__ = 'Copyright (C) 2020-present jkelol111.'
__license__ = 'GNU General Public License Version 3'
__version__ = '1.0.0'

import pypresence
import applescript
import time
import colorama

colorama.init(autoreset=True)

print(f"{colorama.Style.BRIGHT}{colorama.Fore.GREEN}AppleMusicPresence v{__version__}. {__copyright__}")
print(f"{colorama.Fore.YELLOW}Licenced to you under the {__license__}.")
print("")

config = {
    "track": "Not playing anything",
    "artist": "Idling",
    "state": "stopped",
    "version": applescript.tell.app("Music", "version as string").out
}

print("Starting the Rich Presence RPC...")
RPC = pypresence.Presence("785053859915366401")
RPC.connect()

def quit_rpc():
    RPC.clear()
    RPC.close()
    exit()

try:
    while True:
        new_config = {
            "track": applescript.tell.app("Music", "name of current track as string").out,
            "artist": applescript.tell.app("Music", "artist of current track as string").out,
            "state": applescript.tell.app("Music", "player state as string").out,
            "version": applescript.tell.app("Music", "version as string").out
        }

        try:
            if new_config != config:
                if new_config["state"] == "stopped":
                    new_config["track"] = "Not playing anything"
                    new_config["artist"] = "Idling"
                print(f"{colorama.Fore.YELLOW}{config['track']}, {config['artist']}, {config['state'].capitalize()}{colorama.Style.RESET_ALL} --> {colorama.Fore.GREEN}{new_config['track']}, {new_config['artist']}, {new_config['state'].capitalize()}")
                RPC.update(details=new_config["track"],
                            state=new_config["artist"],
                            small_image=new_config["state"],
                            small_text=new_config["state"].capitalize(),
                            large_image="applemusic_large",
                            large_text="Apple Music " + new_config["version"])
                config = new_config
        except Exception as e:
            print(f"{colorama.Fore.RED}Failed update Rich Presence! Exception:")
            print(str(e))
            print(f"{colorama.Fore.RED}Couldn't continue, quitting!")
            quit_rpc()
        time.sleep(15)
except KeyboardInterrupt:
    print(f"\n{colorama.Fore.YELLOW}Keyboard interrupt caught, exiting...")
    quit_rpc()