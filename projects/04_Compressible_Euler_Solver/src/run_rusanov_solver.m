function [x,rho,u,p] = run_rusanov_solver(N,t_end,gamma,CFL)
%RUN_RUSANOV_SOLVER Run Sod shock tube using Rusanov flux solver.

    x_start = 0.0;
    x_end   = 1.0;

    x = linspace(x_start,x_end,N);
    dx = x(2)-x(1);

    [rho,u,p] = initialize_sod(x);
    U = primitive_to_conserved(rho,u,p,gamma);

    t = 0.0;

    while t < t_end

        dt = compute_timestep(U,gamma,dx,CFL);

        if t + dt > t_end
            dt = t_end - t;
        end

        U = rusanov_step(U,gamma,dx,dt);

        t = t + dt;
    end

    [rho,u,p] = conserved_to_primitive(U,gamma);
end