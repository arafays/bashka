# Tap from this repo: brew tap dmtrKovalenko/bashka https://github.com/dmtrKovalenko/bashka
# The version and sha256 lines are pinned by CI on every release (make pin-installer).
class Bashka < Formula
  desc "Safety guard for `curl … | bash`: analyzes the script before it runs"
  homepage "https://github.com/dmtrKovalenko/bashka"
  version "0.4.0"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/dmtrKovalenko/bashka/releases/download/v0.4.0/bashka-aarch64-apple-darwin"
      sha256 "a53fe36b887dfa26db66d17557c6f9f3cac2da00b6760501cd3420efe27dec51"
    end
    on_intel do
      url "https://github.com/dmtrKovalenko/bashka/releases/download/v0.4.0/bashka-x86_64-apple-darwin"
      sha256 "2128d734368bbb52f96682c7c204779c69ab9fc29345663ce2eb370385d4a428"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/dmtrKovalenko/bashka/releases/download/v0.4.0/bashka-aarch64-unknown-linux-musl"
      sha256 "527bd40368ce01b2ae178be5ce4527dd2664d9451d65ec16d085e2927743869a"
    end
    on_intel do
      url "https://github.com/dmtrKovalenko/bashka/releases/download/v0.4.0/bashka-x86_64-unknown-linux-musl"
      sha256 "e8ee86de73c99203368ec1f1db435813126b1e93a3a775a94b6c430fe4ed8eb5"
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
