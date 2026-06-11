%% Project 04
% 1D Compressible Euler Solver
% Sod Shock Tube Initialization

clear;
clc;
close all;

%% Gas Properties

gamma = 1.4;

%% Computational Domain

x_start = 0.0;
x_end   = 1.0;

N = 200;

x = linspace(x_start,x_end,N);

dx = x(2)-x(1);

%% Primitive Variables

rho = zeros(size(x));
u   = zeros(size(x));
p   = zeros(size(x));

%% Sod Shock Tube Initial Condition

rho(x < 0.5) = 1.0;
rho(x >= 0.5) = 0.125;

u(:) = 0.0;

p(x < 0.5) = 1.0;
p(x >= 0.5) = 0.1;

%% Convert to Conserved Variables

U = primitive_to_conserved(rho,u,p,gamma);

%% Display Information

fprintf('Grid Points : %d\n',N);
fprintf('Grid Spacing: %.6f\n',dx);

%% Plot Initial Condition

figure('Position',[100 100 1000 700])

subplot(3,1,1)
plot(x,rho,'LineWidth',2)
ylabel('\rho')
grid on
title('Sod Shock Tube Initial Condition')

subplot(3,1,2)
plot(x,u,'LineWidth',2)
ylabel('u')
grid on

subplot(3,1,3)
plot(x,p,'LineWidth',2)
ylabel('p')
xlabel('x')
grid on

%% Save Figure

saveas(gcf,'results/figures/sod_initial_condition.png')