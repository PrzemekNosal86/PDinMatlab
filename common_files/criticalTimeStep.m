function dt_cr = criticalTimeStep(E, nu, rho, delta)
%% criticalTimeStep.m
% Title: Critical time step estimator for explicit integration
% Author: Przemysław Nosal
% ORCID: 0000-0001-9751-0071
% Affiliation: AGH University of Krakow
% Contact: pnosal@agh.edu.pl
% Date: 2025-04-25
% Version: 1.0
% Description: Estimates the critical time step for an explicit dynamic 
%              peridynamic simulation based on material properties and 
%              horizon. The time step is determined from the characteristic 
%              wave speed of the material (assumed isotropic elasticity).
%              Units must be consistent with the SI system (except stress).
% License: CC-BY 4.0

% -------------------------------------------------------------------------
% INPUTS:
% E      – Young's modulus [N/mm²] (converted to Pa internally)
% nu     – Poisson's ratio [-]
% rho    – Density [kg/mm³]
% delta  – Horizon value [mm]
%
% OUTPUTS:
% dt_cr  – Critical time step [s] for explicit integration
%
% LOCAL VARIABLES:
% c_speed – Characteristic wave propagation speed [mm/s]
% -------------------------------------------------------------------------

% Convert E from [N/mm²] to [Pa] (1 N/mm² = 1e6 Pa)
c_speed = sqrt((2 * E * (1 - nu) * 1e3) / ((1 + nu) * (1 - 2 * nu) * rho));

% Estimate critical time step [s]
dt_cr = delta / c_speed;
