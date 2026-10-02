class FennelLsRs < Formula
  desc "Language server for Fennel, written in Rust"
  homepage "https://github.com/Jarodwr/fennel-tools"
  url "https://github.com/Jarodwr/fennel-tools/archive/ebbb8d10f9f58be986f0ea232a890462c2bca579.tar.gz"
  version "0.1.0"
  sha256 "76f34fff8440f10896d78005148964d7b68f7c15fd9cbd572fbf1f5436ef36cc"
  head "https://github.com/Jarodwr/fennel-tools.git", branch: "main"

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
    # `check` reports problems on stdout but exits 0 either way
    assert_match "unclosed delimiter", shell_output("#{bin}/fennel-ls check #{testpath}/bad.fnl")
  end
end
