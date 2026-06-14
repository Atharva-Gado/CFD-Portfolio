# Project 04: 1D Compressible Euler Solver

## Overview

This project develops a 1D compressible Euler solver from scratch in MATLAB to study numerical methods for shock-dominated flows.

The solver is tested on the classical Sod shock tube problem and serves as a foundation for understanding finite-volume methods, shock-capturing schemes, and compressible CFD solver development.

---

## What Was Implemented

* Primitive ↔ Conserved variable conversion
* Euler flux computation
* CFL-based adaptive time stepping
* Flux-gradient evaluation
* Explicit Euler update (diagnostic)
* MacCormack predictor-corrector scheme
* Artificial viscosity stabilization
* Rusanov (Local Lax-Friedrichs) flux solver

---

## Test Case: Sod Shock Tube

Initial conditions:

| Region | Density | Velocity | Pressure |
| ------ | ------- | -------- | -------- |
| Left   | 1.0     | 0.0      | 1.0      |
| Right  | 0.125   | 0.0      | 0.1      |

---

## Key Findings

The raw MacCormack scheme produced oscillations near the shock discontinuity, including nonphysical pressure and density behavior.

Adding artificial viscosity stabilized the solution but increased numerical diffusion.

The Rusanov solver provided a more robust shock-capturing formulation using interface fluxes and characteristic wave speeds.

---

## Results

### Sod Shock Tube Initial Condition

![Initial Condition](results/figures/sod_initial_condition.png)

### One-Step Euler Diagnostic

![One-Step Euler](results/figures/sod_one_step_euler.png)

### Stabilized MacCormack Solution

![MacCormack](results/figures/sod_maccormack_t005.png)

### MacCormack vs Rusanov

![Comparison](results/figures/sod_maccormack_vs_rusanov.png)

---

## Next Steps

* Validation against the exact Sod solution
* Error norm evaluation
* Roe flux implementation
* Grid convergence study
* Quasi-1D nozzle flow solver
