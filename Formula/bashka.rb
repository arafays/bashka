# Tap from this repo: brew tap dmtrKovalenko/bashka https://github.com/dmtrKovalenko/bashka
# The version and sha256 lines are pinned by CI on every release (make pin-installer).
class Bashka < Formula
  desc "Safety guard for `curl … | bash`: analyzes the script before it runs"
  homepage "https://github.com/dmtrKovalenko/bashka"
  version "0.12.0"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/dmtrKovalenko/bashka/releases/download/v0.12.0/bashka-aarch64-apple-darwin"
      sha256 "b4a23d4361212ae582a5b1502b4d7a5d785658a9bf3142b02a8481f638fb2c9f"
    end
    on_intel do
      url "https://github.com/dmtrKovalenko/bashka/releases/download/v0.12.0/bashka-x86_64-apple-darwin"
      sha256 "dbc8435e6d3daeae15bb9e1b3ed94fed33f73f86aa210ff7dac024d89a7bcbd4"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/dmtrKovalenko/bashka/releases/download/v0.12.0/bashka-aarch64-unknown-linux-musl"
      sha256 "8fed05ae0158464ca3f3ea4a1ae386bde4e1347247f59c68d0c79032a269ead7"
    end
    on_intel do
      url "https://github.com/dmtrKovalenko/bashka/releases/download/v0.12.0/bashka-x86_64-unknown-linux-musl"
      sha256 "64263abb2ebfc88c2b56b2fea4744ac1e7553681cf320c2efa593f2c1b62a1e6"
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
