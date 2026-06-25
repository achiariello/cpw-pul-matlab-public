% Verify Eq. (6) and Eq. (8) consistency against Table 1 values.
% The paper table reports (per column): C [pF/m], eps_eff, Z [Ohm].
% We identify k0 from Eq. (6), then recompute Z with Eq. (8).

clear; clc;

eps0 = 8.854187817e-12;

tableNames = { ...
    '2g=2 um - This work', ...
    '2g=2 um - [9]', ...
    '2g=4 um - This work', ...
    '2g=4 um - [9]'};

C_pF_per_m = [491, 517, 355, 373];
eps_eff    = [14.0, 14.7, 11.4, 12.0];
Z_table    = [25.4, 24.8, 31.6, 31.0];

n = numel(C_pF_per_m);
k0 = zeros(1, n);
Z_calc = zeros(1, n);
Z_err_pct = zeros(1, n);

for i = 1:n
    C = C_pF_per_m(i) * 1e-12;
    R = C / (eps0 * eps_eff(i)); % R = K(k0')/K(k0) from Eq. (6)

    f = @(x) K_modulus(sqrt(1 - x.^2)) ./ K_modulus(x) - R;
    k0(i) = fzero(f, [1e-12, 1 - 1e-12]);

    Kk0 = K_modulus(k0(i));
    Kk0p = K_modulus(sqrt(1 - k0(i)^2));

    Z_calc(i) = (120 * pi / sqrt(eps_eff(i))) * (Kk0 / Kk0p); % Eq. (8)
    Z_err_pct(i) = 100 * (Z_calc(i) - Z_table(i)) / Z_table(i);
end

T = table(tableNames', C_pF_per_m', eps_eff', Z_table', Z_calc', Z_err_pct', k0', ...
    'VariableNames', {'Case', 'C_pF_per_m', 'eps_eff', 'Z_table_Ohm', 'Z_calc_Ohm', 'Z_error_percent', 'k0'});

disp(T);
fprintf('Max |Z error| = %.4f %%\n', max(abs(Z_err_pct)));

function K = K_modulus(k)
% Complete elliptic integral of the first kind K(k), modulus form.
% MATLAB ellipke uses the parameter m = k^2.
    K = ellipke(k.^2);
end
