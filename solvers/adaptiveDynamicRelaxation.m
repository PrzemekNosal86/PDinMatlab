function [U_next, velhalf, cn] = adaptiveDynamicRelaxation(U_n, velhalf, velhalfold, pforce, pforceold, massvec, dt, tt, IdxUknown)
%% adaptiveDynamicRelaxation.m
% Title        : Adaptive Dynamic Relaxation update for PD
% Author       : Przemysław Nosal
% ORCID        : 0000-0001-9751-0071
% Affiliation  : AGH University of Krakow, Faculty of Mechanical Engineering and Robotics
% Contact      : pnosal@agh.edu.pl
% Date         : 2025-05-29
% Version      : 1.1
% Description  : Performs adaptive dynamic relaxation update for displacement,
%                velocity and damping in a peridynamic simulation using pointwise
%                mass and internal forces. Assumes vector format [x1; y1; z1; x2; y2; z2; ...].
% License      : CC-BY 4.0
%
% INPUTS:
%   disp         – displacement at current step [3*ntotnode x 1]
%   vel          – full-step velocity [3*ntotnode x 1]
%   velhalf      – half-step velocity [3*ntotnode x 1]
%   velhalfold   – previous half-step velocity [3*ntotnode x 1]
%   pforce       – internal force at current step [3*ntotnode x 1]
%   pforceold    – internal force at previous step [3*ntotnode x 1]
%   bforce       – body force vector [3*ntotnode x 1]
%   massvec      – mass vector [3*ntotnode x 1]
%   dt           – time step
%   tt           – current step index (integer)
%
% OUTPUTS:
%   disp         – updated displacement
%   vel          – updated full-step velocity
%   velhalf      – updated half-step velocity
%   velhalfold   – updated memory of half-step velocity
%   pforceold    – updated memory of previous force

U_next = U_n;
ntotnode = length(U_n) / 3;
cn1 = 0;
cn2 = 0;

for i = 1:ntotnode
    ix = 3*(i-1)+1;
    iy = ix+1;
    iz = ix+2;

    if velhalfold(ix) ~= 0
        cn1 = cn1 - U_n(ix)^2 * (pforce(ix)/massvec(ix) - pforceold(ix)/massvec(ix)) / (dt * velhalfold(ix));
    end
    if velhalfold(iy) ~= 0
        cn1 = cn1 - U_n(iy)^2 * (pforce(iy)/massvec(iy) - pforceold(iy)/massvec(iy)) / (dt * velhalfold(iy));
    end
    if velhalfold(iz) ~= 0
        cn1 = cn1 - U_n(iz)^2 * (pforce(iz)/massvec(iz) - pforceold(iz)/massvec(iz)) / (dt * velhalfold(iz));
    end

    cn2 = cn2 + U_n(ix)^2 + U_n(iy)^2 + U_n(iz)^2;
end

if cn2 ~= 0
    if (cn1 / cn2) > 0
        cn = 2 * sqrt(cn1 / cn2);
    else
        cn = 0;
    end
else
    cn = 0;
end

if cn > 2
    cn = 1.9;
end

for i = 1:ntotnode
    ix = 3*(i-1)+1;
    iy = ix+1;
    iz = ix+2;

    if tt == 1
        velhalf(ix) = dt / massvec(ix) * (pforce(ix)) / 2;
        velhalf(iy) = dt / massvec(iy) * (pforce(iy)) / 2;
        velhalf(iz) = dt / massvec(iz) * (pforce(iz)) / 2;
    else
        velhalf(ix) = ((2 - cn*dt) * velhalfold(ix) + 2*dt / massvec(ix) * (pforce(ix))) / (2 + cn*dt);
        velhalf(iy) = ((2 - cn*dt) * velhalfold(iy) + 2*dt / massvec(iy) * (pforce(iy))) / (2 + cn*dt);
        velhalf(iz) = ((2 - cn*dt) * velhalfold(iz) + 2*dt / massvec(iz) * (pforce(iz))) / (2 + cn*dt);
    end

    U_next(ix) = U_n(ix) + velhalf(ix) * dt;
    U_next(iy) = U_n(iy) + velhalf(iy) * dt;
    U_next(iz) = U_n(iz) + velhalf(iz) * dt;

end

U_next(IdxUknown) = U_n(IdxUknown);
velhalf(IdxUknown) = 0;

end