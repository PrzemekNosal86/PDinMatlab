function F = deformationGradient(Xi, GRID, INIBOND, dV, delta, U_n, invK, INI_TIME)
%% deformationGradient.m
% Title: Deformation gradient calculator for NOSB peridynamics (with damage)
% Author: Przemysław Nosal
% ORCID: 0000-0001-9751-0071
% Affiliation: AGH University of Krakow
% Contact: pnosal@agh.edu.pl
% Date: 2025-04-25
% Version: 1.0
% Description: Computes the deformation gradient tensor F for each node in 
%              a non-ordinary state-based peridynamic formulation, accounting 
%              for bond breakage (damage). Based on the influence function 
%              and inverse shape tensor (invK).
% Dependencies: 
%   - GRID and INIBOND structures (see gridGenerator.m)
%   - influenceFunction.m (user-defined)
% License: CC-BY 4.0

% -------------------------------------------------------------------------
% INPUTS:
% Xi        – matrix of reference bond lengths (same size as INIBOND)
% GRID      – node matrix [nodeID, x, y, z, ...] (minimum 4 columns)
% INIBOND   – bond connectivity: each row begins with a source node 
%             followed by indices of its family nodes (zeros for padding)
% dV        – scalar volume associated with each node (assumed uniform)
% delta     – horizon value used in the influence function
% U_n       – global displacement vector [3*N x 1] (N = number of nodes)
% invK      – inverse shape tensor for each node [N x 9] (flattened 3×3)
% INI_TIME  – matrix indicating time of bond failure (0 if bond is intact)
%
% OUTPUTS:
% F         – deformation gradient tensor for each node [N x 9]
%             (each row corresponds to a flattened 3×3 tensor)
%
% LOCAL VARIABLES:
% idx1, idx2 – indices of source and family nodes
% x1, x2     – coordinates in reference configuration
% u1, u2     – displacement vectors
% vecXi      – bond vector in reference configuration
% stateY     – deformed bond vector
% omega      – influence function value
% tempF      – deformation gradient under accumulation
% -------------------------------------------------------------------------

rows = size(INIBOND, 1);
F = zeros(rows, 9);

for i = 1:rows
    idx1 = INIBOND(i, 1);
    x1 = GRID(idx1, 2:4);                         % source node coordinates
    u1 = U_n(3*idx1 - 2 : 3*idx1, 1);             % source displacement vector

    tempF = zeros(3, 3);
    tempF(3, 3) = 1;                              % regularization for 2D in 3D setup

    for j = 2:sum(INIBOND(i, :) ~= 0, 2)
        if INI_TIME(i, j) > 0
            % Bond is broken — contribution skipped
            continue
        else
            idx2 = INIBOND(i, j);
            x2 = GRID(idx2, 2:4);                 % family node coordinates
            u2 = U_n(3*idx2 - 2 : 3*idx2, 1);     % family node displacement

            vecXi = x2 - x1;                      % reference bond vector
            stateY = (u2' - u1') + vecXi;         % current bond vector
            xi = Xi(i, j);
            omega = influenceFunction(xi, delta); % influence function value

            % Uncomment below to apply volume correction
            % vc = volumeCorrection(xi, delta, dx);

            tempF = tempF + omega * (stateY' * vecXi) * dV;
        end
    end

    % Apply inverse of shape tensor
    tempF = tempF * reshape(invK(i, :), [3, 3]);

    % Store flattened deformation gradient
    F(i, :) = reshape(tempF, [], 1);
end
end