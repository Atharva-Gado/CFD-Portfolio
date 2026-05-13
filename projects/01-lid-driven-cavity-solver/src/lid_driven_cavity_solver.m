clear; clc; close all;
% 2D Incompressible Navier-Stokes Solver - Lid-Driven Cavity (Re=100)

%% Physical domain and discretization
Lx = 1.0;
Ly = 1.0;
dx = 0.05;
dy = 0.05;

% Grid dimensions
I = round(Lx/dx);  % I = 20
J = round(Ly/dy);  % J = 20

% Physical parameters
rho = 1.0;
U_lid = 1.0;
nu = 0.01;  % Corresponds to Re

% Time stepping
C = 1.0;
dt = C * min((1/4)*(dx^2/nu), dx/U_lid);
fprintf('Computed dt = %.6e\n', dt);

% SOR parameters
N_P = I;
rho_jac = cos(pi/N_P);
omega = 2 / (1 + sqrt(1 - rho_jac^2));
fprintf('Optimal omega = %.6f\n', omega);

% Convergence parameters
Tolfac = 1e-7;
MAX_SOR_ITER = 10000;
T_FINAL = 50.0;  
CHECK_INTERVAL = 100;

%% ========================= GRID SETUP (Staggered Grid) =========================
U = zeros(J+2, I+1);  % U-velocity
V = zeros(J+1, I+2);  % V-velocity
P = zeros(J+2, I+2);  % Pressure (cell centers)

% Coordinate arrays for plotting
x_u = 0:dx:Lx;              % U is at x = 0, dx, 2dx, ..., Lx (I+1 points)
y_u = dx/2:dy:(Ly+dy/2);    % U spans y with ghost cells

x_v = dx/2:dx:(Lx+dx/2);    % V spans x with ghost cells  
y_v = 0:dy:Ly;              % V is at y = 0, dy, 2dy, ..., Ly (J+1 points)

x_p = dx/2:dx:(Lx+dx/2);    % P at cell centers
y_p = dy/2:dy:(Ly+dy/2);

% For plotting - true interior cell centers
x_plot = dx/2:dx:(Lx-dx/2);
y_plot = dy/2:dy:(Ly-dy/2);
[X_plot, Y_plot] = meshgrid(x_plot, y_plot);

%% ========================= INDICATOR FUNCTIONS =========================
% Neumann boundary conditions
epsilon_W = zeros(J+2, I+2);
epsilon_E = zeros(J+2, I+2);
epsilon_S = zeros(J+2, I+2);
epsilon_N = zeros(J+2, I+2);

for i = 2:I+1
    for j = 2:J+1
        % West neighbor
        if i == 2
            epsilon_W(j,i) = 0;
        else
            epsilon_W(j,i) = 1;
        end
        
        % East neighbor
        if i == I+1
            epsilon_E(j,i) = 0;
        else
            epsilon_E(j,i) = 1;
        end
        
        % South neighbor
        if j == 2
            epsilon_S(j,i) = 0;
        else
            epsilon_S(j,i) = 1;
        end
        
        % North neighbor
        if j == J+1
            epsilon_N(j,i) = 0;
        else
            epsilon_N(j,i) = 1;
        end
    end
end

%% ========================= TIME MARCHING =========================
t = 0;
n_step = 0;
steady_state_reached = false;

% Storage for convergence history
time_history = [];
residual_history = [];
sor_iter_history = [];

fprintf('\n=== Starting Time Integration ===\n');
fprintf('Grid: %d x %d cells\n', I, J);
fprintf('Re = %.1f, dt = %.6e\n', U_lid*Lx/nu, dt);

