import numpy as np
import matplotlib.pyplot as plt
from pathlib import Path

# -----------------------------
# BC parameters
# -----------------------------
U0 = 1.0
A = 0.2
f = 5.0
omega = 20.0
R = 0.025
latest_time = 1.2

project_dir = Path(__file__).resolve().parents[1]
case_root = project_dir / "case" / "gridStudy"
fig_dir = project_dir / "results" / "figures"
data_dir = project_dir / "results" / "data"

fig_dir.mkdir(parents=True, exist_ok=True)
data_dir.mkdir(parents=True, exist_ok=True)

meshes = {
    "coarse": {"cells": 14*20*20 + 42*20*20 + 18*20*20},
    "medium": {"cells": 20*30*30 + 60*30*30 + 25*30*30},
    "fine": {"cells": 27*40*40 + 80*40*40 + 34*40*40},
}

def read_xy(path):
    return np.loadtxt(path, comments="#")

def latest_folder(case_dir):
    folders = [p for p in case_dir.iterdir() if p.is_dir()]
    times = []
    for p in folders:
        try:
            times.append((float(p.name), p))
        except ValueError:
            pass
    return sorted(times)[-1][1]

summary = []

# -----------------------------
# Inlet verification plots
# -----------------------------
plt.figure(figsize=(7, 4.5))

for name in meshes:
    case_dir = case_root / name / "postProcessing" / "inletLineY"
    tdir = latest_folder(case_dir)
    data = read_xy(tdir / "inletLineY.xy")

    distance = data[:, 0]
    Ux = data[:, 1]

    r_signed = distance - R
    Ux_analytic = U0 + A*np.sin(2*np.pi*f*latest_time)

    l2 = np.sqrt(np.mean((Ux - Ux_analytic)**2))
    linf = np.max(np.abs(Ux - Ux_analytic))

    meshes[name]["Ux_L2"] = l2
    meshes[name]["Ux_Linf"] = linf

    plt.plot(r_signed, Ux, marker="o", markersize=3, linewidth=1.2, label=f"{name}")

plt.axhline(U0 + A*np.sin(2*np.pi*f*latest_time), linestyle="--", linewidth=2, label="Analytical")
plt.xlabel("Signed radial coordinate r [m]")
plt.ylabel("Axial velocity Ux [m/s]")
plt.title("Grid Sensitivity of Axial Inlet Velocity")
plt.grid(True, alpha=0.3)
plt.legend()
plt.tight_layout()
plt.savefig(fig_dir / "grid_sensitivity_inlet_Ux.png", dpi=300)

plt.figure(figsize=(7, 4.5))

for name in meshes:
    case_dir = case_root / name / "postProcessing" / "inletLineY"
    tdir = latest_folder(case_dir)
    data = read_xy(tdir / "inletLineY.xy")

    distance = data[:, 0]
    Uz = data[:, 3]

    r_signed = distance - R
    Utheta = Uz
    Utheta_analytic = omega*r_signed

    l2 = np.sqrt(np.mean((Utheta - Utheta_analytic)**2))
    linf = np.max(np.abs(Utheta - Utheta_analytic))

    meshes[name]["Utheta_L2"] = l2
    meshes[name]["Utheta_Linf"] = linf

    plt.plot(r_signed, Utheta, marker="o", markersize=3, linewidth=1.2, label=f"{name}")

r_plot = np.linspace(-R, R, 200)
plt.plot(r_plot, omega*r_plot, linestyle="--", linewidth=2, label="Analytical")
plt.xlabel("Signed radial coordinate r [m]")
plt.ylabel("Tangential velocity Uθ [m/s]")
plt.title("Grid Sensitivity of Swirl Inlet Velocity")
plt.grid(True, alpha=0.3)
plt.legend()
plt.tight_layout()
plt.savefig(fig_dir / "grid_sensitivity_inlet_Utheta.png", dpi=300)

# -----------------------------
# Centerline solution comparison
# -----------------------------
plt.figure(figsize=(7, 4.5))

for name in meshes:
    case_dir = case_root / name / "postProcessing" / "inletLineY"
    tdir = latest_folder(case_dir)
    data = read_xy(tdir / "centerLineX.xy")

    x = data[:, 0] - 0.12
    Ux = data[:, 1]

    plt.plot(x, Ux, linewidth=1.8, label=f"{name}")

plt.xlabel("x-location [m]")
plt.ylabel("Centerline axial velocity Ux [m/s]")
plt.title("Grid Sensitivity of Centerline Axial Velocity")
plt.grid(True, alpha=0.3)
plt.legend()
plt.tight_layout()
plt.savefig(fig_dir / "grid_sensitivity_centerline_Ux.png", dpi=300)

