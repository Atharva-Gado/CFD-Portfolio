function U_new = rusanov_step(U, gamma, dx, dt)
%RUSANOV_STEP Advance 1D Euler equations by one Rusanov finite-volume step.

    U_new = U;

    num_cells = size(U,2);

    F_half = zeros(3,num_cells-1);

    for i = 1:num_cells-1
        F_half(:,i) = rusanov_flux(U(:,i), U(:,i+1), gamma);
    end

    for i = 2:num_cells-1
        U_new(:,i) = U(:,i) - (dt/dx) * ...
            (F_half(:,i) - F_half(:,i-1));
    end

    % Transmissive boundary conditions
    U_new(:,1)   = U_new(:,2);
    U_new(:,end) = U_new(:,end-1);
end