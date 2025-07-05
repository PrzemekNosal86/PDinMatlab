clear;clc;
addpath('boundary_conditions')
addpath('common_files')
addpath('input_output')
addpath('material_models')
addpath('solvers')
addpath('tools')
% ========================================================================
% Non-Ordinary State Based Peridynamics Model - Cosserat simplified theory 
% and small strain assumption
% ========================================================================
% Title           : Development of an elasto-plastic model based on Cosserat
%                   theory using the peridynamics method
% Identifier      : DEC-2024/08/X/ST8/00273
% Creator         : Przemysław Nosal
% ORCID           : 0000-0001-9751-0071
% Affiliation     : AGH University of Krakow
% Contact         : pnosal@agh.edu.pl
% Subject         : Computational Mechanics, Peridynamics, Cosserat Theory, Elasto-plasticity
% Description     : MATLAB implementation of a non-ordinary state-based 
%                   peridynamic (NOSB PD) model for simulating brittle fracture 
%                   in a Shear Notch Specimen (SENS). The simulation focuses on 
%                   damage initiation and crack propagation under quasi-static 
%                   shear loading. Elasto-plasticity and Cosserat theory are 
%                   not included in this version.
% Publisher       : AGH University of Krakow
% Contributor     : 
% Date            : 2025-04-25
% Type            : Software
% Format          : MATLAB .m code
% Language        : en
% Relation        : https://osf.io/, https://zenodo.org/
% Coverage        : Simulated elastic material behavior under quasi-static loading
% Rights          : CC BY 4.0 International
% Software        : MATLAB R2024b
% Version         : 1.0 – initial release
% ========================================================================

% Automatically load metadata from the current script file
thisFile = [mfilename, '.m'];
metadata = extractMetadataFromHeader(thisFile);
%writeCitationFile(metadata);
current_data = datetime;
current_data.Format = 'dd_MM_yyyy';
current_data = char(current_data);

description = '_test_';
parameter = 1;

comb_description = [description, current_data];
folder = 'results';
base_filename = 'NOSBPD_brittle_fracture_SENS_ADR';
name_with_description = strcat(base_filename, comb_description, '_verification_', num2str(parameter), '.mat');
filename = fullfile(folder, name_with_description);

%% PRE-PROCESSING

% Model parameters
dx=1;             % Grid spacing [mm]

% Peridynamics parameters
nDOF = 3;           % Number of degrees of freedom
m = 3;              % The m-ratio
delta = 4;% dx * m;     % The horizon
glot = 0.001;       % Global model tolerance(in percentage of grid spacing dx)
tol = dx * glot;    % Geometric tolerance for segment extent

% Specimen dimensions and thickness (h)
dims.H = 60+dx;        % Total specimen length in the y-direction [mm]
dims.W = 60;        % Total specimen height in the x-direction (grip sections) [mm]
dims.t = 1;         % Thickness of the specimen [mm]

% Notch position
nY = dims.H/2; % Notch y direction [mm]
nX = dims.W/2; % Notch x direction [mm]

% Materials properties
E = 5e3;         % Elastic modulus [MPa]
nu = 0.3;          % Poisson ratio [-]
rho = 1.180e-9;      % Density [kg/mm^3]

% Plane stress 
C = E/(1-nu^2) * [1     nu     0;...
                  nu     1     0;...
                  0      0 (1-nu)/2];

critical_strain = 0.03;

c_BB = 9 * E / (pi * dims.t * delta^3);

% Dynamic analysis parameters 
dt = 1;                    % Time step for the dynamic analysis [s]
saving_interval = 50;
ntot_steps = 10000;            % Total number of time steps
ntot_savings = ntot_steps/saving_interval;  % Number of saved displacements configurations
dU = 2e-4;             % Displacement increment [mm]
dV = dx*dx*dims.t;                          % Volume [mm^3]

tic

% Grid generation
[GRID,nnods,dx,col,row] = gridGenerator(dims.W,dims.H,dx);
DOF = nnods * nDOF;                    % DOFs
Grid(1:nDOF:DOF,1) = GRID(:,2);      % Alternative form of GRID matrix: a vector is created in which the x and y co-ordinates of
                                % all nodes are written in sequence
Grid(2:nDOF:DOF,1) = GRID(:,3);
Grid(3:nDOF:DOF,1) = GRID(:,4);
disp('1st step - GRID created')

[INIBOND,Xi] = initializationPD(GRID,m,dx,glot);
pcol = size(INIBOND,2);
disp('2nd step - Peridynamics bonds created')

% Crack
TGx = [0, nX - dx];
TGy = [nY, nY];  % poziomy pęknięcie
[INIBOND, Xi] = applyInitialCrack(GRID, INIBOND, Xi, TGx, TGy, dx, m, pcol);

% Boundary conditions
bottom_line = [0 0 dims.W 0];  % Bottom edge
normalDir = 1;         % Layer extends above the line
bottomLayerNodes = findBoundaryLayerNodes(GRID, bottom_line, dx, m, normalDir);
%bottomNodes = findSpecialBoundaryNodes(GRID, bottomLayerNodes, bottom_line, [dims.W/2,0], dx, m, normalDir);

