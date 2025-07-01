% Plot the deformed configuration with stress field

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
step = 5;
unit_m = 1;
component = 0; % 0 - stress_11, 1 - stress_22, 2 - stress_12
if component == 0
    fname = ['stress_11_field', description];
    s_comp = '$\sigma_{11}$, ';
elseif component == 1
    fname = ['stress_22_field', description];
    s_comp = '$\sigma_{22}$, ';
elseif component == 2
    fname = ['stress_12_field', description];
    s_comp = '$\sigma_{12}$, ';
end
for SavedStep = 1 : loops
for i=1:nnods
    stress_field(i,1)=StressSteps(3*i-2+component,SavedStep);
    v_field(i,1)=Usteps(3*i-1,SavedStep)*unit_m;
end
dmin(SavedStep) = min(stress_field);
dmax(SavedStep) = max(stress_field);
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
    stress_field(i,1)=StressSteps(3*i-2+component,SavedStep);
end

gra=figure(1);
set(gra,'Color',[1 1 1])
%set(gra,'Position',[200 200 1000 1000])
deformed = [GRID(:,2)+scale_factor*u_field(:,1),GRID(:,3)+scale_factor*v_field(:,1)]*unit_m;
S = 70; % size of symbols in pixels
scatter3(deformed(:,1),deformed(:,2),stress_field,S,stress_field,'filled')
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
grid off
hold off
FF = getframe(gcf);
writeVideo(v,FF)
end
close(v)