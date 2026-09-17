#!/usr/bin/env bash
# Bashka own 100% safe bash installation script
# curl --proto '=https' --tlsv1.2 -fsSL https://raw.githubusercontent.com/dmtrKovalenko/bashka/main/install.sh | bash
set -euo pipefail

REPO="dmtrKovalenko/bashka"
APP_NAME="bashka"
INSTALL_DIR="${BASHKA_INSTALL_DIR:-$HOME/.local/bin}"
if [ -z "${BASHKA_INSTALL_DIR:-}" ] && [ -n "${TERMUX_VERSION:-}" ] && [ -n "${PREFIX:-}" ]; then
    INSTALL_DIR="$PREFIX/bin"
fi

# Pinned by CI on every release (see .github/workflows/release.yml).
PINNED_RELEASE_TAG="v0.9.0"
SHA256_X86_64_UNKNOWN_LINUX_GNU="742539cf45bb60cf8d0813760202bce1d949a615bb9acc36d9efe44189edb4a1"
SHA256_AARCH64_UNKNOWN_LINUX_GNU="5d9033e9ceb04db9e848553036de98ded4f5563dd1f60c2128587213edb6e6dc"
SHA256_X86_64_UNKNOWN_LINUX_MUSL="09c96787266d040af4e28e0e553d9e1f6972e8473678e9ca38007b6567bbc1d4"
SHA256_AARCH64_UNKNOWN_LINUX_MUSL="e4d02626d5552aa2a7c771bdca7e1ef9d82c0566e536fece82c786aa2b524262"
SHA256_AARCH64_LINUX_ANDROID="9c78aa1bf116ba51f1e1753198f661c13f81c2f502d1a0af2a460083198ebfce"
SHA256_X86_64_APPLE_DARWIN="dbe8ce4e13fd807594d7a8504193f069bf4473aef3b5a53eb9f74d0422013361"
SHA256_AARCH64_APPLE_DARWIN="cfeb92a6d92d0c81c385aa0582dae7a8081433db8f269ff49925b65580e8b1cc"

info() { printf '\033[1;34m%s\033[0m\n' "$*"; }
fail() { printf '\033[1;31merror: %s\033[0m\n' "$*" >&2; exit 1; }

linux_libc() {
    if [ -n "${TERMUX_VERSION:-}" ] || [ "$(uname -o 2>/dev/null || true)" = "Android" ]; then
        echo "android"
    elif ldd --version 2>&1 | grep -qi glibc; then
        echo "gnu"
    else
        echo "musl"
    fi
}

detect_target() {
    local os arch libc
    os="$(uname -s)"
    arch="$(uname -m)"
    case "$os" in
        Linux)
            libc="$(linux_libc)"
            case "$arch:$libc" in
                x86_64:gnu) echo "x86_64-unknown-linux-gnu" ;;
                x86_64:*) echo "x86_64-unknown-linux-musl" ;;
                aarch64:android | arm64:android) echo "aarch64-linux-android" ;;
                aarch64:gnu | arm64:gnu) echo "aarch64-unknown-linux-gnu" ;;
                aarch64:* | arm64:*) echo "aarch64-unknown-linux-musl" ;;
                *) fail "unsupported architecture: $arch" ;;
            esac
            ;;
        Darwin)
            case "$arch" in
                x86_64) echo "x86_64-apple-darwin" ;;
                arm64) echo "aarch64-apple-darwin" ;;
                *) fail "unsupported architecture: $arch" ;;
            esac
            ;;
        *) fail "unsupported OS: $os (bashka runs on Linux and macOS)" ;;
    esac
}

pinned_sha() {
    case "$1" in
        x86_64-unknown-linux-gnu) echo "$SHA256_X86_64_UNKNOWN_LINUX_GNU" ;;
        aarch64-unknown-linux-gnu) echo "$SHA256_AARCH64_UNKNOWN_LINUX_GNU" ;;
        x86_64-unknown-linux-musl) echo "$SHA256_X86_64_UNKNOWN_LINUX_MUSL" ;;
        aarch64-unknown-linux-musl) echo "$SHA256_AARCH64_UNKNOWN_LINUX_MUSL" ;;
        aarch64-linux-android) echo "$SHA256_AARCH64_LINUX_ANDROID" ;;
        x86_64-apple-darwin) echo "$SHA256_X86_64_APPLE_DARWIN" ;;
        aarch64-apple-darwin) echo "$SHA256_AARCH64_APPLE_DARWIN" ;;
    esac
}

# `sha256sum -c` on Linux, `shasum -a 256 -c` on mac
check_sha256() {
    local file="$1" expected="$2"
    if command -v sha256sum >/dev/null 2>&1; then
        echo "$expected  $file" | sha256sum -c - >/dev/null
    elif command -v shasum >/dev/null 2>&1; then
        echo "$expected  $file" | shasum -a 256 -c - >/dev/null
    else
        fail "neither sha256sum nor shasum is available to verify the download"
    fi
}

main() {
    local target tag expected asset url
    # Not local: the EXIT trap runs after main returns and must still see it under set -u.
    target="$(detect_target)"
    tag="$PINNED_RELEASE_TAG"
    expected="$(pinned_sha "$target")"
    [ -n "$expected" ] || fail "no pinned checksum for $target in this copy of install.sh"

    tmp="$(mktemp -d)"
    trap 'rm -rf "$tmp"' EXIT

    asset="$APP_NAME-$target"
    url="https://github.com/$REPO/releases/download/$tag/$asset"
    info "downloading $APP_NAME $tag for $target"
    curl --proto '=https' --tlsv1.2 -fsSL -o "$tmp/$APP_NAME" "$url" \
        || fail "download failed: $url"

    info "verifying sha256"
    check_sha256 "$tmp/$APP_NAME" "$expected" || fail "checksum mismatch for $asset; refusing to install"

    mkdir -p "$INSTALL_DIR"
    install -m 755 "$tmp/$APP_NAME" "$INSTALL_DIR/$APP_NAME"
    info "installed $INSTALL_DIR/$APP_NAME ($tag)"

    case ":$PATH:" in
        *":$INSTALL_DIR:"*) ;;
        *)
            echo
            echo "$INSTALL_DIR is not on your PATH. Add it in your shell profile, e.g.:"
            echo "  export PATH=\"$INSTALL_DIR:\$PATH\""
            ;;
    esac
    echo
    echo "next time, make the bash installation safer by adding ka, e.g."
    printf '  curl -fsSL https://dmtrkovalenko.dev/install-fff-mcp.sh | bash\033[1;35mka\033[0m\n'
}

main
