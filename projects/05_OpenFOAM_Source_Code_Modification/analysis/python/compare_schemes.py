import numpy as np
import matplotlib.pyplot as plt
from pathlib import Path

root = Path("cases/schemeComparison")
cases = {
    "vanAlbada": root / "vanAlbada/postProcessing/sample/0.007/data.xy",
    "upwind": root / "upwind/postProcessing/sample/0.007/data.xy",
    "linear": root / "linear/postProcessing/sample/0.007/data.xy",
}

out_dir = Path("results/figures/schemeComparison")
out_dir.mkdir(parents=True, exist_ok=True)

fields = {
    "T": (1, "Temperature, T [K]", "scheme_comparison_temperature.png"),
    "U": (2, "Velocity magnitude, |U| [m/s]", "scheme_comparison_velocity.png"),
    "p": (3, "Pressure, p [Pa]", "scheme_comparison_pressure.png"),
}

for field_name, (col, ylabel, filename) in fields.items():
    plt.figure(figsize=(8, 5))

    for case_name, file_path in cases.items():
        data = np.loadtxt(file_path, comments="#")
        x = data[:, 0]
        y = data[:, col]
        plt.plot(x, y, linewidth=2, label=case_name)

    plt.xlabel("x")
    plt.ylabel(ylabel)
    plt.title(f"{field_name} comparison at t = 0.007 s")
    plt.grid(True)
    plt.legend()
    plt.tight_layout()
    plt.savefig(out_dir / filename, dpi=300)
    plt.close()

print("Saved scheme comparison plots to results/figures/schemeComparison/")
