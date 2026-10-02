"""Verify every final social export with the installed FFmpeg tools."""
import json
import pathlib
import re
import subprocess

root = pathlib.Path(__file__).resolve().parent
source = (root / "render.swift").read_text()
assert not re.search(r"[\u0400-\u04ff]", source), "Non-English Cyrillic copy in exporter"
assert 'text("Original orbs' not in source, "Removed caption returned"
results = []
for name in ("noir", "editorial", "pulse"):
    path = root / f"thinking-orbs-{name}.mp4"
    probe = json.loads(subprocess.check_output([
        "ffprobe", "-v", "error", "-show_streams", "-show_format", "-of", "json", str(path)
    ]))
    video = next(s for s in probe["streams"] if s["codec_type"] == "video")
    audio = next(s for s in probe["streams"] if s["codec_type"] == "audio")
    assert (video["width"], video["height"], video["r_frame_rate"], video["pix_fmt"],
            video["codec_name"], int(video["nb_frames"])) == (1080, 1920, "30/1", "yuv420p", "h264", 540)
    assert abs(float(probe["format"]["duration"]) - 18) < 0.05
    assert audio["codec_name"] == "aac" and audio["channels"] == 2
    decoded = subprocess.run(["ffmpeg", "-v", "error", "-i", str(path), "-f", "null", "-"],
                             capture_output=True, text=True, check=True)
    assert not decoded.stderr.strip(), decoded.stderr
    volume = subprocess.run([
        "ffmpeg", "-hide_banner", "-i", str(path), "-af", "volumedetect", "-vn", "-f", "null", "-"
    ], capture_output=True, text=True, check=True)
    peak = float(re.search(r"max_volume: ([-\d.]+) dB", volume.stderr).group(1))
    assert -30 < peak < 0, f"Unexpected audio peak: {peak}"
    results.append({"file": path.name, "resolution": "1080x1920", "fps": 30,
                    "frames": 540, "seconds": 18, "video": "H.264 / yuv420p",
                    "audio": "AAC stereo", "audio_peak_dbfs": peak,
                    "bytes": path.stat().st_size, "full_decode": "passed"})
(root / "verification.json").write_text(json.dumps(results, indent=2) + "\n")
print(json.dumps(results, indent=2))
