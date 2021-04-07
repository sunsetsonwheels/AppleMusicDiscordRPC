package main

import (
	"fmt"
	"strings"
	"time"

	"github.com/andybrewer/mack"
	"github.com/fatih/color"
	"github.com/hugolgst/rich-go/client"
)

type AppleMusicPlaybackData struct {
	track, artist, state, version string
}

const scriptVersion = "2.0.0"

func main() {
	startAMPlaybackData := AppleMusicPlaybackData{
		track:   "Loading track",
		artist:  "Loading artist",
		state:   "stopped",
		version: "Loading AM version",
	}

	color.Green("AppleMusicDiscordPresence v." + scriptVersion + " (C) 2021-present jkelol111 et al.")
	color.Yellow("Licenced to you under the GNU General Public License Version 3.\n\n")

	fmt.Println("Connecting to Discord...")
	loginErr := client.Login("785053859915366401")
	if loginErr != nil {
		color.Red("Unable to connect to Discord, exiting.")
		panic(loginErr)
	}
	color.Green("Connected successfully to Discord!\n\n")

	for {
		newAMPlaybackData := AppleMusicPlaybackData{}

		newTrack, newTrackErr := mack.Tell("Music", "name of current track as string")
		if newTrackErr != nil {
			panic(newTrackErr)
		}
		newAMPlaybackData.track = newTrack

		newArtist, newArtistErr := mack.Tell("Music", "artist of current track as string")
		if newArtistErr != nil {
			panic(newTrackErr)
		}
		newAMPlaybackData.artist = newArtist

		newState, newStateErr := mack.Tell("Music", "player state as string")
		if newStateErr != nil {
			panic(newTrackErr)
		}
		newAMPlaybackData.state = newState

		newVersion, newVersionErr := mack.Tell("Music", "version as string")
		if newVersionErr != nil {
			panic(newVersionErr)
		}
		newAMPlaybackData.version = newVersion

		if startAMPlaybackData != newAMPlaybackData {
			fmt.Println(color.YellowString(startAMPlaybackData.track+", "+startAMPlaybackData.artist+", "+strings.Title(startAMPlaybackData.state)), "-->", color.GreenString(newAMPlaybackData.track+", "+newAMPlaybackData.artist+", "+strings.Title(newAMPlaybackData.state)))
			setActivityErr := client.SetActivity(client.Activity{
				Details:    newAMPlaybackData.track,
				State:      newAMPlaybackData.artist,
				SmallImage: newAMPlaybackData.state,
				SmallText:  strings.Title(newAMPlaybackData.state),
				LargeImage: "applemusic_large",
				LargeText:  "Apple Music " + newAMPlaybackData.version,
			})
			if setActivityErr != nil {
				panic(setActivityErr)
			}
			startAMPlaybackData = newAMPlaybackData
		}

		time.Sleep(15 * time.Second)
	}
}
