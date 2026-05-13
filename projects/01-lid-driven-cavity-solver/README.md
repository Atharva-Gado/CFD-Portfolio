# 2D Lid-Driven Cavity Solver

This project implements a two-dimensional incompressible Navier–Stokes solver for the lid-driven cavity benchmark problem.

The solver is developed using a finite-difference formulation on a staggered grid. Pressure–velocity coupling is handled using a predictor–corrector method with a Pressure Poisson Equation solved using Successive Over-Relaxation.

## Key Features

- 2D incompressible Navier–Stokes equations
- Staggered grid arrangement
- Explicit convection–diffusion predictor step
- Pressure Poisson Equation for incompressibility
- SOR-based pressure solver
- Lid-driven cavity benchmark at Re = 100
- Validation against Ghia et al. benchmark data

## Repository Structure

```text
01-lid-driven-cavity-solver/
├── src/
│   └── lid_driven_cavity_solver.m
├── docs/
│   └── lid_driven_cavity_report.pdf
├── figures/
├── results/
└── README.md