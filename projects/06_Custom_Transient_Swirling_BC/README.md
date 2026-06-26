# 06. Custom Transient Swirling Boundary Condition in OpenFOAM

A custom OpenFOAM boundary condition developed in C++ to prescribe a transient swirling inlet velocity profile, followed by analytical verification, grid convergence analysis, Richardson extrapolation, and quantitative validation using extracted line data.

---

## Overview

This project demonstrates the development, implementation, and verification of a custom transient swirling velocity boundary condition in OpenFOAM.

Rather than prescribing a static inlet profile through dictionary files, the inlet velocity is computed dynamically during runtime using a user-defined C++ boundary condition. The implementation simultaneously prescribes axial and tangential velocity components representative of swirling inflow conditions commonly encountered in gas turbine combustors, cyclone separators, swirl injectors, and rotating flow devices.

To establish numerical credibility, the implementation is verified against analytical velocity profiles, followed by a systematic three-level grid convergence study using Richardson extrapolation and the Grid Convergence Index (GCI). Instead of relying solely on contour plots, quantitative line data are extracted and compared to evaluate numerical accuracy and solution independence.

---

## Project Objectives

- Develop a custom OpenFOAM boundary condition in C++
- Prescribe analytical swirling inlet velocity during runtime
- Validate the implementation against analytical velocity profiles
- Perform a systematic three-level grid convergence study
- Quantify numerical uncertainty using Richardson Extrapolation and GCI
- Analyze flow development using streamlines and centerline profiles
- Demonstrate CFD verification and validation best practices

---

## Physics and Mathematical Formulation

The inlet velocity consists of two components:

### Axial Velocity

The axial velocity is prescribed as

\[
U_x = U_0
\]

where

- \(U_0 = 1~m/s\)

---

### Tangential Velocity

The tangential velocity varies linearly with radius

\[
U_\theta = \Omega r
\]

where

- \(r\) = radial distance from inlet center
- \(\Omega\) = prescribed angular velocity

The velocity vector applied at every inlet face becomes

\[
\mathbf{U}
=
U_x\mathbf{e_x}
+
U_\theta\mathbf{e_\theta}
\]

The boundary condition computes these values every time step inside the custom C++ class before solving the momentum equations.

---

## Custom Boundary Condition Implementation

The custom boundary condition derives from

```
fixedValueFvPatchVectorField
```

For every face on the inlet patch, the boundary condition performs the following operations:

1. Compute face center coordinates
2. Calculate radial distance from inlet center
3. Determine tangential unit direction
4. Evaluate analytical axial velocity
5. Evaluate analytical tangential velocity
6. Convert cylindrical velocity components into Cartesian coordinates
7. Apply the resulting velocity vector to the boundary faces

This allows arbitrary analytical velocity profiles to be prescribed entirely through C++ without modifying solver source code.

---

## Simulation Setup

| Parameter | Value |
|-----------|-------|
| Solver | pimpleFoam |
| Flow | Incompressible |
| Boundary Condition | Custom C++ |
| Mesh Type | Structured Hexahedral |
| Time Integration | Transient |
| Courant Number | < 0.8 |
| Pressure-Velocity Coupling | PIMPLE |
| Programming Language | C++ |
| Post-processing | ParaView + Python |

---

## Grid Convergence Study

Three progressively refined meshes were simulated to evaluate numerical convergence.

| Mesh | Number of Cells |
|------|----------------:|
| Coarse | 29,600 |
| Medium | 94,500 |
| Fine | 225,600 |

Grid convergence was evaluated using

- Pressure drop
- Centerline pressure
- Centerline axial velocity
- Richardson extrapolation
- Grid Convergence Index (GCI)

---

## Verification Against Analytical Solution

The custom boundary condition was verified by extracting velocity profiles directly from the OpenFOAM solution and comparing them with the prescribed analytical profiles.

### Tangential Velocity Verification

![Swirl Verification](results/figures/verification/swirl_profile_verification.png)

The sampled tangential velocity matches the prescribed analytical profile almost exactly, confirming the correct implementation of the custom C++ boundary condition.

