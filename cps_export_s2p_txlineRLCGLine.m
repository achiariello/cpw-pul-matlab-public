function out = cps_export_s2p_txlineRLCGLine(filename, fmin, fmax, Nfreq, lineLength, Cpul, Lpul, Rpul, Gpul)
% CPS_EXPORT_S2P_TXLINERLCGLINE Export differential 2-port S-parameters.
% Uses txlineRLCGLine with scalar per-unit-length RLGC parameters.
%
% Inputs (SI):
%   filename    output Touchstone file (*.s2p)
%   fmin,fmax   frequency limits [Hz]
%   Nfreq       number of frequency points
%   lineLength  physical line length [m]
%   Cpul        differential capacitance per unit length [F/m] (scalar)
%   Lpul        differential inductance per unit length [H/m] (scalar)
%   Rpul        differential resistance per unit length [Ohm/m]:
%               - scalar
%               - vector [1xNfreq] or [Nfreqx1]
%   Gpul        differential conductance per unit length [S/m]:
%               - scalar or vector (optional, default 0)
%
% Model choices:
%   - C and L constant with frequency
%   - R frequency-dependent
%   - default G = 0
%   - S-parameters normalized to 50 Ohm

    if nargin < 9
        Gpul = 0;
    end

    validateattributes(filename,   {'char','string'}, {'nonempty'}, mfilename, 'filename', 1);
    validateattributes(fmin,       {'numeric'}, {'real','positive','scalar'}, mfilename, 'fmin', 2);
    validateattributes(fmax,       {'numeric'}, {'real','positive','scalar','>',fmin}, mfilename, 'fmax', 3);
    validateattributes(Nfreq,      {'numeric'}, {'real','integer','>=',2,'scalar'}, mfilename, 'Nfreq', 4);
    validateattributes(lineLength, {'numeric'}, {'real','positive','scalar'}, mfilename, 'lineLength', 5);
    validateattributes(Cpul,       {'numeric'}, {'real','positive','scalar'}, mfilename, 'Cpul', 6);
    validateattributes(Lpul,       {'numeric'}, {'real','positive','scalar'}, mfilename, 'Lpul', 7);

    freq = logspace(log10(fmin), log10(fmax), Nfreq);
    R = parseFreqArray(Rpul, Nfreq, 'Rpul');
    G = parseFreqArray(Gpul, Nfreq, 'Gpul');

    tl = txlineRLCGLine( ...
        Frequency=freq, ...
        R=R, ...
        L=Lpul, ...
        C=Cpul, ...
        G=G, ...
        LineLength=lineLength);

    Sobj = sparameters(tl, freq, 50);
    S2 = Sobj.Parameters;

    rfwrite(S2, freq, filename, ...
        'Parameter', 'S', ...
        'Format', 'RI', ...
        'FrequencyUnit', 'Hz', ...
        'ReferenceResistance', 50, ...
        'ForceOverwrite', true);

    out = struct( ...
        'filename', char(filename), ...
        'freq_Hz', freq, ...
        'Rpul_Ohm_per_m', R, ...
        'Lpul_H_per_m', Lpul, ...
        'Cpul_F_per_m', Cpul, ...
        'Gpul_S_per_m', G, ...
        'S2', S2);
end

function v = parseFreqArray(x, Nfreq, varName)
    if isscalar(x)
        validateattributes(x, {'numeric'}, {'real','nonnegative'}, mfilename, varName);
        v = x * ones(1, Nfreq);
        return;
    end

    if isvector(x)
        validateattributes(x, {'numeric'}, {'real','nonnegative','numel',Nfreq}, mfilename, varName);
        v = reshape(x, 1, []);
        return;
    end

    error('%s must be scalar or a vector with Nfreq elements.', varName);
end
