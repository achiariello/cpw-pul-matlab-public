function out = cps_export_s4p_txlineRLCGLine(filename, fmin, fmax, Nfreq, lineLength, Cpul, Lpul, Rpul)
% CPS_EXPORT_S4P_TXLINERLCGLINE Export coupled 4-port S-parameters.
% Computes the 4-port S matrix of a coupled 2-conductor line from full
% per-unit-length RLGC matrices (2x2), then writes standard Touchstone s4p.
%
% Inputs (SI):
%   filename    output Touchstone file (*.s4p)
%   fmin,fmax   frequency limits [Hz]
%   Nfreq       number of frequency points
%   lineLength  physical line length [m]
%   Cpul        constant C matrix:
%               - scalar: converted to coupled form C*[1 -1; -1 1]
%               - 2x2 matrix: used directly
%   Lpul        constant L matrix:
%               - scalar: converted to coupled form (L/2)*[1 -1; -1 1]
%               - 2x2 matrix: used directly
%   Rpul        frequency-dependent R matrix:
%               - scalar: R*I
%               - vector [1xNfreq] or [Nfreqx1]: R(f)*I
%               - matrix [2x2xNfreq]: used directly
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

    freq = logspace(log10(fmin), log10(fmax), Nfreq);
    Cmat = parseC(Cpul);
    Lmat = parseL(Lpul);
    Rmats = parseR(Rpul, Nfreq);
    Gmat = zeros(2, 2);

    S4 = zeros(4, 4, Nfreq);
    Z0 = 50;
    for k = 1:Nfreq
        w = 2 * pi * freq(k);
        Zpul = Rmats(:, :, k) + 1j * w * Lmat;
        Ypul = Gmat + 1j * w * Cmat;

        M = [zeros(2,2), Zpul; Ypul, zeros(2,2)];
        T = expm(M * lineLength);
        A = T(1:2, 1:2);
        B = T(1:2, 3:4);
        C = T(3:4, 1:2);
        D = T(3:4, 3:4);

        Binv = inv(B);
        Y11 = D * Binv;
        Y12 = C - D * Binv * A;
        Y21 = -Binv;
        Y22 = Binv * A;
        Y4 = [Y11, Y12; Y21, Y22];

        Zref = Z0 * eye(4);
        Gref = sqrtm(Zref) * Y4 * sqrtm(Zref);
        S4(:, :, k) = (eye(4) - Gref) / (eye(4) + Gref);
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
        'Rpul_Ohm_per_m', Rmats, ...
        'Lpul_H_per_m', Lmat, ...
        'Cpul_F_per_m', Cmat, ...
        'S4', S4);
end

function Cmat = parseC(Cpul)
    if isscalar(Cpul)
        validateattributes(Cpul, {'numeric'}, {'real','positive'}, mfilename, 'Cpul');
        Cmat = Cpul * [1, -1; -1, 1];
        return;
    end

    validateattributes(Cpul, {'numeric'}, {'real','size',[2 2]}, mfilename, 'Cpul');
    Cmat = Cpul;
end

function Lmat = parseL(Lpul)
    if isscalar(Lpul)
        validateattributes(Lpul, {'numeric'}, {'real','positive'}, mfilename, 'Lpul');
        Lmat = 0.5 * Lpul * [1, -1; -1, 1];
        return;
    end

    validateattributes(Lpul, {'numeric'}, {'real','size',[2 2]}, mfilename, 'Lpul');
    Lmat = Lpul;
end

function Rmats = parseR(Rpul, Nfreq)
    if isscalar(Rpul)
        validateattributes(Rpul, {'numeric'}, {'real','nonnegative'}, mfilename, 'Rpul');
        Rmats = zeros(2, 2, Nfreq);
        for k = 1:Nfreq
            Rmats(:, :, k) = Rpul * eye(2);
        end
        return;
    end

    if isvector(Rpul)
        validateattributes(Rpul, {'numeric'}, {'real','nonnegative','numel',Nfreq}, mfilename, 'Rpul');
        Rv = reshape(Rpul, 1, []);
        Rmats = zeros(2, 2, Nfreq);
        for k = 1:Nfreq
            Rmats(:, :, k) = Rv(k) * eye(2);
        end
        return;
    end

    sz = size(Rpul);
    if numel(sz) == 3 && sz(1) == 2 && sz(2) == 2 && sz(3) == Nfreq
        validateattributes(Rpul, {'numeric'}, {'real','nonnegative'}, mfilename, 'Rpul');
        Rmats = Rpul;
        return;
    end

    error('Unsupported Rpul shape. Use scalar, vector length Nfreq, or 2x2xNfreq.');
end
