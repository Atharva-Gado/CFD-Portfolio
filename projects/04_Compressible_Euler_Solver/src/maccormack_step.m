function U_new = maccormack_step(U, gamma, dx, dt)
%MACCORMACK_STEP Advance 1D Euler equations by one MacCormack step.
%
% Predictor: forward difference
% Corrector: backward difference

    F = compute_flux(U, gamma);

    U_pred = U;

    % Predictor step
    for i = 2:size(U,2)-1
        U_pred(:,i) = U(:,i) - (dt/dx) * (F(:,i+1) - F(:,i));
    end

    % Boundary conditions: transmissive copy
    U_pred(:,1)   = U_pred(:,2);
    U_pred(:,end) = U_pred(:,end-1);

    F_pred = compute_flux(U_pred, gamma);

    U_new = U;

    % Corrector step
    for i = 2:size(U,2)-1
        U_new(:,i) = 0.5 * ( ...
            U(:,i) + U_pred(:,i) ...
            - (dt/dx) * (F_pred(:,i) - F_pred(:,i-1)) ...
        );
    end

        % Artificial viscosity for shock stabilization
    epsilon = 0.2;

    U_visc = U_new;

    for i = 2:size(U,2)-1
        U_visc(:,i) = U_new(:,i) + epsilon * ...
            (U_new(:,i+1) - 2*U_new(:,i) + U_new(:,i-1));
    end

    U_new = U_visc;

    % Boundary conditions: transmissive copy
    U_new(:,1)   = U_new(:,2);
    U_new(:,end) = U_new(:,end-1);
end