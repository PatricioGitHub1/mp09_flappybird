# DAM-WebSocketsGameBucle

## Fer anar el servidor

cd server
npm install
npm run dev

## Fer anar el joc

cd game
create .
flutter create . --platform linux
flutter run -d linux

(Obrir diverses finestres del joc, però esperar que cada una hagi iniciat correctament)

## Nota per Flutter i macOS

Per activar l'entrada i sortida de dades WebSocket a Flutter de macOS cal activar les connexions d'entrada i sortida del projecte 'XCode', o també es pot fer modificant els arxius:

```bash
client_flutter/macos/Runner/DebugProfile.entitlements
client_flutter/macos/Runner/Release.entitlements
```

Amb aquest codi:
```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>com.apple.security.app-sandbox</key>
	<true/>
	<key>com.apple.security.cs.allow-jit</key>
	<true/>
	<key>com.apple.security.network.client</key>
	<true/>
	<key>com.apple.security.network.server</key>
	<true/>
</dict>
</plist>