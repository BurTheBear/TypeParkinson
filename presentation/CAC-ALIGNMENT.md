# Congressional App Challenge — pitch alignment

Research checked October 24, 2026. This maps the pitch to published guidance; it does not certify eligibility or a judging score.

## District and rule sources

Livingston is in **NJ-11**, supported by the [New Jersey Division of Elections district results](https://www.nj.gov/state/elections/assets/pdf/election-results/2024/2024-official-general-results-us-house-district11.pdf). The [2026 CAC participating list](https://www.congressionalappchallenge.us/students/participating-districts/) marks NJ-11 participating under Analilia Mejia. Her [official House page](https://mejia.house.gov/) confirms the district. No separate local scoring rubric was verified: the office’s linked App Challenge page returned 403. Confirm local instructions in the registration portal or with the office before submission; no message has been sent on your behalf.

The governing sources used are the [2026 rules](https://www.congressionalappchallenge.us/wp-content/uploads/2026/05/2026-CAC-Rules.pdf), the [published sample rubric](https://www.congressionalappchallenge.us/wp-content/uploads/2023/11/Sample-CAC-Judging-Rubric.pdf), and the [judges page](https://www.congressionalappchallenge.us/get-involved/judges/). The sample is a planning framework, not a verified NJ-11 score sheet.

## Required video information

| Item | Where it appears |
| --- | --- |
| Participant names | 1:26–1:34, on screen and in the draft narration |
| App name | Product reveal and end card |
| Purpose and intended audience | 0:07–0:22; the narration states that TypeParkinson personalizes typing for people with Parkinson’s |
| Languages and tools | 0:14–0:22: Swift, SwiftUI, Xcode |
| Functionality | Touch model/correction illustrations; actual Today, Practice, Voice, Tremor and Progress captures; narration explains the check and exports |
| Length and accessibility | 94 seconds; offline controls, manual Reduce Motion mode, visual transcript; narration still needs recording |

## Sample rubric coverage

| Published dimension | Pitch evidence | Honest limit / preparation |
| --- | --- | --- |
| Ideology | A specific typing barrier, audience and everyday message | No invented personal origin story |
| Impact | Personal settings, reversible correction, communication and care-team records | Intended benefit; no patient outcomes or efficacy percentages |
| Structure | Problem → product → mechanism → real screens → records → privacy → team | Rehearse the timed script; don’t let camera movement obscure the demo |
| Function | Actual app captures plus source-backed explanation | Captures precede new fixes; validate the native branch before presenting it as tested |
| Code | Gaussian model, Bayesian score, dynamic programming, Fourier analysis | Each student should explain their own code and decisions, including limitations |
| UI | Stable keys, large targets, Undo, Reduce Motion, familiar tabs | Physical-device and participatory accessibility checks remain pending |

Code pointers: Shared/TouchModel.swift, Shared/IntentDecoder.swift, Shared/KeyTouchInterpreter.swift, TypeParkinson/Views/CheckScreens.swift, TypeParkinson/Model/SensorAnalysis.swift, TypeParkinson/Model/ReportBuilder.swift. Use the Q&A in PRESENTER-SCRIPT.md to prepare, not as a substitute for understanding the code.

## Submission actions still required

1. Review **AI-ASSISTANCE.md**, add all other tools/help, and describe each student’s real contribution. The 2026 rules require full AI disclosure and significant student contribution/understanding. A polished film does not establish those facts.
2. Record both voices and check the finished video. The silent film plus an unrecorded script is not a completed narrated entry. Upload the final video publicly to an allowed host and put its link in the application. GitHub publication is separate from CAC submission; neither the upload to a video host nor the application has been submitted by Codex.
3. Confirm registration, school/district details, eligibility dates and local office instructions. The official sources conflict on the deadline time: the rules PDF says **October 26 at noon EDT**, while the [registration page](https://www.congressionalappchallenge.us/students/student-registration/) says **October 26 at 9 PM ET**. Verify the portal; plan for the earlier time rather than relying on the later one.
4. Validate the new Swift changes in Xcode/on an iPhone. Native builds/tests were intentionally not run at the user’s instruction. See VALIDATION.md. Don’t claim real-device testing, App Store availability, clinical validation or diagnostic ability.
5. Pranav reviews/merges the existing draft PR #7 and confirms Pages from main /docs. Keep submission materials stable after the competition’s submission period, as required by the rules.
