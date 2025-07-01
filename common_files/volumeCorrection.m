function vc = volumeCorrection(xi, delta, dx)
%% volumeCorrection.m
% Title: Volume correction function for bond-based peridynamics
% Author: Przemysław Nosal
% ORCID: 0000-0001-9751-0071
% Affiliation: AGH University of Krakow
% Contact: pnosal@agh.edu.pl
% Date: 2025-04-25
% Version: 1.0
% Description: Computes the volume correction factor for a bond based on 
%              its distance relative to the horizon delta. Corrects the 
%              interaction force for bonds near the boundary of the horizon.
%              Correction is linear within a transition region of width dx.
% Dependencies: none
% License: CC-BY 4.0

% -------------------------------------------------------------------------
% INPUTS:
% xi      – bond length [mm] in reference configuration
% delta   – peridynamic horizon (interaction radius) [mm]
% dx      – grid spacing [mm]
%
% OUTPUTS:
% vc      – volume correction factor [-], 0 <= vc <= 1
%
% LOGIC:
% If xi < delta - dx/2 → full volume contribution (vc = 1)
% If delta - dx/2 <= xi <= delta + dx/2 → linear decay of volume
% If xi > delta + dx/2 → no contribution (vc = 0)
% -------------------------------------------------------------------------

if xi < delta - dx/2
    vc = 1;
elseif xi <= delta + dx/2
    vc = (delta + dx/2 - xi) / dx;
else
    vc = 0;
end
