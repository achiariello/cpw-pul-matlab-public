function out = cps_single_layer_params(s, g, h, eps_r)
% CPS_SINGLE_LAYER_PARAMS Single-layer CPS parameters from Gevorgian & Berg.
% Inputs are in SI units:
%   s     strip width [m]
%   g     half-gap (spacing is 2g) [m]
%   h     substrate thickness [m]
%   eps_r substrate relative permittivity
%
% Implemented equations (paper numbering):
%   (1)  k  = tanh(pi*g/(2h)) / tanh(pi*(s+g)/(2h))
%   (5)  k0 = g/(s+g), k' = sqrt(1-k^2), k0' = sqrt(1-k0^2)
%   (7)  q  = 1/2 * K(k')/K(k) * K(k0)/K(k0')
%   (6)  C  = eps0*eps_eff1 * K(k0')/K(k0)
%   (8)  Z  = 120*pi/sqrt(eps_eff1) * K(k0)/K(k0')
%
% NOTE on MATLAB elliptic integrals:
%   Paper uses modulus k; MATLAB ellipke uses parameter m = k^2.
%   Therefore K(k) is computed as ellipke(k^2).

    validateattributes(s,     {'numeric'}, {'real','positive','scalar'}, mfilename, 's', 1);
    validateattributes(g,     {'numeric'}, {'real','positive','scalar'}, mfilename, 'g', 2);
    validateattributes(h,     {'numeric'}, {'real','positive','scalar'}, mfilename, 'h', 3);
    validateattributes(eps_r, {'numeric'}, {'real','>=',1,'scalar'},     mfilename, 'eps_r', 4);

    eps0 = 8.854187817e-12; % [F/m]

    k  = tanh(pi * g / (2 * h)) / tanh(pi * (s + g) / (2 * h)); % Eq. (1)
    k0 = g / (s + g);                                             % Eq. (5)

    kp  = sqrt(1 - k^2);
    k0p = sqrt(1 - k0^2);

    Kk   = K_modulus(k);
    Kkp  = K_modulus(kp);
    Kk0  = K_modulus(k0);
    Kk0p = K_modulus(k0p);

    q = 0.5 * (Kkp / Kk) * (Kk0 / Kk0p); % Eq. (7)
    eps_eff1 = 1 + (eps_r - 1) * q;

    C = eps0 * eps_eff1 * (Kk0p / Kk0);                    % Eq. (6) [F/m]
    Z = (120 * pi / sqrt(eps_eff1)) * (Kk0 / Kk0p);        % Eq. (8) [Ohm]

    out = struct( ...
        'k', k, ...
        'k0', k0, ...
        'kp', kp, ...
        'k0p', k0p, ...
        'Kk', Kk, ...
        'Kkp', Kkp, ...
        'Kk0', Kk0, ...
        'Kk0p', Kk0p, ...
        'q', q, ...
        'eps_eff1', eps_eff1, ...
        'C_F_per_m', C, ...
        'C_pF_per_m', C * 1e12, ...
        'Z_Ohm', Z);
end

function K = K_modulus(k)
% Complete elliptic integral of the first kind K(k), modulus form.
% MATLAB ellipke expects m = k^2.
    m = k.^2;
    K = ellipke(m);
end
