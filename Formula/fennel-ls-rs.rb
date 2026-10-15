class FennelLsRs < Formula
  desc "Language server for Fennel, written in Rust"
  homepage "https://github.com/Jarodwr/fennel-tools"
  url "https://github.com/Jarodwr/fennel-tools/archive/31fe082d2ca0e839d15c8d78e0c786b04179e4a1.tar.gz"
  version "0.2.1"
  sha256 "5ef99620cc0c4bdc1d82288c7ca3f5a06718c4533f39bda52bb7a7bff0e092f7"
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
    # `check` prints diagnostics and exits 1 when it finds errors
    assert_match "unclosed delimiter", shell_output("#{bin}/fennel-ls check #{testpath}/bad.fnl", 1)
  end
end
