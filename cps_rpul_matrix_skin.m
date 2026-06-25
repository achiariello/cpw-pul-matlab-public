function out = cps_rpul_matrix_skin(f, s, t, sigma, mu_r)
% CPS_RPUL_MATRIX_SKIN Differential per-unit-length resistance with skin effect.
% Inputs (SI):
%   f      frequency [Hz] (scalar or vector)
%   s      strip width [m]
%   t      strip thickness [m]
%   sigma  conductor conductivity [S/m]
%   mu_r   relative magnetic permeability (optional, default = 1)
%
% Differential-mode assumptions:
% 1) Two identical strips carry equal and opposite currents.
% 2) Current penetrates from conductor boundaries with skin depth delta.
% 3) If delta is large enough to fully penetrate the conductor cross-section,
%    the strip is modeled with uniform current over the full area s*t.
%
% Useful relations:
%   delta = sqrt(2/(omega*mu*sigma))
%   R_s   = 1/(sigma*delta) = sqrt(pi*f*mu/sigma)
%   Aeff_strip = s*t - max(s-2*delta,0)*max(t-2*delta,0)
%   R_strip = 1/(sigma*Aeff_strip)
%   Rdiff_pul = 2*R_strip

    if nargin < 5
        mu_r = 1;
    end

    validateattributes(f,     {'numeric'}, {'real','positive','vector'}, mfilename, 'f', 1);
    validateattributes(s,     {'numeric'}, {'real','positive','scalar'}, mfilename, 's', 2);
    validateattributes(t,     {'numeric'}, {'real','positive','scalar'}, mfilename, 't', 3);
    validateattributes(sigma, {'numeric'}, {'real','positive','scalar'}, mfilename, 'sigma', 4);
    validateattributes(mu_r,  {'numeric'}, {'real','positive','scalar'}, mfilename, 'mu_r', 5);

    mu0 = 4 * pi * 1e-7; % [H/m]
    omega = 2 * pi * f;
    mu = mu0 * mu_r;

    f = f(:).';
    delta = sqrt(2 ./ (omega * mu * sigma)); % [m]
    Rs = 1 ./ (sigma .* delta);               % [Ohm]

    fullArea = s * t;                         % [m^2]
    innerW = max(s - 2 .* delta, 0);
    innerT = max(t - 2 .* delta, 0);
    Aeff = fullArea - (innerW .* innerT);     % [m^2]
    Aeff = min(max(Aeff, eps(fullArea)), fullArea); % numerical safety
    R_strip = 1 ./ (sigma .* Aeff);           % [Ohm/m]
    Rdiff = 2 * R_strip;

    out = struct( ...
        'freq_Hz', f, ...
        'delta_m', delta, ...
        'delta_um', delta * 1e6, ...
        'Rs_Ohm', Rs, ...
        'Aeff_m2', Aeff, ...
        'A_full_m2', fullArea, ...
        'is_fully_penetrated', (delta >= min(s, t) / 2), ...
        'R_strip_Ohm_per_m', R_strip, ...
        'Rpul_Ohm_per_m', Rdiff, ...
        'Rdiff_Ohm_per_m', Rdiff);
end
