function omega = influenceFunction(xi, delta)
%% influenceFunction.m
% Title: Spherical influence function for peridynamic state models
% Author: Przemysław Nosal
% ORCID: 0000-0001-9751-0071
% Affiliation: AGH University of Krakow
% Contact: pnosal@agh.edu.pl
% Date: 2025-04-25
% Version: 1.0
% Description: Computes the value of a spherical influence function (omega)
%              used in state-based peridynamic models. The function decreases
%              exponentially with respect to the bond length relative to the
%              horizon, ensuring stronger interactions for closer bonds.
% License: CC-BY 4.0

% -------------------------------------------------------------------------
% INPUTS:
% xi     – bond length (scalar) in the reference configuration [mm]
% delta  – peridynamic horizon (interaction radius) [mm]
%
% OUTPUTS:
% omega  – scalar influence weight in the range (0,1)
%
% NOTE:
% The function uses an exponential form:
%   omega(xi) = exp(-(xi^2 / delta^2))
% -------------------------------------------------------------------------

omega = exp(-((xi)^2 / delta^2));
end