"""Genera assets/audio/voz_de_dios.wav: la señal que suena justo antes de que
Dios hable en «Escuchar».

Una campana grave (parciales inarmónicos que se apagan despacio) sobre un
acorde cálido que crece, con un poco de reverberación. Solo usa la biblioteca
estándar: python3 tool/sounds/make_voz_de_dios.py
"""

import math
import os
import random
import struct
import wave

RATE = 44100
SECONDS = 3.2
N = int(RATE * SECONDS)

random.seed(7)
out = [0.0] * N

# Campana: fundamental Sol grave (98 Hz) y parciales típicos de campana.
BELL = [  # (múltiplo, amplitud, segundos hasta apagarse a 1/e)
    (0.5, 0.35, 2.6),  # «hum» por debajo
    (1.0, 0.55, 2.2),
    (1.19, 0.25, 1.6),  # tercera menor de la campana
    (1.5, 0.22, 1.4),
    (2.0, 0.30, 1.2),
    (2.52, 0.14, 0.9),
    (3.01, 0.10, 0.7),
    (4.07, 0.06, 0.5),
]
F0 = 98.0
for mult, amp, tau in BELL:
    f = F0 * mult
    phase = random.random() * 2 * math.pi
    for i in range(N):
        t = i / RATE
        attack = min(1.0, t / 0.008)
        out[i] += amp * attack * math.exp(-t / tau) * math.sin(
            2 * math.pi * f * t + phase
        )

# Acorde cálido (Sol, Re, Sol) que crece y se va: sensación de gloria.
for f, amp in [(196.0, 0.10), (293.66, 0.07), (392.0, 0.05)]:
    for i in range(N):
        t = i / RATE
        env = math.sin(math.pi * min(1.0, t / SECONDS)) ** 2
        vib = 1 + 0.002 * math.sin(2 * math.pi * 4.5 * t)
        out[i] += amp * env * math.sin(2 * math.pi * f * vib * t)

# Reverberación sencilla: cuatro ecos que se realimentan.
for delay_ms, gain in [(53, 0.32), (79, 0.28), (113, 0.24), (151, 0.2)]:
    d = int(RATE * delay_ms / 1000)
    for i in range(d, N):
        out[i] += gain * out[i - d]

# Salida suave y normalizada.
fade = int(RATE * 0.6)
for i in range(fade):
    out[N - fade + i] *= 1 - i / fade
peak = max(abs(s) for s in out)
out = [s / peak * 0.85 for s in out]

path = os.path.join(
    os.path.dirname(__file__), '..', '..', 'assets', 'audio', 'voz_de_dios.wav'
)
os.makedirs(os.path.dirname(path), exist_ok=True)
with wave.open(path, 'wb') as w:
    w.setnchannels(1)
    w.setsampwidth(2)
    w.setframerate(RATE)
    w.writeframes(b''.join(struct.pack('<h', int(s * 32767)) for s in out))
print(os.path.normpath(path), os.path.getsize(path) // 1024, 'KB')
