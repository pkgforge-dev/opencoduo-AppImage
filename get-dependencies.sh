#!/bin/sh

set -eu

echo "Installing package dependencies..."
echo "---------------------------------------------------------------"
pacman -Syu --noconfirm \
	minizip \
	nasm \
	openal

echo "Installing debloated packages..."
echo "---------------------------------------------------------------"
get-debloated-pkgs --add-mesa --prefer-nano libdecor-mini

make-aur-package libjpeg6-turbo
make-aur-package sdl2

echo "Downloading Open CoD:UO..."
echo "---------------------------------------------------------------"
RELEASE_JSON=$(curl -Ls https://api.github.com/repos/opencoduo/coduomp/releases/latest)

# $1 asset name regex, $2 destination dir; sets $tarball to the local path
fetch_asset() {
	asset=$(printf '%s\n' "$RELEASE_JSON" | jq -r --arg p "$1" '
		.assets[]
		| select(.name | test($p))
		| "\(.browser_download_url) \((.digest // "") | sub("^sha256:"; ""))"')
	url=$(printf '%s\n' "$asset" | cut -d' ' -f1)
	sha=$(printf '%s\n' "$asset" | cut -d' ' -f2)
	if [ -z "$url" ]; then
		echo "Could not find a release asset matching '$1'!" >&2
		exit 1
	fi
	tarball=$2/${url##*/}

	if [ ! -f "$tarball" ]; then
		mkdir -p "$2"
		curl --retry-connrefused --retry 30 -Lo "$tarball" "$url"
	fi
	if [ -n "$sha" ]; then
		echo "$sha  $tarball" | sha256sum -c -
	fi
}

# $1 asset regex, $2 destination dir, $3 tarball top level dir, $4 final name
unpack_asset() {
	fetch_asset "$1" "$2"
	rm -rf "$2/$3" "$2/$4"
	tar -xzf "$tarball" -C "$2" --strip-components=1
	rm -f "$tarball"
	mv "$2/$3" "$2/$4"
	chmod +x "$2/$4" "$2"/uo/*.so
}

rm -rf pkg
unpack_asset '^opencoduo-linux-x86_64-.*\.tar\.gz$' \
	pkg/client CoDUOMP opencoduo-client
unpack_asset '^opencoduo-server-linux-x86_64-.*\.tar\.gz$' \
	pkg/server coduo_lnxded_recovered opencoduo-server
