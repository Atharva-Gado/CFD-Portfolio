clear; clc; close all;

%% ============================================================
% Project 2: Numerical Scheme Comparison for Lid-Driven Cavity
% gamma = 0 : Central differencing
% gamma = 1 : Donor-cell / upwind blending
% Re = 100
%% ============================================================

%% Physical parameters
params.Lx = 1.0;
params.Ly = 1.0;
params.I = 40;
params.J = 40;
params.rho = 1.0;
params.U_lid = 1.0;
params.nu = 0.01;              % Re = 100
params.C = 0.5;
params.T_FINAL = 50.0;
params.Tolfac = 1e-7;
params.MAX_SOR_ITER = 10000;
params.steady_tol = 1e-6;

fprintf('Running scheme comparison at Re = %.1f\n', ...
    params.U_lid * params.Lx / params.nu);

%% Run both schemes
result_g0 = run_lid_cavity_solver(params, 0.0);
result_g1 = run_lid_cavity_solver(params, 1.0);

%% Ghia et al. Re = 100 benchmark data
y_ghia = [0.0000, 0.0547, 0.0625, 0.0703, 0.1016, 0.1719, ...
          0.2813, 0.4531, 0.5000, 0.6172, 0.7344, 0.8516, ...
          0.9531, 0.9609, 0.9688, 0.9766, 1.0000];

u_ghia = [0.00000, -0.03717, -0.04192, -0.04775, -0.06434, ...
          -0.10150, -0.15662, -0.21090, -0.20581, -0.13641, ...
           0.00332,  0.23151,  0.68717,  0.73722,  0.78871, ...
           0.84123,  1.00000];

x_ghia = [0.0000, 0.0625, 0.0703, 0.0781, 0.0938, 0.1563, ...
          0.2266, 0.2344, 0.5000, 0.8047, 0.8594, 0.9063, ...
          0.9453, 0.9531, 0.9609, 0.9688, 1.0000];

v_ghia = [0.00000,  0.09233,  0.10091,  0.10890,  0.12317, ...
          0.16077,  0.17507,  0.17527,  0.05454, -0.24533, ...
         -0.22445, -0.16914, -0.10313, -0.08864, -0.07391, ...
         -0.05906,  0.00000];

%% Extract centerlines
[~, mid_i] = min(abs(result_g0.x - 0.5));
[~, mid_j] = min(abs(result_g0.y - 0.5));

u_g0 = result_g0.U_center(:, mid_i);
u_g1 = result_g1.U_center(:, mid_i);

v_g0 = result_g0.V_center(mid_j, :);
v_g1 = result_g1.V_center(mid_j, :);

%% Error calculations against Ghia data
u_ghia_interp = interp1(y_ghia, u_ghia, result_g0.y, 'linear');
v_ghia_interp = interp1(x_ghia, v_ghia, result_g0.x, 'linear');

