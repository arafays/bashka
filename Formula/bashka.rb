# Tap from this repo: brew tap dmtrKovalenko/bashka https://github.com/dmtrKovalenko/bashka
# The version and sha256 lines are pinned by CI on every release (make pin-installer).
class Bashka < Formula
  desc "Safety guard for `curl … | bash`: analyzes the script before it runs"
  homepage "https://github.com/dmtrKovalenko/bashka"
  version "0.9.0"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/dmtrKovalenko/bashka/releases/download/v0.9.0/bashka-aarch64-apple-darwin"
      sha256 "cfeb92a6d92d0c81c385aa0582dae7a8081433db8f269ff49925b65580e8b1cc"
    end
    on_intel do
      url "https://github.com/dmtrKovalenko/bashka/releases/download/v0.9.0/bashka-x86_64-apple-darwin"
      sha256 "dbe8ce4e13fd807594d7a8504193f069bf4473aef3b5a53eb9f74d0422013361"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/dmtrKovalenko/bashka/releases/download/v0.9.0/bashka-aarch64-unknown-linux-musl"
      sha256 "e4d02626d5552aa2a7c771bdca7e1ef9d82c0566e536fece82c786aa2b524262"
    end
    on_intel do
      url "https://github.com/dmtrKovalenko/bashka/releases/download/v0.9.0/bashka-x86_64-unknown-linux-musl"
      sha256 "09c96787266d040af4e28e0e553d9e1f6972e8473678e9ca38007b6567bbc1d4"
    end
  end

  def install
    bin.install Dir["bashka*"].first => "bashka"
    chmod 0755, bin/"bashka"
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/bashka --version")
  end
end
