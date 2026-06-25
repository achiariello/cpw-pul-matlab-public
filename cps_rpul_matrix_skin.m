function out = cps_rpul_matrix_skin(f, s, t, sigma, mu_r)
% CPS_RPUL_MATRIX_SKIN Per-unit-length resistance matrix with skin effect.
% Inputs (SI):
%   f      frequency [Hz]
%   s      strip width [m]
%   t      strip thickness [m]
%   sigma  conductor conductivity [S/m]
%   mu_r   relative magnetic permeability (optional, default = 1)
%
% Model assumptions:
% 1) Strong skin effect (current confined within skin depth delta).
% 2) Identical strips, same material, balanced CPS.
% 3) Effective conducting perimeter per strip P_eff = 2*(s+t).
% 4) No cross-conductor ohmic coupling in the matrix (off-diagonal = 0).
%
% Useful relations:
%   delta = sqrt(2/(omega*mu*sigma))
%   R_s   = 1/(sigma*delta) = sqrt(pi*f*mu/sigma)
%   R_strip = R_s / P_eff
%   R_pul matrix = [R_strip, 0; 0, R_strip]
%
% Differential-mode series resistance:
%   Rdiff_pul = 2*R_strip

    if nargin < 5
        mu_r = 1;
    end

    validateattributes(f,     {'numeric'}, {'real','positive','scalar'}, mfilename, 'f', 1);
    validateattributes(s,     {'numeric'}, {'real','positive','scalar'}, mfilename, 's', 2);
    validateattributes(t,     {'numeric'}, {'real','positive','scalar'}, mfilename, 't', 3);
    validateattributes(sigma, {'numeric'}, {'real','positive','scalar'}, mfilename, 'sigma', 4);
    validateattributes(mu_r,  {'numeric'}, {'real','positive','scalar'}, mfilename, 'mu_r', 5);

    mu0 = 4 * pi * 1e-7; % [H/m]
    omega = 2 * pi * f;
    mu = mu0 * mu_r;

    delta = sqrt(2 / (omega * mu * sigma)); % [m]
    Rs = 1 / (sigma * delta);               % [Ohm]

    P_eff = 2 * (s + t);                    % [m]
    R_strip = Rs / P_eff;                   % [Ohm/m]

    Rpul = [R_strip, 0; 0, R_strip];
    Rdiff = 2 * R_strip;

    out = struct( ...
        'delta_m', delta, ...
        'delta_um', delta * 1e6, ...
        'Rs_Ohm', Rs, ...
        'P_eff_m', P_eff, ...
        'R_strip_Ohm_per_m', R_strip, ...
        'Rpul_Ohm_per_m', Rpul, ...
        'Rdiff_Ohm_per_m', Rdiff);
end
