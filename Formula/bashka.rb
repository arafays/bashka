# Tap from this repo: brew tap dmtrKovalenko/bashka https://github.com/dmtrKovalenko/bashka
# The version and sha256 lines are pinned by CI on every release (make pin-installer).
class Bashka < Formula
  desc "Safety guard for `curl … | bash`: analyzes the script before it runs"
  homepage "https://github.com/dmtrKovalenko/bashka"
  version "0.7.0"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/dmtrKovalenko/bashka/releases/download/v0.7.0/bashka-aarch64-apple-darwin"
      sha256 "72e975ab07421524bee73db8f54f00d2902a176e912a232c6b485d8588f77512"
    end
    on_intel do
      url "https://github.com/dmtrKovalenko/bashka/releases/download/v0.7.0/bashka-x86_64-apple-darwin"
      sha256 "a052c6e059a1eb2e00e744a9a82138daf07541c59f9c546dbeae98866fc33d64"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/dmtrKovalenko/bashka/releases/download/v0.7.0/bashka-aarch64-unknown-linux-musl"
      sha256 "15cd194cbeaaaf6d6e89a2b8c3dc498b7709800af5c1aeded1eea3b27717adf3"
    end
    on_intel do
      url "https://github.com/dmtrKovalenko/bashka/releases/download/v0.7.0/bashka-x86_64-unknown-linux-musl"
      sha256 "6f6a6d6139624dd46264af1a55025de57df9d8920dafbc99503743f68917eb6d"
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
