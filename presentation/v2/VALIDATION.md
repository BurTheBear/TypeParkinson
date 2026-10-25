# v2 validation

## Native baseline — October 24, 2026, 22:45 New York

The latest v2 brief explicitly requests building/testing the existing app, replacing the earlier no-build restriction. Built with Xcode26.5, schemeTypeParkinson, iPhone17Pro iOS26.2 simulator (4ED0F50B-CEC6-4B17-A835-70F32AAF01C7), CODE_SIGNING_ALLOWED=NO, derived data /tmp/tp-v2-dd.

**TEST SUCCEEDED:67 tests in13 suites passed.** Includes the previously unrun export, keyboard transient-cache, hold-delete and Speak-settings regression cases. Full local log /tmp/tp-v2-native.log and xcresult /tmp/tp-v2-dd/Logs/Test/Test-TypeParkinson-2026.10.24_22-45-26--0400.xcresult. No real-device validation is implied. Keyboard host integration/AppGroup permissions, actual motion/microphone input, reminder actions and PDF layout remain hardware/manual follow-ups.

All tracked v1 files were moved into ../v1 and verified byte-for-byte against commitcfa5f46. The v2 film has not been implemented or validated yet.

## October 25 export baseline

The 112-second960×54012fps animatic has1344frames and fully decodes. This is a prototype, not the requested final. Reviewed three recorded prototype/still passes; see REVIEW.md. Native code has not changed since the67-test run.

The final168-second1920×1080at60fps/four-shutter-sample master is currently rendering, with clean and captioned pictures from the same clock. A real native-resolution direct-canvas export benchmark completed. The long browser audio export stalled; tools/score.py generated a deterministic168-second48kHz stereo16-bit WAV (32,256,044bytes), mean−35.4dB/peak−21.4dB, without clipping. No student narration is included.

Live-player review reproduced that paused chapter navigation sought an invisible transition boundary. It now seeks a settled pose. Actual browser checks confirmed Next changes chapter, Space starts playback, and R pauses on a settled scene and sets Reduce motion. Mobile wrapping/reserved control space was improved in source; responsive checks and final media validation remain to be completed. Fullscreen has not yet been manually exercised in v2.

Offline packaged playback now passes with all HTTP/HTTPS requests blocked. Rendering44s, seeking backward to7s, then returning to44s produces identical SHA-256 frame hashes with four shutter samples (reviews/offline-check.json). Submission duration is168s and engineering seek returns the expected scene.

At320×640, actual browser measurements show no horizontal overflow and every player button/select/link is at least44×44px and fully in the viewport. The temporary viewport was reset. Space starts playback; Next now selects a visible settled scene; R pauses and exposes Reduce motion as enabled. Fullscreen remains untested manually.
