%% Project 04
% 1D Compressible Euler Solver
% Sod Shock Tube Driver

clear;
clc;
close all;

project_root = fileparts(fileparts(mfilename('fullpath')));
cd(project_root);

%% Output Directory

output_dir = fullfile('results','figures');

if ~exist(output_dir,'dir')
    mkdir(output_dir);
end

%% Gas Properties

gamma = 1.4;

%% Numerical Parameters

CFL = 0.2;

%% Computational Domain

x_start = 0.0;
x_end   = 1.0;
N = 200;

x = linspace(x_start,x_end,N);
dx = x(2)-x(1);

t_end = 0.05;

%% Initialize Sod Shock Tube

[rho,u,p] = initialize_sod(x);

%% Convert to Conserved Variables

U = primitive_to_conserved(rho,u,p,gamma);

%% Initial CFL Time Step

dt_initial = compute_timestep(U,gamma,dx,CFL);

%% Compute Initial Flux and RHS

F = compute_flux(U,gamma);
RHS = compute_rhs(F,dx);

%% One Explicit Euler Update Diagnostic

U_new = U + dt_initial * RHS;
[rho_new,u_new,p_new] = conserved_to_primitive(U_new,gamma);

%% Display Information

fprintf('Grid Points : %d\n',N);
fprintf('Grid Spacing: %.6f\n',dx);
fprintf('CFL Number  : %.2f\n',CFL);
fprintf('Initial Time Step: %.8e\n',dt_initial);
fprintf('Maximum RHS magnitude: %.4f\n',max(abs(RHS(:))));
fprintf('Initial left momentum flux : %.4f\n',F(2,1));
fprintf('Initial right momentum flux: %.4f\n',F(2,end));

%% Time Integration Using MacCormack Scheme

t = 0.0;


U_mac = U;

while t < t_end

    dt = compute_timestep(U_mac,gamma,dx,CFL);

    if t + dt > t_end
        dt = t_end - t;
    end

    U_mac = maccormack_step(U_mac,gamma,dx,dt);

    t = t + dt;

end

[rho_mac,u_mac,p_mac] = conserved_to_primitive(U_mac,gamma);

%% Time Integration Using Rusanov Flux

t = 0.0;


U_rus = U;

while t < t_end

    dt = compute_timestep(U_rus,gamma,dx,CFL);

    if t + dt > t_end
        dt = t_end - t;
    end

    U_rus = rusanov_step(U_rus,gamma,dx,dt);

    t = t + dt;

end

[rho_rus,u_rus,p_rus] = conserved_to_primitive(U_rus,gamma);

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

saveas(gcf, fullfile(output_dir,'sod_initial_condition.png'))

%% Plot One-Step Evolution Diagnostic

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

saveas(gcf, fullfile(output_dir,'sod_one_step_euler.png'))

%% Plot MacCormack Result

figure('Position',[200 200 1000 700])

subplot(3,1,1)
plot(x,rho_mac,'LineWidth',2)
ylabel('\rho')
grid on
title('Sod Shock Tube: MacCormack Solution at t = 0.05')

subplot(3,1,2)
plot(x,u_mac,'LineWidth',2)
ylabel('u')
grid on

subplot(3,1,3)
plot(x,p_mac,'LineWidth',2)
ylabel('p')
xlabel('x')
grid on

saveas(gcf, fullfile(output_dir,'sod_maccormack_t005.png'))

%% Plot MacCormack vs Rusanov

figure('Position',[250 250 1000 700])

subplot(3,1,1)
plot(x,rho_mac,'LineWidth',2)
hold on
plot(x,rho_rus,'--','LineWidth',2)
ylabel('\rho')
grid on
legend('MacCormack + AV','Rusanov')
title('Sod Shock Tube: MacCormack vs Rusanov')

subplot(3,1,2)
plot(x,u_mac,'LineWidth',2)
hold on
plot(x,u_rus,'--','LineWidth',2)
ylabel('u')
grid on

subplot(3,1,3)
plot(x,p_mac,'LineWidth',2)
hold on
plot(x,p_rus,'--','LineWidth',2)
ylabel('p')
xlabel('x')
grid on

saveas(gcf, fullfile(output_dir,'sod_maccormack_vs_rusanov.png'))
fprintf('Saved comparison figure successfully\n');