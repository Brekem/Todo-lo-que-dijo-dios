"""Fondo musical original para el modo predicador: pad cósmico en re menor.
Progresión i–VI–III–VII (Dm–B♭–F–C), 8 s por acorde, 64 s en bucle exacto."""
import numpy as np, wave, sys
sr = 32000
L = 64.0
n = int(sr * L)
t = np.arange(n) / sr
rng = np.random.default_rng(7)

def hz(midi): return q(440.0 * 2 ** ((midi - 69) / 12))

def q(f):
    # frecuencia con un número entero de ciclos en 64 s: el bucle empalma
    return round(f * L) / L

def saw(f, phase=0.0):
    # sierra con pocas armónicas (suave, sin aliasing)
    out = np.zeros(n)
    for k in range(1, 9):
        out += np.sin(2 * np.pi * q(f * k) * t + phase * k) / k * (0.85 ** k)
    return out

def lowpass(x, fc, hp=None):
    """Filtro circular en frecuencia (12 dB/oct): el bucle no hace clic."""
    m = len(x)
    f = np.fft.rfftfreq(m, 1 / sr)
    h = 1 / (1 + (f / fc) ** 4) ** 0.5
    if hp:
        h *= 1 / (1 + (hp / np.maximum(f, 1e-6)) ** 4) ** 0.5
    return np.fft.irfft(np.fft.rfft(x) * h, m)

chords = [  # notas MIDI
    [50, 57, 62, 65, 69],   # Dm
    [46, 53, 58, 62, 65],   # B♭
    [41, 53, 57, 60, 65],   # F
    [48, 55, 60, 64, 67],   # C
] * 2
seg = L / len(chords)
pad = np.zeros(n)
for ci, notes in enumerate(chords):
    start = ci * seg
    # envolvente con fundido largo; circular para que el bucle no se corte
    d = (t - start) % L
    env = np.clip(d / 2.5, 0, 1) * np.clip((seg + 2.5 - d) / 2.5, 0, 1)
    env = np.where(d < seg + 2.5, env, 0)
    for m in notes:
        voice = sum(saw(hz(m) * 2 ** (c / 1200), rng.uniform(0, 6)) for c in (-7, 0, 7)) / 3
        pad += voice * env * (0.55 if m < 50 else 0.32)
# el filtro se abre y se cierra lentamente (respira) — con un solo filtro global
pad = lowpass(pad, 1100, hp=70)

drone = 0.25 * np.sin(2 * np.pi * hz(50) * t) + 0.18 * np.sin(2 * np.pi * hz(57) * t)
drone *= 0.8 + 0.2 * np.sin(2 * np.pi * t / L * 2)

# brillo lejano: quintas altas que titilan
shimmer = np.zeros(n)
for m, rate in ((81, 1), (86, 3), (88, 2)):
    shimmer += np.sin(2 * np.pi * hz(m) * t) * (0.5 + 0.5 * np.sin(2 * np.pi * t * rate / L + m)) ** 3
shimmer *= 0.05

# viento cósmico: ruido filtrado que crece y decrece
noise = lowpass(rng.standard_normal(n), 900, hp=200)
noise *= (0.5 + 0.5 * np.sin(2 * np.pi * t * 2 / L)) * 0.6

dry = pad + drone * 0.35 + shimmer + noise * 0.25
# reverberación circular (convolución en el círculo de 64 s → bucle perfecto)
ir_len = int(sr * 3.2)
ir = rng.standard_normal(ir_len) * np.exp(-np.arange(ir_len) / sr / 0.9)
ir = lowpass(ir, 3000, hp=80)
ir /= np.sqrt((ir ** 2).sum())
wet = np.real(np.fft.ifft(np.fft.fft(dry) * np.fft.fft(ir, n)))
mix = lowpass(0.55 * dry + 0.9 * wet, 6000, hp=60)
mix -= mix.mean()
mix /= np.max(np.abs(mix)) * 1.12
pcm = (mix * 32767).astype(np.int16)
with wave.open(sys.argv[1], 'wb') as w:
    w.setnchannels(1); w.setsampwidth(2); w.setframerate(sr); w.writeframes(pcm.tobytes())
print('ok', len(pcm) / sr, 's')
