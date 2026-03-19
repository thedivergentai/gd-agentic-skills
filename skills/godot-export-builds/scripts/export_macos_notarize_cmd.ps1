# Expert macOS Notarization CLI Steps
# Required for distribution outside the Mac App Store.

# 1. Sign the APP
# codesign --deep --force --options runtime --sign "Developer ID Application: Company" Game.app

# 2. Package into ZIP/DMG
# /usr/bin/ditto -c -k --keepParent Game.app Game.zip

# 3. Submit for Notarization
# xcrun notarytool submit Game.zip --apple-id "me@company.com" --password "app-specific-pw" --team-id "TEAMID" --wait

# 4. Staple the ticket
# xcrun stapler staple Game.app
