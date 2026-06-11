function [rho, u, p] = conserved_to_primitive(U, gamma)
%CONSERVED_TO_PRIMITIVE Convert conserved variables to primitive variables.
%
% Conserved variables:
%   U(1,:) = rho
%   U(2,:) = rho*u
%   U(3,:) = E

    rho = U(1,:);
    u   = U(2,:) ./ rho;
    E   = U(3,:);

    p = (gamma - 1) .* (E - 0.5 .* rho .* u.^2);
end