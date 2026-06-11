function dt = compute_timestep(U, gamma, dx, CFL)
%COMPUTE_TIMESTEP Compute stable timestep using CFL condition.
%
% Inputs:
%   U     = conserved variable matrix
%   gamma = ratio of specific heats
%   dx    = grid spacing
%   CFL   = CFL number
%
% Output:
%   dt    = stable timestep

    [rho, u, p] = conserved_to_primitive(U, gamma);

    a = sqrt(gamma .* p ./ rho);

    max_wave_speed = max(abs(u) + a);

    dt = CFL * dx / max_wave_speed;
end