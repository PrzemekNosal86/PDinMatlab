function [INIBOND, Xi] = applyInitialCrack(GRID, INIBOND, Xi, TGx, TGy, dx, m, pcol)
%% applyInitialCrack.m
% Title          : Initial crack generator for NOSB peridynamics
% Author         : Przemysław Nosal
% ORCID          : 0000-0001-9751-0071
% Affiliation    : AGH University of Krakow
% Contact        : pnosal@agh.edu.pl
% Date           : 2025-07-05
% Version        : 1.0
% Description    :
%   Removes all bonds that intersect with an initial crack segment defined 
%   by endpoints (TGx, TGy). Works on regular 2D grids in 3D. The function 
%   modifies both INIBOND and Xi arrays in-place.
% Dependencies   : polyxpoly (Mapping Toolbox or custom)
% License        : CC-BY 4.0
% -------------------------------------------------------------------------
% INPUTS:
% GRID      - [n x 3] array, where columns are [ID, x, y]
% INIBOND   - [n x pcol] matrix, each row: [source_node, family_node_1, ..., family_node_n]
% Xi        - same size as INIBOND, contains bond lengths or vectors
% TGx       - [1 x 2] x-coordinates of initial crack endpoints
% TGy       - [1 x 2] y-coordinates of initial crack endpoints
% dx        - grid spacing
% m         - horizon / dx ratio (or another margin factor)
% pcol      - max number of columns in INIBOND
% -------------------------------------------------------------------------

    % Find nodes in vicinity of the crack
    NoTg = find(GRID(:,2) <= TGx(2) + m*dx & ...
                GRID(:,3) <= TGy(2) + m*dx & ...
                GRID(:,3) >= TGy(2) - m*dx);

    % Loop through each node in vicinity
    for ii = 1:length(NoTg)
        xs = GRID(NoTg(ii),2);
        ys = GRID(NoTg(ii),3);

        riga_ini = find(INIBOND(:,1) == NoTg(ii)); % index in INIBOND
        if isempty(riga_ini)
            continue;
        end
        nnJ = nnz(INIBOND(riga_ini,:));

        kk = 2;
        while kk <= nnJ
            x2 = [xs, GRID(INIBOND(riga_ini,kk),2)];
            y2 = [ys, GRID(INIBOND(riga_ini,kk),3)];

            [xi, yi] = polyxpoly(TGx, TGy, x2, y2);
            if ~isempty([xi, yi])
                if kk ~= pcol
                    INIBOND(riga_ini,kk:pcol-1) = INIBOND(riga_ini,kk+1:pcol);
                    Xi(riga_ini,kk:pcol-1) = Xi(riga_ini,kk+1:pcol);
                    INIBOND(riga_ini,pcol) = 0;
                    Xi(riga_ini,pcol) = 0;
                    kk = kk - 1;
                else
                    INIBOND(riga_ini,kk) = 0;
                    Xi(riga_ini,kk) = 0;
                end
                nnJ = nnz(INIBOND(riga_ini,:));
            end
            kk = kk + 1;
        end
    end
end