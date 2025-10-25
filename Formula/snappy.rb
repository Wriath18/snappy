class Snappy < Formula
  desc "macOS window snapping utility with global hotkeys"
  homepage "https://github.com/yourusername/Snappy"
  url "https://github.com/yourusername/Snappy/archive/refs/tags/v1.0.0.tar.gz"
  sha256 "" # Will be filled when you create a release
  license "MIT"
  
  depends_on :macos
  depends_on xcode: ["14.0", :build]

  def install
    system "swift", "build", "-c", "release", "--disable-sandbox"
    bin.install ".build/release/Snappy" => "snappy"
  end

  def plist
    <<~EOS
      <?xml version="1.0" encoding="UTF-8"?>
      <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
      <plist version="1.0">
      <dict>
        <key>Label</key>
        <string>#{plist_name}</string>
        
        <key>ProgramArguments</key>
        <array>
          <string>#{opt_bin}/snappy</string>
        </array>
        
        <key>RunAtLoad</key>
        <true/>
        
        <key>KeepAlive</key>
        <true/>
        
        <key>StandardOutPath</key>
        <string>/tmp/snappy.out.log</string>
        
        <key>StandardErrorPath</key>
        <string>/tmp/snappy.err.log</string>
        
        <key>ProcessType</key>
        <string>Interactive</string>
      </dict>
      </plist>
    EOS
  end

  def plist_name
    "com.snappy.agent"
  end

  def caveats
    <<~EOS
      Snappy has been installed!

      To start the service now and at login:
        brew services start snappy

      Or run manually:
        snappy

      First-time setup:
        1. Press any hotkey (Ctrl+Opt+Cmd + Arrow) to trigger the accessibility permission dialog
        2. Enable Snappy in System Settings > Privacy & Security > Accessibility
        3. Press the hotkey again to start snapping windows!

      Hotkeys:
        Ctrl+Opt+Cmd + Left/Right/Up/Down  - Snap to half
        Ctrl+Opt+Cmd + Return              - Maximize
        Ctrl+Opt+Cmd + C                   - Center

      HTTP API:
        POST http://localhost:42424/snap/{action}
        Actions: left, right, top, bottom, maximize, center

      Logs: /tmp/snappy.out.log and /tmp/snappy.err.log
    EOS
  end

  test do
    system "#{bin}/snappy", "--version"
  end
end

