% Export 4-port S-parameters (.s4p) using txlineRLCGLine.
% Assumptions:
%   - Cpul and Lpul constant with frequency
%   - Gpul = 0
%   - Rpul(f) from skin-depth model
%   - Port reference impedance Z0 = 50 Ohm (all 4 ports)

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
fmin = 100e9;
fmax = 100e12;
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

% Frequency-dependent Rpul matrix (2x2xN)
rac = cps_rpul_matrix_skin(freq, s, t_au, sigma_au);
Rpul = rac.Rpul_Ohm_per_m;

% Export Touchstone
outfile = fullfile(this_dir, 'gaas_gold_cps_4port_100GHz_100THz.s4p');
out = cps_export_s4p_txlineRLCGLine(outfile, fmin, fmax, Nfreq, lineLength, Cpul, Lpul, Rpul);

% Plot
S = out.S4;
S11_dB = 20 * log10(abs(squeeze(S(1, 1, :))));
S13_dB = 20 * log10(abs(squeeze(S(1, 3, :))));
S24_dB = 20 * log10(abs(squeeze(S(2, 4, :))));
S33_dB = 20 * log10(abs(squeeze(S(3, 3, :))));

fig = figure('Visible', 'off');
semilogx(freq, S11_dB, 'LineWidth', 1.3); hold on;
semilogx(freq, S13_dB, 'LineWidth', 1.3);
semilogx(freq, S24_dB, 'LineWidth', 1.3);
semilogx(freq, S33_dB, 'LineWidth', 1.3);
grid on;
xlabel('Frequency [Hz]');
ylabel('Magnitude [dB]');
title('CPS 4-port S-parameters (Z0 = 50 Ohm)');
legend('|S11|', '|S13|', '|S24|', '|S33|', 'Location', 'best');

plotfile = fullfile(this_dir, 'gaas_gold_cps_4port_100GHz_100THz_plot.png');
exportgraphics(fig, plotfile, 'Resolution', 180);
close(fig);

fprintf('Touchstone file written:\n%s\n', out.filename);
fprintf('Plot written:\n%s\n', plotfile);
fprintf('f-range: %.3f GHz .. %.3f THz, N=%d\n', fmin/1e9, fmax/1e12, Nfreq);
fprintf('Z0 normalization: 50 Ohm on all 4 ports\n');
