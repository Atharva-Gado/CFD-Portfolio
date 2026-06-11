function F = compute_flux(U, gamma)
%COMPUTE_FLUX Compute physical Euler flux vector.
%
% Inputs:
%   U     = conserved variable matrix
%   gamma = ratio of specific heats
%
% Output:
%   F     = flux vector matrix
%
% Conserved variables:
%   U(1,:) = rho
%   U(2,:) = rho*u
%   U(3,:) = E
%
% Euler flux:
%   F(1,:) = rho*u
%   F(2,:) = rho*u^2 + p
%   F(3,:) = u*(E+p)

    [rho, u, p] = conserved_to_primitive(U, gamma);

    E = U(3,:);

    F = zeros(size(U));

    F(1,:) = rho .* u;
    F(2,:) = rho .* u.^2 + p;
    F(3,:) = u .* (E + p);
end