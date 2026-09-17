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
PINNED_RELEASE_TAG="v0.11.0"
SHA256_X86_64_UNKNOWN_LINUX_GNU="0898de5fad62335adea9a2fe8b0ad0b758fcac85c71a75f597913239d9efd31d"
SHA256_AARCH64_UNKNOWN_LINUX_GNU="6350741b97c0f63430cbe8184e8ebd95b944cad722e464404102a8a93599320c"
SHA256_X86_64_UNKNOWN_LINUX_MUSL="21646beec711413fa7fffe45fceb3cffe0f6ebc7642d4d58506aba4332af19bf"
SHA256_AARCH64_UNKNOWN_LINUX_MUSL="f6787924c211ff51a6cc250f3d976179b6b22e9db6169c805cb2b03b7d0e037f"
SHA256_AARCH64_LINUX_ANDROID="319fa30188452884555de0ee9067ae7837e07a99df0fc0deafc78c8fe0b06a35"
SHA256_X86_64_APPLE_DARWIN="2aaea6d37562d04ad85e30f49395d6c1dd48963068f4d397c5f932e7efd7a3e0"
SHA256_AARCH64_APPLE_DARWIN="7bf03ea6a0c8f0315fb441664a6aa39b832fdf5bdaab5a20d0414bf600d13e1d"

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
