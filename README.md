# CFD Portfolio

A collection of computational fluid dynamics projects built around a simple question: *what is happening inside the solver?*

The portfolio follows a progression from implementing numerical methods and validating discretization schemes to reproducing benchmark flows in OpenFOAM and investigating the physics behind the results. Rather than treating CFD as a black box, each project emphasizes understanding the governing equations, numerical algorithms, verification & validation, and the connection between simulation outputs and flow physics.


## Technical Areas

* CFD Solver Development
* Numerical Methods
* Finite Difference & Finite Volume Methods
* OpenFOAM
* Verification & Validation
* Python & MATLAB Automation
* Scientific Computing
* High-Performance Computing (HPC)
* Turbulence & Compressible Flows

---
## Projects

### 01. Lid-Driven Cavity Solver

A 2D incompressible Navier–Stokes solver developed from scratch using a staggered-grid finite difference formulation, pressure Poisson equation, and SOR-based pressure solution.

**Key Skills:** Numerical Methods, Pressure-Velocity Coupling, CFD Verification, Solver Development

---

### 02. Numerical Scheme Comparison

Comparison of central differencing and donor-cell schemes for the lid-driven cavity benchmark, including validation against Ghia et al. data and quantitative error analysis.

**Key Skills:** Discretization Schemes, Numerical Diffusion Analysis, Verification & Validation

---

### 03. Schäfer–Turek Cylinder Benchmark (OpenFOAM)

An OpenFOAM validation study of the classical Schäfer–Turek 2D-2 benchmark featuring vortex shedding analysis, force coefficient extraction, FFT-based frequency analysis, and comparison against published benchmark data.

**Key Skills:** OpenFOAM, Transient CFD, Vortex Shedding, FFT Analysis, Verification & Validation

---

### 04. Compressible Euler Solver

A 1D compressible Euler solver developed from scratch in MATLAB to investigate shock-capturing methods using the Sod shock tube problem. The project compares MacCormack and Rusanov schemes, examines numerical stability and diffusion, and includes grid convergence verification.

**Key Skills:** Compressible Flow, Finite Volume Methods, Shock Capturing, Numerical Stability, Solver Development, Grid Verification

---

## Featured Results

### Vortex Shedding Behind a Circular Cylinder

![Vortex Shedding](projects/03_OpenFOAM_Schaefer_Turek_2D2_Benchmark/results/animations/vortex_shedding_animation.avi)

### Grid Convergence Study – Compressible Euler Solver

![Grid Convergence](projects/04_Compressible_Euler_Solver/results/figures/rusanov_grid_convergence.png)

---

## Purpose of This Portfolio

This repository documents my transition from industrial CFD applications toward deeper work in numerical methods, solver development, scientific computing, and open-source CFD workflows.

Each project is designed to emphasize:

* Understanding of governing equations
* Numerical implementation
* Verification and validation
* Reproducible computational workflows

---

## About Me

Atharva Gado

M.S. Engineering Mechanics (Aerospace)
University of Wisconsin–Madison

I enjoy building CFD tools almost as much as running them. My background spans industrial CFD, turbomachinery, aerodynamics, and propulsion, but these days I spend a growing amount of time wondering what is happening inside the solver rather than just looking at contours.

Interests include numerical methods, solver development, OpenFOAM, high-performance computing, turbulence, and compressible flows.
