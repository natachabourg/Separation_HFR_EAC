% 
% Creates a rectangular cartesian grid
% Lets the user remove any unuseful point (e.g. ground points)
% Computes the GDOP error and the angle between the "radial" directions,
% and s all the untrustworthy points wrt to a given threshold
% 
% INPUTS:
% - map_opts: structure, containing the map informations, with fields:
%       - lon_lim/lat_lim: 2-element vectors with lon/lat limits of the
%                          region to be plotted
%       - lon0/lat0:       reference lon/lat used if an x/y plot is asked (lonlat_xy==2)
%       - lonlat_xy:       1: plot in lon/lat coordinates
%                          2: plot in x/y coordinates in km
%       - plot_bath:       plot isobaths (0: no, 1: yes)
% - RADAR_infos: n-element structure (n is the number of RADAR sites),
%                containing the RADAR site(s) informations, with fields:
%       - lon_rx/lat_rx: lon/lat coordinates
%       - x_rx/y_rx:     x/y coordinates in km if map_opts.lonlat_xy==2
%       - mono_bi:       1: monostatic RADAR; 2: bistatic RADAR
% - cartesian_grid: structure, with the characteristics of the cartesian grid, with fields:
%       - lon_lim/lat_lim: 2-element vectors with lon/lat limits of the grid
%       - step:            grid step (same for x and y) [km]
%       - rot_angle:       counterclockwise rotation angle of the grid wrt the WE axis
%       - GDOP_thresh:     maximum allowed normalized GDOP error
%       - ang_thresh:      minimum allowed angle between "radial" directions [deg]
% 
% OUTPUT
% - cartesian_grid: (optional) same as the input structure plus the following fields:
%       - master_RADAR:          name of the RADAR used as origin of time                            [string]
%       - x,y:                   x/y coordinates of the grid points                                  [km]
%       - lon,lat:               lon/lat coordinates of the grid points                              [dec deg]
%       - lon0,lat0:             lon/lat coordinate of the origin of the grid (in case x/y is used)  [dec deg]
%       - geo_mask:              geographic mask
%       - err_mask:              mask based on either a maximum GDOP error or a minimum
%                                angle between the radial directions
%       - bistatic_distance:     for each site, bistatic distance (round-trip length)                 [km]
%       - bistatic_angle:        for each site, half of the bistatic angle (theta/2)                  [deg]
%       - radial_direction:      for each site, "radial" direction, oriented toward the RADAR station [deg]
%       - angle_between_radials: angle between the "radial" directions (site1 - site2)                [deg]
%       - err_GDOP_u,v:          GDOP error on u,v normalized wrt the Doppler-induced speed resolution
% 
% PB 6/2003 revu PFO 13/12/12 pour TOSCA
% Lucio Bellomo 13/06/2012
% 


function cartesian_grid = install_grid(map_opts,RADAR_infos,cartesian_grid)


%% Creates the rectangular grid in km (cartesian_grid.x/y) and in decimal degrees (cartesian_grid.lon/lat)
cartesian_grid.lon0         = map_opts.lon0;    % use map's lon0/lat0 as origin for the cartesian grid
cartesian_grid.lat0         = map_opts.lat0;
cartesian_grid.master_RADAR = RADAR_infos(1).name;
cartesian_grid = create_grid(cartesian_grid);


%% Plot the grid
if nargout == 0
    figure; hold on;
    implantation(map_opts,RADAR_infos,0);
    if map_opts.lonlat_xy == 1
        h = m_plot(cartesian_grid.lon,cartesian_grid.lat,'*r');
    else
        h = plot(cartesian_grid.x,cartesian_grid.y,'*r');
    end
end


%% Manually mask unuseful points (e.g. ground points)
cartesian_grid.geo_mask = adjust_mask(cartesian_grid,map_opts.lonlat_xy,h);


%% Compute the Geometric Dilution Of Precision (GDOP) error
cartesian_grid = GDOP(RADAR_infos, cartesian_grid,map_opts);
% cartesian_grid = GDOP_bkp(RADAR_infos, cartesian_grid);   % uses one _BEN.xyv to fetch the angles
                                                            % and griddata to cast them into the
                                                            % cartesian grid

err = sqrt(cartesian_grid.err_GDOP_u.^2 + cartesian_grid.err_GDOP_v.^2);    % norm of GDOP normalized error
ang = -squeeze(diff(cartesian_grid.radial_direction,1,1));                     % angle between the "radial" directions [deg]
                                                                            % as it is written, ang is ang1 - ang2
% Threshold on the error based on maximum allowed GDOP error and minimum
% allowed angle between the radial distances
err_mask = NaN(size(err));
err_mask(cartesian_grid.err_GDOP_u <= cartesian_grid.GDOP_thresh & ...
         cartesian_grid.err_GDOP_v <= cartesian_grid.GDOP_thresh & ...
         ang >= cartesian_grid.ang_thresh) = 1;


%% Plot the GDOP error, the angle between "radial" directions, and the retained grid points
if nargout == 0
    figure;
    subplot(2,2,1); hold on;
    if map_opts.lonlat_xy == 1
        h = m_pcolor(cartesian_grid.lon,cartesian_grid.lat,cartesian_grid.err_GDOP_u);
    else
        h = pcolor(cartesian_grid.x,cartesian_grid.y,cartesian_grid.err_GDOP_u);
    end
    set(h,'LineStyle','None');              % same as shading flat, but more robust!
    implantation(map_opts,RADAR_infos,0);
    caxis([0 5]);
    colorbar;
    title('WE GDOP normalized error component');

    subplot(2,2,2); hold on;
    if map_opts.lonlat_xy == 1
        h = m_pcolor(cartesian_grid.lon,cartesian_grid.lat,cartesian_grid.err_GDOP_v);
    else
        h = pcolor(cartesian_grid.x,cartesian_grid.y,cartesian_grid.err_GDOP_v);
    end
    set(h,'LineStyle','None');              % same as shading flat, but more robust!
    implantation(map_opts,RADAR_infos,0);
    caxis([0 5]);
    colorbar;
    title('SN GDOP error normalized component');

    subplot(2,2,3); hold on;
    if map_opts.lonlat_xy == 1
        h = m_pcolor(cartesian_grid.lon,cartesian_grid.lat,ang);
    else
        h = pcolor(cartesian_grid.x,cartesian_grid.y,ang);
    end
    set(h,'LineStyle','None');              % same as shading flat, but more robust!
    implantation(map_opts,RADAR_infos,0);
    caxis([0 90]);
    colorbar;
    title('Angle between the "radial" directions (deg)');

    subplot(2,2,4); hold on;
    if map_opts.lonlat_xy == 1
        h = m_pcolor(cartesian_grid.lon,cartesian_grid.lat,err_mask);
    else
        h = pcolor(cartesian_grid.x,cartesian_grid.y,err_mask);
    end
    set(h,'LineStyle','None');              % same as shading flat, but more robust!
    implantation(map_opts,RADAR_infos,0);
    caxis([0 2]);
    title(['     Coverage for a normalized GDOP error smaller than ' num2str(cartesian_grid.GDOP_thresh) ' \newline ' ...
           'and an angle between the "radial" directions larger than ' num2str(cartesian_grid.ang_thresh) ' deg']);
end


%% Save the updated cartesian_grid structure (with valid values and manual )
% Create some new fields in cartesian_grid structure
cartesian_grid.err_mask              = err_mask;
cartesian_grid.angle_between_radials = ang;

save grid_cartesian.mat cartesian_grid

if nargout == 1
    varargout{1} = cartesian_grid;
end
