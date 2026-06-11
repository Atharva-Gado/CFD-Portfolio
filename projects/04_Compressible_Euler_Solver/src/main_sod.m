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

%% Initialize Sod Shock Tube

[rho,u,p] = initialize_sod(x);

%% Convert to Conserved Variables

U = primitive_to_conserved(rho,u,p,gamma);

%% CFL Time Step

CFL = 0.5;

dt = compute_timestep(U,gamma,dx,CFL);

%% Compute Initial Flux

F = compute_flux(U,gamma);

%% Compute RHS

RHS = compute_rhs(F,dx);

fprintf('Maximum RHS magnitude: %.4f\n',max(abs(RHS(:))));

%% One Explicit Euler Update

U_new = U + dt * RHS;

[rho_new,u_new,p_new] = conserved_to_primitive(U_new,gamma);


%% Display Information

fprintf('Grid Points : %d\n',N);
fprintf('Grid Spacing: %.6f\n',dx);
fprintf('CFL Number  : %.2f\n',CFL);
fprintf('Time Step   : %.8e\n',dt);
fprintf('Initial left momentum flux : %.4f\n',F(2,1));
fprintf('Initial right momentum flux: %.4f\n',F(2,end));

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

%% Plot One-Step Evolution

figure('Position',[150 150 1000 700])

subplot(3,1,1)
plot(x,rho,'LineWidth',2)
hold on
plot(x,rho_new,'--','LineWidth',2)
ylabel('\rho')
grid on
legend('Initial','After One Step')
title('Sod Shock Tube: One Explicit Euler Step')

subplot(3,1,2)
plot(x,u,'LineWidth',2)
hold on
plot(x,u_new,'--','LineWidth',2)
ylabel('u')
grid on

subplot(3,1,3)
plot(x,p,'LineWidth',2)
hold on
plot(x,p_new,'--','LineWidth',2)
ylabel('p')
xlabel('x')
grid on

%% Save Figure

output_dir = fullfile('results','figures');

if ~exist(output_dir,'dir')
    mkdir(output_dir);
end

saveas(gcf, fullfile(output_dir,'sod_initial_condition.png'))
saveas(gcf, fullfile(output_dir,'sod_one_step_euler.png'))