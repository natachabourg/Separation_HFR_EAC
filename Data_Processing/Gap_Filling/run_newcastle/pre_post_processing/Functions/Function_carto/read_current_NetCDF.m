
%
% Reads the full current velocities over the given period of time
% from a single NetCDF file
%
% INPUT
% - ncfile: full file name (including path) of the NetCDF file
% 

function [currents, grid, radial_params, cartesian_params] = read_current_NetCDF(ncfile)

%% Data
x                        = double(ncread(ncfile,'xv'));
y                        = double(ncread(ncfile,'yv'));
lon                      = double(ncread(ncfile,'lon'));
lat                      = double(ncread(ncfile,'lat'));
% coverage                 = double(ncread(ncfile,'coverage'));               %%%% might not exist in the NetCDF
bistatic_distance(1,:,:) = double(ncread(ncfile,'bistatic_distance_1'));
bistatic_distance(2,:,:) = double(ncread(ncfile,'bistatic_distance_2'));
bistatic_angle(1,:,:)    = double(ncread(ncfile,'bistatic_angle_1'));
bistatic_angle(2,:,:)    = double(ncread(ncfile,'bistatic_angle_2'));
radial_direction(1,:,:)  = double(ncread(ncfile,'radial_direction_1'));
radial_direction(2,:,:)  = double(ncread(ncfile,'radial_direction_2'));
GDOP_error_u             = double(ncread(ncfile,'GDOP_error_u'));
GDOP_error_v             = double(ncread(ncfile,'GDOP_error_v'));
angle_between_radials    = double(ncread(ncfile,'angle_between_radials'));
u                        = double(ncread(ncfile,'u'));
v                        = double(ncread(ncfile,'v'));
time                     = double(ncread(ncfile,'time'));


%% Re-arrangement according to Matlab's spatial convention (y,x) starting from Ferret's convention (x,y,z,t)
u = permute(u,[3,2,1]);                                           %%% (x,y,t) -> (t,y,x)
v = permute(v,[3,2,1]);                                           %%% (x,y,t) -> (t,y,x)
N_time = size(u,1);
for i_time = 1 : N_time
    currents(i_time).u    = squeeze(u(i_time,:,:));
    currents(i_time).v    = squeeze(v(i_time,:,:));
    currents(i_time).time = time(i_time);
end
grid.x                     = x';                                  %%% (x,y)   -> (y,x)
grid.y                     = y';                                  %%% (x,y)   -> (y,x)
grid.lon                   = lon';                                %%% (x,y)   -> (y,x)
grid.lat                   = lat';                                %%% (x,y)   -> (y,x)
% grid.coverage              = coverage';                           %%% (x,y)   -> (y,x)          %%%% might not exist in the NetCDF
grid.bistatic_distance     = permute(bistatic_distance,[1,3,2]);  %%% (:,x,y) -> (:,y,x)  
grid.bistatic_angle        = permute(bistatic_angle,[1,3,2]);     %%% (:,x,y) -> (:,y,x)
grid.radial_direction      = permute(radial_direction,[1,3,2]);   %%% (:,x,y) -> (:,y,x)
grid.GDOP_error_u          = GDOP_error_u';                       %%% (x,y)   -> (y,x)
grid.GDOP_error_v          = GDOP_error_v';                       %%% (x,y)   -> (y,x)
grid.angle_between_radials = angle_between_radials';              %%% (x,y)   -> (y,x)


%% Attributes
% time0
tmp = ncreadatt(ncfile,'time','units');
for i_time = 1 : N_time
    currents(i_time).time0 = tmp(end-18:end);
end
% lon0, lat0
tmp = ncreadatt(ncfile,'/','grid origin coordinates');
[tmp1 tmp2] = strtok(tmp,',');
grid.lon0  = str2double(strtok(tmp1,'lon:'));
grid.lat0  = str2double(strtok(tmp2,', lat:'));
% grid step
tmp = ncreadatt(ncfile,'/','grid resolution');
grid.step = str2double(strtok(tmp,'km'));
% time accuracy
cartesian_params.time_accuracy = double(ncreadatt(ncfile,'/','time accuracy for combining two radial maps'));
% master RADAR
cartesian_params.master_RADAR = ncreadatt(ncfile,'/','master RADAR');
% geographic mask on vector currents
tmp = ncreadatt(ncfile,'/','geographic mask on vector currents');
if strcmp(tmp,'applied')
    cartesian_params.use_geo_mask = 1;
else
    cartesian_params.use_geo_mask = 0;