%top_line = [0 dims.H/2+dx 0 dims.H];  % Top edge
top_line = [0 dims.H dims.W dims.H];  % Top edge
normalDir = -1;         % Layer extends above the line
topLayerNodes = findBoundaryLayerNodes(GRID, top_line, dx, m, normalDir);
%topNodes = findSpecialBoundaryNodes(GRID, topLayerNodes, top_line, [dims.W/2,dims.H], dx, m, normalDir);

% Initialize displacement and known DOF vectors
I = eye(3,3);
U_n = zeros(DOF, 1);
V_nM1=zeros(DOF,1); %Initial condition on velocity
V_nP1=zeros(DOF,1); %Initial condition on velocity
L_old = zeros(DOF,1); %Initial condition on external applied forces
L = zeros(DOF,1); %Initial condition on external applied forces

IdxUknown = false(DOF, 1);

Usteps=zeros(DOF,ntot_savings);      % DoF displacements; e.g node=ii, saving nr=kk: x-displacement component = Usteps(ii*2-1,kk) ; y-displacement component = Usteps(ii*2,kk)
Fsteps=zeros(DOF,ntot_savings);
StressSteps=zeros(DOF,ntot_savings);
StrainSteps=zeros(DOF,ntot_savings);
post_stress=zeros(DOF,ntot_savings);
post_strain=zeros(DOF,ntot_savings);

% Bond crack Indexes
INI_STATE=false(nnods,1);       % the row number corresponds to the node number, the value contained in the individual cell becomes true if at least one of the 
                                 % bonds starting from the node under consideration (the node number is the index of the cell in the vector) is broken
INI_TIME=zeros(nnods,pcol);     % time step of bond breakage

% Compute fictitious mass matrix
Lambda = computeLambda(nDOF, DOF, nnods, GRID, INIBOND, INI_TIME, c_BB, dt, delta, dx, dims.t);
Lambda = Lambda * 6;

if any(~isfinite(Lambda)) || any(Lambda < 1e-12)
    error('Invalid Lambda: contains zeros or NaNs');
end

pcent = 1; % counter for solution progress percentage and data storage
disp('Simulation progress (percentage):')
toc
for ii = 1:ntot_steps


    % Apply displacement to the bottom boundary layer: u_x = 0.0, u_y = 0.0 
    [U_n, IdxUknown] = assignDisplacementBC(U_n, IdxUknown, bottomLayerNodes, 0.0, 0.0, 0.0, NaN, NaN, NaN, nDOF);
    
    % Apply displacement to the top boundary layer: only u_x = dU
    %[U_n, IdxUknown] = assignDisplacementBC(U_n, IdxUknown, topLayerNodes, dU*ii, NaN, 0.0, NaN, NaN, NaN, nDOF);
    [U_n, IdxUknown] = assignDisplacementBC(U_n, IdxUknown, topLayerNodes, dU*ii, 0.0, 0.0, NaN, NaN, NaN, nDOF);

    invK = inverseShapeTensor(Xi,GRID,INIBOND,dV,delta,dx,INI_TIME);
    F = deformationGradient(Xi,GRID,INIBOND,dV,delta,U_n,invK,INI_TIME);
    [L, post_stress, post_strain] = elasticForceStateNew(Xi, GRID, INIBOND, dV, delta, C, F, invK, I, dx, U_n, INI_TIME, c_BB, L);

    if any(~isfinite(L))
        error('Internal force vector L contains NaN or Inf!');
    end
    

    % Adaptive Dynamic Relaxation step
     [U_nP1, V_nP1, damping_c] = adaptiveDynamicRelaxation(U_n, V_nP1, V_nM1, L, L_old, Lambda, dt, ii, IdxUknown);

    U_n=U_nP1;
    V_nM1=V_nP1;
    
    % DISPLACEMENTS ASSESMENT
    Def=Grid+U_n; %deformed configuration
    [INI_TIME,INI_STATE] = damageBonds(INIBOND,INI_TIME,INI_STATE,nnods,Def,Xi,critical_strain,ii);
    
    if ii>=ntot_steps/ntot_savings*pcent
        % monitoring the advancement of the simulation
        fprintf('%0.2f%%\n',(100/ntot_savings*pcent));
        % saving data for post-processing
        Usteps(:,pcent)=U_n; % save the vector of node displacements at 
                             % the time step=ntot_steps/ntot_savings*pcent
        Fsteps(:,pcent) = L;
        StressSteps(:,pcent) = post_stress;
        StrainSteps(:,pcent) = post_strain;
        pcent = pcent + 1;   % counter for saving data
    end
    L_old = L;
    L = zeros(DOF,1); % Force reset
end
t_end = seconds(toc);
t_end.Format = 'hh:mm:ss';
disp(t_end)

save(filename, '-v7.3');