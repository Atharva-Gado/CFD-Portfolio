# Governing Equations

## Introduction

This project develops a one-dimensional compressible flow solver based on the Euler equations. The objective is to understand the numerical methods used to simulate compressible flows containing shocks, expansion waves, and contact discontinuities.

The solver is implemented using a finite-volume formulation and validated against canonical benchmark problems including Sod's shock tube and quasi-one-dimensional nozzle flow.

---

## Euler Equations

The one-dimensional Euler equations describe conservation of mass, momentum, and energy for an inviscid compressible fluid.

Conservative form:

dU/dt + dF/dx = 0

---

## Conserved Variables

U =

[ rho
  rho*u
  E ]

where:

rho = density

u = velocity

E = total energy per unit volume

---

## Flux Vector

F =

[ rho*u
  rho*u^2 + p
  u*(E+p) ]

where:

p = pressure

---

## Total Energy

The total energy is given by:

E = p/(gamma-1) + 0.5*rho*u^2

where:

gamma = ratio of specific heats

For air:

gamma = 1.4

---

## Primitive Variables

The primitive variables are:

[ rho
  u
  p ]

These variables are easier to interpret physically but the Euler equations are solved using conserved variables.

---

## Equation of State

The ideal gas equation of state closes the system:

p = (gamma-1)*(E - 0.5*rho*u^2)

---

## Why Finite Volume?

Shock waves introduce discontinuities in the solution.

Finite-volume methods preserve conservation across discontinuities and are therefore widely used in compressible CFD solvers.

The numerical flux evaluated at cell interfaces determines how information propagates through the computational domain.

---

## Validation Cases

The solver will be validated using:

1. Sod Shock Tube
2. Quasi-1D Nozzle Flow
3. Normal Shock in a Converging-Diverging Nozzle

---

## Numerical Methods

The following numerical schemes will be implemented and compared:

1. MacCormack Scheme
2. Rusanov Flux
3. Roe Flux

Their accuracy, numerical diffusion, stability, and shock-capturing capability will be evaluated.