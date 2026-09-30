<div align="center">

# Open CoD:UO-AppImage 🐧

[![GitHub Downloads](https://img.shields.io/github/downloads/pkgforge-dev/opencoduo-AppImage/total?logo=github&label=GitHub%20Downloads)](https://github.com/pkgforge-dev/opencoduo-AppImage/releases/latest)
[![CI Build Status](https://img.shields.io/github/pkgforge-dev/opencoduo-AppImage/actions/workflows/appimage.yml/badge.svg)](https://github.com/pkgforge-dev/opencoduo-AppImage/actions/workflows/appimage.yml)
[![Latest Stable Release](https://img.shields.io/github/v/release/pkgforge-dev/opencoduo-AppImage)](https://github.com/pkgforge-dev/opencoduo-AppImage/releases/latest)

<p align="center">
  <img src="./AppDir/opencoduo.png" width="128" />
</p>

| Latest Stable Release | Upstream URL |
| :---: | :---: |
| [Click here](https://github.com/pkgforge-dev/opencoduo-AppImage/releases/latest) | [Click here](https://github.com/opencoduo/coduomp) |

</div>

---

Unofficial AppImage of [Open CoD:UO](https://github.com/opencoduo/coduomp), reconstructed source for the <em>Call of Duty: United Offensive</em> multiplayer client and dedicated server. Client is launched by default. Rename the binary or make a symlink named `opencoduo-server` to launch the dedicated server.

The icon is upstream's own `assets/coduomp-icon-master.png`, resized to 512x512.

AppImage made using [quick-sharun](https://github.com/pkgforge-dev/Anylinux-AppImages/blob/main/useful-tools/quick-sharun.sh), which makes it extremely easy to turn any binary into a portable package reliably without using containers or similar tricks.

**This AppImage bundles everything and it should work on any Linux distro, including old and musl-based ones.**

This AppImage doesn't require FUSE to run at all, thanks to the [uruntime](https://github.com/VHSgunzo/uruntime).

This AppImage is also supplied with a self-updater by default, so any updates to this application won't be missed, you will be prompted for permission to check for updates and if agreed you will then be notified when a new update is available.

Self-updater is disabled by default if AppImage managers like [am](https://github.com/ivan-hc/AM), [soar](https://github.com/pkgforge/soar) or [dbin](https://github.com/xplshn/dbin) exist, which manage AppImage updates.

## Running the client

The client is the default, so it starts with no arguments:

```sh
./Open_CoD_UO-x86_64.AppImage
```

## Running the dedicated server

The server is selected by the name the AppImage is invoked as, the same way the [Kate](https://github.com/pkgforge-dev/Kate-AppImage-Enhanced) AppImage ships both `kate` and `kwrite`. Make a symlink named `opencoduo-server` pointing at the AppImage and run that instead:

```sh
ln -s Open_CoD_UO-x86_64.AppImage opencoduo-server
./opencoduo-server +set dedicated 2 +exec server.cfg
```

The dedicated server entry is also bundled, at `share/applications/opencoduo-server.desktop` inside the AppDir, together with its icon in `share/icons/hicolor/512x512/apps/`. Extract the AppDir if you want to install it into your menu; it expects an `opencoduo-server` symlink to exist.

## Retail game data is required

This AppImage contains the engine binaries and their modules only. **Call of Duty: United Offensive must already be installed**, because both binaries read your existing game data in place and do not copy it.

On launch both binaries look for a retail root containing both `main/pak0.pk3` and `uo/pakuo00.pk3`:

1. the `CODUOMP_DATA_PATH` environment variable, if set;
2. the working directory, so running the AppImage from the game directory works;
3. a previously saved path;
4. Steam app **2640**, across all configured Steam libraries.

If you pass `+set fs_cdpath` yourself, that is used as-is.

If nothing is found, set the path explicitly:

```sh
CODUOMP_DATA_PATH="$HOME/.steam/steam/steamapps/common/Call of Duty United Offensive" \
  ./Open_CoD_UO-x86_64.AppImage
```

Each binary keeps its own saved path, so they are configured independently: the client writes `~/.config/opencoduo/data-path` and the server writes `~/.config/coduo_lnxded/data-path`. `CODUOMP_DATA_PATH` is the same variable for both, since it is the same game data.

Client configuration, logs, downloads and screenshots live in `~/.local/share/opencoduo` (or `$XDG_DATA_HOME/opencoduo`). Server configuration, logs and screenshots live in `~/.callofduty`. Neither is ever written inside the AppImage.

---

More at: [AnyLinux-AppImages](https://pkgforge-dev.github.io/Anylinux-AppImages/)
