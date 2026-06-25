% Example: CPS with two gold strips on GaAs substrate.
% Geometry:
%   strip width s = 20 um
%   strip thickness t = 1 um (not used by the closed-form model)
%   inner-edge spacing = 50 um  => 2g = 50 um, g = 25 um
%   substrate thickness h = 1 um
%   substrate: GaAs
%
% GaAs relative permittivity source (300 K):
%   Ioffe Institute - Basic Parameters of GaAs
%   https://www.ioffe.ru/SVA/NSM/Semicond/GaAs/basic.html
%   dielectric constant (static) = 12.9
%
% Computed quantities:
%   Cpul [F/m], Z0 [Ohm], Lpul [H/m] with Lpul = Z0^2 * Cpul

clear; clc;

% Geometry [m]
s = 20e-6;
t_au = 1e-6; %#ok<NASGU> % present in the physical description; not in Eq. (1)-(8) model
inner_gap = 50e-6;
g = inner_gap / 2;
h = 1e-6;

% Material
eps_r_gaas = 12.9;

% Make root routines visible
this_file = mfilename('fullpath');
this_dir = fileparts(this_file);
repo_root = fileparts(fileparts(this_dir));
addpath(repo_root);

out = cps_single_layer_params(s, g, h, eps_r_gaas);

Cpul = out.C_F_per_m;
Z0 = out.Z_Ohm;
Lpul = Z0^2 * Cpul;

fprintf('Example: GaAs CPS (s=20 um, 2g=50 um, h=1 um)\n');
fprintf('eps_r(GaAs) = %.3f\n', eps_r_gaas);
fprintf('Cpul = %.6e F/m  (%.6f pF/m)\n', Cpul, Cpul * 1e12);
fprintf('Z0   = %.6f Ohm\n', Z0);
fprintf('Lpul = %.6e H/m  (%.6f nH/m)\n', Lpul, Lpul * 1e9);
