import pandas as pd
import matplotlib.pyplot as plt
from pathlib import Path

df = pd.read_csv(
    "results/metrics/atharva_beta_sweep.csv"
)

outdir = Path("results/figures/betaSweep")
outdir.mkdir(parents=True, exist_ok=True)

beta = df["beta"].to_numpy()
tv = df["TV_pressure"].to_numpy()
temp = df["max_temperature"].to_numpy()

plt.figure(figsize=(7,5))
plt.plot(beta, tv, marker="o")
plt.xlabel("Beta")
plt.ylabel("TV Pressure")
plt.grid(True)
plt.tight_layout()
plt.savefig(outdir/"tv_pressure_vs_beta.png", dpi=300)

plt.figure(figsize=(7,5))
plt.plot(beta, temp, marker="o")
plt.xlabel("Beta")
plt.ylabel("Maximum Temperature [K]")
plt.grid(True)
plt.tight_layout()
plt.savefig(outdir/"temperature_vs_beta.png", dpi=300)

print("Plots saved")
