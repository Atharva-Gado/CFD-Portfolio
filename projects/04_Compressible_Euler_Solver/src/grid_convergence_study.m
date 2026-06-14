%% Grid Convergence Study
% Sod shock tube using Rusanov flux solver

clear;
clc;
close all;

project_root = fileparts(fileparts(mfilename('fullpath')));
cd(project_root);

addpath('src')

output_dir = fullfile('results','figures');

if ~exist(output_dir,'dir')
    mkdir(output_dir);
end

gamma = 1.4;
CFL = 0.2;
t_end = 0.05;

grid_sizes = [100, 200, 400];

solutions = cell(length(grid_sizes),1);

for k = 1:length(grid_sizes)
    N = grid_sizes(k);
    [x,rho,u,p] = run_rusanov_solver(N,t_end,gamma,CFL);

    solutions{k}.N = N;
    solutions{k}.x = x;
    solutions{k}.rho = rho;
    solutions{k}.u = u;
    solutions{k}.p = p;
end

%% Plot Grid Convergence

figure('Position',[100 100 1000 700])

subplot(3,1,1)
hold on
for k = 1:length(grid_sizes)
    plot(solutions{k}.x,solutions{k}.rho,'LineWidth',2)
end
ylabel('\rho')
grid on
legend('N = 100','N = 200','N = 400')
title('Grid Convergence Study: Rusanov Solver')

subplot(3,1,2)
hold on
for k = 1:length(grid_sizes)
    plot(solutions{k}.x,solutions{k}.u,'LineWidth',2)
end
ylabel('u')
grid on

subplot(3,1,3)
hold on
for k = 1:length(grid_sizes)
    plot(solutions{k}.x,solutions{k}.p,'LineWidth',2)
end
ylabel('p')
xlabel('x')
grid on

saveas(gcf, fullfile(output_dir,'rusanov_grid_convergence.png'))