# AppleMusicDiscordPresence
Discord Rich Presence for Apple Music on macOS, based on CustomDiscordPresence.

Only works on macOS for now, preferrably with Music 1.1.4.94 (shipped with macOS 11.3 Beta 2 and above).

## Instructions to run

1. Clone this repository somewhere.
2. Download Python 3 from python.org or from Homebrew.
3. Download Pipenv
4. `cd` to the directory where you cloned this project.
5. `pipenv install`
6. `pipenv run python3 applemusicrp.py`

## Instructions to build

You have to complete '[Instructions to run](#instructions-to-run)' before continuing!

1. `pipenv install -d`
3. `pyinstaller applemusicrp.spec`
3. The application will be built to `dist/`. Run it from there or distribute to others.

Icons by Flaticons.