function [L, post_stress, post_strain] = elasticForceStateNew(Xi, GRID, INIBOND, dV, delta, C, F, invK, I, dx, U_n, INI_TIME, c_BB, L)
%% elasticForceState.m
% Title: Elastic force and stress-strain state calculator for NOSB peridynamics
% Author: Przemysław Nosal
% ORCID: 0000-0001-9751-0071
% Affiliation: AGH University of Krakow
% Contact: pnosal@agh.edu.pl
% Date: 2025-04-25
% Version: 1.0
% Description: Computes nodal internal forces, stresses, and strains for a
%              non-ordinary state-based peridynamic elastic material.
%              Includes volume correction and broken bond handling.
% Dependencies: 
%   - influenceFunction.m
%   - volumeCorrection.m
%   - nonuniformDeformationState.m
% License: CC-BY 4.0

% -------------------------------------------------------------------------
% INPUTS:
% Xi          – matrix of reference bond lengths [N x nf]
% GRID        – node matrix [nodeID, x, y, z]
% INIBOND     – bond connectivity matrix [N x (nf+1)]
% dV          – nodal volume [mm³]
% delta       – peridynamic horizon [mm]
% C           – material stiffness matrix (elastic)
% F           – deformation gradient tensor matrix [N x 9]
% invK        – inverse shape tensor matrix [N x 9]
% I           – identity tensor (3x3)
% T           – internal force vector [3*N x 1] (updated in-place)
% L           – global internal force vector [3*N x 1]; updated in-place
% dx          – grid spacing [mm]
% U_n         – displacement vector [3*N x 1]
% INI_TIME    – bond damage matrix (0 if intact, >0 if broken)
%
% OUTPUTS:
% L           – updated internal force vector [3*N x 1]
% post_stress – stress vector for each node [3*N x 1]
% post_strain – strain vector for each node [3*N x 1]
% -------------------------------------------------------------------------

rows = size(INIBOND, 1);
post_stress = zeros(3*rows, 1);
post_strain = zeros(3*rows, 1);
T = zeros(3*rows,1);

for i = 1:rows
    idx1 = INIBOND(i, 1);
    idx1_local = (idx1-1)*3 + (1:3); % Local indices for displacement and force

    x1 = GRID(idx1, 2:4);               % Source node coordinates
    tempK = reshape(invK(i, :), [3, 3]);
    tempF = reshape(F(i, :), [3, 3]);
    detF = det(tempF);

    % --- DIAGNOSTICS: check for NaN/Inf in deformation gradient and K ---
    if any(~isfinite(tempF(:)))
        error('F contains NaN or Inf at node %d', idx1);
    end
    if any(~isfinite(tempK(:)))
        error('invK contains NaN or Inf at node %d', idx1);
    end
    if ~isfinite(detF)
        error('det(F) is NaN or Inf at node %d', idx1);
    end

    % Calculate strain and stress tensors
    epsilon_matrix = 0.5 * (tempF' + tempF) - I;
    epsilon = [epsilon_matrix(1,1); epsilon_matrix(2,2); epsilon_matrix(1,2)];
    sigma = C * epsilon;

    % Construct stress tensor
    sigma_matrix = zeros(3,3);
    sigma_matrix(1,1) = sigma(1);
    sigma_matrix(2,2) = sigma(2);
    sigma_matrix(1,2) = sigma(3);
    sigma_matrix(2,1) = sigma(3);

    % Store nodal stress and strain
    post_stress(3*i-2:3*i, 1) = sigma;
    post_strain(3*i-2:3*i, 1) = epsilon;

    % Retrieve number of family nodes
    non_zero = nnz(INIBOND(i, :));

    for j = 2:non_zero
        if INI_TIME(i, j) > 0
            % Bond is broken – skip contribution
            continue
        end

        idx2 = INIBOND(i, j);

        x2 = GRID(idx2, 2:4);            % Family node coordinates
        vecXi = x2 - x1;
        xi = Xi(i, j);

        Cz = c_BB * (vecXi' * vecXi)/(norm(vecXi))^3;

        omega = influenceFunction(xi, delta);
        vc = volumeCorrection(xi, delta, dx);

        % Nonuniform deformation state
        z = nonuniformDeformationState(idx1, idx2, GRID, F, U_n);

        % Force update
        force_update = omega * (detF * sigma_matrix * (inv(tempF))' * tempK * vecXi') * (vc * dV) + ...
                       0.5 * vc * omega * Cz * z';

        if any(~isfinite(force_update))
            error('force_update NaN/Inf at node %d → node %d', idx1, idx2);
        end

        T(idx1_local,1) = T(idx1_local,1) + force_update;
    end
end

for i = 1:rows
    idx1 = INIBOND(i, 1);
    idx1_local = (idx1-1)*3 + (1:3); % Local indices for displacement and force
    % Retrieve number of family nodes
    non_zero = nnz(INIBOND(i, :));
    for j = 2:non_zero
        if INI_TIME(i, j) > 0
            % Bond is broken – skip contribution
            continue
        end
        idx2 = INIBOND(i, j);
        idx2_local = (idx2-1)*3 + (1:3); % Local indices
        dL = T(idx1_local,1) - T(idx2_local,1);

        if any(~isfinite(dL))
            error('L increment NaN/Inf at pair %d → %d', idx1, idx2);
        end

        L(idx1_local,1) = L(idx1_local,1) + dL;
    end
end

% Final check
if any(~isfinite(L))
    error('Internal force vector L contains NaN or Inf!');
end

end