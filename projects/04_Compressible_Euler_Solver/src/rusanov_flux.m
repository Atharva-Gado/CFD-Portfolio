function F_half = rusanov_flux(U_left, U_right, gamma)
%RUSANOV_FLUX Compute Rusanov numerical flux at a cell interface.

    F_left  = compute_flux(U_left, gamma);
    F_right = compute_flux(U_right, gamma);

    [rhoL,uL,pL] = conserved_to_primitive(U_left, gamma);
    [rhoR,uR,pR] = conserved_to_primitive(U_right, gamma);

    aL = sqrt(gamma * pL / rhoL);
    aR = sqrt(gamma * pR / rhoR);

    smax = max(abs(uL) + aL, abs(uR) + aR);

    F_half = 0.5 * (F_left + F_right) - 0.5 * smax * (U_right - U_left);
end