cask "workyard" do
  version "0.1.2"
  sha256 "6c620344578eb4fd16766cd5792502f469677dd8084c8141eac2b6bc80695e19"

  url "https://github.com/Jarodwr/workyard/releases/download/v#{version}/Workyard-#{version}-aarch64.dmg"
  name "Workyard"
  desc "Local-first kanban for coordinating AI coding agents"
  homepage "https://github.com/Jarodwr/workyard"

  depends_on arch: :arm64
  depends_on macos: :ventura

  app "Workyard.app"
  # Link only the desktop executable, as `workyard-app`. The bundled CLI is not linked:
  # a second `workyard` in the prefix would clash with the `workyard` formula.
  binary "#{appdir}/Workyard.app/Contents/MacOS/workyard-desktop", target: "workyard-app"

  zap trash: [
    "~/Library/Application Support/dev.workyard.app",
    "~/Library/Caches/dev.workyard.app",
    "~/Library/Preferences/dev.workyard.app.plist",
    "~/Library/Saved Application State/dev.workyard.app.savedState",
    "~/Library/WebKit/dev.workyard.app",
  ]

  caveats <<~EOS
    Workyard.app is not signed with an Apple Developer ID or notarized, so
    macOS blocks it on first launch. Allow it once with
      xattr -dr com.apple.quarantine /Applications/Workyard.app
    or right-click the app and choose Open.

    The app carries its own copy of the workyard CLI, so it works on its own.
    The desktop executable is linked as `workyard-app`. To use `workyard` in a terminal,
    install the formula too:
      brew install workyard

    To use the Claude Code plugin that ships inside the app:
      claude plugin marketplace add /Applications/Workyard.app/Contents/Resources/marketplace
      claude plugin install workyard@workyard
  EOS
end
