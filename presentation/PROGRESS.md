# October25 — delivered recording package and live website

Live website: https://fancy-frangipane-e17df3.netlify.app/ . Interactive app tour: /demo. Netlify Drop deployment verified publicly: film plays/seeks (45s, readyState4, paused=false), and app tour loads. User completed Netlify login. No paid service/reset was purchased. A ZIP is on Desktop/TypeParkinson-Netlify.zip; future Netlify updates require manually redeploying docs.

The revised30s intro and45s showcase are in presentation/v2, with actual Practice/tremor/voice recordings. After the user's continuity feedback, the 3D keyboard remains visible through reveal/correction, then moves below frame before exercises. Re-rendered the first30s at1080p60/four samples and preserved the finished15s exercise segment. All six delivery files pass H.264/yuv420p, duration, <50MB and full-decode checks; exact sizes in v2/reviews/media-validation.json. Offline blocked-network/backward-seek check passes. The longer112/168s exports retain the earlier rejected draft's design, explicitly labeled. No subjective user approval is claimed.

HYBRID-SCRIPT.md targets2:45 including45s animation plus actual app demonstration/closing. Students still must record narration/interaction, caption their actual words, complete AI/contribution disclosure and submit CAC themselves. Do not append a demo to the168s alternative film. The web tour is real screens/recorded samples, not a running iOS simulator.

Native source is unchanged since the verified67-test/13-suite simulator run October24. Existing reliability/accessibility fixes are preserved, as are Pranav's work, v1 and privacy/support paths. Real-device keyboard/AppGroup, motion/mic, notification actions and PDF layout remain pending. Never claim clinical validation.

Publication: major package f7da2ec was pushed to personal FIRST. The final keyboard/Netlify checkpoint is being committed, then pushed personal FIRST and fork/presentation, updating SAME draft upstreamPR7. Never push or merge origin. All current source and media are saved locally. Heartbeat stays paused. Usage was85% at the last milestone; user asked to conserve usage and finish immediately, so no further polish or speculative features.

---

Historical progress (superseded by the active state above):

# Active v2 brief — October 24 night

**Read presentation/v2/BRIEF.md completely before acting.** The latest pasted brief supersedes the earlier incremental-polish plan. Build a separate, much stronger Three.js v2 TONIGHT. Keep v1 untouched in presentation/v1/. Mandatory research and STORYBOARD before any new animation code. Two cuts: presenter 90–120s with music/SFX plus silent copy; submission 2:30–2:55 with captions/SRT/VOICEOVER.md. Offline player, deterministic __render(t), 1080p60, 4–8 motion-blur samples, procedural sound, three documented review passes. 4K only if time permits. Website AFTER the film.

User explicitly changed publication order: FIRST create a separate repository under their account, upload everything/new changes there, THEN put the finished work into Pranav’s existing PR. **Created https://github.com/BurTheBear/TypeParkinson-CAC and pushed all current commits through cfa5f46.** `personal` remote points there, branch presentation now tracks personal/presentation. Existing `fork` still BurTheBear/TypeParkinson; origin remains Pranav. Do not create a duplicate PR or push upstream. All future checkpoints go to personal first.

The new v2 brief explicitly says to build the existing app, record fresh footage and show a verified test count. This supersedes the prior no-build instruction; the plan told the user this. Never create another app. Do not display “55 tests passing” unless actually confirmed; use the actual verified count or state verification pending. The existing app now BUILDS and TEST SUCCEEDED:67 tests in13 suites, completed22:45NYOct24. Previously unrun regression cases now pass. See v2/VALIDATION.md; real-device/manual checks remain.

Current environment: Xcode 26.5 17F42; iPhone 17 Pro iOS26.2 booted UDID4ED0F50B-CEC6-4B17-A835-70F32AAF01C7. simctl needs sandbox escalation. Repository creation succeeded; no permission blocker.

