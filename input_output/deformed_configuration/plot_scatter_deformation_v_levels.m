% Plot the deformed configuration

% Get the path to the folder where the script is located
script_folder = fileparts(mfilename('fullpath'));

% Go two levels up to reach the main NOSBPD_Nosal folder
input_output_folder = fileparts(script_folder); % one level up
main_folder = fileparts(input_output_folder);   % two levels up

% Path to the "figures" folder in NOSBPD_Nosal
figures_folder = fullfile(main_folder, 'figures');

% Additional description of the file
description = '_shear_band_elastic';
fname = ['deformed_v_displacement', description];

% === Parameters ===
loops = ntot_savings;
scale_factor = 1;
step = 10;
unit_m = 1;
num_colormap_levels = 9;  % <-- number of desired color levels in the colormap

% Precompute color range across all steps
for SavedStep = 1 : loops
    for i = 1 : nnods
        u_field(i,1) = Usteps(3*i-2, SavedStep) * unit_m;
        v_field(i,1) = Usteps(3*i-1, SavedStep) * unit_m;
    end
    dmin(SavedStep) = min(v_field);
    dmax(SavedStep) = max(v_field);
    %ymax(SavedStep) = max(v_field);
end

% Define color scale limits based on the number of levels
cmp = linspace(min(dmin), max(dmax), num_colormap_levels);
%cmp = linspace(-0.0035, 0.3, num_colormap_levels);

% Create video object
v = VideoWriter(fullfile(figures_folder, fname), 'MPEG-4');
v.FrameRate = 30;         
v.Quality = 100;          
open(v)

for SavedStep = step : step : loops
    set(gcf, "NextPlot", "replacechildren")
    TimeInstant = SavedStep * (ntot_steps / ntot_savings) * dt; % compute current time

    % Extract displacement components at current time step
    for i = 1 : nnods
        u_field(i,1) = Usteps(3*i-2, SavedStep); 
        v_field(i,1) = Usteps(3*i-1, SavedStep); 
    end

    % Plotting
    gra = figure(1);
    set(gra, 'Color', [1 1 1])
    deformed = [GRID(:,2) + scale_factor * u_field(:,1), GRID(:,3) + scale_factor * v_field(:,1)] * unit_m;
    S = 50; % marker size in pixels

    scatter3(deformed(:,1), deformed(:,2), v_field * unit_m, S, v_field * unit_m, 'filled')

    % Apply colormap with user-defined number of levels
    colormap(jet(num_colormap_levels)); 
    clim([min(cmp), max(cmp)]);
    cb = colorbar('vert');
    cb.Ticks = linspace(min(cmp), max(cmp), num_colormap_levels); % equal tick spacing

    view(0, 90); % top-down 2D view
    hold on
    Font_t = 20;
    Font_s = 20;
    set(gca, 'FontSize', Font_s, 'FontName', 'Times')
    xlabel('Distance [mm]', 'FontSize', Font_s, 'FontWeight', 'bold', 'interpreter', 'latex')
    ylabel('Distance [mm]', 'FontSize', Font_s, 'FontWeight', 'bold', 'interpreter', 'latex')
    %title(['Displacement field $u_2$, Iteration = ' num2str(TimeInstant,'%.1d')], ...
    %    'FontSize', Font_t, 'FontWeight', 'bold', 'interpreter', 'latex')

    axis equal
    axis off
    grid off
    hold off

    % Save current frame to video
    FF = getframe(gcf);
    writeVideo(v, FF)
end

% Finalize and close video
close(v)
