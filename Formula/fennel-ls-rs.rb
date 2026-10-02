class FennelLsRs < Formula
  desc "Language server for Fennel, written in Rust"
  homepage "https://github.com/Jarodwr/fennel-tools"
  url "https://github.com/Jarodwr/fennel-tools/archive/ebbb8d10f9f58be986f0ea232a890462c2bca579.tar.gz"
  version "0.1.0"
  sha256 "76f34fff8440f10896d78005148964d7b68f7c15fd9cbd572fbf1f5436ef36cc"
  head "https://github.com/Jarodwr/fennel-tools.git", branch: "main"

  bottle do
    root_url "https://github.com/Jarodwr/homebrew-tap/releases/download/fennel-ls-rs-0.1.0"
    sha256 cellar: :any_skip_relocation, arm64_tahoe: "f203d5104196c13cfb1ac5ae92edd5668bd5044d05a46731daef7f732a0dd04d"
  end

  depends_on "rust" => :build

  # Same `fennel-ls` binary name as homebrew-core's Lua implementation, which
  # is also the server name Helix's defaults use for Fennel.
  conflicts_with "fennel-ls", because: "both install a `fennel-ls` binary"

  def install
    system "cargo", "install", *std_cargo_args(path: "fennel-ls")
  end

  test do
    assert_match "fennel-ls #{version}", shell_output("#{bin}/fennel-ls --version")

    (testpath/"bad.fnl").write "(fn add [a b]\n  (+ a b)\n"
    # `check` prints diagnostics and exits 1 when it finds errors
    assert_match "unclosed delimiter", shell_output("#{bin}/fennel-ls check #{testpath}/bad.fnl", 1)
  end
end