while t < T_FINAL && ~steady_state_reached
    n_step = n_step + 1;
    
    % Store old velocity for convergence check
    U_old = U;
    V_old = V;
    
    %% === STEP 1: Apply Boundary Conditions ===
    for j = 2:J                   % Left BC
        V(j,1) = -V(j,2);
    end
    
    for j = 2:J                   % Right BC
        V(j,I+2) = -V(j,I+1);
    end

    for i = 2:I-1                 % Bottom BC
        U(1,i) = -U(2,i);
    end
   
    for i = 2:I-1                 % Top BC
        U(J+2,i) = 2*U_lid - U(J+1,i);
    end
    
    %% === STEP 1: Predictor Step - Convection-Diffusion ===
    U_star = U;
    V_star = V;
    
    % Update interior U velocities (i: 2 to I-1, j: 2 to J+1)
    for i = 2:I-1
        for j = 2:J+1
            % Diffusion term: nu * Laplacian(u)
            d2u_dx2 = (U(j,i+1) - 2*U(j,i) + U(j,i-1)) / dx^2;
            d2u_dy2 = (U(j+1,i) - 2*U(j,i) + U(j-1,i)) / dy^2;
            diffusion_u = nu * (d2u_dx2 + d2u_dy2);
            
            % Convection term: d(u^2)/dx + d(uv)/dy
            u_avg_e = (U(j,i) + U(j,i+1)) / 2;
            u_avg_w = (U(j,i-1) + U(j,i)) / 2;
            du2_dx = (u_avg_e^2 - u_avg_w^2) / dx;
            
            v_avg_n = (V(j,i) + V(j,i+1)) / 2;
            v_avg_s = (V(j-1,i) + V(j-1,i+1)) / 2;
            u_avg_n = (U(j,i) + U(j+1,i)) / 2;
            u_avg_s = (U(j-1,i) + U(j,i)) / 2;
            duv_dy = (v_avg_n * u_avg_n - v_avg_s * u_avg_s) / dy;
            
            convection_u = du2_dx + duv_dy;
            
            % Update U* (Equation L-1)
            U_star(j,i) = U(j,i) + dt * (diffusion_u - convection_u);
        end
    end
    
    % Update interior V velocities (i: 2 to I+1, j: 2 to J-1)
    for i = 2:I+1
        for j = 2:J-1
            % Diffusion term: nu * Laplacian(v)
            d2v_dx2 = (V(j,i+1) - 2*V(j,i) + V(j,i-1)) / dx^2;
            d2v_dy2 = (V(j+1,i) - 2*V(j,i) + V(j-1,i)) / dy^2;
            diffusion_v = nu * (d2v_dx2 + d2v_dy2);
            
            % Convection term: d(uv)/dx + d(v^2)/dy
            u_avg_e = (U(j,i) + U(j+1,i)) / 2;
            u_avg_w = (U(j,i-1) + U(j+1,i-1)) / 2;
            v_avg_e = (V(j,i) + V(j,i+1)) / 2;
            v_avg_w = (V(j,i-1) + V(j,i)) / 2;
            duv_dx = (u_avg_e * v_avg_e - u_avg_w * v_avg_w) / dx;
            
            v_avg_n = (V(j,i) + V(j+1,i)) / 2;
            v_avg_s = (V(j-1,i) + V(j,i)) / 2;
            dv2_dy = (v_avg_n^2 - v_avg_s^2) / dy;
            
            convection_v = duv_dx + dv2_dy;
            
            % Update V* (Equation L-2)
            V_star(j,i) = V(j,i) + dt * (diffusion_v - convection_v);
        end
    end
    
    % Apply BCs to U_star and V_star (same as U and V)
    for j = 2:J
        V_star(j,1) = -V_star(j,2);
        V_star(j,I+2) = -V_star(j,I+1);
    end
    for i = 2:I-1
        U_star(1,i) = -U_star(2,i);
        U_star(J+2,i) = 2*U_lid - U_star(J+1,i);
    end
    
    %% === STEP 2: Pressure Poisson Equation ===
    RHS = zeros(J+2, I+2);
    
    for i = 2:I+1
        for j = 2:J+1
            du_dx = (U_star(j,i) - U_star(j,i-1)) / dx;
            dv_dy = (V_star(j,i) - V_star(j-1,i)) / dy;
            RHS(j,i) = (rho/dt) * (du_dx + dv_dy);
        end
    end
    
    % Calculate tolerance for SOR
    L_inf_g = max(abs(RHS(:)));
    Tol = L_inf_g * Tolfac;
    if Tol < 1e-10; Tol = 1e-10; end  % Minimum tolerance
    
    % SOR Iteration
    sor_iter = 0;
    sor_converged = false;
    
    while ~sor_converged && sor_iter < MAX_SOR_ITER
        sor_iter = sor_iter + 1;
        P_old = P;
        
        % Update all interior pressure nodes (i: 2 to I+1, j: 2 to J+1)
        for i = 2:I+1
            for j = 2:J+1
                % Numerator: sum of neighbor pressures weighted by epsilon
                numerator = epsilon_E(j,i) * P(j,i+1) + ...
                           epsilon_W(j,i) * P(j,i-1) + ...
                           epsilon_N(j,i) * P(j+1,i) + ...
                           epsilon_S(j,i) * P(j-1,i) - ...
                           RHS(j,i) * dx^2;
                
                % Denominator: sum of epsilon values
                denominator = epsilon_E(j,i) + epsilon_W(j,i) + ...
                             epsilon_N(j,i) + epsilon_S(j,i);
                
                % SOR update
                P_hat = numerator / denominator;
                P(j,i) = P_old(j,i) + omega * (P_hat - P_old(j,i));
            end
        end
        
        % Check convergence (Residual, Page 16)
        if mod(sor_iter, 10) == 0
            residual = zeros(J, I);
            for i = 2:I+1
                for j = 2:J+1
                    lap_P = (epsilon_E(j,i)*(P(j,i+1)-P(j,i)) + ...
                            epsilon_W(j,i)*(P(j,i-1)-P(j,i)) + ...
                            epsilon_N(j,i)*(P(j+1,i)-P(j,i)) + ...
                            epsilon_S(j,i)*(P(j-1,i)-P(j,i))) / dx^2;
                    residual(j-1,i-1) = lap_P - RHS(j,i);
                end
            end
            L_inf_res = max(abs(residual(:)));
            
            if L_inf_res < Tol
                sor_converged = true;
            end
        end
    end
    
    if ~sor_converged
        warning('SOR did not converge at step %d after %d iterations', n_step, sor_iter);
    end
    
    %% === STEP 3: Corrector Step ===
    for i = 2:I-1
        for j = 2:J+1
            dP_dx = (P(j,i+1) - P(j,i)) / dx;
            U(j,i) = U_star(j,i) - (dt/rho) * dP_dx;
        end
    end
    
    for i = 2:I+1
        for j = 2:J-1
            dP_dy = (P(j+1,i) - P(j,i)) / dy;
            V(j,i) = V_star(j,i) - (dt/rho) * dP_dy;
        end
    end
    
    %% === Update Time and Check Convergence ===
    t = t + dt;
    
    % Check for steady state (after initial transient)
    if t > 5.0
        % Calculate normalized change
        delta_U = sqrt(sum((U(:) - U_old(:)).^2));
        delta_V = sqrt(sum((V(:) - V_old(:)).^2));
        norm_U = sqrt(sum(U(:).^2)) + 1e-10;
        norm_V = sqrt(sum(V(:).^2)) + 1e-10;
        
        relative_change = (delta_U/norm_U + delta_V/norm_V) / 2;
        
        if relative_change < 1e-6
            steady_state_reached = true;
            fprintf('Steady state reached at t=%.4f\n', t);
        end
    end
    
    % Store history
    time_history = [time_history, t];
    sor_iter_history = [sor_iter_history, sor_iter];
    
    % Progress output
    if mod(n_step, CHECK_INTERVAL) == 0
        fprintf('Step %5d: t=%8.4f, SOR iters=%4d\n', n_step, t, sor_iter);
    end
