# Tap from this repo: brew tap dmtrKovalenko/bashka https://github.com/dmtrKovalenko/bashka
# The version and sha256 lines are pinned by CI on every release (make pin-installer).
class Bashka < Formula
  desc "Safety guard for `curl … | bash`: analyzes the script before it runs"
  homepage "https://github.com/dmtrKovalenko/bashka"
  version "0.11.0"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/dmtrKovalenko/bashka/releases/download/v0.11.0/bashka-aarch64-apple-darwin"
      sha256 "7bf03ea6a0c8f0315fb441664a6aa39b832fdf5bdaab5a20d0414bf600d13e1d"
    end
    on_intel do
      url "https://github.com/dmtrKovalenko/bashka/releases/download/v0.11.0/bashka-x86_64-apple-darwin"
      sha256 "2aaea6d37562d04ad85e30f49395d6c1dd48963068f4d397c5f932e7efd7a3e0"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/dmtrKovalenko/bashka/releases/download/v0.11.0/bashka-aarch64-unknown-linux-musl"
      sha256 "f6787924c211ff51a6cc250f3d976179b6b22e9db6169c805cb2b03b7d0e037f"
    end
    on_intel do
      url "https://github.com/dmtrKovalenko/bashka/releases/download/v0.11.0/bashka-x86_64-unknown-linux-musl"
      sha256 "21646beec711413fa7fffe45fceb3cffe0f6ebc7642d4d58506aba4332af19bf"
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