Research already explored official 2026 CAC rules/sample rubric, NJ11 participation, Sony Cine/Adobe camera motivation, Tendril Figure02 and IBM z17, BUCK Nothing Playground, Apple Relay transcript, W3C flash/caption guidance, Three.js docs and clinical sources. V2 RESEARCH.md is still to be written and more technical/craft research remains. A CAC winning demo on YouTube was unavailable (account error151); do not claim to have watched it. Tendril main Vimeo embed missing, but its official process stills and some embeds load; actual Figure02 hero screenshot reviewed in IAB. Research tabs:4 YouTube,5 Tendril; original user tabs1–3 preserved.

Overnight heartbeat typeparkinson-overnight-work ACTIVE through7AMOct25NY; update its prompt to the new v2 brief/publication/build instructions. Latest usage44% current5h/28%weekly used. No credits/reset purchases.

---

Earlier v1 record (paths below now live under presentation/v1; do not redo):

# Overnight progress — October 23, 2026

## Current priority — 3D cinematic pitch revision, October 24 night

Latest request: strengthen the film substantially with **3D camera movement**, then polish the existing website, prepare a two-person pitch script and align it to CAC guidance. The user resumed overnight work through 7 AM October 25 New York time; the existing heartbeat is ACTIVE. Current work must be preserved.

Earlier context: the user rejected the first animation and selected **cinematic product launch**: close-up keyboard motion, a large moving iPhone, less text. They then authorized continuing throughout the day while away. The daytime schedule ended after 7 PM New York time; the TypeParkinson daytime work heartbeat is now paused. The first cinematic revision is now rendered and validated technically, with a large moving phone, angled key close-ups, individual letter transformations, shorter copy and new transition timing. The user has not yet reviewed this revision. Use their next feedback to guide further visual work. Native rebuilds remain prohibited. Keep updating the same draft PR #7; do not overwrite in-progress edits on a heartbeat.

Continue in this repository on branch `presentation`; do not create another app or run xcodebuild. The installed simulator app was used for all captures. The initial rebuild was stopped after the user said no rebuilds. No app installation or native rebuild was completed during the task.

## Completed

- Deterministic 94-second film in `animation.template.html`, packaged offline `animation.html` (about 1.58 MB), and render tools with no npm dependencies.
- Real captures: Today, Practice, Progress, Speak, onboarding, tremor sample session and voice sample session. System keyboard correction is illustrated using cases from existing tests; accessibility activation deliberately provides no raw touch locations and therefore does not demonstrate spatial autocorrection. Do not present the failed AX-driven `tje` capture as correction footage.
- Final MP4 verified by ffprobe and full decode: H.264, 1920×1080, 30 fps, 2,820 frames, 94 seconds, 8,067,314 bytes, no audio. Privacy wording is explicitly scoped to the keyboard.
- Existing docs website replaced with Aura landing page, WebP screenshots, film, interactive correction demo, transcript, preserved privacy/support URLs, revised privacy details.
- Browser checks so far: 390px and 320px no horizontal overflow; no broken loaded images or console errors; all four demo examples and undo pass; actual keyboard Space preserves capitalization; all demo keys >=44px in both dimensions.
- Existing app improvements in source: CSV includes tremor/voice/dose records, stable decimal points, quoted user-entered medication details, spreadsheet formula protection; PDF adds sensor/dose summaries and counts those practice sessions. Regression tests added to existing SmartFeatureTests.swift (not run: user prohibits native rebuild).
- VoiceMeter startup failures now return failure instead of creating synthetic results, and VoiceSession displays a retry notice. Voice/tremor countdown tasks cancel when their screens close. Sample voice sessions are labeled. These native changes remain unbuilt/unverified on hardware.

## Current publication state

Final film and website checks are complete; details are in VALIDATION.md. The final 1080p film is 94 seconds and 8,067,314 bytes, with a 3,506,874-byte 720p website copy. Playback controls, video backward seeking and reduced-motion slides pass. Native changes remain deliberately unbuilt. Published to the fork and opened draft upstream PR #7: https://github.com/pranav-atreya10/TypeParkinson/pull/7. It targets main from BurTheBear:presentation. Pranav must review, validate native changes and merge. Update this same PR during overnight follow-ups.

