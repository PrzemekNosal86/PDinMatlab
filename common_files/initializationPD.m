function [INIBOND, Xi] = initializationPD(GRID, m, dx, glot)
%% initializationPD.m
% Title: Initialization of peridynamic bonds and bond lengths (simple version)
% Author: Przemysław Nosal
% ORCID: 0000-0001-9751-0071
% Affiliation: AGH University of Krakow
% Contact: pnosal@agh.edu.pl
% Date: 2025-04-25
% Version: 1.0
% Description: Creates the bond connectivity matrix (INIBOND) and the 
%              initial bond lengths (Xi) for each node based on proximity.
%              This simplified version does not compute stiffness correction
%              factors (Beta) or critical time step (dt_cr).
% Dependencies: none
% License: CC-BY 4.0

% -------------------------------------------------------------------------
% INPUTS:
% GRID     – matrix [nodeID, x, y]; grid of nodes in the domain
% m        – horizon to grid spacing ratio (delta/dx)
% dx       – grid spacing [mm]
% glot     – global numerical tolerance coefficient [-]
%
% OUTPUTS:
% INIBOND  – connectivity matrix [N x (nf+1)]:
%            INIBOND(i,1) = source node ID, INIBOND(i,2:end) = family node IDs
% Xi       – initial bond lengths corresponding to each entry in INIBOND [mm]
%
% LOCAL VARIABLES:
% perySEARCHInd – logical array selecting candidate family nodes
% perySEARCH    – subset of nodes in the search region
% Coo1, Coo2    – coordinates of source and candidate family nodes
% Vet           – relative position vector
% csi           – bond length (norm of Vet)
% count         – current family node counter
% -------------------------------------------------------------------------

% Define bond list length depending on horizon ratio
switch m
    case 2, inilen = 21;
    case 3, inilen = 36;
    case 4, inilen = 69;
    case 5, inilen = 97;
    case 6, inilen = 137;
    otherwise
        error('Unsupported value of m. "inilen" must be defined manually.');
end

% Initialize output arrays
INIBOND = zeros(length(GRID), inilen); 
Xi      = zeros(length(GRID), inilen);

% Loop over all nodes
for i = 1:length(GRID)
    Coo1 = GRID(i, 2:3);                % Source node coordinates
    INIBOND(i, 1) = GRID(i, 1);          % Assign source node ID
    count = 2;                           % Start from second column (family)

    % Search for candidate family nodes within a square of size 2*m*dx
    perySEARCHInd = GRID(:,2) - GRID(i,2) - m*dx <= dx*glot & ...
                    GRID(:,2) - GRID(i,2) + m*dx >= -dx*glot & ...
                    GRID(:,3) - GRID(i,3) - m*dx <= dx*glot & ...
                    GRID(:,3) - GRID(i,3) + m*dx >= -dx*glot;
    perySEARCH = GRID(perySEARCHInd, :);

    for j = 1:length(perySEARCH)
        Coo2 = perySEARCH(j, 2:3);       % Family node coordinates
        Vet  = Coo2 - Coo1;              % Relative vector
        csi  = norm(Vet);                % Bond length

        if csi ~= 0                      % Exclude self
            if csi < m*dx + dx/2          % Accept only if within horizon
                INIBOND(i, count) = perySEARCH(j, 1);  % Save family node ID
                Xi(i, count) = csi;                    % Save bond length
                count = count + 1;                     % Increment counter
            end
        end
    end
end
