import numpy as np
import matplotlib.pyplot as plt
from pathlib import Path

# -----------------------------
# User-defined BC parameters
# -----------------------------
U0 = 1.0
A = 0.2
f = 5.0
omega = 20.0
R = 0.05

project_dir = Path(__file__).resolve().parents[1]
case_dir = project_dir / "case" / "swirlChamber"
fig_dir = project_dir / "results" / "figures"
data_dir = project_dir / "results" / "data"

fig_dir.mkdir(parents=True, exist_ok=True)
data_dir.mkdir(parents=True, exist_ok=True)

sample_root = case_dir / "postProcessing" / "inletLineY"

times = sorted(
    [float(p.name) for p in sample_root.iterdir() if p.is_dir()]
)

center_Ux = []
analytical_Ux = []

for t in times:
    file_path = sample_root / f"{t:g}" / "inletLineY.xy"

    if not file_path.exists():
        file_path = sample_root / str(t) / "inletLineY.xy"

    data = np.loadtxt(file_path, comments="#")

    distance = data[:, 0]
    Ux = data[:, 1]

    center_index = np.argmin(np.abs(distance - R))

    center_Ux.append(Ux[center_index])
    analytical_Ux.append(U0 + A * np.sin(2 * np.pi * f * t))

center_Ux = np.array(center_Ux)
analytical_Ux = np.array(analytical_Ux)

# -----------------------------
# Plot 1: Axial pulsation
# -----------------------------
plt.figure(figsize=(7, 4.5))
plt.plot(times, analytical_Ux, "k--", linewidth=2, label="Analytical")
plt.plot(times, center_Ux, "o", markersize=5, label="OpenFOAM sampled")
plt.xlabel("Time [s]")
plt.ylabel("Centerline axial velocity Ux [m/s]")
plt.title("Verification of Axial Pulsating Velocity")
plt.grid(True, alpha=0.3)
plt.legend()
plt.tight_layout()
plt.savefig(fig_dir / "axial_pulsation_verification.png", dpi=300)

# -----------------------------
# Plot 2: Swirl profile at latest time
# -----------------------------
latest_time = times[-1]
file_path = sample_root / f"{latest_time:g}" / "inletLineY.xy"

if not file_path.exists():
    file_path = sample_root / str(latest_time) / "inletLineY.xy"

data = np.loadtxt(file_path, comments="#")

distance = data[:, 0]
Ux = data[:, 1]
Uy = data[:, 2]
Uz = data[:, 3]

# Convert distance along inlet line into signed radial coordinate.
# The sampling line goes from y = -R to y = +R.
r_signed = distance - R

# For axis along x, sampling along y at z = 0 gives tangential velocity mainly in z.
# Sign depends on cross-product convention.
Utheta_sampled = Uz
Utheta_analytical = omega * r_signed

# Avoid wall/interpolation points at exact boundaries for cleaner verification
mask = np.abs(r_signed) < 0.045

plt.figure(figsize=(7, 4.5))
plt.plot(r_signed[mask], Utheta_analytical[mask], "k--", linewidth=2, label="Analytical")
plt.plot(r_signed[mask], Utheta_sampled[mask], "o", markersize=5, label="OpenFOAM sampled")
plt.xlabel("Signed radial coordinate r [m]")
plt.ylabel("Tangential velocity Uθ [m/s]")
plt.title(f"Verification of Swirl Velocity Profile at t = {latest_time:.3f} s")
plt.grid(True, alpha=0.3)
plt.legend()
plt.tight_layout()
plt.savefig(fig_dir / "swirl_profile_verification.png", dpi=300)

# -----------------------------
# Save quantitative error metrics
# -----------------------------
axial_error = np.abs(center_Ux - analytical_Ux)
swirl_error = np.abs(Utheta_sampled[mask] - Utheta_analytical[mask])

with open(data_dir / "verification_metrics.txt", "w") as f_out:
    f_out.write("Custom transient swirling inlet BC verification\n")
    f_out.write("------------------------------------------------\n\n")
    f_out.write(f"Number of sampled times: {len(times)}\n")
    f_out.write(f"Maximum axial velocity error: {axial_error.max():.6e}\n")
    f_out.write(f"Mean axial velocity error: {axial_error.mean():.6e}\n")
    f_out.write(f"Maximum swirl velocity error: {swirl_error.max():.6e}\n")
    f_out.write(f"Mean swirl velocity error: {swirl_error.mean():.6e}\n")

print("Verification complete.")
print(f"Saved: {fig_dir / 'axial_pulsation_verification.png'}")
print(f"Saved: {fig_dir / 'swirl_profile_verification.png'}")
print(f"Saved: {data_dir / 'verification_metrics.txt'}")