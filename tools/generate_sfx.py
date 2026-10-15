"""Generate the game's six short, original 44.1 kHz stereo PCM sound effects."""

from pathlib import Path
import math
import wave

import numpy as np


ROOT = Path(__file__).resolve().parents[1] / "sounds"
RATE = 44100


def tone(duration, notes, noise=0.0):
    count = int(RATE * duration)
    t = np.arange(count, dtype=np.float64) / RATE
    sound = np.zeros(count, dtype=np.float64)
    for start, length, frequency, strength in notes:
        local = t - start
        active = (local >= 0) & (local < length)
        phase = 2 * math.pi * frequency * local
        attack = np.minimum(1, np.maximum(0, local) / 0.012)
        release = np.maximum(0, 1 - np.maximum(0, local) / length) ** 2
        sound += np.where(active, np.sin(phase) * attack * release * strength, 0)
    if noise:
        rng = np.random.default_rng(713)
        sound += rng.uniform(-1, 1, count) * noise * np.exp(-t * 25)
    fade = np.minimum(1, t / 0.008) * np.minimum(1, (duration - t) / 0.025)
    sound *= np.maximum(0, fade)
    peak = np.max(np.abs(sound))
    if peak:
        sound *= 0.9 / peak
    return sound


SOUNDS = {
    "snd_shot": (0.38, [(0, .36, 190, 1), (0, .16, 380, .35)], .12),
    "snd_cushion": (0.28, [(0, .26, 540, 1), (0, .20, 810, .45)], .1),
    "snd_payout": (0.68, [(0, .28, 520, 1), (.14, .30, 660, .9), (.29, .37, 880, .8)], .04),
    "snd_foul": (1.0, [], 0),
    "snd_slot_spin": (0.8, [], 0),
    "snd_slot_payout": (1.0, [], 0),
    "snd_risk_wipe": (1.05, [(0, .42, 300, 1), (.20, .48, 180, .95), (.48, .55, 95, .8)], .2),
    "snd_item": (0.54, [(0, .28, 620, 1), (.16, .35, 930, .85)], .03),
}


def foul_slot_loss(duration):
    """A short descending electronic losing cue with a final buzzy thud."""
    t = np.arange(int(RATE * duration), dtype=np.float64) / RATE
    sound = np.zeros_like(t)
    for start, length, frequency in ((0.0, .15, 523.25), (.16, .15, 392.0),
                                     (.32, .32, 261.63)):
        local = t - start
        active = (local >= 0) & (local < length)
        elapsed = np.maximum(local, 0)
        envelope = np.minimum(1, elapsed / .004) * np.minimum(1, np.maximum(0, length - elapsed) / .035)
        # A clipped pulse gives the cue an arcade-machine timbre, without bell resonance.
        phase = 2 * math.pi * frequency * elapsed
        pulse = np.tanh(2.8 * (np.sin(phase) + .24 * np.sin(2 * phase)))
        sound += active * pulse * envelope * (.58 if start < .32 else .72)
    # The last tone drops in pitch, like a failed payout winding down.
    tail = np.maximum(t - .64, 0)
    tail_active = (t >= .64) & (t < 1.0)
    glide = 240 * tail - 115 * tail * tail
    sound += tail_active * .48 * np.tanh(2.2 * np.sin(2 * math.pi * glide)) * np.exp(-tail * 8)
    sound *= np.minimum(1, np.maximum(0, duration - t) / .025)
    return sound * (.92 / np.max(np.abs(sound)))


def slot_spin(duration):
    """A bright repeating reel rhythm for the entire big-score animation."""
    t = np.arange(int(RATE * duration), dtype=np.float64) / RATE
    sound = np.zeros_like(t)
    rng = np.random.default_rng(114)
    # Eight quick reel clicks per loop, pitched upward into a celebratory chord.
    notes = (523.25, 659.25, 783.99, 1046.5, 783.99, 659.25, 987.77, 1174.66)
    for index, frequency in enumerate(notes):
        local = t - index * .1
        active = (local >= 0) & (local < .1)
        elapsed = np.maximum(local, 0)
        envelope = np.minimum(1, elapsed / .003) * np.exp(-elapsed * 22)
        chime = np.sin(2 * math.pi * frequency * elapsed)
        chime += .28 * np.sin(2 * math.pi * frequency * 2 * elapsed)
        click = rng.uniform(-1, 1, len(t)) * np.exp(-elapsed * 110)
        sound += active * (.68 * chime + .2 * click) * envelope
    # Repeating low pulse gives the sequence a spinning machine feel.
    sound += .12 * np.sin(2 * math.pi * 130.81 * t) * np.sin(math.pi * t / duration) ** 2
    sound *= np.minimum(1, t / .004) * np.minimum(1, (duration - t) / .004)
    return sound * (.88 / np.max(np.abs(sound)))


def slot_payout(duration):
    """A jackpot chord followed by a quick cascade of bright coin clinks."""
    t = np.arange(int(RATE * duration), dtype=np.float64) / RATE
    sound = np.zeros_like(t)
    for frequency in (523.25, 659.25, 783.99, 1046.5):
        sound += .17 * np.sin(2 * math.pi * frequency * t) * np.exp(-t * 5.5)
    for index in range(13):
        start = .12 + index * .057
        elapsed = np.maximum(t - start, 0)
        active = t >= start
        frequency = 1300 + (index % 5) * 185
        envelope = np.exp(-elapsed * 31) * np.minimum(1, elapsed / .002)
        sound += active * .27 * envelope * (
            np.sin(2 * math.pi * frequency * elapsed)
            + .34 * np.sin(2 * math.pi * frequency * 2.7 * elapsed)
        )
    sound *= np.minimum(1, t / .004) * np.minimum(1, np.maximum(0, duration - t) / .04)
    return sound * (.9 / np.max(np.abs(sound)))


def main():
    for name, (duration, notes, noise) in SOUNDS.items():
        if name == "snd_foul":
            mono = foul_slot_loss(duration)
        elif name == "snd_slot_spin":
            mono = slot_spin(duration)
        elif name == "snd_slot_payout":
            mono = slot_payout(duration)
        else:
            mono = tone(duration, notes, noise)
        # A standard stereo PCM container also plays reliably in simple Windows players.
        stereo = np.column_stack((mono, mono))
        data = (stereo * 32767).astype("<i2").tobytes()
        path = ROOT / name / f"{name}.wav"
        with wave.open(str(path), "wb") as output:
            output.setnchannels(2)
            output.setsampwidth(2)
            output.setframerate(RATE)
            output.writeframes(data)


if __name__ == "__main__":
    main()
