import applescript
import json
import os
import pathlib
import time

CONFIG_FILE = os.path.join(pathlib.Path(__file__).parent, "cdrpcfg.json")
config = {}

with open(CONFIG_FILE, "r") as config_file:
    config = json.load(config_file)

while True:
    track = applescript.tell.app("Music", "name of current track as string").out
    artist = applescript.tell.app("Music", "artist of current track as string").out
    state = applescript.tell.app("Music", "player state as string").out
    version = applescript.tell.app("Music", "version as string").out

    if state == "paused":
        config["images"]["small"]["name"] = "paused"
        config["images"]["small"]["tooltip"] = "Paused"
    elif state == "playing":
        config["images"]["small"]["name"] = "playing"
        config["images"]["small"]["tooltip"] = "Playing"
    else:
        track = "Not playing anything"
        artist = "Idling"
        config["images"]["small"]["name"] = "stopped"
        config["images"]["small"]["tooltip"] = "Stopped"

    config["state"]["details"] = track
    config["state"]["state"] = artist
    config["images"]["large"]["tooltip"] = "Apple Music " + version

    with open(CONFIG_FILE, "r") as config_file:
        if config != json.load(config_file):
            with open(CONFIG_FILE, "w") as config_file:
                json.dump(config, config_file)

    time.sleep(10)