end

fprintf('\n=== Simulation Complete ===\n');
fprintf('Final time: t = %.4f\n', t);
fprintf('Total steps: %d\n', n_step);

%% ========================= POST-PROCESSING =========================

%% 1. Extract velocity at cell centers for plotting
U_center = zeros(J, I);
V_center = zeros(J, I);

for i = 1:I
    for j = 1:J
        % U at cell center: average of left and right face
        U_center(j,i) = (U(j+1,i) + U(j+1,i+1)) / 2;
        % V at cell center: average of bottom and top face
        V_center(j,i) = (V(j,i+1) + V(j+1,i+1)) / 2;
    end
end

% Pressure at interior cells (remove ghost cells)
P_interior = P(2:J+1, 2:I+1);
P_interior = P_interior - mean(P_interior(:));  % Normalize (pressure is defined up to constant)

%% 2. Plot SOR iterations per time step
figure('Position', [100 100 800 400]);
plot(1:length(sor_iter_history), sor_iter_history, 'b-', 'LineWidth', 1.5);
xlabel('Time Step', 'FontSize', 12);
ylabel('SOR Iterations', 'FontSize', 12);
title('Poisson Solver Convergence History', 'FontSize', 14);
grid on;

%% 3. Plot Pressure Field
figure('Position', [100 100 700 600]);
contourf(X_plot, Y_plot, P_interior, 20, 'LineColor', 'none');
colorbar;
xlabel('x', 'FontSize', 12);
ylabel('y', 'FontSize', 12);
title('Pressure Field (P)', 'FontSize', 14);
axis equal tight;
set(gca, 'FontSize', 11);

