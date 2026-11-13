#!/usr/bin/env bash
set -euo pipefail

if [[ "${1:-}" != "--confirm-release" ]]; then
    echo "Release generation is disabled by default. Obtain explicit user approval, then run:" >&2
    echo "  bash tools/package.sh --confirm-release" >&2
    exit 2
fi

theme_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
release_dir="$theme_dir/release"
stage_dir="$release_dir/laterial"
package_name="Laterial-alpha1.0"

if [[ "$stage_dir" != "$release_dir/laterial" ]]; then
    echo "Refusing to package into an unexpected path." >&2
    exit 1
fi

cd "$theme_dir"

mkdir -p "$release_dir"
if [[ -d "$stage_dir" ]]; then
    find "$stage_dir" -mindepth 1 -delete
else
    mkdir -p "$stage_dir"
fi

mkdir -p \
    "$stage_dir/components" \
    "$stage_dir/js" \
    "$stage_dir/assets"

install -m 0644 Main.qml metadata.desktop theme.conf LICENSE "$stage_dir/"
install -m 0644 README.MD "$stage_dir/README.md"
install -m 0644 components/*.qml "$stage_dir/components/"
install -m 0644 js/*.js "$stage_dir/js/"
install -m 0644 assets/default-wallpaper.svg "$stage_dir/assets/"

grep -q '^\[SddmGreeterTheme\]$' "$stage_dir/metadata.desktop"
grep -q '^MainScript=Main.qml$' "$stage_dir/metadata.desktop"
grep -q '^ConfigFile=theme.conf$' "$stage_dir/metadata.desktop"
grep -q '^Theme-API=2.0$' "$stage_dir/metadata.desktop"
grep -q '^QtVersion=6$' "$stage_dir/metadata.desktop"
test -f "$stage_dir/Main.qml"
test -f "$stage_dir/theme.conf"
test -f "$stage_dir/assets/default-wallpaper.svg"

echo "Release directory: $stage_dir"
set +e
greeter_output="$(QT_QPA_PLATFORM=offscreen timeout 5s \
    sddm-greeter-qt6 --test-mode --theme "$stage_dir" 2>&1)"
status=$?
set -e

if [[ "$status" -ne 0 && "$status" -ne 124 ]]; then
    printf '%s\n' "$greeter_output"
    exit "$status"
fi
if [[ -n "$greeter_output" ]] \
    && printf '%s\n' "$greeter_output" \
        | grep -Eq '(TypeError|ReferenceError|is not defined|Cannot assign|QML .*error|Error:)'; then
    printf '%s\n' "$greeter_output"
    exit 1
fi

tar \
    --sort=name \
    --mtime='2026-11-12 00:00:00Z' \
    --owner=0 \
    --group=0 \
    --numeric-owner \
    -C "$release_dir" \
    -czf "$release_dir/$package_name.tar.gz" \
    laterial

(
    cd "$release_dir"
    bsdtar -a -cf "$package_name.zip" laterial
    sha256sum "$package_name.tar.gz" "$package_name.zip" > SHA256SUMS
)

top_levels="$(tar -tzf "$release_dir/$package_name.tar.gz" | cut -d/ -f1 | sort -u)"
if [[ "$top_levels" != "laterial" ]]; then
    echo "Unexpected archive top-level entries: $top_levels" >&2
    exit 1
fi

zip_top_levels="$(bsdtar -tf "$release_dir/$package_name.zip" | cut -d/ -f1 | sort -u)"
if [[ "$zip_top_levels" != "laterial" ]]; then
    echo "Unexpected zip top-level entries: $zip_top_levels" >&2
    exit 1
fi

echo "Created:"
echo "  $release_dir/$package_name.tar.gz"
echo "  $release_dir/$package_name.zip"
echo "  $release_dir/SHA256SUMS"
