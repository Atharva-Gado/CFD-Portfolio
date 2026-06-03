import numpy as np
import matplotlib.pyplot as plt

file = "case/runs/run_003_medium_mesh_validation/postProcessing/forceCoeffs/0/forceCoeffs.dat"

data = np.loadtxt(file, comments="#")

t  = data[:, 0]
Cd = data[:, 2]
Cl = data[:, 3]

mask = t > 4.0
t_dev = t[mask]
Cd_dev = Cd[mask]
Cl_dev = Cl[mask]

Cl_fluc = Cl_dev - np.mean(Cl_dev)

dt = np.mean(np.diff(t_dev))
freq = np.fft.rfftfreq(len(Cl_fluc), d=dt)
amp = np.abs(np.fft.rfft(Cl_fluc))

freq_nonzero = freq[1:]
amp_nonzero = amp[1:]

f_shed = freq_nonzero[np.argmax(amp_nonzero)]

D = 0.1
Umean = 1.0
St = D * f_shed / Umean

print("\n===== Force Coefficient Summary: Run 003 =====")
print(f"Cd mean   = {np.mean(Cd_dev):.5f}")
print(f"Cd max    = {np.max(Cd_dev):.5f}")
print(f"Cd min    = {np.min(Cd_dev):.5f}")
print(f"Cl max    = {np.max(Cl_dev):.5f}")
print(f"Cl min    = {np.min(Cl_dev):.5f}")
print(f"f_shed    = {f_shed:.5f} Hz")
print(f"Strouhal  = {St:.5f}")

plt.figure(figsize=(9,5))
plt.plot(t, Cd, lw=1.5)
plt.xlabel("Time [s]")
plt.ylabel("Cd")
plt.title("Drag Coefficient History - Run 003")
plt.grid(True)
plt.tight_layout()
plt.savefig("figures/run003_cd_history.png", dpi=300)

plt.figure(figsize=(9,5))
plt.plot(t, Cl, lw=1.5)
plt.xlabel("Time [s]")
plt.ylabel("Cl")
plt.title("Lift Coefficient History - Run 003")
plt.grid(True)
plt.tight_layout()
plt.savefig("figures/run003_cl_history.png", dpi=300)

plt.figure(figsize=(9,5))
plt.plot(freq_nonzero, amp_nonzero, lw=1.5)
plt.xlabel("Frequency [Hz]")
plt.ylabel("FFT Amplitude")
plt.title("Lift Coefficient Frequency Spectrum - Run 003")
plt.xlim(0, 10)
plt.grid(True)
plt.tight_layout()
plt.savefig("figures/run003_cl_fft.png", dpi=300)

plt.show()