L2_u_g0 = sqrt(mean((u_g0 - u_ghia_interp').^2));
L2_u_g1 = sqrt(mean((u_g1 - u_ghia_interp').^2));

L2_v_g0 = sqrt(mean((v_g0 - v_ghia_interp).^2));
L2_v_g1 = sqrt(mean((v_g1 - v_ghia_interp).^2));

Linf_u_g0 = max(abs(u_g0 - u_ghia_interp'));
Linf_u_g1 = max(abs(u_g1 - u_ghia_interp'));

Linf_v_g0 = max(abs(v_g0 - v_ghia_interp));
Linf_v_g1 = max(abs(v_g1 - v_ghia_interp));

fprintf('\n===== Error Summary Against Ghia et al. =====\n');
fprintf('Gamma = 0: L2(u) = %.6e, L2(v) = %.6e\n', L2_u_g0, L2_v_g0);
fprintf('Gamma = 1: L2(u) = %.6e, L2(v) = %.6e\n', L2_u_g1, L2_v_g1);
fprintf('Gamma = 0: Linf(u) = %.6e, Linf(v) = %.6e\n', Linf_u_g0, Linf_v_g0);
fprintf('Gamma = 1: Linf(u) = %.6e, Linf(v) = %.6e\n', Linf_u_g1, Linf_v_g1);

%% ============================================================
% FIGURE 1: U-centerline comparison
%% ============================================================
figure('Color','w','Position',[100 100 800 600]);
plot(u_g0, result_g0.y, 'b-', 'LineWidth', 2); hold on;
plot(u_g1, result_g1.y, 'r--', 'LineWidth', 2);
plot(u_ghia, y_ghia, 'ko', 'MarkerSize', 7, 'LineWidth', 1.5);
xlabel('u-velocity');
ylabel('y');
title('U-Velocity Along Vertical Centerline, x = 0.5');
legend('\gamma = 0 Central', '\gamma = 1 Donor-cell', ...
       'Ghia et al. (1982)', 'Location','best');
grid on;
set(gca,'FontSize',12);

%% ============================================================
% FIGURE 2: V-centerline comparison
%% ============================================================
figure('Color','w','Position',[150 150 800 600]);
plot(result_g0.x, v_g0, 'b-', 'LineWidth', 2); hold on;
plot(result_g1.x, v_g1, 'r--', 'LineWidth', 2);
plot(x_ghia, v_ghia, 'ko', 'MarkerSize', 7, 'LineWidth', 1.5);
xlabel('x');
ylabel('v-velocity');
title('V-Velocity Along Horizontal Centerline, y = 0.5');
legend('\gamma = 0 Central', '\gamma = 1 Donor-cell', ...
       'Ghia et al. (1982)', 'Location','best');
grid on;
set(gca,'FontSize',12);

%% ============================================================
% FIGURE 3: Velocity magnitude comparison
%% ============================================================
figure('Color','w','Position',[100 100 1200 500]);

subplot(1,2,1);
contourf(result_g0.X, result_g0.Y, result_g0.vel_mag, 30, 'LineColor','none');
colorbar;
axis equal tight;
xlabel('x'); ylabel('y');
title('\gamma = 0 Central: Velocity Magnitude');

subplot(1,2,2);
contourf(result_g1.X, result_g1.Y, result_g1.vel_mag, 30, 'LineColor','none');
colorbar;
axis equal tight;
xlabel('x'); ylabel('y');
title('\gamma = 1 Donor-cell: Velocity Magnitude');

%% ============================================================
% FIGURE 4: Streamline comparison
%% ============================================================
figure('Color','w','Position',[100 100 1200 500]);

startx = linspace(0.05, 0.95, 25);
starty = 0.95 * ones(size(startx));

subplot(1,2,1);
streamline(result_g0.X, result_g0.Y, result_g0.U_center, result_g0.V_center, startx, starty);
hold on;
quiver(result_g0.X(1:3:end,1:3:end), result_g0.Y(1:3:end,1:3:end), ...
       result_g0.U_center(1:3:end,1:3:end), result_g0.V_center(1:3:end,1:3:end), ...
       1.5, 'k');
axis equal tight;
xlabel('x'); ylabel('y');
title('\gamma = 0 Central: Streamlines');

subplot(1,2,2);
streamline(result_g1.X, result_g1.Y, result_g1.U_center, result_g1.V_center, startx, starty);
hold on;
quiver(result_g1.X(1:3:end,1:3:end), result_g1.Y(1:3:end,1:3:end), ...
       result_g1.U_center(1:3:end,1:3:end), result_g1.V_center(1:3:end,1:3:end), ...
       1.5, 'k');
axis equal tight;
xlabel('x'); ylabel('y');
title('\gamma = 1 Donor-cell: Streamlines');

%% ============================================================
% FIGURE 5: Pressure comparison
%% ============================================================
figure('Color','w','Position',[100 100 1200 500]);

subplot(1,2,1);
contourf(result_g0.X, result_g0.Y, result_g0.P, 30, 'LineColor','none');
colorbar;
axis equal tight;
xlabel('x'); ylabel('y');
title('\gamma = 0 Central: Pressure');

subplot(1,2,2);
contourf(result_g1.X, result_g1.Y, result_g1.P, 30, 'LineColor','none');
colorbar;
axis equal tight;
xlabel('x'); ylabel('y');
title('\gamma = 1 Donor-cell: Pressure');

%% ============================================================
% FIGURE 6: SOR iteration comparison
%% ============================================================
figure('Color','w','Position',[100 100 800 500]);
plot(result_g0.sor_iter_history, 'b-', 'LineWidth', 2); hold on;
plot(result_g1.sor_iter_history, 'r--', 'LineWidth', 2);
xlabel('Time Step');
ylabel('SOR Iterations');
title('Pressure Poisson Solver Iteration History');
legend('\gamma = 0 Central', '\gamma = 1 Donor-cell', 'Location','best');
grid on;
set(gca,'FontSize',12);

%% ============================================================
% FIGURE 7: Error comparison
%% ============================================================
figure('Color','w','Position',[100 100 750 500]);
errors = [L2_u_g0, L2_v_g0; L2_u_g1, L2_v_g1];
bar(errors);
set(gca, 'XTickLabel', {'\gamma = 0 Central', '\gamma = 1 Donor-cell'});
ylabel('L2 Error Norm');
title('Centerline Velocity L2 Error Against Ghia et al.');
legend('u-centerline', 'v-centerline', 'Location','best');
grid on;
set(gca,'FontSize',12);

fprintf('\nAll comparison plots generated. Review figures before saving.\n');

%% ============================================================
% LOCAL SOLVER FUNCTION
%% ============================================================

function result = run_lid_cavity_solver(params, gamma)

    Lx = params.Lx;
    Ly = params.Ly;
    I = params.I;
    J = params.J;
    rho = params.rho;
    U_lid = params.U_lid;
    nu = params.nu;
    C = params.C;
    T_FINAL = params.T_FINAL;
    Tolfac = params.Tolfac;
    MAX_SOR_ITER = params.MAX_SOR_ITER;
    steady_tol = params.steady_tol;

    dx = Lx / I;
    dy = Ly / J;

    dt_diffusion = 0.25 * dx^2 / nu;
    dt_advection = dx / U_lid;
    dt = C * min(dt_diffusion, dt_advection);

    fprintf('\n=============================================\n');
    fprintf('Running gamma = %.1f\n', gamma);
    fprintf('Grid: %d x %d\n', I, J);
    fprintf('dx = %.5f, dt = %.6e\n', dx, dt);
    fprintf('Re = %.1f\n', U_lid * Lx / nu);
    fprintf('=============================================\n');

    U = zeros(J+2, I+1);
    V = zeros(J+1, I+2);
    P = zeros(J+2, I+2);

    x_plot = dx/2:dx:(Lx-dx/2);
    y_plot = dy/2:dy:(Ly-dy/2);
    [X_plot, Y_plot] = meshgrid(x_plot, y_plot);

    rho_jac = cos(pi/I);
    omega = 2 / (1 + sqrt(1 - rho_jac^2));

    epsilon_W = zeros(J+2, I+2);
    epsilon_E = zeros(J+2, I+2);
    epsilon_S = zeros(J+2, I+2);
    epsilon_N = zeros(J+2, I+2);

    for i = 2:I+1
        for j = 2:J+1
            epsilon_W(j,i) = i > 2;
            epsilon_E(j,i) = i < I+1;
            epsilon_S(j,i) = j > 2;
            epsilon_N(j,i) = j < J+1;
        end
    end

    t = 0;
    n_step = 0;
    steady_state_reached = false;
    sor_iter_history = [];
    time_history = [];

    while t < T_FINAL && ~steady_state_reached
        n_step = n_step + 1;

        U_old = U;
        V_old = V;

        %% Boundary conditions
        for j = 2:J
            V(j,1) = -V(j,2);
            V(j,I+2) = -V(j,I+1);
        end

        for i = 2:I-1
            U(1,i) = -U(2,i);
            U(J+2,i) = 2*U_lid - U(J+1,i);
        end

        %% Predictor
        U_star = U;
        V_star = V;

        %% U-momentum
        for i = 2:I-1
            for j = 2:J+1

                d2u_dx2 = (U(j,i+1) - 2*U(j,i) + U(j,i-1)) / dx^2;
                d2u_dy2 = (U(j+1,i) - 2*U(j,i) + U(j-1,i)) / dy^2;
                diffusion_u = nu * (d2u_dx2 + d2u_dy2);

                Ui  = U(j,i);
                Uip = U(j,i+1);
                Uim = U(j,i-1);

                Fc_u = ((Ui + Uip)/2)^2 - ((Uim + Ui)/2)^2;
                Fd_u = abs((Ui + Uip)/2) * ((Ui - Uip)/2) ...
                     - abs((Uim + Ui)/2) * ((Uim - Ui)/2);

                du2_dx = ((1 - gamma)*Fc_u + gamma*(Fc_u + Fd_u)) / dx;

                vN = 0.5 * (V(j,i) + V(j,i+1));
                vS = 0.5 * (V(j-1,i) + V(j-1,i+1));

                uN = 0.5 * (U(j+1,i) + U(j,i));
                uS = 0.5 * (U(j-1,i) + U(j,i));

                Hc = vN*uN - vS*uS;
                Hd = abs(vN)*(U(j,i) - U(j+1,i))/2 ...
                   - abs(vS)*(U(j-1,i) - U(j,i))/2;

                duv_dy = ((1 - gamma)*Hc + gamma*(Hc + Hd)) / dy;

                convection_u = du2_dx + duv_dy;

                U_star(j,i) = U(j,i) + dt * (diffusion_u - convection_u);
            end
        end

        %% V-momentum
        for i = 2:I+1
            for j = 2:J-1

                d2v_dx2 = (V(j,i+1) - 2*V(j,i) + V(j,i-1)) / dx^2;
                d2v_dy2 = (V(j+1,i) - 2*V(j,i) + V(j-1,i)) / dy^2;
                diffusion_v = nu * (d2v_dx2 + d2v_dy2);

                uE = 0.5 * (U(j,i) + U(j+1,i));
                uW = 0.5 * (U(j,i-1) + U(j+1,i-1));

                vE = 0.5 * (V(j,i+1) + V(j,i));
                vW = 0.5 * (V(j,i-1) + V(j,i));

                Kc = uE*vE - uW*vW;
                Kd = abs(uE)*(V(j,i) - V(j,i+1))/2 ...
                   - abs(uW)*(V(j,i-1) - V(j,i))/2;

                duv_dx = ((1 - gamma)*Kc + gamma*(Kc + Kd)) / dx;

                Vi  = V(j,i);
                Vjp = V(j+1,i);
                Vjm = V(j-1,i);

                Fc_v = ((Vi + Vjp)/2)^2 - ((Vjm + Vi)/2)^2;
                Fd_v = abs((Vi + Vjp)/2) * ((Vi - Vjp)/2) ...
                     - abs((Vjm + Vi)/2) * ((Vjm - Vi)/2);

                dv2_dy = ((1 - gamma)*Fc_v + gamma*(Fc_v + Fd_v)) / dy;

                convection_v = duv_dx + dv2_dy;

                V_star(j,i) = V(j,i) + dt * (diffusion_v - convection_v);
            end
        end

        %% Apply BCs to starred velocities
        for j = 2:J
            V_star(j,1) = -V_star(j,2);
            V_star(j,I+2) = -V_star(j,I+1);
        end

        for i = 2:I-1
            U_star(1,i) = -U_star(2,i);
            U_star(J+2,i) = 2*U_lid - U_star(J+1,i);
        end

        %% Pressure Poisson RHS
        RHS = zeros(J+2, I+2);

        for i = 2:I+1
            for j = 2:J+1
                du_dx = (U_star(j,i) - U_star(j,i-1)) / dx;
                dv_dy = (V_star(j,i) - V_star(j-1,i)) / dy;
                RHS(j,i) = (rho/dt) * (du_dx + dv_dy);
            end
        end

        L_inf_g = max(abs(RHS(:)));
        Tol = max(L_inf_g * Tolfac, 1e-10);

        %% SOR solver
        sor_iter = 0;
        sor_converged = false;
        L_inf_res = Inf;

        while ~sor_converged && sor_iter < MAX_SOR_ITER
            sor_iter = sor_iter + 1;
            P_old = P;

            for i = 2:I+1
                for j = 2:J+1
                    numerator = epsilon_E(j,i)*P(j,i+1) + ...
                                epsilon_W(j,i)*P(j,i-1) + ...
                                epsilon_N(j,i)*P(j+1,i) + ...
                                epsilon_S(j,i)*P(j-1,i) - ...
                                RHS(j,i)*dx^2;

                    denominator = epsilon_E(j,i) + epsilon_W(j,i) + ...
                                  epsilon_N(j,i) + epsilon_S(j,i);

                    P_hat = numerator / denominator;
                    P(j,i) = P_old(j,i) + omega * (P_hat - P_old(j,i));
                end
            end

            if mod(sor_iter, 10) == 0
                residual = zeros(J,I);

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

        %% Corrector
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

        %% Time update
        t = t + dt;
        time_history = [time_history, t];
        sor_iter_history = [sor_iter_history, sor_iter];

        if t > 5.0
            delta_U = sqrt(sum((U(:) - U_old(:)).^2));
            delta_V = sqrt(sum((V(:) - V_old(:)).^2));

            norm_U = sqrt(sum(U(:).^2)) + 1e-12;
            norm_V = sqrt(sum(V(:).^2)) + 1e-12;

            relative_change = 0.5 * (delta_U/norm_U + delta_V/norm_V);

            if relative_change < steady_tol
                steady_state_reached = true;
            end
        end

        if mod(n_step, 100) == 0
            fprintf('gamma=%.1f | step=%5d | t=%8.4f | SOR=%4d | res=%.2e\n', ...
                gamma, n_step, t, sor_iter, L_inf_res);
        end
    end

    fprintf('Finished gamma=%.1f at t=%.4f after %d steps.\n', ...
        gamma, t, n_step);

    %% Cell-centered velocities
    U_center = zeros(J,I);
    V_center = zeros(J,I);

    for i = 1:I
        for j = 1:J
            U_center(j,i) = 0.5 * (U(j+1,i) + U(j+1,i+1));
            V_center(j,i) = 0.5 * (V(j,i+1) + V(j+1,i+1));
        end
    end

    P_interior = P(2:J+1, 2:I+1);
    P_interior = P_interior - mean(P_interior(:));

    result.gamma = gamma;
    result.U_center = U_center;
    result.V_center = V_center;
    result.P = P_interior;
    result.vel_mag = sqrt(U_center.^2 + V_center.^2);
    result.x = x_plot;
    result.y = y_plot;
    result.X = X_plot;
    result.Y = Y_plot;
    result.sor_iter_history = sor_iter_history;
    result.time_history = time_history;
    result.final_time = t;
    result.n_steps = n_step;
    result.dt = dt;
end