%% 4. Plot Velocity Magnitude
vel_mag = sqrt(U_center.^2 + V_center.^2);
figure('Position', [100 100 700 600]);
contourf(X_plot, Y_plot, vel_mag, 20, 'LineColor', 'none');
colorbar;
xlabel('x', 'FontSize', 12);
ylabel('y', 'FontSize', 12);
title('Velocity Magnitude', 'FontSize', 14);
axis equal tight;
set(gca, 'FontSize', 11);

%% 5. Plot Streamlines with Velocity Vectors
figure('Position', [100 100 800 700]);
% Streamlines
startx = linspace(0.05, 0.95, 25);
starty = 0.95 * ones(size(startx));
streamline(X_plot, Y_plot, U_center, V_center, startx, starty);
hold on;
% Velocity vectors (subsampled)
skip = 2;
quiver(X_plot(1:skip:end, 1:skip:end), Y_plot(1:skip:end, 1:skip:end), ...
       U_center(1:skip:end, 1:skip:end), V_center(1:skip:end, 1:skip:end), ...
       1.5, 'k', 'LineWidth', 1);
xlabel('x', 'FontSize', 12);
ylabel('y', 'FontSize', 12);
title('Streamlines and Velocity Vectors', 'FontSize', 14);
axis equal tight;
grid on;
set(gca, 'FontSize', 11);

%% 6. Validation: Compare with Ghia et al. (1982) benchmark data for Re=100
% Ghia data for vertical centerline (x=0.5): u-velocity vs y
y_ghia = [0.0000, 0.0547, 0.0625, 0.0703, 0.1016, 0.1719, 0.2813, 0.4531, ...
          0.5000, 0.6172, 0.7344, 0.8516, 0.9531, 0.9609, 0.9688, 0.9766, 1.0000];
u_ghia = [0.00000, -0.03717, -0.04192, -0.04775, -0.06434, -0.10150, -0.15662, ...
          -0.21090, -0.20581, -0.13641, 0.00332, 0.23151, 0.68717, 0.73722, ...
          0.78871, 0.84123, 1.00000];

% Ghia data for horizontal centerline (y=0.5): v-velocity vs x
x_ghia = [0.0000, 0.0625, 0.0703, 0.0781, 0.0938, 0.1563, 0.2266, 0.2344, ...
          0.5000, 0.8047, 0.8594, 0.9063, 0.9453, 0.9531, 0.9609, 0.9688, 1.0000];
v_ghia = [0.00000, 0.09233, 0.10091, 0.10890, 0.12317, 0.16077, 0.17507, ...
          0.17527, 0.05454, -0.24533, -0.22445, -0.16914, -0.10313, -0.08864, ...
          -0.07391, -0.05906, 0.00000];

% Extract u-velocity along vertical centerline (x = 0.5)
[~, mid_i] = min(abs(x_plot - 0.5));
u_centerline = U_center(:, mid_i);

% Extract v-velocity along horizontal centerline (y = 0.5)
[~, mid_j] = min(abs(y_plot - 0.5));
v_centerline = V_center(mid_j, :);

% Plot U-velocity comparison
figure('Position', [100 100 800 600]);
plot(u_centerline, y_plot, 'b-', 'LineWidth', 2); hold on;
plot(u_ghia, y_ghia, 'ro', 'MarkerSize', 8, 'LineWidth', 1.5);
xlabel('u-velocity', 'FontSize', 12);
ylabel('y', 'FontSize', 12);
title('U-velocity along Vertical Centerline (x=0.5)', 'FontSize', 14);
legend('Current Simulation', 'Ghia et al. (1982)', 'Location', 'best');
grid on;
set(gca, 'FontSize', 11);

% Plot V-velocity comparison
figure('Position', [100 100 800 600]);
plot(x_plot, v_centerline, 'b-', 'LineWidth', 2); hold on;
plot(x_ghia, v_ghia, 'ro', 'MarkerSize', 8, 'LineWidth', 1.5);
xlabel('x', 'FontSize', 12);
ylabel('v-velocity', 'FontSize', 12);
title('V-velocity along Horizontal Centerline (y=0.5)', 'FontSize', 14);
legend('Current Simulation', 'Ghia et al. (1982)', 'Location', 'best');
grid on;
set(gca, 'FontSize', 11);

fprintf('\n=== Validation Complete ===\n');
fprintf('Compare plots with Ghia et al. (1982) benchmark data\n');