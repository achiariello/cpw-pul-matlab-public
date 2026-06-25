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
fmin = 1e9;
fmax = 40e9;
Nfreq = 201;
freq = linspace(fmin, fmax, Nfreq);

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
outfile = fullfile(this_dir, 'gaas_gold_cps_4port.s4p');
out = cps_export_s4p_txlineRLCGLine(outfile, fmin, fmax, Nfreq, lineLength, Cpul, Lpul, Rpul);

fprintf('Touchstone file written:\n%s\n', out.filename);
fprintf('f-range: %.3f .. %.3f GHz, N=%d\n', fmin/1e9, fmax/1e9, Nfreq);
fprintf('Z0 normalization: 50 Ohm on all 4 ports\n');