Keep following the user's overnight request after publication: inspect the existing app for concrete correctness/accessibility issues and update the same branch/PR when justified. Avoid speculative features, new apps, native builds, duplicate PRs and routine status messages. The user extended work throughout the day; stop the updated daytime heartbeat at or after 7 PM October 24 America/New_York. Check usage before substantial work; preserve allowance to save progress.

Credits confirmed: **Atharv Sharma & Pranav Atreya**. Population source checked: Parkinson's Foundation currently estimates 1.1 million Americans. All displayed clinical-looking histories are sample data, labeled; no diagnostic or effectiveness claims.

Automation: heartbeat id `typeparkinson-overnight-work` (name: TypeParkinson daytime work), PAUSED at the scheduled evening cutoff. Final usage check: 19% current window used, 21% weekly used. Check again before substantial final work. No credits or paid reset were used.

## October 24, shortly after midnight — keyboard review

- PR #7 remains open, draft and mergeable, with no new comments. Working tree was clean on presentation before this pass.
- Found source evidence that system-keyboard Undo retained old edits across dismissal and replayed them without document/cursor checks. Added per-edit document ID and before/after context guards, stale-edit invalidation before keyboard actions, and transient-text clearing on appearance/disappearance. Word-validation caches are also cleared while the numerical touch model is preserved.
- Selection replacements/deletions now remember the actual selected text; Delete word removes a selection once rather than continuing left of it. Hold-delete also records a selected range correctly.
- Confirmed the proxy documentIdentifier, selectedText and context API names against the installed Apple UIKit SDK headers. Added one decoder cache/learning regression test. No native compilation or test execution occurred. Manual device scenarios are appended to VALIDATION.md.
- Website local links/assets check, JavaScript syntax and git diff whitespace checks still pass. Presentation/video/site media preserved.
- Hold-delete boundary issue was investigated and addressed in the following pass.

## October 24, 1 AM — hold-delete review

- Source confirmed two grouping problems: Speak recorded every repeated deletion separately; the extension kept its hold flag across separate gestures because the repeated gesture suppresses the final ordinary press.
- Added an explicit onRepeatDeleteStart signal after the hold threshold. Speak and the extension start a new Undo group from that signal. TextComposer remembers the pre-hold text once, clears obsolete correction chips during repeated deletion, and breaks the group if another edit occurs. Short taps and cancellation before the threshold do not signal a repeat start.
- Added four regression cases for one-hold restoration, independent holds, an intervening edit and clearing a stale correction chip. All new native tests remain unrun, and no native rebuild/installation occurred. Changes target the same draft PR #7.
- Reviewed all callback wiring and changed source paths; git diff --check passes. Film, website and media are untouched.
- Reduce Motion number/control paths were reviewed in the following pass.

## October 24, 2 AM — Reduce Motion review

- Source confirmed that BigNumber guarded its entrance but not later value changes; shared button styles always shrank/sprang, practice carousel tiles scaled with scrolling, and FeelingPicker always bounced its icon.
- Added existing accessibilityReduceMotion environment checks to these components. Reduced motion uses immediate numeric updates and identity text transitions, stable button/tile sizes, non-animated segmented/feeling selection, and no feeling-symbol bounce. Press feedback remains through colour/opacity, with the existing Aura palette and Liquid Glass option preserved. Normal-motion paths retain their previous animations. Aura mood colour changes also stop animating under Reduce Motion.
- Verified ContentTransition.identity and symbolEffectsRemoved API availability in the installed SwiftUI SDK interfaces. Reviewed the source diff and ran git diff --check. No native build, installation or native test execution occurred. Manual on/off and live-toggle scenarios are in VALIDATION.md. Film and website/media are unchanged.
- PR #7 was open, draft and mergeable with no new comments at the start of this pass. Continue updating that PR, not another one.
- The medication controls candidate was reviewed in the following pass.