end
% error mask on vector currents
tmp = ncreadatt(ncfile,'/','error mask on vector currents');
if strcmp(tmp,'applied')
    cartesian_params.use_err_mask = 1;
    grid.GDOP_thresh = double(ncreadatt(ncfile,'/','maximum GDOP error'));
    grid.ang_thresh  = double(ncreadatt(ncfile,'/','minimum angle between radial directions'));
else
    cartesian_params.use_err_mask = 0;
end
% mapping method
tmp = ncreadatt(ncfile,'/','mapping method');
if strcmp(tmp,'classical local interpolation with weighted interpolation')
    cartesian_params.mapping.method = 5;
    tmp = ncreadatt(ncfile,'/','influence region radius');
    cartesian_params.mapping.radius = str2double(strtok(tmp,'km'));
elseif strcmp(tmp,'mean-square-error local interpolation')
    cartesian_params.mapping.method = 6;
    tmp = ncreadatt(ncfile,'/','influence region radius');
    cartesian_params.mapping.radius = str2double(strtok(tmp,'km'));
end

% radial specific attributes
tmp = ncreadatt(ncfile,'/','number of RADAR sites');
N_RADAR = str2double(tmp);
for i_site = 1 : N_RADAR
    % - RADAR names
    name = ncreadatt(ncfile,'/',['RADAR site ' num2str(i_site) ' name']);
    % - mask on radial currents
    tmp = ncreadatt(ncfile,'/',[name ': mask on radial currents']);
    if strcmp(tmp,'applied')
        radial_params(i_site).use_radial_mask = 1;
    else
        radial_params(i_site).use_radial_mask = 0;
    end
    % - outlier removal algorithm (time)
    tmp = ncreadatt(ncfile,'/',[name ': outlier removal algorithm based on statistical analysis of the current velocity time gradient']);
    if strcmp(tmp,'applied')
        radial_params(i_site).outliers.time = 1;
        tmp = ncreadatt(ncfile,'/',[name ': outlier removal algorithm type (time)']);
        if strfind(tmp,'overall pdf')
            radial_params(i_site).outliers.time_method = 1;
            tmp = ncreadatt(ncfile,'/',[name ': outlier removal gradient threshold (time)']);
            radial_params(i_site).outliers.time_max_grad = str2double(strtok(tmp,'m/s/h'));
        elseif strfind(tmp,'pixel-based pdf')
            radial_params(i_site).outliers.time_method = 2;
        elseif strfind(tmp,'hard-coded')
            radial_params(i_site).outliers.time_method = 3;
            tmp = ncreadatt(ncfile,'/',[name ': outlier removal gradient threshold (time)']);
            radial_params(i_site).outliers.time_max_grad = str2double(strtok(tmp,'m/s/h'));
        end
    else
        radial_params(i_site).outliers.remove = 0;
    end
    % - outlier removal algorithm (space)
    tmp = ncreadatt(ncfile,'/',[name ': outlier removal algorithm based on statistical analysis of the current velocity space gradient']);
    if strcmp(tmp,'applied')
        radial_params(i_site).outliers.space = 1;
        tmp = ncreadatt(ncfile,'/',[name ': outlier removal algorithm type (space)']);
        if strfind(tmp,'overall pdf')
            radial_params(i_site).outliers.space_method = 1;
            tmp = ncreadatt(ncfile,'/',[name ': outlier removal gradient threshold (space)']);
            radial_params(i_site).outliers.space_max_grad = str2double(strtok(tmp,'m/s/km'));
        elseif strfind(tmp,'pixel-based pdf')
            radial_params(i_site).outliers.space_method = 2;
        elseif strfind(tmp,'hard-coded')
            radial_params(i_site).outliers.space_method = 3;
            tmp = ncreadatt(ncfile,'/',[name ': outlier removal gradient threshold (space)']);
            radial_params(i_site).outliers.space_max_grad = str2double(strtok(tmp,'m/s/km'));
        end
    else
        radial_params(i_site).outliers.remove = 0;
    end
    % - time-domain hole filling
    tmp = ncreadatt(ncfile,'/',[name ': time-domain gap filling technique based on linear regression between neighboring points']);
    if strcmp(tmp,'applied')
        radial_params(i_site).fill_holes.time = 1;
        tmp = ncreadatt(ncfile,'/',[name ': time-domain gap filling technique accuracy']);
        radial_params(i_site).fill_holes.time_resol = str2double(strtok(tmp,'hours'));
    else
        radial_params(i_site).fill_holes.time = 0;
    end
    % - space-domain hole filling
    tmp = ncreadatt(ncfile,'/',[name ': space-domain gap filling technique based on linear regression between neighboring points']);
    if strcmp(tmp,'applied')
        radial_params(i_site).fill_holes.space = 1;
    else
        radial_params(i_site).fill_holes.space = 0;
    end
    radial_params(i_site).name = name;
end
