function [U_n, IdxUknown] = assignDisplacementBC(U_n, IdxUknown, nodeIDs, ux_value, uy_value, uz_value, rx_value, ry_value, rz_value, nDOF)
%% assignDisplacementBC.m
% Title          : Displacement and rotation boundary condition assigner (general nDOF)
% Author         : Przemysław Nosal
% ORCID          : 0000-0001-9751-0071
% Affiliation    : AGH University of Krakow
% Contact        : pnosal@agh.edu.pl
% Date           : 2025-04-28
% Version        : 3.0
% Description    : 
%   Assigns prescribed displacements and/or rotations to specified nodes.
%   Automatically handles cases from 2 DOF (2D translation) up to 6 DOF 
%   (3D translation and rotation). Skips unconstrained directions (NaN).
% Dependencies   : None
% License        : CC-BY 4.0
%
% -------------------------------------------------------------------------
% INPUTS:
% U_n           – displacement/rotation vector [u1;v1;w1;rx1;ry1;rz1;u2;v2;w2;...]
% IdxUknown     – logical vector indicating known DOFs (same size as U_n)
% nodeIDs       – column vector of node indices
% ux_value      – prescribed displacement in x-direction (NaN if unconstrained)
% uy_value      – prescribed displacement in y-direction (NaN if unconstrained)
% uz_value      – prescribed displacement in z-direction (NaN if unconstrained)
% rx_value      – prescribed rotation around x-axis (NaN if unconstrained)
% ry_value      – prescribed rotation around y-axis (NaN if unconstrained)
% rz_value      – prescribed rotation around z-axis (NaN if unconstrained)
% nDOF          – number of degrees of freedom per node (2 ≤ nDOF ≤ 6)
%
% OUTPUTS:
% U_n           – updated displacement/rotation vector
% IdxUknown     – updated logical vector of known DOFs
%
% LOCAL VARIABLES:
% prescribed_values – vector storing prescribed values for all DOFs
% dof_local          – local degree of freedom index (1 to nDOF)
% global_dof         – corresponding global index in U_n and IdxUknown
% -------------------------------------------------------------------------

    if nargin < 10
        error('Function requires ten input arguments.');
    end
    
    if nDOF < 2 || nDOF > 6
        error('nDOF must be between 2 and 6.');
    end

    % Prescribed values array
    prescribed_values = [ux_value, uy_value, uz_value, rx_value, ry_value, rz_value];

    for i = 1:length(nodeIDs)
        idx = nodeIDs(i);
        for dof_local = 1:nDOF
            if ~isnan(prescribed_values(dof_local))
                global_dof = nDOF * (idx - 1) + dof_local;
                U_n(global_dof) = prescribed_values(dof_local);
                IdxUknown(global_dof) = true;
            end
        end
    end
end