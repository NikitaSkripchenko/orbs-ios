# ThinkingOrbsKit — social videos

Three vertical videos: **1080×1920, 9:16, 18 seconds, 30 fps**, H.264 + AAC stereo.

- `thinking-orbs-noir.mp4`: dark, sculptural particles; curved particle transitions, gentle camera movement; 80 BPM.
- `thinking-orbs-editorial.mp4`: warm paper background and geometric forms; smooth particle transformations; 100 BPM.
- `thinking-orbs-pulse.mp4`: faster state changes, fluid light/dark transitions and a two-orb composition; 120 BPM.

All on-screen copy is English: the project name, “9 states”, and the repository URL. The attribution caption was removed from the videos at the user's request. All nine states appear in every video.

The compositions use the existing Swift engines at `.points64`, enlarged for video. Animation speed is 1.15× for Noir/Editorial and 1.30× for Pulse. Transitions interpolate screen-space particles along curved paths over 0.72 or 0.48 seconds, with opacity compensation when particle counts differ. These are promotional compositions, not app screen recordings or additional public API features. Package sources and the iOS-only renderer remain unchanged.

Audio is locally synthesized without third-party samples. Music is embedded in each MP4; separate WAV files and PNG covers are included.

Original animation design and engine mathematics: © 2026 Jakub Antalik, MIT. See the repository `LICENSE` and `Upstream/UPSTREAM.md`. License, source provenance, pinned upstream files, and README attribution are preserved.

## Rebuild and verify

Export-only requirements: macOS, Swift/Xcode, and FFmpeg at `/opt/homebrew/bin/ffmpeg`. No package dependencies are added.

Run from the repository root:

```sh
bash media/social/render.sh --check    # Transition endpoints, opacity, counts and cut boundaries
bash media/social/render.sh            # Three MP4s, WAVs and covers
bash media/social/render.sh --preview  # Five sample frames per variant
python3 media/social/verify.py         # Format, frame count, full decode, audio and English-only copy
```

`storyboard.jpg` contains frames from the final MP4s at 1.5, 3.3, 6.3, 9.3 and 16 seconds; rows: Noir, Editorial, Pulse. Intermediate transition frames intentionally show particles travelling between forms.
