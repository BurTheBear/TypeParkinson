# TypeParkinson v2 — research and production decisions

Research completed October 24, 2026, before new animation code. This is a creative interpretation of sources, not an assertion that a style guarantees a competition result. No third-party film footage, music, models or stills are incorporated.

## Competition: use the current year

The [2026 rules](https://www.congressionalappchallenge.us/wp-content/uploads/2026/05/2026-CAC-Rules.pdf) govern this entry. The brief's [2025 rules](https://trahan.house.gov/uploadedfiles/2025-cac-rules.pdf) are historical context. The current rules require a functioning app and a short demonstration covering its name, purpose, audience, tools and operation. The three principal criteria concern the idea, implementation/design and programming skill. Therefore the film cannot consist solely of polished hardware shots: it needs a readable workflow, actual comparison screen, algorithm, architecture and test evidence.

The [sample rubric](https://www.congressionalappchallenge.us/wp-content/uploads/2023/11/Sample-CAC-Judging-Rubric.pdf) expands those concerns into idea, impact, structure, function, code and interface. It is an example, not a verified NJ11 scoring sheet. [Judges guidance](https://www.congressionalappchallenge.us/get-involved/judges/) reinforces those concerns. The film's rubric map is in STORYBOARD.md.

The 2026 PDF and [registration page](https://www.congressionalappchallenge.us/students/student-registration/) publish conflicting October 26 cutoff times (noon versus 9 PM Eastern). Treat noon as the planning deadline and have the students verify their submission portal. Uploading to GitHub does not submit an entry. Students must register and upload their video to the accepted public video service, complete the application and disclose AI assistance.

The rules require full AI disclosure, significant student contributions and technical understanding. Claude Code and Codex contributed extensively to this project and film; students must accurately describe that work and their own contributions. No fictional origin story, user interviews, clinical trial or student division of labor will be invented.

[Official NJ election results](https://www.nj.gov/state/elections/assets/pdf/election-results/2024/2024-official-general-results-us-house-district11.pdf) place Livingston in NJ11. The [2026 participating list](https://www.congressionalappchallenge.us/students/participating-districts/) includes NJ11, currently represented by [Analilia Mejia](https://mejia.house.gov/). Her [challenge service page](https://mejia.house.gov/services/congressional-app-challenge) returned 403, so additional local judging requirements remain unverified. School location alone does not replace the students' eligibility confirmation.

## Winning entries: task clarity and technical specificity

Official summaries reviewed:

- [2025 KY2 WaterWise and CarePath](https://guthrie.house.gov/news/documentsingle.aspx?DocumentID=390863): clear resource/health tasks and identifiable audiences. Linked [WaterWise demo](https://www.youtube.com/watch?v=pPRUIzA1NOU) returned YouTube account error 151; [CarePath demo](https://www.youtube.com/watch?v=AUX9_xyljwM) could not be opened. These videos were not watched.
- [2025 WA5 ChestFlow AI](https://www.congressionalappchallenge.us/25-WA05/): the summary names a concrete model and implementation. Its clinical claims are not evidence for TypeParkinson, and are not adopted. Embedded video could not be reviewed.
- [2022 KY2 Parkinson's Assistive Technology](https://guthrie.house.gov/news/documentsingle.aspx?DocumentID=387839): relevant precedent for an assistive task rather than a diagnostic claim.
- [2025 MA1 Health Advocate](https://neal.house.gov/2026/01/20/from-a-missed-question-to-capitol-hill-berkshires-teen-builds-ai-app-to-help-patients-speak-up/): a specific communication difficulty explains the product's purpose.
- [2024 MA5 WayPoint](https://katherineclark.house.gov/2024/12/16/2024-12-whip-clark-announces-congressional-app-challenge-winner/): accessibility is expressed through a concrete action.

Our inference: open with trying to type a familiar word, explain adaptation, then demonstrate and substantiate it. These summaries do not establish why judges selected the winners. No claim is made to have watched unavailable demonstrations.

## Camera and product-film language

[Sony Cine's creative breakdown](https://sony-cinematography.com/articles/breaking-down-the-script---part-2---the-creative-breakdown/) connects camera moves to story emphasis. [Adobe tracking-shot guidance](https://www.adobe.com/creativecloud/video/production/cinematography/camera-shots-and-angles/tracking-shot.html) emphasizes a stable subject and rehearsed movement; its [shot overview](https://www.adobe.com/uk/creativecloud/video/production/cinematography/camera-shots-and-angles.html) provides vocabulary for changes in scale and viewpoint.

Translate that into three motivated moves: a macro push to reveal the difficulty of a tap, an orbit to reveal the product, and a pull-through from touch particles to the algorithm. Camera moves must settle on readable evidence. Constant spinning is not a substitute for staging.

[Tendril Figure 02](https://tendril.studio/work/figure02/) was inspected visually: the hero still shows close mechanical detail, reflective dark material, raking light and selective focus. The main Vimeo embed was unavailable; the process page and stills were accessible. [Tendril IBM z17](https://tendril.studio/work/ibm-z17/) describes making internal engineering tangible. [BUCK Nothing Playground](https://buck.co/work/nothing-playground) shows the value of a coherent visual identity and iteration. Their assets are references only.

The [Apple Relay transcript](https://images.apple.com/uk/accessibility/the-relay/) centers people pursuing goals and using specific accessibility features. The transcript was read; the complete film was not reviewed. Adopt agency and a concrete task, avoid pity or implying every person with Parkinson's has the same symptoms. [Apple's accessibility page](https://www.apple.com/accessibility/) provides additional feature-in-context examples.

[Awwwards' Bruno Simon portfolio listing](https://www.awwwards.com/sites/bruno-simon-portfolio) was located, but subsequent page fetches timed out. It is a lead for interactive spatial storytelling, not a film claimed to have been evaluated. No award claim is used to justify our design quality.

## Motion craft

[Adobe's twelve principles](https://www.adobe.com/creativecloud/animation/discover/principles-of-animation.html) and [their adaptation to motion design](https://blog.adobe.com/en/publish/2016/11/08/redesigning-the-12-principles-of-animation-for-motion-design) support staging, anticipation, arcs, overlapping action and follow-through. For this film: keys anticipate with a small lift, depress rapidly, recover with a damped spring; particles trail a camera move; typography settles before reading time. Do not squash a medical chart or bounce every object.

[Apple WWDC23 Animate with springs](https://developer.apple.com/videos/play/wwdc2023/10158/) explains physical spring parameters and continuous motion. Use an analytic damped spring evaluated from absolute scene time, so seeking backward produces the same pose. Use smooth interpolation for camera rails, restrained overshoot for keys/letters, and at least 300 ms for object visibility changes. Match the key's position to the keyboard on the phone during the reveal rather than replacing the world with a slide.

## WebGL implementation: pinned and offline

- [MeshPhysicalMaterial](https://threejs.org/docs/pages/MeshPhysicalMaterial.html): titanium uses metalness/roughness; front glass uses restrained clearcoat; frosted panels use transmission selectively because it is expensive.
- [PMREMGenerator](https://threejs.org/docs/pages/PMREMGenerator.html) and [r170 RoomEnvironment source](https://github.com/mrdoob/three.js/blob/r170/examples/jsm/environments/RoomEnvironment.js): generate a roughness-aware studio reflection environment without an external HDR.
- [VideoTexture](https://threejs.org/docs/pages/VideoTexture.html): use real captured app media, fixed dimensions, explicit deterministic seeks and updates before capture.
- [InstancedMesh](https://threejs.org/docs/pages/InstancedMesh.html): share rounded key/particle geometry while varying transforms, reducing draw calls.
- [ShaderMaterial](https://threejs.org/docs/pages/ShaderMaterial.html): an absolute-time Aura field preserves one visual world throughout the film.
- [RenderTarget](https://threejs.org/docs/pages/RenderTarget.html): accumulate four actual shutter-time scene samples for each final frame. This must average different object/camera poses, not duplicate frames.
- [r170 BokehPass](https://github.com/mrdoob/three.js/blob/r170/examples/jsm/postprocessing/BokehPass.js) and [Three.js examples](https://threejs.org/examples/): selective depth of field for macro shots; keep readable app screens and code in focus. Bloom must be restrained and never reduce text contrast.
- [Nunito sources and license](https://github.com/google/fonts/tree/main/ofl/nunito): locally vendor the font with its SIL Open Font License. Use heavy rounded display lettering, ordinary legible code type. No runtime CDN dependency.
- [MDN OfflineAudioContext](https://developer.mozilla.org/en-US/docs/Web/API/OfflineAudioContext): schedule pad oscillators, filtered seeded noise and clicks offline, render to a buffer, export WAV, then mux. There is no licensed music dependency.

Use Three.js 0.170.0, vendored with MIT license. Build tools may be npm dependencies, but playback must require neither npm nor network. Do not use a generated raster as a substitute for actual 3D geometry.

## Health claims: precise scope

The [Parkinson's Foundation statistics page](https://www.parkinson.org/understanding-parkinsons/statistics), checked October 24, says an estimated **1.1 million** people in the US live with Parkinson's; its detailed counter is **1,112,643**. The film uses the page's rounded estimate with attribution. This is not a count of users or people who need this particular keyboard.

The [Movement Disorder Society consensus](https://pmc.ncbi.nlm.nih.gov/articles/PMC6530552/) describes typical parkinsonian tremor in a 4–7 Hz band and explains overlap between conditions. A [review](https://pmc.ncbi.nlm.nih.gov/articles/PMC8350038/) describes classic resting tremor around 4–6 Hz. The film's approximately 5 Hz visualization is **illustrative**, not a diagnostic threshold or actual patient measurement. The app estimates strength and frequency from motion, without identifying disease.

[NINDS](https://www.ninds.nih.gov/current-research/focus-disorders/parkinsons-disease-research/parkinsons-disease-challenges-progress-and-promise) and the [Foundation movement-symptom guide](https://www.parkinson.org/understanding-parkinsons/movement-symptoms) describe quiet/changed voice. The [Foundation's fine-motor discussion](https://www.parkinson.org/understanding-parkinsons/movement-symptoms/small-handwriting), [technology guide](https://www.parkinson.org/living-with-parkinsons/management/tech-tools) and [workplace guide](https://www.parkinson.org/blog/awareness/workplace) support difficulty with writing/typing and assistive options. Do not generalize these experiences to everyone. The voice meter is relative loudness, not calibrated decibels or a clinical treatment.

## Evidence from this repository

IntentDecoder.swift scores candidates using touch alignment plus a word prior; its alignment accounts for matching, repeated touches, missing letters and transpositions. Touch patterns use expert-set Gaussian naive Bayes, not patient-trained diagnostic AI. Show exact source lines rather than invented pseudocode.

AppModel's comparison preview has errors 4→1 and fixes 6→2. These are **demo data**, not a study or efficacy proof. Real within-person checks use different short phrases and may be influenced by order/practice. Sample progress and medication insights also need explicit labels.

The new build/test run actually passed **67 automated tests in 13 suites**, October 24 at 22:45 New York. This supersedes the brief's old 55. Automated simulator tests do not verify extension behavior in every host app, hardware sensors, microphone, notification actions or real patient benefit.

Privacy wording is scoped: the **keyboard** saves numerical touch parameters, not typed text. Speak can save phrases and recent spoken messages locally. Optional Apple sign-in/iCloud uses the user's account. No TypeParkinson server is involved. Never imply no text is stored anywhere in the app.

## Accessibility and review

[W3C flash guidance](https://www.w3.org/WAI/WCAG22/Understanding/three-flashes-or-below-threshold.html) limits flashes; avoid strobing entirely. [Caption guidance](https://www.w3.org/WAI/WCAG22/Understanding/captions-prerecorded.html) calls for relevant spoken and non-speech information. [Animation from interactions](https://www.w3.org/WAI/WCAG22/Understanding/animation-from-interactions.html) explains disabling nonessential motion. The live player must honor the system preference, offer R, pause on a settled scene and retain keyboard controls.

48 px presenter labels and 120–200 px headlines are the brief's viewing-room targets, not a WCAG certification. Real app UI remains unaltered; magnify it when discussing an interaction. Dark backing under captions, generous safe margins, restrained glow and no flash transitions preserve contrast. Supply matching SRT and a readable transcript. Three documented reviews must inspect actual imagery and motion, not only video metadata.
