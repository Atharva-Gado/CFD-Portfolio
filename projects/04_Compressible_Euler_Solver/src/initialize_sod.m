function [rho, u, p] = initialize_sod(x)
%INITIALIZE_SOD Initialize Sod shock tube primitive variables.
%
% Inputs:
%   x = spatial grid
%
% Outputs:
%   rho = density
%   u   = velocity
%   p   = pressure

    rho = zeros(size(x));
    u   = zeros(size(x));
    p   = zeros(size(x));

    rho(x < 0.5)  = 1.0;
    rho(x >= 0.5) = 0.125;

    u(:) = 0.0;

    p(x < 0.5)  = 1.0;
    p(x >= 0.5) = 0.1;
end