%% Project 04
% 1D Compressible Euler Solver
% Sod Shock Tube Initialization

clear;
clc;
close all;

%% Paths

addpath('src')

%% Gas Properties

gamma = 1.4;

%% Computational Domain

x_start = 0.0;
x_end   = 1.0;

N = 200;

x = linspace(x_start,x_end,N);
dx = x(2)-x(1);

%% Initialize Sod Shock Tube

[rho,u,p] = initialize_sod(x);

%% Convert to Conserved Variables

U = primitive_to_conserved(rho,u,p,gamma);

%% CFL Time Step

CFL = 0.5;

dt = compute_timestep(U,gamma,dx,CFL);

%% Display Information

fprintf('Grid Points : %d\n',N);
fprintf('Grid Spacing: %.6f\n',dx);
fprintf('CFL Number  : %.2f\n',CFL);
fprintf('Time Step   : %.8e\n',dt);

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

output_dir = fullfile('results','figures');

if ~exist(output_dir,'dir')
    mkdir(output_dir);
end

saveas(gcf, fullfile(output_dir,'sod_initial_condition.png'))