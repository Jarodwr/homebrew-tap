class Workyard < Formula
  desc "Local-first kanban for coordinating AI coding agents"
  homepage "https://github.com/Jarodwr/workyard"
  url "https://github.com/Jarodwr/workyard/archive/refs/tags/v0.1.1.tar.gz"
  sha256 "db32c58f52b767a0b2203e96a31b508bb8088164f0a0fc7c6796317780619d0a"
  license "MIT"
  head "https://github.com/Jarodwr/workyard.git", branch: "main"

  depends_on "rust" => :build

  def install
    system "cargo", "install", *std_cargo_args(path: "crates/workyard-cli")
    # The CLI finds its Claude plugin at <prefix>/share/workyard/plugin (`pkgshare`)
    pkgshare.install "plugin"
    # `claude plugin marketplace add` needs a marketplace.json beside the plugin, so install that layout too
    (pkgshare/"marketplace").install ".claude-plugin"
    cp_r pkgshare/"plugin", pkgshare/"marketplace"
  end

  def caveats
    <<~EOS
      Workyard ships a Claude Code plugin. To use it with Claude Code, run:
        claude plugin marketplace add #{opt_pkgshare}/marketplace
        claude plugin install workyard@workyard

      Then check that everything is in place:
        workyard doctor
    EOS
  end

  test do
    assert_match "workyard #{version}", shell_output("#{bin}/workyard --version")
    assert_path_exists pkgshare/"marketplace/.claude-plugin/marketplace.json"
    assert_path_exists pkgshare/"marketplace/plugin/.claude-plugin/plugin.json"

    # `doctor` fails when `claude` or `git` is missing from PATH, as in the
    # test sandbox; stub both so the report is deterministic.
    %w[claude git].each do |tool|
      (testpath/"stubs"/tool).write "#!/bin/sh\necho \"#{tool} 0.0.0\"\n"
      (testpath/"stubs"/tool).chmod 0755
    end
    ENV.prepend_path "PATH", testpath/"stubs"
    ENV["WORKYARD_DB"] = testpath/"workyard.db"
    report = JSON.parse(shell_output("#{bin}/workyard doctor --json"))
    assert_equal version.to_s, report.dig("data", "version")
    assert_path_exists pkgshare/"plugin/.claude-plugin/plugin.json"
  end
end
