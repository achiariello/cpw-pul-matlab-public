function out = cps_export_s4p_txlineRLCGLine(filename, fmin, fmax, Nfreq, lineLength, Cpul, Lpul, Rpul)
% CPS_EXPORT_S4P_TXLINERLCGLINE Export 4-port S-parameters to Touchstone.
% Uses txlineRLCGLine for each strip line (2-port each), then assembles a
% 4-port network with port mapping (1<->3) and (2<->4).
%
% Inputs (SI):
%   filename    output Touchstone file (*.s4p)
%   fmin,fmax   frequency limits [Hz]
%   Nfreq       number of frequency points
%   lineLength  physical line length [m]
%   Cpul        constant capacitance per unit length [F/m]
%   Lpul        constant inductance per unit length [H/m]
%   Rpul        per-unit-length resistance:
%               - scalar
%               - vector [1xNfreq] or [Nfreqx1]
%               - matrix [2x2xNfreq] (diagonal used as line 1/2 losses)
%
% Fixed model choices requested:
%   - L and C constant with frequency
%   - G = 0
%   - S parameters normalized to 50 Ohm on all 4 ports

    validateattributes(filename,   {'char','string'}, {'nonempty'}, mfilename, 'filename', 1);
    validateattributes(fmin,       {'numeric'}, {'real','positive','scalar'}, mfilename, 'fmin', 2);
    validateattributes(fmax,       {'numeric'}, {'real','positive','scalar','>',fmin}, mfilename, 'fmax', 3);
    validateattributes(Nfreq,      {'numeric'}, {'real','integer','>=',2,'scalar'}, mfilename, 'Nfreq', 4);
    validateattributes(lineLength, {'numeric'}, {'real','positive','scalar'}, mfilename, 'lineLength', 5);
    validateattributes(Cpul,       {'numeric'}, {'real','positive','scalar'}, mfilename, 'Cpul', 6);
    validateattributes(Lpul,       {'numeric'}, {'real','positive','scalar'}, mfilename, 'Lpul', 7);

    freq = linspace(fmin, fmax, Nfreq);
    [R1, R2] = parseRpul(Rpul, Nfreq);
    G = zeros(1, Nfreq);

    tx1 = txlineRLCGLine( ...
        Frequency=freq, ...
        R=R1, ...
        L=Lpul, ...
        C=Cpul, ...
        G=G, ...
        LineLength=lineLength);

    tx2 = txlineRLCGLine( ...
        Frequency=freq, ...
        R=R2, ...
        L=Lpul, ...
        C=Cpul, ...
        G=G, ...
        LineLength=lineLength);

    s1 = sparameters(tx1, freq, 50);
    s2 = sparameters(tx2, freq, 50);

    S4 = zeros(4, 4, Nfreq);
    for k = 1:Nfreq
        s1k = s1.Parameters(:, :, k);
        s2k = s2.Parameters(:, :, k);

        % Line 1: ports 1 (near) and 3 (far)
        S4(1, 1, k) = s1k(1, 1);
        S4(1, 3, k) = s1k(1, 2);
        S4(3, 1, k) = s1k(2, 1);
        S4(3, 3, k) = s1k(2, 2);

        % Line 2: ports 2 (near) and 4 (far)
        S4(2, 2, k) = s2k(1, 1);
        S4(2, 4, k) = s2k(1, 2);
        S4(4, 2, k) = s2k(2, 1);
        S4(4, 4, k) = s2k(2, 2);
    end

    rfwrite(S4, freq, filename, ...
        'Parameter', 'S', ...
        'Format', 'RI', ...
        'FrequencyUnit', 'Hz', ...
        'ReferenceResistance', 50, ...
        'ForceOverwrite', true);

    out = struct( ...
        'filename', char(filename), ...
        'freq_Hz', freq, ...
        'R1_Ohm_per_m', R1, ...
        'R2_Ohm_per_m', R2, ...
        'S4', S4);
end

function [R1, R2] = parseRpul(Rpul, Nfreq)
    if isscalar(Rpul)
        validateattributes(Rpul, {'numeric'}, {'real','nonnegative'}, mfilename, 'Rpul');
        R1 = Rpul * ones(1, Nfreq);
        R2 = Rpul * ones(1, Nfreq);
        return;
    end

    if isvector(Rpul)
        validateattributes(Rpul, {'numeric'}, {'real','nonnegative','numel',Nfreq}, mfilename, 'Rpul');
        R1 = reshape(Rpul, 1, []);
        R2 = R1;
        return;
    end

    sz = size(Rpul);
    if numel(sz) == 3 && sz(1) == 2 && sz(2) == 2 && sz(3) == Nfreq
        validateattributes(Rpul, {'numeric'}, {'real','nonnegative'}, mfilename, 'Rpul');
        cross12 = squeeze(Rpul(1,2,:));
        cross21 = squeeze(Rpul(2,1,:));
        if any(abs(cross12) > 0) || any(abs(cross21) > 0)
            error('Rpul off-diagonal terms are non-zero: this routine uses uncoupled txlineRLCGLine branches.');
        end
        R1 = reshape(squeeze(Rpul(1,1,:)), 1, []);
        R2 = reshape(squeeze(Rpul(2,2,:)), 1, []);
        return;
    end

    error('Unsupported Rpul shape. Use scalar, vector length Nfreq, or 2x2xNfreq.');
end
