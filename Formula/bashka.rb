# Tap from this repo: brew tap dmtrKovalenko/bashka https://github.com/dmtrKovalenko/bashka
# The version and sha256 lines are pinned by CI on every release (make pin-installer).
class Bashka < Formula
  desc "Safety guard for `curl … | bash`: analyzes the script before it runs"
  homepage "https://github.com/dmtrKovalenko/bashka"
  version "0.6.0"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/dmtrKovalenko/bashka/releases/download/v0.6.0/bashka-aarch64-apple-darwin"
      sha256 "b80e97c679ae4324ea2eef0f8f05f4a274b551efc861490f35ce72070c68803c"
    end
    on_intel do
      url "https://github.com/dmtrKovalenko/bashka/releases/download/v0.6.0/bashka-x86_64-apple-darwin"
      sha256 "a31326c21ad844b1973bc91a137d7a3f822ab3e208cb6bdf65b46e7b0d951da6"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/dmtrKovalenko/bashka/releases/download/v0.6.0/bashka-aarch64-unknown-linux-musl"
      sha256 "c78460ca58550d89bb3e6dcc5e3d355ae396d53061aa77cb445a79546baeb142"
    end
    on_intel do
      url "https://github.com/dmtrKovalenko/bashka/releases/download/v0.6.0/bashka-x86_64-unknown-linux-musl"
      sha256 "9809d918eceadc47f886d58e88524bfec6c1734b55bf4598cbab672c65999340"
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
