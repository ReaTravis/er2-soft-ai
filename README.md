# Soft Brain AI (Mac) 

Slightly less smooth-brain infantry for [Easy Red 2](https://store.steampowered.com/app/1229080/Easy_Red_2/) on Mac.

Stock AI is....smooth brained — guys standing around, MGs running around, nobody bounding. Soft Brain is WW2-ish fire and movement Based off of WW2 Infantry fighting manuals: set a base of fire, hop under cover, throw smoke/frags when it makes sense, and actually push when you're on top of the objective.

Squads attacking the same objective will team up.  One or more will setup a base of fire, others will flank and attack. (sometimes)

Not a full second brain. Not a genius. Just a couple of wrinkles... not smooth brain.

Mac only for now (Steam / Mono). I have a PC sitting here I should probably get it setup for my windows friends... Prebuilt DLLs — no compile step.

## You need

- Easy Red 2 on Steam
- BepInEx already working (`run_bepinex.sh` in the game folder — if you don't have that, set Doorstop up first)
- [.NET 8 runtime](https://dotnet.microsoft.com/download/dotnet/8.0) once, just so the install script can patch the game. You don't need it to play.

## Tweaks and Changes
- Base of fire + maneuver split (MG/supports plant and suppress)
- Short bounds under covering fire
- Squads on the same objective team up (sometimes base + flank)
- Contact-first — less random flanking with no eyes-on
- Assault endgame: close → grenades → CQB
- Smoke when suppressed / no fire superiority
- Frags near the objective
- Melee/bayonet in knife range
- Aim settle + suppression affecting accuracy
- Better close-range awareness
- Hot-reload knobs in `uiandai.cfg` (Soft on/off, aggression, etc.)

## Install

Quit Easy Red 2 completely.

```bash
git clone https://github.com/ReaTravis/er2-soft-ai.git
cd er2-soft-ai
./install.sh
```

If your game isn't in the usual Steam spot:

```bash
export ER2_GAME_PATH="/wherever/Easy Red 2"
./install.sh
```

Then launch bepinex

```bash
cd "$HOME/Library/Application Support/Steam/steamapps/common/Easy Red 2"
./run_bepinex.sh
```

Config and logs end up here:

```text
~/ER2SoftAI/uiandai.cfg
~/ER2SoftAI/plugin.log
```

Steam updated the game and Soft Brain died? Close it, run `./install.sh` again. That's normal — the inject gets wiped.

## Is it on?

Review `~/ER2SoftAI/plugin.log`. You want something like:

```text
INJECT alive … Soft=ON AimMods=ON
SOFT #n [SoftON] …
```

To flip Soft without reinstalling, edit `~/ER2SoftAI/uiandai.cfg`:

```ini
SoftActuators=true    # Soft feet / squad / plant / smoke
SoftActuators=false   # stock movement again (full smooth-brain mode)

SoftAimMods=true      # Soft aim settle + suppress
SoftAimMods=false     # stock aim
```

If `HotReloadConfig=true` (default), save the file mid-match and it picks up most knobs without restarting.

## What it tries to do

Roughly the Infantry manual stuff that wins fights:

- MG + a couple supports dig in as base of fire
- Everyone else bounds — short rushes, not a parade across open ground
- Don't freestyle flank with no contact
- Close on the objective, grenades, then knife distance
- Smoke when you're getting chewed up; frags when you're stacked

It will still do dumb things sometimes. Soft Brain, not overlord.

## Knobs

Defaults are on the aggressive side. Config is just a text file — mess with it.

Cooler:

```ini
FireSuperioritySuppressMax=0.38
BoundRestSeconds=7.0
SoftMeleeMixChance=0.45
```

Hotter:

```ini
AssaultCloseMeters=65
AssaultOverwhelmSpeed=1.2
SoftMeleeMixChance=0.7
```

There's a lot more in `uiandai.cfg`. Names are mostly self-explanatory. If something feels broken, turn Soft off (`SoftActuators=false`) and see if stock behaves — that tells you it's us.

## What's in the box

```text
mods/          the three DLLs
tools/         patchers for arm64 + Intel (install script picks the right one)
uiandai.cfg    defaults
install.sh     copies DLLs + hooks the game
```





Not affiliated with Easy Red 2. Game updates will break the inject — reinstall. Use at your own risk, etc.

MIT — see [LICENSE](LICENSE).
