import numpy as np
import matplotlib.pyplot as plt
from pathlib import Path

case_dir = Path("cases/sodShockTube")
data_file = case_dir / "postProcessing/sample/0.007/data.xy"

data = np.loadtxt(data_file, comments="#")

x = data[:, 0]
T = data[:, 1]
U = data[:, 2]
p = data[:, 3]

out_dir = Path("results/figures")
out_dir.mkdir(parents=True, exist_ok=True)

def make_plot(y, ylabel, title, filename):
    plt.figure(figsize=(7, 4.5))
    plt.plot(x, y, linewidth=2)
    plt.xlabel("x")
    plt.ylabel(ylabel)
    plt.title(title)
    plt.grid(True)
    plt.tight_layout()
    plt.savefig(out_dir / filename, dpi=300)
    plt.close()

make_plot(p, "Pressure, p [Pa]", "Shock Tube Pressure at t = 0.007 s", "shocktube_pressure.png")
make_plot(T, "Temperature, T [K]", "Shock Tube Temperature at t = 0.007 s", "shocktube_temperature.png")
make_plot(U, "Velocity magnitude, |U| [m/s]", "Shock Tube Velocity at t = 0.007 s", "shocktube_velocity.png")

print("Saved clean plots to results/figures/")

