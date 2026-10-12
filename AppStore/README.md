# App Store submission

Everything needed to fill in App Store Connect for TypeParkinson 1.0, plus the steps that have to be done by hand.

## Before the first upload

1. **Apple Developer account** (team `7J9DZ35Y3A`): in Xcode › Settings › Accounts, make sure the team is signed in. Archiving with automatic signing registers these for you:
   - App IDs `com.pranavatreya.typeparkinson` and `com.pranavatreya.typeparkinson.keyboard`
   - App Group `group.com.pranavatreya.typeparkinson` (both targets)
   - Sign in with Apple and iCloud (key-value storage) on the app
2. **Host the privacy policy and support pages**: on GitHub, Settings › Pages › Build from branch `main`, folder `/docs`. They'll appear at
   - https://pranav-atreya10.github.io/TypeParkinson/privacy.html
   - https://pranav-atreya10.github.io/TypeParkinson/support.html

   The app links to these addresses (`AppLinks` in `TypeParkinson/Views/AccountScreens.swift`), so change both places if you host them elsewhere.
3. **Create the app** in App Store Connect › Apps › + New App: platform iOS, name **TypeParkinson**, bundle ID `com.pranavatreya.typeparkinson`, SKU `typeparkinson`.
4. **Archive and upload**: in Xcode choose *Any iOS Device*, then Product › Archive › Distribute App › App Store Connect.
5. **Test on a real iPhone via TestFlight before submitting.** In particular:
   - The keyboard reads your approved settings with Full Access **off** (change the key size in the app, then check the keyboard in Notes).
   - Sign in with Apple, then sign in on a second device with the same Apple Account and check the profile arrives.
   - Settings › Delete account and data, then check the app returns to onboarding and the keyboard returns to standard settings.

## Listing

**Name:** TypeParkinson
**Subtitle (30):** A keyboard built for your hands
**Category:** Utilities (secondary: Health & Fitness, optional)
**Price:** Free
**Age rating:** 4+ (answer "None" to every question)
**Copyright:** 2026 Pranav Atreya

**Promotional text (170):**
Typing feels different today? One button runs a six-tap check and adjusts how your touches are read — the keys stay exactly where they are.

**Description:**
TypeParkinson watches how you touch the screen, builds a keyboard around it, and then checks — on a phrase you haven’t seen — that the new keyboard actually helps you type.

MEASURE
Five short exercises, about three minutes: tapping targets, double taps, touch and release, following a path, and copying a phrase. There are no right answers, and you can pause or skip any of them.

BUILD
Five settings, each traced to something you did:
• Key size and spacing — bigger keys when close targets are hard to hit
• Touch interpretation — reads each touch where you aimed, if your taps tend to land off to one side
• Repeat handling — ignores accidental second contacts, while deliberate double letters still type
• Tap tolerance — keeps the key you first touched if your finger drifts before lifting
• Correction controls — large Undo, Delete word and Backspace buttons above the keys
Change any of them before you try the keyboard.

CHECK
Type one phrase on a standard keyboard and another on yours, then compare errors, corrections and time. Anything that didn’t help is flagged so you can turn it off.

TYPE ANYWHERE
Turn on the TypeParkinson keyboard in Settings and use it in any app — with letters, numbers, symbols and number pads, caps lock without a quick double tap, and hold-to-delete that waits a little longer so a slow lift doesn’t erase your text.

EVERY DAY AFTER
Hands aren’t the same every morning. “Typing feels different today” runs a six-tap check, compares today with your usual, and adjusts how touches are read for the day. Once you approve a layout, the keys never move, so your fingers can learn where everything is.

PRIVATE BY DESIGN
• No account needed. Optionally sign in with Apple to keep your keyboard in your own iCloud across your iPhone and iPad.
• No servers, no analytics, no ads, no tracking.
• The keyboard runs without Full Access, so it can’t send what you type anywhere, and it never saves it.

TypeParkinson describes how your touches behave. It isn’t a medical device, doesn’t assess or diagnose any condition, and isn’t a substitute for advice from a clinician.

**Keywords (100):**
keyboard,tremor,accessibility,typing,large keys,motor,hand,shaky,accessible keyboard,touch,steady

**Support URL:** https://pranav-atreya10.github.io/TypeParkinson/support.html
**Marketing URL:** https://pranav-atreya10.github.io/TypeParkinson/
**Privacy policy URL:** https://pranav-atreya10.github.io/TypeParkinson/privacy.html

## App Privacy ("nutrition label")

Answer **"No, we do not collect data from this app."**
Sign in with Apple identifiers and iCloud key-value data stay on the device or in the user's own iCloud and are never sent to the developer, so under Apple's definitions they aren't "collected". The privacy manifest (`Shared/PrivacyInfo.xcprivacy`) declares no tracking and no collected data types.

## Export compliance

The app uses no non-exempt encryption; `ITSAppUsesNonExemptEncryption = NO` is set, so App Store Connect won't ask.

## Notes for App Review

> TypeParkinson is a custom keyboard for people whose touches are imprecise, for example because of a tremor.
>
> To review: open the app, go through the four onboarding pages, and choose "Continue without an account" (Sign in with Apple is optional and only syncs settings through the user's own iCloud). Do the five short touch exercises — they can each be skipped — then review the proposed keyboard, try the comparison, and approve.
>
> To use the keyboard in other apps: Settings › Apps › TypeParkinson › Keyboards › turn on TypeParkinson. It does not request Full Access. In any text field, tap the globe key to switch to it.
>
> No login is needed to review any feature. Account deletion is in the app under Settings › Delete account and data. The app has no server; nothing typed is stored or transmitted. It is not a medical device and makes no diagnostic claims.

## Screenshots

App Store Connect needs at least one set for **6.9" iPhone** (1320 × 2868) and, because the app runs on iPad, **13" iPad** (2064 × 2752). Run this once there's a few GB of free disk space:

```bash
AppStore/make_screenshots.sh
```

It builds the app, opens each screen with sample data on the iPhone 17 Pro Max and iPad Pro 13-inch simulators with a clean status bar, and saves PNGs in `AppStore/screenshots/`. Suggested order: onboarding, profile, proposed keyboard, comparison, home, "today vs usual". A shot of the keyboard typing in another app (e.g. Notes) is worth adding by hand.
