import numpy as np
import pandas as pd
from pathlib import Path

root = Path("cases/schemeComparison")

cases = {
    "upwind": root / "upwind/postProcessing/sample/0.007/data.xy",
    "linear": root / "linear/postProcessing/sample/0.007/data.xy",
    "Minmod": root / "Minmod/postProcessing/sample/0.007/data.xy",
    "vanLeer": root / "vanLeer/postProcessing/sample/0.007/data.xy",
    "vanAlbada": root / "vanAlbada/postProcessing/sample/0.007/data.xy",
    "SuperBee": root / "SuperBee/postProcessing/sample/0.007/data.xy",
    "atharvaLimiter": root / "atharvaLimiter/postProcessing/sample/0.007/data.xy",
}

out_dir = Path("results/metrics")
out_dir.mkdir(parents=True, exist_ok=True)

rows = []

for name, file_path in cases.items():
    data = np.loadtxt(file_path, comments="#")

    x = data[:, 0]
    T = data[:, 1]
    U = data[:, 2]
    p = data[:, 3]

    dx = np.mean(np.diff(x))

    # Shock region identified using pressure drop near right-moving shock.
    p_left_shock = 30000.0
    p_right_shock = 10000.0

    p_90 = p_right_shock + 0.9 * (p_left_shock - p_right_shock)
    p_10 = p_right_shock + 0.1 * (p_left_shock - p_right_shock)

    shock_mask = (x > 3.0) & (x < 4.3)
    xs = x[shock_mask]
    ps = p[shock_mask]

    try:
        x_90 = xs[np.argmin(np.abs(ps - p_90))]
        x_10 = xs[np.argmin(np.abs(ps - p_10))]
        shock_thickness = abs(x_10 - x_90)
        shock_cells = shock_thickness / dx
    except Exception:
        shock_thickness = np.nan
        shock_cells = np.nan

        # Total variation
    TV_p = np.sum(np.abs(np.diff(p)))
    TV_T = np.sum(np.abs(np.diff(T)))

    # Overshoots relative to expected physical values
    vel_overshoot = np.max(U) - 295.0
    temp_overshoot = np.max(T) - 400.0

    rows.append({
        "Limiter": name,
        "Max pressure [Pa]": np.max(p),
        "Min pressure [Pa]": np.min(p),
        "Max temperature [K]": np.max(T),
        "Max velocity [m/s]": np.max(U),
        "Temp overshoot [K]": temp_overshoot,
        "Velocity overshoot [m/s]": vel_overshoot,
        "TV Pressure": TV_p,
        "TV Temperature": TV_T,
        "Shock thickness [cells]": shock_cells,
    })

df = pd.DataFrame(rows)

csv_path = out_dir / "limiter_metrics.csv"
md_path = out_dir / "limiter_metrics.md"

df.to_csv(csv_path, index=False)
df.to_markdown(md_path, index=False)

print(df)
print(f"\nSaved metrics to:\n{csv_path}\n{md_path}")
