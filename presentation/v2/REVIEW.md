# v2 visual review log

## Pass 1 — spatial / lighting prototype, October 24 night

Reviewed actual WebGL frames at2,12,21,31,44,58,68,79,91,101,109 seconds. Contact sheet: [pass1-contact.jpg](reviews/pass1-contact.jpg), ordered lexicographically by screenshot filename (101,109,12,2,21,31,44,58,68,79,91). This is a prototype review, not a claim that final motion was watched.

Findings: physical depth, reflective frame, real VideoTexture and Gaussian/spectrum geometry render, but studio lighting overexposes pale keys; the background is too bright after linear-to-display conversion. A horizon band weakens continuity. Some two-line headings overlap their subheading. Keys remain visible at the bottom after their chapter. Thin default variable-font outlines weaken the extruded corrections. Initial macro framing shows too much of the keyboard. Four-sample accumulation uses incorrect premultiplication and would darken final blur.

Changes: darker metallic keycaps and white labels, lower studio intensity/exposure, darker shader values, restrained bloom, floor limited to relevant shots, measured heading height before subheading placement, key group scales away after its scenes, closer opening camera, static Nunito Black outlines, one-plus-one accumulation blend. Pending: render this pass, full animatic and actual motion prototypes. No final film exists yet.

## Pass2 — corrected stills / animatic in progress

Reviewed corrected actual frames at2 and44seconds at960wide. Dark metallic keys now show bevels and studio reflections; the opening reads as a macro. Remaining findings: the contact cloud is too dense and a thick ripple masks the key; the extruded correction overlaps its subtitle. Reduced particle radius/ripple thickness and moved correction down in source. These last adjustments are not in the running animatic-pass2 export, which was already loaded; review the next build before final encoding.

The full112s12fps animatic export is running. Do not yet claim it was watched or that three passes are complete.

## Pass3 — full-resolution staging and export review, October 25

Reviewed the full112-second animatic as a contact sheet at4-second intervals (pass2-animatic.jpg). It confirms consistent palette and coverage, but shows the original correction/subtitle collision, thin architecture labels, a rectangular Gaussian base and repetitive framing. That sheet predates the following corrections; it is retained as evidence, not presented as a finished cut.

Reviewed actual1920×1080 four-sample frames from the revised renderer at21,31,44,58,79,91,109seconds. The close-up keys, phone orbit, camera arcs, extruded letters and layered spectrum now have physical depth. The source panel is legible after reducing it to the actual alignmentScore call plus prior, and the architecture labels use loaded Nunito rather than an unintended serif fallback. The headline no longer overlaps the code panel. Corrected particle density, moved word/subtitle, made the spectrum four rows deep, limited the first flip to the j/h glyph and added300ms montage envelopes. Gaussian base now fades away instead of appearing as a solid square.

A one-second1080p60/four-sample benchmark completed successfully. Native Metal rendering was confirmed on AppleM1Max. Browser compositor screenshots were the bottleneck; direct native-resolution canvas export of the same world/editorial layer reduced sampled frame times to66–172ms. JPEG97 is used as an intermediate before H.264; it is not a lower-resolution render. Final export captures clean and captioned frames from the same render clock. The112s presenter cut is derived from the168s master scene-by-scene, preserving its60fps output and matching the presenter script. Optional4K and further experiments were dropped at the user's urgent request.

The final master is rendering. Encoded-film checks, complete decode, caption/SRT checks and final contact sheet remain pending. No physical10-metre viewing test or patient/hardware validation has been performed.

Live controls follow-up: browser review reproduced a blank paused chapter boundary; navigation now seeks into a settled pose. At320px all controls fit in two rows, meet44px targets and avoid the picture. Normal size was restored. These player-only changes do not alter the master already rendering. The final encoded cut is still pending review; the user has rejected the draft aesthetic, so no user approval or subjective quality claim is implied.

## User review and short-cut revision — October 25 evening

The user rejected the rendered draft and requested actual exercises. Reviewed the encoded 30-second first cut as `reviews/intro-before.jpg`: keys have excessive mirror highlights, the keyboard crowds the phone reveal, correction/note text collides, and the composition repeats. This feedback was not treated as approval of the technically valid long export.

Built dedicated 30/45-second camera staging in the same Three.js world. Keys use softer, rougher material; the keyboard clears the reveal and correction shots; the phone makes a sustained full turn rather than a small returning drift. The exercise extension uses actual Practice, tremor and voice captures, with visible simulator labels. Reviewed nine native-resolution four-sample stills (`reviews/short-revision-stills.jpg`); this revealed another collision on the Practice title. Its cause was export typography: the canvas ignored the DOM's negative letter spacing, so the exported title wrapped to a second line while the subtitle used the DOM's one-line height. The export now respects computed letter spacing. A fresh 1920px frame at32s confirms the title and subtitle are separate. The touch-model keyboard was raised to clear its note.

The short master renders natively at1080p60 with four shutter samples. Encoded motion and final media checks follow after it finishes. The long exports retain the earlier draft's design; the latest short source is not represented as a rerender of those long files. No physical ten-metre readability test, patient study or subjective user approval is claimed.

Encoded short-cut check: reviews/showcase-encoded-contact.jpg covers the whole45-second export at5-second intervals, confirming the correction caption has its own space, keys no longer have white mirror faces, and Practice/tremor/voice shots use the actual app. Browser playback and chapter seeking were verified at31s with paused=false/readyState4 and through the final voice segment. This is a concrete revision, not a claim that the user has approved its aesthetic.

Keyboard continuity follow-up: the user wanted the 3D keyboard to remain. It now stays visible at a smaller scale during the phone reveal and correction, then moves below the frame over the last part of the correction shot. Checked native frames at12s and26s show it clearly without overlapping the word or note. The exercise footage remains unchanged.
