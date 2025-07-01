function Lambda = computeLambda(nDOF, DOF, nnods, GRID, INIBOND, INI_TIME, c, dt, delta, dx, h)
%% computeLambda.m
% Title        : Compute diagonal fictitious mass matrix for DRM
% Author       : Przemysław Nosal
% ORCID        : 0000-0001-9751-0071
% Affiliation  : AGH University of Krakow, Faculty of Mechanical Engineering and Robotics
% Contact      : pnosal@agh.edu.pl
% Date         : 2025-05-05
% Version      : 2.0
% Description  : Computes the diagonal entries of the fictitious mass matrix (Lambda)
%                based on Gerschgorin's theorem and a simplified estimation of the
%                peridynamic bond stiffness. Micromodulus is calculated automatically
%                from material properties and the horizon radius.
% License      : CC-BY 4.0
%
% -------------------------------------------------------------------------
% INPUTS:
%   nDOF     – number of degrees of freedom per node (2 for 2D, 3 for 3D)
%   DOF      – total number of degrees of freedom (nDOF * nnods)
%   nnods    – number of nodes in the grid
%   GRID     – nodal coordinates [nnods x (1+dim+1)] format: [ID, x, y, z, (massFactor)]
%   INIBOND  – connectivity matrix [nnods x M], each row: [i, neighbors...]
%   c        – micromodulus [MPa/mm^dimension]
%   dt       – time step size [s]
%
% OUTPUT:
%   Lambda    – vector [nDOF*N x 1], fictitious mass values for each DOF
%
% NOTES:
% - The code determines 2D or 3D problem from the number of columns in GRID.
% - Lambda is constant during simulation and should be computed once.
% -------------------------------------------------------------------------

% Initialize output vector
Lambda = zeros(DOF, 1);

% Loop over all nodes
for i = 1:nnods
    %xi = GRID(i, 2:4);
    %neighbors = INIBOND(i, 2:end);
    %neighbors = neighbors(neighbors > 0);

    %stiffness_sum = 0;

    % for j = neighbors
    %     % if INI_TIME(i, j) > 0
    %     %     % Bond is broken – skip contribution
    %     %     continue
    %     % end
    %     xj = GRID(j, 2:4);
    %     dx = xj - xi;
    %     r = norm(dx);
    %     if r > 0
    %         %stiffness_sum = stiffness_sum + c * r;
    %         stiffness_sum = stiffness_sum + 5 * pi * delta^2 * c;
    %     end
    % end

    %lambda_i = (1/4) * dt^2 * stiffness_sum;
    lambda_i = (1/4) * dt^2 * (pi * delta^2 * h * c) / dx;
    for d = 1:nDOF
        Lambda(nDOF*(i-1) + d) = lambda_i;
    end
end
end