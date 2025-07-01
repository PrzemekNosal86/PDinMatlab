function [GRID,nnods,new_dx,col,row]=gridGenerator(lx,ly,dx)
%% gridGenerator.m
% Title: Grid generator for rectangular 2D plate
% Author: Przemysław Nosal
% ORCID: 0000-0001-9751-0071
% Affiliation: AGH University of Krakow
% Contact: pnosal@agh.edu.pl
% Date: 2025-04-22
% Version: 1.0
% Description: Generates a regular grid of nodes over a rectangular domain. 
%              Adjusts dx if necessary to fit the exact plate dimensions and assigns 
%              mass weighting factors for use in lumped mass matrices.
% Dependencies: None
% License: CC-BY 4.0

% -------------------------------------------------------------------------
% INPUTS:
% lx      – length of plate in x direction [m] or [mm]
% ly      – length of plate in y direction [m] or [mm]
% dx      – initial node spacing

% OUTPUTS:
% GRID    – [nodeID, x, y, z, mass_factor]; z = 0 for 2D
% nnods   – total number of nodes
% new_dx  – adjusted grid spacing to match lx, ly exactly
% col     – number of columns in grid
% row     – number of rows in grid

% LOCAL VARIABLES:
% col, row     – estimated number of columns and rows
% new_dx       – updated spacing to ensure exact fitting of lx, ly
% cx, cy, cz   – temporary node coordinates
% mass_w       – weight factor: 1 for interior, 1/2 edge, 1/4 corner
% dxcol, dxrig – trial spacings in x and y directions
% ii, jj       – loop counters
% -------------------------------------------------------------------------

%% GRID spacing adapating
col=ceil(lx/dx);  %number of columns
row=ceil(ly/dx);  %number of rows
new_dx=dx;

%while cicle until new grid spacing found
while mod(lx,new_dx)>=dx*0.001 || mod(ly,new_dx)>=dx*0.001
    dxcol=lx/col;
    dxrig=ly/row;
    new_dx = min(dxcol,dxrig);
    col=ceil(lx/new_dx);
    row=ceil(ly/new_dx);
end

if new_dx~=dx    %ALERT if new GRID spacing calculated the user must be notified
    fprintf('ALERT,dx value changed from %s to %d.\n',dx,new_dx);
end

%% GRID matrix creation and mass factor allocation
GRID = zeros(row*col,5);
cy=0;
cz=0;
nnods=0;
for ii=0:row
    cx=0;
    for jj=0:col
        
        % node mass allocation for lumped mass matrix creation
        mass_w=1;        % nominal value of the node mass factor
        if (ii==0 || ii==row) && (jj==0 || jj==col)
            mass_w=1/4;  % nodes at the corner, 1/4 of the nominal mass
        elseif xor((ii==0 || ii==row),(jj==0 || jj==col))
            mass_w=1/2;  % nodes along boundaries 1/2 of the nominal mass
        end
        
        GRID(nnods+1,:)=[nnods+1,cx,cy,cz,mass_w];
        cx=cx+dx;
        nnods=nnods+1;
    end
    cy=cy+dx;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%