## October 24, 3 AM — medication editor controls

- Enlarged the plain Remove dose icon to a 44×44-point minimum hit area and Add a time to a 44-point minimum height, keeping their existing styling and accessibility labels.
- Source confirmed that Save immediately persists the schedule before awaiting reminder replacement. Repeated taps could launch overlapping updates. Added a synchronous saving guard, disabled Save and schedule editing while it runs, and a Saving… label. The flag clears after completion, including the notifications-off path.
- Reviewed the focused source diff and ran git diff --check. These UI paths remain unbuilt and require the manual native checks in VALIDATION.md. Film, website, media and other app source are unchanged. PR #7 remains the publication target.
- Notification scheduling errors were reviewed in the following pass.

## October 24, 4 AM — reminder scheduling results

- Source confirmed that medication scheduling suppressed notification-add errors and returned success. Authorization errors were also indistinguishable from denied permission. Replaced the Boolean result with scheduled / notificationsOff / failed and updated all call sites.
- Scheduling continues attempting the remaining times after an add error, but reports failure if any request throws. The editor keeps the saved local schedule and shows a retry notice without closing; denied permission retains its separate Settings notice. An empty schedule still clears reminders without requesting permission.
- Reviewed all result branches and call sites; git diff --check passes. No native build, installation or native test execution occurred. Injected-error and real notification checks are documented in VALIDATION.md and remain pending. Film, website and media are untouched; continue using draft PR #7.
- No additional candidate has been established. Future passes should review only concrete source evidence or new PR feedback; avoid speculative features or changes just to fill the overnight window.

## October 24, 5 AM — tapping session timing

- Reviewed the existing spiral, tapping, typing and sensor analysis functions and their call sites. Left their scoring unchanged. PR #7 remains open and draft with no new comments; branch was clean before the pass.
- Found that tapping accepted events until the next 50 ms timer callback, even if their timestamps exceeded the ten-second deadline. Added the deadline check to the touch handler before counting a tap. A late tap finishes the session without entering its event list.
- Added a cancellation check after the timer sleep: a cancelled timer must not continue into result saving when the screen closes. Finishing now cancels the timer and guards against a repeated save.
- Source diff and git diff --check reviewed; no native build, installation or native tests run. Manual deadline, dismissal and retry checks are in VALIDATION.md. Film, website and media remain unchanged. No additional issue has been established.

## October 24 morning — cinematic film revision

- User rejected the previous animation and explicitly chose a cinematic product launch, then authorized continuing all day while away. Revised the existing Canvas film and renderer rather than creating another app or changing native source.
- Removed scene counters and repeated slide layouts. Added bevelled keys, a camera pullback, a large iPhone reveal, masked typography, individual glyph movement during corrections, fixed-key touch contours, tracking device shots and cleaner cuts/iris/push transitions.
- Recovered the original /tmp voice and tremor recordings. Voice now shows the meter reaching the loud zone; tremor shows recording followed by its result. Captures remain explicitly sample data. No native builds or installations.
- Reviewed every scene, 32 motion samples, nine final frames and live browser playback. Fixed caption occlusion, a mis-anchored target callout, clipped space bar, device/subtitle collisions and unreadable screen hold timing. An early 540p draft is ignored in preview/ and predates final transition/sensor refinements; do not present that draft as the delivery film.
- Revised 1080p30 master: 94 seconds, 2,820 frames, H.264, no audio, 8,067,314 bytes; full decode passes. Website 720p30 copy: 3,506,874 bytes. Offline HTML about 1.58 MB. Updated website poster and transcript.
- Deterministic seek, arrows, Space and reduced-motion checks pass; live replay and 320px player controls checked (all controls >=44px, no horizontal overflow). Renderer has preview, selectable still times and poster modes. Native regression tests remain unrun.
- Continue meaningful visual review and incorporate user feedback during daytime follow-ups. Preserve the finished assets, existing website and native fixes; no speculative features or edits just to fill time. The revised film is technically checked, not yet approved by the user.

