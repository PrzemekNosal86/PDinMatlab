%% plotDeformedStrainField.m
% Title          : Animated visualization of strain field in deformed configuration
% Author         : Przemysław Nosal
% ORCID          : 0000-0001-9751-0071
% Affiliation    : AGH University of Krakow
% Contact        : pnosal@agh.edu.pl
% Date           : 2025-07-05
% Version        : 1.0
% Description    :
%   Creates an animated scatter plot of a selected strain component 
%   (ε₁₁, ε₂₂ or ε₁₂) in the deformed configuration of the sample.
%   Uses nodal displacements and strain field data from a quasi-static 
%   Peridynamics simulation to plot color-coded values on the mesh.
%   Saves the result as a video file in the "figures" directory.
% Dependencies   : GRID, Usteps, StrainSteps, dt, nnods, ntot_savings, ntot_steps
% License        : CC-BY 4.0

% Get the path to the folder where the script is located
script_folder = fileparts(mfilename('fullpath'));

% Go two levels up to reach the main NOSBPD_Nosal folder
input_output_folder = fileparts(script_folder); % one level up
main_folder = fileparts(input_output_folder);   % two levels up

% Path to the "figures" folder in NOSBPD_Nosal
figures_folder = fullfile(main_folder, 'figures');

% Additional description of the file
description = '_tensile_ep';

loops = ntot_savings;
scale_factor =1.;
step = 10;
unit_m = 1;
component = 0; % 0 - strain_11, 1 - strain_22, 2 - strain_12
if component == 0
    fname = ['strain_11_field', description];
    s_comp = '$\varepsilon_{11}$, ';
elseif component == 1
    fname = ['strain_22_field', description];
    s_comp = '$\varepsilon_{22}$, ';
elseif component == 2
    fname = ['strain_12_field', description];
    s_comp = '$\varepsilon_{12}$, ';
end
for SavedStep = 1 : loops
for i=1:nnods
    strain_field(i,1)=StrainSteps(3*i-2+component,SavedStep);
    v_field(i,1)=Usteps(3*i-1,SavedStep)*unit_m;
end
dmin(SavedStep) = min(strain_field);
dmax(SavedStep) = max(strain_field);
ymax(SavedStep) = max(v_field);
end
cmp = linspace(min(dmin),max(dmax),numel(Usteps(:,1))/2);
v = VideoWriter(fullfile(figures_folder, fname),'MPEG-4');
v.FrameRate = 30;         % 30 frames/s
v.Quality = 100;          % Quality (0–100)
open(v)
for SavedStep = step : step : loops
set(gcf,"NextPlot","replacechildren")
TimeInstant=SavedStep*(ntot_steps/ntot_savings)*dt; % evaluation of the time istant associated with the shown deformed configuration
for i=1:nnods
    u_field(i,1)=Usteps(3*i-2,SavedStep); % x component of the amplified displacement
    v_field(i,1)=Usteps(3*i-1,SavedStep); % y component of the amplified displacement
    strain_field(i,1)=StrainSteps(3*i-2+component,SavedStep);
end

gra=figure(1);
set(gra,'Color',[1 1 1])
%set(gra,'Position',[200 200 1000 1000])
deformed = [GRID(:,2)+scale_factor*u_field(:,1),GRID(:,3)+scale_factor*v_field(:,1)]*unit_m;
S = 50; % size of symbols in pixels
scatter3(deformed(:,1),deformed(:,2),strain_field,S,strain_field,'filled')
colorbar('vert');
caxis([min(cmp), max(cmp)]);
colormap jet;
view(0,90); % is a 2D view
hold on
Font_t=20; % Title  fontSize
Font_s=20; % Axis Label fontSize
set(gca,'FontSize',Font_s,'FontName','Times')
xlabel('Distance [mm]','FontSize',Font_s,'FontWeight','bold','interpreter','latex')
ylabel('Distance [mm]','FontSize',Font_s,'FontWeight','bold','interpreter','latex')
title([s_comp ' Time=' num2str(TimeInstant,'%.8f') ' [s]'],'FontSize',Font_t,'FontWeight','bold','interpreter','latex') %, Scale Factor =' num2str(scale_factor,'%10.f%')])
%xlim([(0-lx*0.1)*1e3 (lx+lx*0.1)*1e3])
%ylim([(-0.001)*1e3 (ly+ly*0.2)*1e3])
%xlim([(-lx/2-lx*0.1)*unit_m (lx/2+lx*0.1)*unit_m])
%ylim([(-1-ly/2)*unit_m (ly/2+max(ymax)*4*scale_factor)*unit_m])
axis equal
axis off
grid off
hold off
FF = getframe(gcf);
writeVideo(v,FF)
end
close(v)