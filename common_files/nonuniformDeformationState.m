function z = nonuniformDeformationState(idx1, idx2, GRID, F, U_n)
%% nonuniformDeformationState.m
% Title: Nonuniform deformation state calculator for NOSB peridynamics
% Author: Przemysław Nosal
% ORCID: 0000-0001-9751-0071
% Affiliation: AGH University of Krakow
% Contact: pnosal@agh.edu.pl
% Date: 2025-04-25
% Version: 1.0
% Description: Computes the nonuniform part of the deformation state vector
%              for a bond between two nodes in a non-ordinary state-based
%              peridynamic formulation. The nonuniform state captures the 
%              deviation from the affine deformation described by F.
% Dependencies: none
% License: CC-BY 4.0

% -------------------------------------------------------------------------
% INPUTS:
% idx1     – index of source node
% idx2     – index of family node
% GRID     – node matrix [nodeID, x, y, z]
% F        – deformation gradient tensor matrix [N x 9] (each row flattened 3x3)
% U_n      – global displacement vector [3*N x 1] (displacements ordered as [u_x1; u_y1; u_z1; ...])
%
% OUTPUTS:
% z        – nonuniform deformation state vector [1x3]
%
% LOCAL VARIABLES:
% x1, x2   – position vectors of source and family nodes
% u1, u2   – displacement vectors at source and family nodes
% vecXi    – relative position vector in reference configuration
% stateY   – deformed bond vector
% tempF    – deformation gradient tensor (3x3 matrix)
% -------------------------------------------------------------------------

x1 = GRID(idx1, 2:4);                % source node coordinates
u1 = U_n(3*idx1-2 : 3*idx1, 1);       % source node displacement
tempF = reshape(F(idx1, :), [3, 3]);  % deformation gradient tensor for source

x2 = GRID(idx2, 2:4);                 % family node coordinates
u2 = U_n(3*idx2-2 : 3*idx2, 1);       % family node displacement

vecXi = x2 - x1;                      % reference bond vector
stateY = (u2' - u1') + vecXi;          % deformed bond vector

% Compute nonuniform deformation state
z = (stateY - (tempF * vecXi')');
