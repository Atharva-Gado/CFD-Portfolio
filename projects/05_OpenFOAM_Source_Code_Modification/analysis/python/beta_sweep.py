import subprocess
import re
from pathlib import Path
import numpy as np
import pandas as pd

project = Path.cwd()
limiter_file = project / "customSchemes/atharvaLimiter/atharvaLimiter.H"
limiter_dir = project / "customSchemes/atharvaLimiter"
case_dir = project / "cases/schemeComparison/atharvaLimiter"

betas = [0.5, 1.0, 1.5, 2.0, 3.0, 5.0]

rows = []

def run(cmd, cwd=None):
    print(f"\nRunning: {cmd}")
    subprocess.run(cmd, cwd=cwd, shell=True, check=True)

def set_beta(beta):
    text = limiter_file.read_text()
    text_new = re.sub(
        r"const scalar beta = [0-9.]+;",
        f"const scalar beta = {beta};",
        text
    )
    limiter_file.write_text(text_new)

def compute_metrics(beta):
    data_file = case_dir / "postProcessing/sample/0.007/data.xy"
    data = np.loadtxt(data_file, comments="#")

    x = data[:, 0]
    T = data[:, 1]
    U = data[:, 2]
    p = data[:, 3]

    dx = np.mean(np.diff(x))

    # Shock thickness based on pressure transition from 90% to 10%
    p_left_shock = 30000.0
    p_right_shock = 10000.0

    p_90 = p_right_shock + 0.9 * (p_left_shock - p_right_shock)
    p_10 = p_right_shock + 0.1 * (p_left_shock - p_right_shock)

    shock_mask = (x > 3.0) & (x < 4.3)
    xs = x[shock_mask]
    ps = p[shock_mask]

    x_90 = xs[np.argmin(np.abs(ps - p_90))]
    x_10 = xs[np.argmin(np.abs(ps - p_10))]

    shock_thickness = abs(x_10 - x_90)
    shock_cells = shock_thickness / dx

    TV_p = np.sum(np.abs(np.diff(p)))
    TV_T = np.sum(np.abs(np.diff(T)))

    return {
        "beta": beta,
        "max_pressure": np.max(p),
        "min_pressure": np.min(p),
        "max_temperature": np.max(T),
        "max_velocity": np.max(U),
        "TV_pressure": TV_p,
        "TV_temperature": TV_T,
        "shock_thickness_cells": shock_cells,
    }

for beta in betas:
    print(f"\n==============================")
    print(f"Running beta = {beta}")
    print(f"==============================")

    set_beta(beta)

    run("wmake libso", cwd=limiter_dir)
    run("./Allclean", cwd=case_dir)
    run("./Allrun", cwd=case_dir)

    rows.append(compute_metrics(beta))

out_dir = project / "results/metrics"
out_dir.mkdir(parents=True, exist_ok=True)

df = pd.DataFrame(rows)
df.to_csv(out_dir / "atharva_beta_sweep.csv", index=False)
df.to_markdown(out_dir / "atharva_beta_sweep.md", index=False)

print("\nBeta sweep results:")
print(df)
print(f"\nSaved to {out_dir}")
