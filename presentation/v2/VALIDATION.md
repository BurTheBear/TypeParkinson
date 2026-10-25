# v2 validation

## Native baseline — October 24, 2026, 22:45 New York

The latest v2 brief explicitly requests building/testing the existing app, replacing the earlier no-build restriction. Built with Xcode26.5, schemeTypeParkinson, iPhone17Pro iOS26.2 simulator (4ED0F50B-CEC6-4B17-A835-70F32AAF01C7), CODE_SIGNING_ALLOWED=NO, derived data /tmp/tp-v2-dd.

**TEST SUCCEEDED:67 tests in13 suites passed.** Includes the previously unrun export, keyboard transient-cache, hold-delete and Speak-settings regression cases. Full local log /tmp/tp-v2-native.log and xcresult /tmp/tp-v2-dd/Logs/Test/Test-TypeParkinson-2026.10.24_22-45-26--0400.xcresult. No real-device validation is implied. Keyboard host integration/AppGroup permissions, actual motion/microphone input, reminder actions and PDF layout remain hardware/manual follow-ups.

All tracked v1 files were moved into ../v1 and verified byte-for-byte against commitcfa5f46. The v2 film has not been implemented or validated yet.
