# SkyRoute — getting it into the stores

This folder is the native app project (Capacitor). The web app itself lives in `www/`;
`src/native.js` is the bridge to phone features (GPS, share sheet, keep-awake, back button, links).

```
www/            the app (index.html + icons + privacy.html)
src/native.js   native bridge → bundled to www/native.js
android/        Android Studio / Gradle project (ready to build)
ios/            Xcode project (build on a Mac or via GitHub Actions)
keys/           your Android upload keystore — KEEP THIS SAFE, never commit it
.github/        cloud build recipes for both platforms
```

## What's already built
- `SkyRoute-release.apk` — signed, installable on any Android phone today (Settings → allow installs from this source).
- `SkyRoute-release.aab` — the file Google Play wants.
- `keys/skyroute-upload.jks` + `keys/KEYSTORE_PASSWORD.txt` — your upload signing key. If you lose this you
  cannot update the app on Google Play without a key-reset request, so back it up somewhere private.

## Android → Google Play (can do this week)
1. Register at https://play.google.com/console ($25 one-time). Identity verification takes 1–3 days.
2. Create app → "SkyRoute" → Free → App.
3. Upload `SkyRoute-release.aab` under **Testing → Internal testing** first (instant, up to 100 testers by email).
4. Fill in the store listing: short + full description, 2–8 phone screenshots (1080×1920+), a 512×512 icon
   (use `www/icon-512.png`), a 1024×500 feature graphic, privacy policy URL (host `www/privacy.html` anywhere public).
5. **App content** section: Data safety → "Location: collected, not shared, used for app functionality, not stored";
   no ads; target audience 18+; not a news/finance/health app.
6. Location permission declaration: choose "Navigation" as the core purpose.
7. Promote the internal test to Production when ready. First review takes a few days; updates are usually hours.

Version bumps: edit `versionCode` (must increase every upload) and `versionName` in `android/app/build.gradle`.

## iPhone → App Store (no Mac needed)
1. Enroll at https://developer.apple.com/programs/ ($99/yr; 1–2 days).
2. In https://appstoreconnect.apple.com create the app: name SkyRoute, bundle ID `com.melissacherry.skyroute`.
3. Create the three things the cloud build needs (all in the Apple developer portal → Certificates, IDs & Profiles):
   - an **Apple Distribution certificate** (exported as .p12 with a password),
   - an **App Store provisioning profile** for the bundle ID,
   - an **App Store Connect API key** (Users & Access → Integrations → App Store Connect API).
   Making the .p12 normally needs a Mac's Keychain; the cheap workaround is a one-hour cloud Mac
   (MacinCloud / MacStadium ~ $1–2/hr) or a friend's Mac — it's a five-minute task.
4. Push this folder to a private GitHub repo, add the secrets named at the top of `.github/workflows/ios.yml`,
   then Actions → **iOS build** → Run workflow. It compiles on GitHub's Mac and uploads to TestFlight.
5. TestFlight lets you and up to 10,000 testers install it immediately. Submit for App Review from App Store Connect
   when ready (screenshots for 6.7" and 6.5" iPhones, description, privacy policy URL, and an "App Privacy"
   declaration matching the Android one: location used for app functionality, not linked to identity).

Apple will ask why the app needs location — the strings in `ios/App/App/Info.plist` already explain it.

## Everyday development
```
npm install                       # once
# edit www/index.html (same file as the web version)
npx esbuild src/native.js --bundle --minify --format=iife --outfile=www/native.js
npx cap sync                      # copies www/ into both native projects
cd android && ./gradlew assembleRelease bundleRelease   # needs Android SDK + Java 21
```
Test the web version in any browser first — `index.html?demo=1&lat=37.9779&lon=-122.0311` simulates a ride.

## Before going public — things to swap
- **Routing/search servers**: Valhalla (valhalla1.openstreetmap.de), OSRM and Nominatim are community demo servers meant for
  light use. Fine for testing and a small club; for a public store app plan on a keyed provider
  (Stadia Maps hosts Valhalla, ~free up to 200k requests/month; or Mapbox / OpenRouteService). It's a URL swap in `index.html`.
- **Share links**: `SHARE_BASE` in `index.html` is set to `https://skyroute.app/` — change it to wherever you host the
  web version, and add that domain to `android/app/src/main/AndroidManifest.xml` so links open the app.
- **Name**: "SkyRoute" is a placeholder; check the stores for conflicts before you commit to it.
