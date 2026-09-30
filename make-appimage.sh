#!/bin/sh

set -eu

ARCH=$(uname -m)
export VERSION=$(git ls-remote --tags --refs --sort=-v:refname \
	https://github.com/opencoduo/coduomp.git |
	sed 's|.*refs/tags/||' |
	head -n 1)
if [ -z "$VERSION" ]; then
	echo "Could not determine the current version!" >&2
	exit 1
fi
export ARCH
export OUTPATH=./dist
export ADD_HOOKS="self-updater.hook"
export UPINFO="gh-releases-zsync|${GITHUB_REPOSITORY%/*}|${GITHUB_REPOSITORY#*/}|latest|*$ARCH.AppImage.zsync"
export MAIN_BIN=opencoduo-client
export APPDIR=${PWD}/AppDir
export DEPLOY_SDL=1
export DEPLOY_OPENGL=1
export DEPLOY_VULKAN=0
export DEPLOY_PULSE=1
export ANYLINUX_LIB=1

# Deploy dependencies, the client and the dedicated server share one AppDir
quick-sharun \
	"$PWD/pkg/client/opencoduo-client"                  \
	"$PWD"/pkg/client/uo/uo_cgame_mp_x86_64.so           \
	"$PWD"/pkg/client/uo/uo_ui_mp_x86_64.so             \
	"$PWD"/pkg/client/uo/uo_game_mp_x86_64.so           \
	"$PWD/pkg/server/opencoduo-server"                  \
	"$PWD"/pkg/server/uo/game.mp.uo.x86_64.so

# fs_basepath points at APPDIR and Sys_LoadDll builds "<basepath>/uo/<name>",
# so every module has to sit at APPDIR/uo/ instead of under lib/
mkdir -p "$APPDIR"/uo
for m in \
	uo_cgame_mp_x86_64.so \
	uo_ui_mp_x86_64.so \
	uo_game_mp_x86_64.so \
	game.mp.uo.x86_64.so
do
	found=$(find "$APPDIR"/lib -name "$m" -print | head -n 1)
	if [ -z "$found" ]; then
		echo "ERROR: $m was not deployed!" >&2
		exit 1
	fi
	mv -f "$found" "$APPDIR"/uo/"$m"
done
find "$APPDIR"/lib -type d -empty -delete

# lib.path was written before the move, so it still lists the old locations
"$APPDIR"/sharun -g

quick-sharun --make-appimage

quick-sharun --simple-test ./dist/*.AppImage