plt.figure(figsize=(7, 4.5))

pressure_drop = {}

for name in meshes:
    case_dir = case_root / name / "postProcessing" / "inletLineY"
    tdir = latest_folder(case_dir)
    data = read_xy(tdir / "centerLineX.xy")

    x = data[:, 0] - 0.12
    p = data[:, 4]

    pressure_drop[name] = p[0] - p[-1]

    plt.plot(x, p, linewidth=1.8, label=f"{name}")

plt.xlabel("x-location [m]")
plt.ylabel("Pressure p [m²/s²]")
plt.title("Grid Sensitivity of Centerline Pressure")
plt.grid(True, alpha=0.3)
plt.legend()
plt.tight_layout()
plt.savefig(fig_dir / "grid_sensitivity_centerline_pressure.png", dpi=300)

# -----------------------------
# Summary table
# -----------------------------
summary_path = data_dir / "grid_sensitivity_summary.csv"

with open(summary_path, "w") as f_out:
    f_out.write("mesh,cells,Ux_L2,Ux_Linf,Utheta_L2,Utheta_Linf,pressure_drop\n")
    for name, vals in meshes.items():
        f_out.write(
            f"{name},{vals['cells']},"
            f"{vals['Ux_L2']:.8e},{vals['Ux_Linf']:.8e},"
            f"{vals['Utheta_L2']:.8e},{vals['Utheta_Linf']:.8e},"
            f"{pressure_drop[name]:.8e}\n"
        )

# -----------------------------
# Grid convergence metrics for pressure drop
# -----------------------------
phi1 = pressure_drop["coarse"]
phi2 = pressure_drop["medium"]
phi3 = pressure_drop["fine"]

N1 = meshes["coarse"]["cells"]
N2 = meshes["medium"]["cells"]
N3 = meshes["fine"]["cells"]

# Effective grid refinement ratios for 3D meshes
r21 = (N2 / N1) ** (1/3)
r32 = (N3 / N2) ** (1/3)

e21 = phi2 - phi1
e32 = phi3 - phi2

# Approximate observed order
p_obs = np.log(abs(e21 / e32)) / np.log((r21 + r32) / 2)

# Richardson extrapolation using medium and fine
phi_ext = phi3 + (phi3 - phi2) / (r32**p_obs - 1)

# Grid Convergence Index
Fs = 1.25
GCI_fine = Fs * abs((phi3 - phi2) / phi3) / (r32**p_obs - 1) * 100
GCI_medium = Fs * abs((phi2 - phi1) / phi2) / (r21**p_obs - 1) * 100

with open(data_dir / "grid_convergence_metrics.txt", "w") as f_out:
    f_out.write("Grid convergence metrics based on pressure drop\n")
    f_out.write("------------------------------------------------\n\n")
    f_out.write(f"Coarse pressure drop: {phi1:.8e}\n")
    f_out.write(f"Medium pressure drop: {phi2:.8e}\n")
    f_out.write(f"Fine pressure drop:   {phi3:.8e}\n\n")
    f_out.write(f"r21: {r21:.6f}\n")
    f_out.write(f"r32: {r32:.6f}\n")
    f_out.write(f"Observed order p: {p_obs:.6f}\n")
    f_out.write(f"Richardson extrapolated pressure drop: {phi_ext:.8e}\n")
    f_out.write(f"GCI medium-grid: {GCI_medium:.6f} %\n")
    f_out.write(f"GCI fine-grid:   {GCI_fine:.6f} %\n")
# -----------------------------
# Plot pressure-drop convergence
# -----------------------------
cell_counts = np.array([N1, N2, N3])
dp_values = np.array([phi1, phi2, phi3])

plt.figure(figsize=(7, 4.5))
plt.plot(cell_counts, dp_values, "o-", linewidth=2, markersize=7, label="Computed")
plt.axhline(phi_ext, linestyle="--", linewidth=2, label="Richardson extrapolated")

plt.xscale("log")
plt.xlabel("Number of cells")
plt.ylabel("Pressure drop Δp [m²/s²]")
plt.title("Grid Convergence of Pressure Drop")
plt.grid(True, which="both", alpha=0.3)
plt.legend()
plt.tight_layout()
plt.savefig(fig_dir / "grid_convergence_pressure_drop.png", dpi=300)

print("Grid sensitivity analysis complete.")
print(f"Saved figures to: {fig_dir}")
print(f"Saved summary to: {summary_path}")