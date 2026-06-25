% Export differential 2-port S-parameters (.s2p) using txlineRLCGLine.
% Frequency range: 50 GHz .. 100 GHz (logspace).
% Assumptions:
%   - Cpul and Lpul constant with frequency
%   - Gpul = 0
%   - Rpul(f) from skin-depth model
%   - Port reference impedance Z0 = 50 Ohm

clear; clc;

% Geometry [m]
s = 20e-6;
t_au = 1e-6;
inner_gap = 50e-6;
g = inner_gap / 2;
h = 1e-6;
lineLength = 1e-3; % [m]

% Materials
eps_r_gaas = 12.9;
sigma_au = 4.10e7; % [S/m]

% Frequency sweep
fmin = 50e9;
fmax = 100e9;
Nfreq = 10000;
freq = logspace(log10(fmin), log10(fmax), Nfreq);

% Make root routines visible
this_file = mfilename('fullpath');
this_dir = fileparts(this_file);
repo_root = fileparts(fileparts(this_dir));
addpath(repo_root);

% Quasi-static C and L (constant over frequency)
qs = cps_single_layer_params(s, g, h, eps_r_gaas);
Cpul = qs.C_F_per_m;
Lpul = qs.Z_Ohm^2 * Cpul;

% Frequency-dependent differential Rpul (1xN)
rac = cps_rpul_matrix_skin(freq, s, t_au, sigma_au);
Rpul = rac.Rpul_Ohm_per_m;

% Export Touchstone
outfile = fullfile(this_dir, 'gaas_gold_cps_diff_2port_50GHz_100GHz.s2p');
out = cps_export_s2p_txlineRLCGLine(outfile, fmin, fmax, Nfreq, lineLength, Cpul, Lpul, Rpul, 0);

% Plot
S = out.S2;
S11_dB = 20 * log10(abs(squeeze(S(1, 1, :))));
S21_dB = 20 * log10(abs(squeeze(S(2, 1, :))));

fig = figure('Visible', 'off');
semilogx(freq, S11_dB, 'LineWidth', 1.3); hold on;
semilogx(freq, S21_dB, 'LineWidth', 1.3);
grid on;
xlabel('Frequency [Hz]');
ylabel('Magnitude [dB]');
title('Differential CPS S-parameters (50 GHz .. 100 GHz, Z0 = 50 Ohm)');
legend('|S11|', '|S21|', 'Location', 'best');

plotfile = fullfile(this_dir, 'gaas_gold_cps_diff_2port_50GHz_100GHz_plot.png');
exportgraphics(fig, plotfile, 'Resolution', 180);
close(fig);

fprintf('Touchstone file written:\n%s\n', out.filename);
fprintf('Plot written:\n%s\n', plotfile);
fprintf('f-range: %.3f GHz .. %.3f GHz, N=%d\n', fmin/1e9, fmax/1e9, Nfreq);
fprintf('Z0 normalization: 50 Ohm\n');
