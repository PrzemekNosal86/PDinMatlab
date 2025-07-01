function [NEW_GRID, nnods] = gridCut_TBone(dims, dx)
%% gridCut_TBone.m
% Title: Grid generator with geometric cutouts for dog-bone specimen
% Author: Przemysław Nosal
% ORCID: 0000-0001-9751-0071
% Affiliation: AGH University of Krakow
% Contact: pnosal@agh.edu.pl
% Date: 2025-04-25
% Version: 1.0
% Description:
%   Generates a regular 2D grid centered at (0,0) representing a
%   dog-bone tensile specimen. Removes nodes located within:
%   - four circular arc cutouts at the necking zone corners,
%   - two lateral rectangular cutouts representing optical gauge zone.
%
% Inputs:
%   dims – structure with geometry parameters:
%       dims.L   – total specimen length (y-direction)
%       dims.H   – specimen width (x-direction)
%       dims.w   – neck width (gauge section)
%       dims.W   – grip width (end sections)
%       dims.r   – radius of arc cutouts
%       dims.Lg  – gauge section length (vertical)
%   dx   – initial grid spacing
%
% Outputs:
%   NEW_GRID – node matrix after cutouts: [nodeID, x, y, z, mass_factor]
%   nnods    – number of remaining nodes
%
% License: CC-BY 4.0
% -------------------------------------------------------------------------

% Geometry input
ly = dims.L;   % length of specimen in y
lx = dims.H;   % width of specimen in x
w  = dims.w;   % neck width
r  = dims.r;   % arc radius
Lg = dims.Lg;  % gauge length

% Grid spacing adjustment
col = ceil(lx/dx);
row = ceil(ly/dx);
new_dx = dx;

while mod(lx,new_dx) >= dx*0.001 || mod(ly,new_dx) >= dx*0.001
    dxcol = lx / col;
    dxrow = ly / row;
    new_dx = min(dxcol, dxrow);
    col = ceil(lx / new_dx);
    row = ceil(ly / new_dx);
end

if new_dx ~= dx
    fprintf('ALERT: dx value changed from %.3f to %.3f.\n', dx, new_dx);
end

% Generate full rectangular grid centered at (0,0)
GRID = zeros(row * col, 5);
cz = 0;
nnods = 0;
x_shift = lx / 2;
y_shift = ly / 2;

for ii = 0:row
    cy = ii * new_dx;
    for jj = 0:col
        cx = jj * new_dx;

        mass_w = 1;
        if (ii == 0 || ii == row) && (jj == 0 || jj == col)
            mass_w = 1/4;
        elseif xor((ii == 0 || ii == row), (jj == 0 || jj == col))
            mass_w = 1/2;
        end

        GRID(nnods + 1, :) = [nnods + 1, cx - x_shift, cy - y_shift, cz, mass_w];
        nnods = nnods + 1;
    end
end

% Define arc cutout centers
xL = -(r + w/2);
xR =  (r + w/2);
yT =  Lg / 2;
yB = -Lg / 2;

cut1 = [xL, yT];  % upper left
cut2 = [xL, yB];  % lower left
cut3 = [xR, yT];  % upper right
cut4 = [xR, yB];  % lower right

% Define rectangular cutout bounds (gauge zone)
cut_width  = (lx - w)/2;
cut_height = Lg;

x_cut_left_min  = -w/2 - cut_width;
x_cut_left_max  = -w/2;
x_cut_right_min =  w/2;
x_cut_right_max =  w/2 + cut_width;

y_cut_min = -cut_height/2;
y_cut_max =  cut_height/2;

% Remove nodes inside any cutout
count = 0;
NEW_GRID = zeros(size(GRID));

for ii = 1:length(GRID)
    x = GRID(ii,2);
    y = GRID(ii,3);

    % Arc check
    R1 = sqrt((x - cut1(1))^2 + (y - cut1(2))^2);
    R2 = sqrt((x - cut2(1))^2 + (y - cut2(2))^2);
    R3 = sqrt((x - cut3(1))^2 + (y - cut3(2))^2);
    R4 = sqrt((x - cut4(1))^2 + (y - cut4(2))^2);

    isInArc = R1 < r || R2 < r || R3 < r || R4 < r;

    % Rectangle check
    isInRectLeft  = (x >= x_cut_left_min)  && (x <= x_cut_left_max)  && (y >= y_cut_min) && (y <= y_cut_max);
    isInRectRight = (x >= x_cut_right_min) && (x <= x_cut_right_max) && (y >= y_cut_min) && (y <= y_cut_max);

    if isInArc || isInRectLeft || isInRectRight
        count = count + 1;
    else
        NEW_GRID(ii - count, :) = GRID(ii, :);
        NEW_GRID(ii - count, 1) = NEW_GRID(ii - count, 1) - count;
    end
end

% Trim unused rows
NEW_GRID = NEW_GRID(1:end - count, :);
nnods = size(NEW_GRID, 1);
end
