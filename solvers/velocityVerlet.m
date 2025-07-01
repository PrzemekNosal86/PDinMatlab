function [U_nP1, V_nP1, a_nP1] = velocityVerlet(dt, rho, U_n, V_nM1, a_n, T, IdxUknown)
%% velocityVerlet.m
% Title        : Velocity Verlet time integration solver with enforced boundary conditions
% Author       : Przemysław Nosal
% ORCID        : 0000-0001-9751-0071
% Affiliation  : AGH University of Krakow
% Contact      : pnosal@agh.edu.pl
% Date         : 2025-04-25
% Version      : 2.0
% Description  : Advances nodal displacements, velocities, and accelerations
%                using the Velocity Verlet scheme with artificial damping.
%                Enforces prescribed boundary conditions after each update step.
% Dependencies : None
% License      : CC-BY 4.0
%
% -------------------------------------------------------------------------
% INPUTS:
%   dt         – time step size [s]
%   rho        – mass density [kg/mm³]
%   U_n        – displacement vector at current time step [nDOF*N x 1]
%   V_nM1      – velocity vector at previous time step [nDOF*N x 1]
%   a_n        – acceleration vector at current time step [nDOF*N x 1]
%   T          – internal force vector at current time step [nDOF*N x 1]
%   IdxUknown  – logical vector indicating known DOFs (true for constrained DOFs)
%
% OUTPUTS:
%   U_nP1      – updated displacement vector at next time step
%   V_nP1      – updated velocity vector at next full-time step
%   a_nP1      – updated acceleration vector at next time step
%
% LOCAL VARIABLES:
%   damping_coeff – artificial damping coefficient (dimensionless)
%   V_nP12        – mid-step velocity (at t + dt/2)
% -------------------------------------------------------------------------

% Artificial damping coefficient (stabilizes high-frequency oscillations)
damping_coeff = 0.6;

% --- 1. Mid-step velocity update ---
V_nP12 = V_nM1 + 0.5 * a_n * dt;

% --- 2. Apply damping to internal forces ---
T_damped = T .* (1 - damping_coeff * sign(T .* V_nM1));

% --- 3. Update acceleration using damped forces ---
a_nP1 = T_damped / rho;

% --- 4. Update displacement using mid-step velocity ---
U_nP1 = U_n + V_nP12 * dt;

% --- 5. Final velocity update ---
V_nP1 = V_nP12 + 0.5 * a_nP1 * dt;

% --- 6. Enforce boundary conditions on constrained DOFs ---
% Reset velocities and accelerations to zero at known DOFs
V_nP1(IdxUknown) = 0;
a_nP1(IdxUknown) = 0;
% Restore prescribed displacements
U_nP1(IdxUknown) = U_n(IdxUknown);

end