# TypeParkinson v2 — recording package

The exact brief is BRIEF.md. Research and shot plan were written before animation code. Source is src/, offline generated player is animation.html, Three.js 0.170.0 and Nunito are vendored with their licenses. Rebuild using npm ci then npm run build. No network is needed for the generated player.

Start with [HYBRID-SCRIPT.md](HYBRID-SCRIPT.md) for the latest requested format: a short animation followed by a real app walkthrough. The target is 2:45 total, within the official three-minute maximum. Student narration must still be recorded and added.

| File | Use |
|---|---|
| [TypeParkinson-showcase-45s.mp4](TypeParkinson-showcase-45s.mp4) | Revised 3D opener plus real Practice, tremor and voice screens; music/SFX |
| [TypeParkinson-showcase-silent.mp4](TypeParkinson-showcase-silent.mp4) | Same 45-second picture, silent |
| [TypeParkinson-intro-30s.mp4](TypeParkinson-intro-30s.mp4) | Shorter opener if you need more live demo time |
| [TypeParkinson-presenter.mp4](TypeParkinson-presenter.mp4) | Earlier 1:52 illustrated draft with score; [silent copy](TypeParkinson-presenter-silent.mp4) |
| [TypeParkinson-submission.mp4](TypeParkinson-submission.mp4) | Earlier 2:48 illustrated draft, burned planned narration captions and music; [VOICEOVER.md](VOICEOVER.md) and [SRT](TypeParkinson-submission.srt) match this draft only |

The user rejected the long draft's visual finish. The short cuts revise its materials, camera staging, typography/export spacing, keyboard continuity and exercise coverage; the longer exports preserve that earlier draft. They are alternatives, not clips to concatenate. No subjective user approval is claimed. See [REVIEW.md](REVIEW.md) and [VALIDATION.md](VALIDATION.md) for measured checks and limitations.

The default offline player opens the revised 45-second version. Normal live playback uses a 1280px render surface to reduce GPU load; offline export explicitly uses 1920×1080. The capture renderer accumulates four actual shutter-time poses per frame. The 30-second intro is trimmed from the same native 60fps short master; the earlier presenter was retimed scene-by-scene from the 168-second master to save a second full render.

Render examples:

    node tools/render.mjs --width=960 --stills=2,21,44,68 --prefix=review
    node tools/render.mjs --width=960 --fps=15 --output=preview/animatic.mp4
    node tools/render.mjs --width=1920 --fps=60 --samples=4 --output=preview/presenter-picture.mp4
    node tools/render.mjs --cut=submission --audio=score-submission.wav

Reproduce the short recording cuts from this folder:

    npm ci
    npm run build
    node tools/render.mjs --cut=showcase --width=1920 --fps=60 --samples=4 --format=canvas --clean --output=preview/showcase-picture.mp4 --crf=19
    python3 tools/score.py --showcase
    node tools/finalize-shorts.mjs
    node tools/verify-media.mjs

The browser audio export stalled during production. The delivered original score uses the deterministic PCM fallback in `tools/score.py`; WAV/M4A are provided for the long draft. Render intermediates live in ignored `preview/`, and can be reproduced using the tools. The packaged HTML and checked-in final MP4s do not need those intermediates to play.

Space pauses, arrows select chapters, F fullscreen, R reduced motion. Submission/player cut selector shares deterministic poses. __render(t,{samples:4}) accumulates actual shutter-time camera/object poses. Preview paths are ignored in Git; review contact sheets are retained.
