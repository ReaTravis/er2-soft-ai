#!/usr/bin/env bash
# Install Soft Brain AI into Steam Easy Red 2 (macOS).
# Close Easy Red 2 before running (Assembly-CSharp is rewritten).
set -euo pipefail

ROOT="$(cd "$(dirname "$0")" && pwd)"
GAME="${ER2_GAME_PATH:-${HOME}/Library/Application Support/Steam/steamapps/common/Easy Red 2}"
MOD_HOME="${ER2_MOD_HOME:-${HOME}/ER2SoftAI}"
CORE="${GAME}/BepInEx/core"
MODS="${GAME}/Mods"
MANAGED="${GAME}/EasyRed2_OSX.app/Contents/Resources/Data/Managed"
export ER2_GAME_PATH="$GAME"
export ER2_MOD_HOME="$MOD_HOME"

ARCH="$(uname -m)"
case "$ARCH" in
  arm64) TOOLS="${ROOT}/tools/osx-arm64" ;;
  x86_64) TOOLS="${ROOT}/tools/osx-x64" ;;
  *)
    echo "Unsupported Mac arch: $ARCH" >&2
    exit 1
    ;;
esac

die() { echo "ERROR: $*" >&2; exit 1; }

[[ -d "$GAME" ]] || die "Game not found: $GAME
Set ER2_GAME_PATH if Steam is elsewhere."
[[ -d "$CORE" ]] || die "BepInEx not found at $CORE
Install Doorstop/BepInEx for Easy Red 2 first."
[[ -f "${MANAGED}/Assembly-CSharp.dll" ]] || die "Missing Assembly-CSharp at $MANAGED"
[[ -x "${TOOLS}/PatchGame" ]] || die "Missing ${TOOLS}/PatchGame"
[[ -x "${TOOLS}/PatchPreloader" ]] || die "Missing ${TOOLS}/PatchPreloader"

# Patch tools are framework-dependent — need .NET 8 runtime (not full SDK)
export PATH="${HOME}/.dotnet:${HOME}/.dotnet/tools:${PATH:-}"
export DOTNET_ROOT="${DOTNET_ROOT:-${HOME}/.dotnet}"
if ! command -v dotnet >/dev/null 2>&1; then
  die "dotnet not found. Install the .NET 8 runtime (one-time, for install/patch only):
  https://dotnet.microsoft.com/download/dotnet/8.0
Then re-run ./install.sh"
fi

mkdir -p "$MODS" "$CORE" "${MOD_HOME}/backups"

echo "== Copy mod DLLs =="
cp -f "${ROOT}/mods/ER2.UIAndAI.dll" "${MODS}/"
cp -f "${ROOT}/mods/Er2.Doctrine.dll" "${MODS}/"
cp -f "${ROOT}/mods/ER2.ModLoader.dll" "${MODS}/"
cp -f "${ROOT}/mods/ER2.UIAndAI.dll" "${MANAGED}/"
cp -f "${ROOT}/mods/Er2.Doctrine.dll" "${MANAGED}/"
cp -f "${ROOT}/mods/ER2.ModLoader.dll" "${CORE}/"

# Backup pristine BepInEx.Preloader once
REAL_PRE="${MOD_HOME}/backups/BepInEx.Preloader.dll.real"
if [[ ! -f "$REAL_PRE" && -f "${CORE}/BepInEx.Preloader.dll" ]]; then
  cp "${CORE}/BepInEx.Preloader.dll" "$REAL_PRE"
  echo "Backed up BepInEx.Preloader -> $REAL_PRE"
fi

echo "== Patch BepInEx.Preloader =="
if [[ -f "$REAL_PRE" ]]; then
  cp -f "$REAL_PRE" "${CORE}/BepInEx.Preloader.dll"
fi
"${TOOLS}/PatchPreloader" "${CORE}/BepInEx.Preloader.dll"
cp -f "${CORE}/BepInEx.Preloader.dll.patched" "${CORE}/BepInEx.Preloader.dll"
cp -f "${MODS}/ER2.ModLoader.dll" "${CORE}/ER2.ModLoader.dll"

echo "== IL-inject Assembly-CSharp hooks =="
"${TOOLS}/PatchGame"

# Default config if missing
CFG="${MOD_HOME}/uiandai.cfg"
if [[ ! -f "$CFG" ]]; then
  cp "${ROOT}/uiandai.cfg" "$CFG"
  echo "Wrote default config: $CFG"
else
  echo "Keeping existing config: $CFG"
fi

echo
echo "Installed Soft Brain AI."
echo "  Launch:  cd $(printf %q "$GAME") && ./run_bepinex.sh"
echo "  Config:  $CFG"
echo "  Log:     ${MOD_HOME}/plugin.log"
echo
echo "After a Steam game update, re-run ./install.sh (close the game first)."
