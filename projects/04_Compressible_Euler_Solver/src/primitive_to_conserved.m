function U = primitive_to_conserved(rho, u, p, gamma)
%PRIMITIVE_TO_CONSERVED Convert primitive variables to conserved variables.
%
% Primitive variables:
%   rho = density
%   u   = velocity
%   p   = pressure
%
% Conserved variables:
%   U(1,:) = rho
%   U(2,:) = rho*u
%   U(3,:) = E

    E = p./(gamma - 1) + 0.5 .* rho .* u.^2;

    U = zeros(3, length(rho));
    U(1,:) = rho;
    U(2,:) = rho .* u;
    U(3,:) = E;
end