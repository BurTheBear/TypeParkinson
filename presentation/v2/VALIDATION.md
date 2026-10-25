# v2 validation — October 25, 2026

## Native baseline — October 24, 22:45 New York

The latest v2 brief explicitly authorized a build/test of the EXISTING app, superseding the earlier no-build restriction. Xcode 26.5, TypeParkinson scheme, iPhone 17 Pro iOS 26.2 simulator (4ED0F50B-CEC6-4B17-A835-70F32AAF01C7), CODE_SIGNING_ALLOWED=NO, derived data /tmp/tp-v2-dd.

**67 tests in 13 suites passed.** Log: /tmp/tp-v2-native.log; xcresult: /tmp/tp-v2-dd/Logs/Test/Test-TypeParkinson-2026.10.24_22-45-26--0400.xcresult. Native source has not changed since that run; comparison against af1c8b3 shows no changes in Shared, TypeParkinson, KeyboardExtension or TypeParkinsonTests. No new native test run is claimed today.

Real-device/manual validation remains: keyboard in host apps and App Group permissions, actual motion/microphone input, medication notification actions and PDF layout. Automated simulator tests do not establish patient benefit.

## Encoded delivery files

All six files passed ffprobe format/duration/size checks and full ffmpeg decode with no errors. All are H.264, 1920×1080, 60fps, TV-range yuv420p; audio versions use AAC, silent copies contain no audio stream. Each is below 50,000,000 bytes. Exact machine-readable evidence: reviews/media-validation.json.

| File | Duration | Bytes |
|---|---:|---:|
| TypeParkinson-intro-30s.mp4 | 30 s | 12,622,065 |
| TypeParkinson-showcase-45s.mp4 | 45 s | 17,641,356 |
| TypeParkinson-showcase-silent.mp4 | 45 s | 16,876,999 |
| TypeParkinson-presenter.mp4 | 112.05 s | 39,885,874 |
| TypeParkinson-presenter-silent.mp4 | 112.05 s | 37,983,431 |
| TypeParkinson-submission.mp4 | 168 s | 43,464,957 |

The 30-second intro and 45-second showcase use the revised short-cut design. The longer files preserve the earlier draft rejected by the user; the presenter is retimed scene-by-scene from the 168-second master. Both picture masters were rendered with four actual shutter-time samples at native 1080p60. No 4K export was made. The SRT has 36 ordered cues, exactly matches the long narration source and ends at 168 seconds. It does not match the new hybrid script. No student narration has been recorded or added by Codex.

The first compatibility check caught full-range yuvj420p inherited from JPEG intermediates and an extra pair of copied frames at the 30-second boundary. Explicit TV-range conversion and an exact re-encoded trim corrected those issues. Final checks above passed afterward. The website copy is 1280×720 at30fps; its transcript and chapter links match the revised45-second film.

## Offline player and browser checks

With all HTTP/HTTPS requests blocked, the packaged file player loads. Rendering44s, seeking backward to7s and returning to44s produces identical SHA-256 frame hashes with four samples. Submission120s selects the engineering scene and the duration is168s. See reviews/offline-check.json. Space, chapter navigation and Reduce Motion were exercised earlier; manual fullscreen remains untested. The live player now uses a1280px surface to reduce GPU load, while capture explicitly uses1920px.

Website film failure was reproduced as a stopped local server with a cached page. Restored a detached loopback server (tools/serve-site.mjs) with HTTP byte-range support; a request for bytes0–1023 returns206 and Content-Range. After reload, the actual embedded45-second movie plays and Practice seeks to31s (paused=false, readyState4). It also played through the voice segment to45s. Proof: reviews/website-film-playing.jpg. An accessible load-error fallback and metadata preload were added.

The interactive web tour shows actual existing app screens, with clear labeling that it is not a running iOS simulator. Practice opens real tremor/voice sample recordings; voice playback was verified with duration6.033s, readyState4 and paused=false. Progress-to-Speak ArrowLeft navigation changes selection correctly. At390px and320px the tour has no horizontal overflow; tab buttons are48px tall. Viewport reset afterward. Original privacy.html and support.html paths are preserved.

## Visual and provenance limits

Three prototype/still passes and the user's rejection are documented honestly in REVIEW.md. The short revision was reviewed through native-resolution stills, an encoded contact sheet and actual website playback. No physical ten-metre viewing test or subjective user approval is claimed. Fresh app clips are real but mostly static; sensor clips are earlier simulator samples. No live physical keyboard correction was captured. See assets/PROVENANCE.md. The v1 archive remains unchanged.

## Publication

Publish all work to personal/presentation FIRST, then fork/presentation and the same upstream draft PR7. Never push or merge upstream. Netlify deployment requires the user's login; its page explicitly accepts terms at login, so that step is handed to the user. Static deploy config and a ready-to-upload website ZIP are prepared. No credits, paid hosting or paid reset were purchased.
