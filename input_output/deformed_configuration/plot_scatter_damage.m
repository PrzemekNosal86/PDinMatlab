% Plot the deformed configuration

% Get the path to the folder where the script is located
script_folder = fileparts(mfilename('fullpath'));

% Go two levels up to reach the main NOSBPD_Nosal folder
input_output_folder = fileparts(script_folder); % one level up
main_folder = fileparts(input_output_folder);   % two levels up

% Path to the "figures" folder in NOSBPD_Nosal
figures_folder = fullfile(main_folder, 'figures');

% Additional description of the file
description = '_SENS_CNOSB_elastic_';

fname = ['damage_field', description];

loops = ntot_savings;
step = 1;
scale_factor = 1;
unit_m = 1;
for SavedStep = 1 : loops
for i=1:nnods
    v_field(i,1)=Usteps(3*i-1,SavedStep)*unit_m;
end
dmax(SavedStep) = max(v_field);
end
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
end

[rr,cc]=size(INIBOND);
Damage=zeros(nnods,1); % vector initialisation

for jj=1:rr
    NowIND=INI_TIME(jj,:)>0 & INI_TIME(jj,:)<=SavedStep*saving_interval; % we will only consider bonds that broke from the initial time step to the time step ii of interest 
    Damage(INIBOND(jj,1))=(nnz(INI_TIME(jj,NowIND)))/(nnz(INIBOND(jj,:))-1); % ratio between the number of broken bonds and the initial number of bonds for each node in the model
end

gra=figure(1);
set(gra,'Color',[1 1 1])
deformed = [GRID(:,2)+scale_factor*u_field(:,1),GRID(:,3)+scale_factor*v_field(:,1)]*unit_m;
S = 50; % size of symbols in pixels
scatter3(deformed(:,1),deformed(:,2),Damage,S,Damage,'filled')
colorbar('vert');
caxis([0, 0.5]);
colormap jet;
view(0,90); % is a 2D view
hold on
Font_t=20; % Title  fontSize
Font_s=20; % Axis Label fontSize
set(gca,'FontSize',Font_s,'FontName','Times')
xlabel('Distance [mm]','FontSize',Font_s,'FontWeight','bold','interpreter','latex')
ylabel('Distance [mm]','FontSize',Font_s,'FontWeight','bold','interpreter','latex')
%title(['Damage $D$, ' ' Time=' num2str(TimeInstant,'%.8f') ' [s]'],'FontSize',Font_t,'FontWeight','bold','interpreter','latex') %, Scale Factor =' num2str(scale_factor,'%10.f%')])
title(['Damage $D$, ' ' Iteration =' num2str(TimeInstant,'%.1d')],'FontSize',Font_t,'FontWeight','bold','interpreter','latex')
% xlim([(-lx/2-lx*0.1)*unit_m (lx/2+lx*0.1)*unit_m])
% ylim([(-1-ly/2)*unit_m (ly/2+max(dmax)*4*scale_factor)*unit_m])
axis equal
axis off
grid off
hold off
F = getframe(gcf);
writeVideo(v,F)
end
close(v)