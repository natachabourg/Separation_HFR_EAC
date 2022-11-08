
% 
% This function maps the radial current velocities into full vectors
% according to the method chosen by the user in CONFIGURATION.m
% 
% INPUTS:
% - radial_data: at least 2-element structure containing radial data with fields:
%       - lonr/latr: lon/lat meshgrid coordinates of the radial grid  [decimal deg]
%       - time:      array of the dates of each dataset                [julian day]
%       - vr:        radial velocities for all the dates and over the grid    [m/s]
%       - time0    : time origin for the dates                             [string]
% - params:      structure containing the parameters of the cartesian mapping with fields:
%       - master_RADAR:  name of the RADAR used as origin of time                      [string]
%       - time_accuracy: time tolerance for merging two radial maps of different sites [min]
%       - mapping:       structure containing parameters for the mapping algorithm
%           - method: algorithm type (5: classic interpolation + MSE, 6: MSE mapping)
%           - radius: influence radius of the circle around each pixel                 [km]
% 
% OUTPUTS:
% - currents:       structure containing the mapped full vector current velocities with fields:
%       - u,v:   zonal/meridional components of the current velocity [m/s]
%       - time:  date of each map                                    [julian days]
%       - time0: origin of time for the julian days (time)           [string]
% - cartesian_grid: structure containing the grid of the full vector current velocities
%                   with additional fields, wrt the one in CONFIGURATION.m:
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


function [currents cartesian_grid] = vector_mapping(radial_data,params)

%% Fetch the cartesian grid that must have been generated previously

name1 = 'PEY';
name2 = 'POB';

if exist(['/home/natachab/RADAR_NATACHA/grid_cartesian_PEYPOB.mat'],'file')
    load(['/home/natachab/RADAR_NATACHA/grid_cartesian_PEYPOB.mat']);
elseif exist(['grid_cartesian_' name2 '.mat'],'file')
    load(['grid_cartesian_' name2 '.mat']);
else
    error('You haven''t generated the cartesian grid yet!');
end

clear name1 name2


%% Verify the number of active sites
N_sites = length(radial_data);
if N_sites == 1
    currents = 0;
    cartesian_grid = 0;
    return;
    error('Only 1 RADAR site is considered: no mapping is possible!');
end

if length(radial_data(1).name) == 0 || length(radial_data(2).name) ==0
    disp('Only 1 RADAR site is considered: no mapping is possible!');
    currents = 0;
    cartesian_grid = 0;
    write = false;
    return;
end


%% Check that the time origin is the same for the sites
for i_site = 2 : N_sites
    if radial_data(i_site).time0 ~= radial_data(1).time0
        radial_data(i_site).time = radial_data(i_site).time + ...
                            datenum(radial_data(1).time0) - datenum(radial_data(i_site).time0);
    end
end


%% Build a map at each time
time_acc = params.time_accuracy/60/24;  % [min] -> [days]
N_times = length(radial_data(1).time);

disp('Computing current velocities ...');

for i_time = 1 : N_times

    % Build a structure for the present time only
    for i_site = 1 : N_sites
        data_time(i_site).lonr = radial_data(i_site).lonr; 
        data_time(i_site).latr = radial_data(i_site).latr;
        data_time(i_site).angr = radial_data(i_site).angr;
    end

    % Find the slave RADAR map within the required time accuracy
    date = radial_data(1).time(i_time);
    for i_site = 2 : N_sites
        [date_nearest(i_site-1), i_time_tmp(i_site-1)] = find_nearest(radial_data(i_site).time,date);
    end

    if all( abs(date_nearest - date) > time_acc )  % unavailable date
        date_off = julday2date(date,radial_data(1).time0);
        disp(['    No ' radial_data(2).name ' radial map around ' date_off.calendar]);
        u = NaN(size(cartesian_grid.x));
        v = NaN(size(cartesian_grid.x));
        
    else
        data_time(1).vr = squeeze(radial_data(1).vr(:,:,i_time));

        for i_site = 2 : N_sites
            data_time(i_site).vr = squeeze(radial_data(i_site).vr(:,:,i_time_tmp(i_site-1)));
        end


        % Do the mapping according to the selected method
        switch params.mapping.method
            case 1
                % Griddata of cartesian bistatic components (Philippe)

            case 2
                % Griddata of cartesian bistatic components (Yves)

            case 3
                % Griddata of radial components w/o the angles (Philippe)

            case 4
                % Interp2d (distance-azimuth interpolation) (Philippe)

            case 5
                % Classic local interpolation through a weighted interpolation of the radial currents of each RADAR site, 
                % followed by a MSE minimization
                [u, v] = mapping_LI_classic(data_time,cartesian_grid,params);
            case 6
                % Local Interpolation through the Weighted Least Squares Minimization of all the radial currents at once
                [u,v] = mapping_LI_all_radial(radial_data,data_time,cartesian_grid,params);
        end

    end



    % Build the output structure
    currents(i_time).u = u;
    currents(i_time).v = v;
    currents(i_time).time  = date;
    currents(i_time).time0 = radial_data(1).time0;

     waitbar(i_time/N_times);

end
disp(blanks(1)');