## October 24, daytime — correction-to-toolkit cut

- PR #7 remains open and draft with no new comments; source and fork were clean before the pass. Reviewed encoded frames at 47.8, 47.966 and 48.2 seconds. The final correction reverted from “the” to “teh” just before the camera push and remained wrong during the outgoing shot.
- Fixed the local example clock so the final example holds instead of restarting on a modulo boundary. No layout, camera, copy or native app changes. Poster and transcript remain accurate and unchanged.
- Added an actual rendered-pixel regression over the final word region at 47.8 and 47.99 seconds. It failed before the fix and passes after it. Deterministic seeking, arrows, Space and reduced-motion slides also pass.
- Re-exported the 94-second 1080p30 master (8,067,314 bytes) and matching 720p30 website copy (3,506,874 bytes). Both fully decode without errors. Encoded frames at 47.966 and 48.2 seconds now visibly retain “the”. Published in the same PR; poster and transcript are unchanged because those scenes did not change.

## October 24 afternoon — live player accessibility

- PR #7 is still open and draft with no new comments; branch and fork were clean before this pass. The cinematic revision has not yet received user feedback.
- Found and reproduced that changing Reduce Motion while playing had no effect until reload. The player now pauses on a settled still of the current chapter immediately; disabling the preference leaves it paused. Added an actual browser preference-change regression, which failed before the fix.
- Screenshot review at 1920×1080 also confirmed the visible manual controls covered the bottom caption. Manual mode now reserves controls space; capture mode is excluded. Reviewed the corrected screenshot and added layout/hit-area checks at presentation and phone sizes. All browser regression checks pass, including live preference changes.
- This changes only HTML player behavior and browser checks. Both MP4 copies, the matching poster/transcript, native source and prior native validation limits are preserved. Continue using the same PR, conserving allowance and avoiding speculative edits while awaiting user feedback.

## October 24, 7:26 PM New York — scheduled work finished

- Disabled the existing heartbeat at the authorized evening cutoff; tool result and saved automation state both confirm PAUSED. No further scheduled work will run unless the user resumes it.
- Verified the presentation branch is clean and matches the fork; PR #7 remains OPEN and DRAFT with no new comments. The last implementation commit is 7a7b788 (live Reduce Motion); all film/player changes and the matching website media are pushed.
- The revised cinematic master is 94 seconds, 1080p30, silent H.264, 8,067,314 bytes. The website copy, poster and transcript match. Browser motion/controls/accessibility checks and complete decoding of both videos have passed; see VALIDATION.md.
- The user has not yet reviewed the cinematic revision. Native source changes remain deliberately unbuilt and their Swift tests unrun. Pranav must validate the native changes in Xcode/on a real iPhone before merging, then confirm Pages from main /docs. Existing privacy/support URLs and both credits are preserved.
- Account usage at closure: 19% current window used, 21% weekly used. No credits or paid resets purchased.


## October 24 night — 3D camera / pitch pass in progress

