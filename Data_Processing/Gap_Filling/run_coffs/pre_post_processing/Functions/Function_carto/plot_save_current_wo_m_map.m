
% 
% Plots full vectors of current velocities
% 
% INPUTS:
% - map_opts:       structure with plotting parameters with fields:
%       - lon_lim,lat_lim: lon/lat range of the map                                  [dec deg]
%       - lonlat_xy:       use 1: lon/lat coordinates, 2: x/y coordinates in km
%       - lon0,lat0:       reference lon/lat for x/y maps (only if map.lonlat_xy==2) [dec deg]
%       - plot_bath:       plot isobaths (0 or 1) whose values are in installation/trace_coast.m
% - currents:       current velocity structure with fields:
%       - u,v:   zonal/meridional components of the current velocities [m/s]
%       - time:  dates                                                 [julian day]
%       - time0: time origin for the dates                             [string]
% - cartesian_grid: structure containing the grid of the full vector current velocities with fields:
%       - x/y:     x/y coordinates of the grid points     [km]
%       - lon,lat: lon/lat coordinates of the grid points [dec deg]
%       - step:    grid step (same for x and y)           [km]
% - params:         structure with some radial data parameters with fields:
%       - plot: plot the radial maps: 1: yes, 0: no
%       - save: save the radial maps: 1: yes, 0: no
%       - path: path where the figures should be saved if save == 1
% 
% OUTPUTS
%


function plot_save_current_wo_m_map(map_opts,currents,cartesian_grid,params)

if ~exist('params','var')
    params.plot = 1;
    params.save = 0;
end

%% Plot the coverage ratio
if isfield(cartesian_grid,'coverage')
    if params.plot == 1
        h_fig = figure;
    else
        h_fig = figure('Visible','Off');
    end
    hold on;
    trace_coast_wo_m_map(map_opts);
    h_col = colorbar;
    coverage = cartesian_grid.coverage;
    coverage(coverage == 0) = NaN;
    ylabel(h_col,'Coverage ratio');
    if map_opts.lonlat_xy == 1
        h = pcolor(cartesian_grid.lon,cartesian_grid.lat,coverage);
        set(h,'LineStyle','None');              % equivalent to shading flat,
        caxis([0 1]);                           % only shading flat gives a strange result
    else
        h = pcolor(cartesian_grid.x,cartesian_grid.y,coverage);
        shading flat;
        caxis([0 1]);
    end
    date(1) = julday2date(currents(1).time,  currents(1).time0);
    date(2) = julday2date(currents(end).time,currents(end).time0);
    fig_title = [date(1).calendar ' - ' date(2).calendar];
    title(fig_title);
    % Save the figure, if asked
    if params.save == 1
        savefig(['Coverage ' fig_title],h_fig,'png');
        movefile(['Coverage ' fig_title '*'],params.path);
    end
end


%% Plot the current velocity field time by time
if params.plot == 1
    h_fig = 1;%figure; % h_fig = figure;
else
    h_fig = figure('Visible','Off');
end
% pos = get(h_fig,'Position');                    % increases the size of the figure by 100%
% set(h_fig,'Position',pos+[0 0 pos(3) pos(4)]);  % in order to have a better resolution when
hold on;                                        % the figure is saved

% Trace coastline and bathymetry, then create the legend arrow
% trace_coast_wo_m_map(map_opts);
if map_opts.lonlat_xy == 1
    scale = 1.5*cartesian_grid.step/100;    % deg
    lon_legend = max(max(cartesian_grid.lon)) + cartesian_grid.step/100;
    lat_legend = max(max(cartesian_grid.lat)) + cartesian_grid.step/100;
    quiver(lon_legend,lat_legend,scale,0,'Color','r','MaxHeadSize',2,'LineWidth',2);
    text(lon_legend,lat_legend+cartesian_grid.step/100,'1 m/s','Color','r','FontSize',10);
else
    scale = 1.5*cartesian_grid.step;        % km
    x_legend = max(max(cartesian_grid.x)) + cartesian_grid.step;
    y_legend = max(max(cartesian_grid.y)) + cartesian_grid.step;
    quiver(x_legend,y_legend,scale,0,'Color','r','MaxHeadSize',2,'LineWidth',2);
    text(x_legend,y_legend+cartesian_grid.step,'1 m/s','Color','r','FontSize',10);
end

% Loop on the time
h_quiver = [];
for i_time = length(currents)-20 : length(currents)   % 1 : length(currents)
    delete(h_quiver);
    
    date = julday2date(currents(i_time).time,currents(i_time).time0);
    u = scale*currents(i_time).u;
    v = scale*currents(i_time).v;
    if map_opts.lonlat_xy == 1
       h_quiver = quiver(cartesian_grid.lon,cartesian_grid.lat,u,v,0,'k','LineWidth',0.5,'MarkerSize',1);
    else
       h_quiver = quiver(cartesian_grid.x,  cartesian_grid.y,  u,v,0,'k','LineWidth',0.5,'MarkerSize',1);
    end
    title(date.calendar);
    
    % Save the figure, if asked
    if params.save == 1
        savefig(date.radar,h_fig,'png');
        movefile([date.radar '.*'],params.path);
    else
        pause;%(0.25);  % Useful to trim the time a figure (i.e., a date) stays on the screen
    end
end
