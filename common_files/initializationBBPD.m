function [INIBOND, Xi, Beta, dt_cr] = initializationPD(GRID, GRIDpery, m, dx, glot, h, kn, rho)
%% initializationPD.m
% Title: Initialization of peridynamic bonds and critical time step
% Author: Przemysław Nosal
% ORCID: 0000-0001-9751-0071
% Affiliation: AGH University of Krakow
% Contact: pnosal@agh.edu.pl
% Date: 2025-04-25
% Version: 1.0
% Description: Creates peridynamic bond matrix (INIBOND), bond lengths (Xi),
%              and stiffness modifiers (Beta) based on neighborhood search.
%              Also estimates the global critical time step (dt_cr) for 
%              explicit time integration. Loads correction factors (TABb) 
%              based on horizon ratio m.
% Dependencies: Requires TABb<m>.mat correction table to be present.
% License: CC-BY 4.0

% -------------------------------------------------------------------------
% INPUTS:
% GRID       – matrix [nodeID, x, y]; complete grid of all nodes
% GRIDpery   – matrix [nodeID, x, y]; nodes for which bonds are generated
% m          – horizon ratio (delta/dx), integer
% dx         – grid spacing [mm]
% glot       – global numerical tolerance [-]
% h          – thickness of the plate [mm]
% kn         – bond stiffness scaling parameter [N/mm⁴]
% rho        – density [kg/mm³]
%
% OUTPUTS:
% INIBOND    – connectivity matrix [N x (nf+1)]:
%              INIBOND(i,1) = source node i, INIBOND(i,2:end) = family nodes
% Xi         – initial bond lengths for each pair in INIBOND [mm]
% Beta       – stiffness correction factors (from TABb) for each bond [-]
% dt_cr      – estimated global critical time step [s]
%
% LOCAL VARIABLES:
% TABb       – correction table for beta factors, loaded from file
% perySEARCH – subset of GRID within search region around source node
% csi        – bond length (norm of relative position vector)
% denominator– stiffness-weighted sum used in time step estimation
% dt_cr_i    – critical time step estimate for node i
% -------------------------------------------------------------------------

% Load precomputed beta table
load(sprintf('TABb%d.mat', m))

% Define bond list length depending on horizon ratio
switch m
    case 2, inilen = 21;
    case 3, inilen = 36;
    case 4, inilen = 69;
    case 5, inilen = 97;
    case 6, inilen = 137;
    otherwise
        error('Unsupported value of m. TABb table and inilen must be defined.');
end

% Initialize output arrays
INIBOND = zeros(length(GRIDpery), inilen); 
Xi      = zeros(length(GRIDpery), inilen);
Beta    = zeros(length(GRIDpery), inilen);
dt_cr_i = zeros(1, length(GRIDpery));

for i = 1:length(GRIDpery)
    Coo1 = GRIDpery(i, 2:3);          % Source node coordinates
    INIBOND(i, 1) = GRIDpery(i, 1);   % Assign source node ID
    count = 2;                        % Start filling family from column 2
    denominator = 0;                    
    
    % Search for neighboring nodes within m·dx distance (bounding box)
    perySEARCHInd = GRID(:,2) - GRIDpery(i,2) - m*dx <= dx*glot & ...
                    GRID(:,2) - GRIDpery(i,2) + m*dx >= -dx*glot & ...
                    GRID(:,3) - GRIDpery(i,3) - m*dx <= dx*glot & ...
                    GRID(:,3) - GRIDpery(i,3) + m*dx >= -dx*glot;
                
    perySEARCH = GRID(perySEARCHInd, :);

    for j = 1:length(perySEARCH)
        Coo2 = perySEARCH(j, 2:3);           % Family node coordinates
        Vet  = Coo2 - Coo1;                  % Relative position vector
        csi  = norm(Vet);                    % Bond length

        if csi ~= 0 && csi < m*dx + dx/2      % Exclude self and apply cutoff
            INIBOND(i, count) = perySEARCH(j, 1);  % Save family node ID
            Xi(i, count) = csi;                     % Save bond length

            % Retrieve beta correction from table TABb
            beta = TABb(abs(TABb(:,1) - abs(Vet(1)/dx)) < dx*glot & ...
                        abs(TABb(:,2) - abs(Vet(2)/dx)) < dx*glot, 3);

            Beta(i, count) = beta;

            % For time step estimation (volume stiffness contribution)
            denominator = denominator + dx^2 * h / csi;
            count = count + 1;
        end
    end

    % Estimate local critical time step for node i
    dt_cr_i(i) = sqrt(2 * rho / (kn * denominator));
end

% Take the most restrictive (smallest) time step across all nodes
dt_cr = min(dt_cr_i);