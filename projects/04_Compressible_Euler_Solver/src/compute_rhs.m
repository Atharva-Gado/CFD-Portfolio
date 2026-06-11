function RHS = compute_rhs(F, dx)
%COMPUTE_RHS Compute flux-gradient term for Euler equations.
%
% Inputs:
%   F  = flux vector
%   dx = grid spacing
%
% Output:
%   RHS = -dF/dx

    RHS = zeros(size(F));

    for i = 2:size(F,2)-1

        RHS(:,i) = -(F(:,i+1) - F(:,i-1))/(2*dx);

    end

end