---

### Axial Velocity Verification

![Axial Verification](results/figures/verification/axial_pulsation_verification.png)

The imposed axial inlet velocity is accurately reproduced throughout the inlet section, demonstrating correct boundary condition enforcement.

---

## Grid Sensitivity Analysis

### Pressure Drop Convergence

![Pressure Convergence](results/figures/convergence/grid_convergence_pressure_drop.png)

The pressure drop converges monotonically toward the Richardson extrapolated solution as the mesh is refined.

---

### Centerline Pressure

![Centerline Pressure](results/figures/gridSensitivity/grid_sensitivity_centerline_pressure.png)

The medium and fine meshes produce nearly identical pressure distributions, indicating mesh-independent behavior over most of the computational domain.

---

### Centerline Axial Velocity

![Centerline Velocity](results/figures/gridSensitivity/grid_sensitivity_centerline_Ux.png)

Velocity oscillations near the inlet become less pronounced with mesh refinement while the downstream solution becomes essentially grid independent.

---

### Swirl Velocity Verification Across Meshes

![Swirl Grid](results/figures/verification/grid_sensitivity_inlet_Utheta.png)

All three meshes reproduce the analytical swirl profile with high accuracy, while finer meshes reduce interpolation error near the inlet boundaries.

---

### Axial Velocity Verification Across Meshes

![Axial Grid](results/figures/verification/grid_sensitivity_inlet_Ux.png)

The prescribed axial velocity remains nearly identical across all mesh resolutions.

---

## Richardson Extrapolation and GCI

Grid convergence metrics were computed using the pressure drop as the representative quantity.

| Quantity | Value |
|-----------|-------|
| Observed Order of Accuracy | 4.42 |
| Richardson Extrapolated Pressure Drop | 1.5301 |
| GCI (Medium Grid) | 0.553 % |
| GCI (Fine Grid) | 0.213 % |

The small GCI values indicate that the numerical solution is effectively mesh independent.

---

## Flow Physics

### Streamline Visualization

![Streamlines](results/figures/visualization/streamlines_velocity.png)

The prescribed swirl generates a strong recirculation region immediately downstream of the inlet. As the flow develops through the expanding chamber, vortical structures gradually dissipate while the axial component becomes dominant toward the outlet.

Rather than relying solely on qualitative contour plots, the project emphasizes quantitative verification using extracted line data and systematic grid convergence analysis.

---

## Repository Structure

```
06_Custom_Transient_Swirling_BC
│
├── analysis
│   ├── gridSensitivityAnalysis.py
│   └── verification.py
│
├── boundaryCondition
│   └── swirlingVelocity
│
├── case
│
├── docs
│
├── results
│   ├── data
│   ├── figures
│   │   ├── convergence
│   │   ├── gridSensitivity
│   │   ├── verification
│   │   └── visualization
│   └── logs
│
└── README.md
```

---

## Key Results

| Metric | Result |
|---------|---------|
| Custom OpenFOAM Boundary Condition | ✓ |
| Analytical Verification | ✓ |
| Grid Independence Study | ✓ |
| Richardson Extrapolation | ✓ |
| Grid Convergence Index | ✓ |
| Pressure Drop Convergence | ✓ |
| Automated Python Post-processing | ✓ |

---

## Skills Demonstrated

- OpenFOAM Development
- C++ Boundary Condition Programming
- Finite Volume Method (FVM)
- CFD Verification & Validation
- Grid Independence Studies
- Richardson Extrapolation
- Grid Convergence Index (GCI)
- Scientific Python Automation
- ParaView Visualization
- Numerical Accuracy Assessment
- Engineering Data Analysis

---

## Future Improvements

Potential extensions of this project include:

- Time-dependent swirl intensity
- Helical and vortex-core inlet profiles
- Turbulence model sensitivity (RANS/LES)
- Higher-order discretization scheme comparison
- Swirl number evaluation
- Parallel scaling studies
- Compressible swirling flow applications

---

## Author

**Atharva Gado**

M.S. Engineering Mechanics (Computational Fluid Dynamics)

University of Wisconsin–Madison