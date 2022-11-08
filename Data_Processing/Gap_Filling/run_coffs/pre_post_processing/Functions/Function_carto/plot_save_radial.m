
% 
% Plots the radial current velocities of a given site
% 
% INPUTS:
% - map:    structure with plotting parameters with fields:
%       - lon_lim,lat_lim: lon/lat range of the map                                  [dec deg]
%       - lonlat_xy:       use 1: lon/lat coordinates, 2: x/y coordinates in km
%       - plot_bath:       plot isobaths (0 or 1) whose values are in installation/trace_coast.m
% - data:   radial data structure with fields
%       - xr,yr:     x/y     meshgrid coordinates of the radial grid     [km]
%       - lonr,latr: lon/lat meshgrid coordinates of the radial grid     [decimal deg]
%       - lon0,lat0: lon/lat coordinate of the origin of the radial grid [dec deg]
%       - vr:        radial velocities over the grid                     [m/s]
%       - time:      dates                                               [julian day]
%       - time0:     time origin for the dates                           [string]
% - params: structure with some radial data parameters with fields:
%       - plot: plot the radial maps: 1: yes, 0: no
%       - save: save the radial maps: 1: yes, 0: no
%       - path: path where the figures should be saved if save == 1
% 
% OUTPUTS
%


function plot_save_radial(map,data,params)

if params.plot == 1
    h_fig = figure;
else
    h_fig = figure('Visible','Off');
end
hold on;

% Trace coastline and bathymetry
trace_coast(map);
h_col = colorbar;
ylabel(h_col,'Current speed (m/s)');

% Loop on the time
h = [];
for i_t = 1 : size(data.vr,1)
    delete(h);
    
    % Plot the radial currents
    vr = squeeze(data.vr(i_t,:,:));
    if map.lonlat_xy == 1
        h = m_pcolor(data.lonr,data.latr,vr);
        set(h,'LineStyle','None');              % equivalent to shading flat,
        caxis([-1 1]);                          % only shading flat gives a strange result
    else
        [dx, dy] = xy2lonlat(data.lon0,data.lat0,map.lon0,map.lat0,1);
        h = pcolor(data.xr-dx,data.yr-dy,vr);
        shading flat;
        caxis([-1 1]);
    end
    date = julday2date(data.time(i_t),data.time0);
    title([data.name ' - ' date.calendar]);
    
    % Save the figure, if asked
    if params.save
        savefig(date.radar,h_fig,'png');
        movefile([date.radar '.*'],[params.path]);
    else
        pause(0.5);  % Useful to trim the time a figure (i.e., a date) stays on the screen
    end
 
end