- Latest steering: “breathtaking 3D animation,” animation FIRST, website polish AFTER. Existing app only; no native rebuilds. Credits and school confirmed: Atharv Sharma & Pranav Atreya, freshmen, Livingston High School, New Jersey.
- Replaced 2D sheared devices with a small world-space perspective renderer: extruded rounded chassis and keys, textured screen meshes, generic illustrated rear device, camera orbit/crane/truck paths, true near/far parallax, view-dependent edge lighting. Retained the 94-second timeline, offline deterministic rendering, sample labels and correction-hold regression.
- Researched cinematography (Sony Cine and Adobe) and national CAC requirements, published sample rubric, NJ-11 participation. Sources and the local-rubric limitation are in CAC-ALIGNMENT.md and DESIGN.md. Added PRESENTER-SCRIPT.md and AI-ASSISTANCE.md. Do not invent student contributions or claim eligibility is certified. Official sources disagree on the submission deadline time; documented for team verification.
- Reviewed a motion preview, opening/orbit/tracking frame sequences and full-resolution stills. Fixed triangulation seams, correction-chip/key overlap, and camera-relative callout/ripple anchors. Latest packed player and browser regressions pass. Final master encode was started; website media/poster/transcript and website visual polish are NEXT after it is decoded/reviewed. Do not confuse the older tracked MP4 with the new encode until it completes.
- Added a concrete Speak fix: refresh correction preferences/calibration after Settings changes without losing message/Undo, clear stale touch coordinates if layout/model changed, and honor suggestions/phrases toggles. Added three behavioral regressions, UNRUN. Native source remains unbuilt.
- Renderer now writes to an ignored temporary MP4 and renames on success so interrupted renders preserve the last delivered movie.
- Resumed existing automation typeparkinson-overnight-work as TypeParkinson overnight polish, ACTIVE hourly through 7 AM October 25 America/New_York. No duplicate automation, new app or PR. Last usage: 20% current window /25% weekly used, no credits or paid reset.

## October24night — v2 active implementation checkpoint

Personal repository verified PUBLIC at https://github.com/BurTheBear/TypeParkinson-CAC, defaultbranchpresentation, contains0880f86. All new work MUST push personal FIRST. Existing draft upstreamPR7 still open; do not update fork/upstream until finished.

V2 mandatory RESEARCH.md and STORYBOARD.md completed before animation code. New Three.js0.170.0 offline prototype now in presentation/v2/src + generatedanimation.html. Persistent physical phone, studio environment/materials, realVideoTexture, instancedkeys/contacts, Gaussian surface, extruded corrections, waveform/barcity, frostedcode/architecture/reportpanels, rings, two112s/168stimelines, proceduralOfflineAudioContext score and4sampletemporalaccumulation. This is NOT final/approved. Pass1contactsheet reviewed; corrective lighting/layout/font changes in progress. See REVIEW.md. render.mjs supportsstills/animatic/audio/finalCDPexport; initial960frames~.2-.7seceach.

Fresh app screens/4sclips:today/practice/progress/speak/compare/onboarding. Real physicalsimulatorinputfailednoWindowsAvailable, so freshSpeakisemptycomposer; don'tclaimactualcorrectioncapture. Sensorclipsstillv1samples,labelclearly. Native67testsverified earlierthisnight.

Usage92%current5hused36%weeklyat~23:15NY; reset1792902492(~00:28NY). Save/push checkpoint, use remaining allowance conservatively. No paidcredits/resets. OvernightheartbeatACTIVEthrough7AMOct25. Next: renderpass2andfullanimatic, inspectactualmotion; improvecamera/staginguntilmateriallystronger,threehonestpasses,final1080p60sound+silentpresenter112s,captionedsubmission168s/SRT/VOICEOVER,websiteAFTERfilm. Currentprototypecontainsrequiredobjectsbutneedsvisualpolishandreview. Readfullv2brief,don'toverwritearchivev1.

Latest checkpoint af1c8b3 is pushed to personal. Running render execsession53256: full112s960x54012fps animatic preview/animatic-pass2.mp4 (~3–4minrender). It also saved pass2stills. Source now additionally fixescorrection/subtitlecollision and reducesparticle/rippledensity; generatedHTMLrebuiltaftertherenderloaded,soanimaticdoesNOTcontainthesetwofinaltweaks. Pass2stillimages2and44wereactuallyviewed;donotclaimwholefilmwatchedyet. VOICEOVER.md, matching36cueSRT and112spresenter-scriptnowexist. Narration391words/168s; scorehasnospeech. FinalMP4snotyetmade. Needrenderafterreview. Confirmcurrentrendercompletionwithwrite_stdin53256orfilesystemffprobe.
