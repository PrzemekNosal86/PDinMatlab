function invK = inverseShapeTensor(Xi, GRID, INIBOND, dV, delta, dx, INI_TIME)
%% inverseShapeTensor.m
% Title: Inverse shape tensor calculator for NOSB peridynamics
% Author: Przemysław Nosal
% ORCID: 0000-0001-9751-0071
% Affiliation: AGH University of Krakow
% Contact: pnosal@agh.edu.pl
% Date: 2025-04-25
% Version: 1.0
% Description: Computes the inverse shape tensor for each node in a 
%              non-ordinary state-based peridynamic model. Accounts for
%              broken bonds by excluding their contribution to the tensor.
%              Assumes 2D regular grids embedded in 3D (z-regularized).
% Dependencies: 
%   - influenceFunction.m
% License: CC-BY 4.0

% -------------------------------------------------------------------------
% INPUTS:
% Xi        – matrix of reference bond lengths (same size as INIBOND)
% GRID      – matrix [nodeID, x, y, z]; grid of nodes
% INIBOND   – bond connectivity: each row starts with source node followed 
%             by indices of its family nodes (zeros for padding)
% dV        – nodal volume [mm³] (assumed uniform)
% delta     – peridynamic horizon [mm]
% dx        – grid spacing [mm] (used for optional volume correction)
% INI_TIME  – matrix indicating time of bond failure (0 if bond is intact)
%
% OUTPUTS:
% invK      – inverse shape tensor for each node [N x 9] (flattened 3x3 matrices)
%
% LOCAL VARIABLES:
% idx1, idx2 – indices of source and family nodes
% x1, x2     – coordinates of nodes in reference configuration
% vecXi      – relative bond vector
% xi         – bond length
% omega      – influence function value
% tempK      – accumulated shape tensor
% inverseK   – inverted shape tensor
% -------------------------------------------------------------------------

rows = size(INIBOND, 1);
invK = zeros(rows, 9);

for i = 1:rows
    idx1 = INIBOND(i, 1);
    x1 = GRID(idx1, 2:4);                        % source node coordinates

    tempK = zeros(3, 3);
    tempK(3, 3) = 1;                              % regularization for 2D plane stress

    for j = 2:sum(INIBOND(i, :) ~= 0, 2)
        if INI_TIME(i, j) > 0
            % Bond is broken – no contribution
            continue
        else
            idx2 = INIBOND(i, j);
            x2 = GRID(idx2, 2:4);                 % family node coordinates

            vecXi = x2 - x1;                      % reference bond vector
            xi = Xi(i, j);                        % bond length
            omega = influenceFunction(xi, delta); % influence function value

            % Uncomment below to apply volume correction
            % vc = volumeCorrection(xi, delta, dx);

            % Accumulate shape tensor
            tempK = tempK + omega * (vecXi' * vecXi) * dV;
        end
    end

    % --- DIAGNOSTIC: check if shape tensor is singular or contains NaN ---
    if any(~isfinite(tempK(:)))
        error('Shape tensor at node %d contains NaN or Inf', idx1);
    end
    condK = cond(tempK(1:2,1:2));  % check only in-plane part
    if condK > 1e12
        error('Shape tensor at node %d is nearly singular (cond = %.2e)', idx1, condK);
    end

    % Invert shape tensor (assumed non-singular)
    inverseK = tempK^-1;
    invK(i, :) = reshape(inverseK, [], 1);        % flatten to row
end
