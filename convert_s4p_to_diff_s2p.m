function out = convert_s4p_to_diff_s2p(inputS4P, outputS2P, conductor1, conductor2, varargin)
% CONVERT_S4P_TO_DIFF_S2P Convert single-ended 4-port S4P to differential S2P.
%
% Usage:
%   out = convert_s4p_to_diff_s2p(inputS4P, outputS2P, [p1 p2], [p3 p4])
%
% Inputs:
%   inputS4P   path to input Touchstone .s4p
%   outputS2P  path to output Touchstone .s2p
%   conductor1 [t1 t2] terminals of conductor #1 (first side, second side)
%   conductor2 [t1 t2] terminals of conductor #2 (first side, second side)
%
% Example:
%   [1 3], [2 4] means:
%     conductor #1: terminal-1 is port 1, terminal-2 is port 3
%     conductor #2: terminal-1 is port 2, terminal-2 is port 4
%
% Name-Value options:
%   'ExpectedZ0'                expected input SE reference impedance (default 50)
%   'Z0Tolerance'               absolute tolerance for Z0 check (default 1e-9)
%   'OutputReferenceResistance' output differential S2P reference impedance (default 100)
%
% Output:
%   out struct with fields:
%     .input_file
%     .output_file
%     .input_z0
%     .output_z0
%     .port_order_used        [c1(1) c2(1) c1(2) c2(2)]
%     .freq_Hz
%     .Sdd                    2x2xN differential S parameters

    p = inputParser;
    addParameter(p, 'ExpectedZ0', 50);
    addParameter(p, 'Z0Tolerance', 1e-9);
    addParameter(p, 'OutputReferenceResistance', 100);
    parse(p, varargin{:});

    expectedZ0 = p.Results.ExpectedZ0;
    z0Tol = p.Results.Z0Tolerance;
    outputZ0 = p.Results.OutputReferenceResistance;

    validateattributes(inputS4P, {'char','string'}, {'nonempty'}, mfilename, 'inputS4P', 1);
    validateattributes(outputS2P, {'char','string'}, {'nonempty'}, mfilename, 'outputS2P', 2);
    validateattributes(conductor1, {'numeric'}, {'integer','numel',2,'>=',1,'<=',4}, mfilename, 'conductor1', 3);
    validateattributes(conductor2, {'numeric'}, {'integer','numel',2,'>=',1,'<=',4}, mfilename, 'conductor2', 4);
    validateattributes(expectedZ0, {'numeric'}, {'real','positive','scalar'}, mfilename, 'ExpectedZ0');
    validateattributes(z0Tol, {'numeric'}, {'real','positive','scalar'}, mfilename, 'Z0Tolerance');
    validateattributes(outputZ0, {'numeric'}, {'real','positive','scalar'}, mfilename, 'OutputReferenceResistance');

    ports = [conductor1(:); conductor2(:)].';
    if numel(unique(ports)) ~= 4
        error('Conductor terminal assignment is invalid: ports must be four unique values in [1..4].');
    end

    s4 = sparameters(inputS4P);
    freq = s4.Frequencies;
    Sse = s4.Parameters;
    Zin = double(s4.Impedance);
    zinVals = Zin(:);
    if any(abs(zinVals - expectedZ0) > z0Tol)
        error('Input Touchstone reference impedance is not %.12g Ohm on all ports/frequencies.', expectedZ0);
    end

    % Reorder ports as [cond1_side1, cond2_side1, cond1_side2, cond2_side2]
    pord = [conductor1(1), conductor2(1), conductor1(2), conductor2(2)];

    % Mixed-mode transform for each side:
    % [ad; ac] = [ 1/sqrt(2)  -1/sqrt(2); 1/sqrt(2) 1/sqrt(2) ] * [a1; a2]
    M = (1/sqrt(2)) * [ ...
        1, -1,  0,  0; ...
        1,  1,  0,  0; ...
        0,  0,  1, -1; ...
        0,  0,  1,  1];

    nFreq = numel(freq);
    Sdd = zeros(2, 2, nFreq);

    for k = 1:nFreq
        S4k = Sse(:, :, k);
        S4k = S4k(pord, pord);

        Smm = M * S4k * M.';       % M is orthonormal, inverse is transpose
        Sdd(:, :, k) = Smm([1, 3], [1, 3]); % keep differential ports only
    end

    rfwrite(Sdd, freq, outputS2P, ...
        'Parameter', 'S', ...
        'Format', 'RI', ...
        'FrequencyUnit', 'Hz', ...
        'ReferenceResistance', outputZ0, ...
        'ForceOverwrite', true);

    out = struct( ...
        'input_file', char(inputS4P), ...
        'output_file', char(outputS2P), ...
        'input_z0', expectedZ0, ...
        'output_z0', outputZ0, ...
        'port_order_used', pord, ...
        'freq_Hz', freq, ...
        'Sdd', Sdd);
end
