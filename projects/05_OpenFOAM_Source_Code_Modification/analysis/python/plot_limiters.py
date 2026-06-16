import numpy as np
import matplotlib.pyplot as plt
from pathlib import Path

r = np.linspace(0, 4, 1000)

# Upwind
phi_upwind = np.zeros_like(r)

# Linear
phi_linear = np.ones_like(r)

# Minmod
phi_minmod = np.minimum(r, 1.0)

# Van Leer
phi_vanleer = (r + np.abs(r)) / (1 + np.abs(r))

# Van Albada
phi_vanalbada = r*(r + 1)/(r**2 + 1)

# Superbee
phi_superbee = np.maximum(
    np.minimum(2*r, 1),
    np.minimum(r, 2)
)

out_dir = Path("results/figures/limiters")
out_dir.mkdir(parents=True, exist_ok=True)

plt.figure(figsize=(8,6))

plt.plot(r, phi_upwind, label="Upwind")
plt.plot(r, phi_linear, label="Linear")
plt.plot(r, phi_minmod, label="Minmod")
plt.plot(r, phi_vanleer, label="Van Leer")
plt.plot(r, phi_vanalbada, label="Van Albada", linewidth=3)
plt.plot(r, phi_superbee, label="Superbee")

plt.xlabel("r")
plt.ylabel("Limiter φ(r)")
plt.title("Flux Limiter Comparison")
plt.grid(True)
plt.legend()

plt.tight_layout()
plt.savefig(out_dir / "limiter_comparison.png", dpi=300)

print("Saved limiter comparison figure")
