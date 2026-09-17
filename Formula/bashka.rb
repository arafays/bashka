# Tap from this repo: brew tap dmtrKovalenko/bashka https://github.com/dmtrKovalenko/bashka
# The version and sha256 lines are pinned by CI on every release (make pin-installer).
class Bashka < Formula
  desc "Safety guard for `curl … | bash`: analyzes the script before it runs"
  homepage "https://github.com/dmtrKovalenko/bashka"
  version "0.8.0"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/dmtrKovalenko/bashka/releases/download/v0.8.0/bashka-aarch64-apple-darwin"
      sha256 "de346b11fbd49eed3d16537bb494cae67084355c28362f1ad4d0c1738fd9e0a7"
    end
    on_intel do
      url "https://github.com/dmtrKovalenko/bashka/releases/download/v0.8.0/bashka-x86_64-apple-darwin"
      sha256 "d62797f13a71be88644100cd6f8853ad3c44416ae9c78d0d901f44fd2bee6119"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/dmtrKovalenko/bashka/releases/download/v0.8.0/bashka-aarch64-unknown-linux-musl"
      sha256 "6265d964e3a91ce97eeef7486e0609d48c8eb0086d04d13339c3d9941fcf5462"
    end
    on_intel do
      url "https://github.com/dmtrKovalenko/bashka/releases/download/v0.8.0/bashka-x86_64-unknown-linux-musl"
      sha256 "266c5770e4dccfd3f3ff1e10df61da733a09a198b0f4e6d9a4b2f6df4962a191"
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
