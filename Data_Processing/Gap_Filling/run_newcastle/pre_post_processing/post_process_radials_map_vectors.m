% 02 Nov. 2022 Natacha Bourg
% 
% This script uses outputs from PostProcessNewcastleMasks*.npy to remove 
% data badly reconstructed by DINEOF and then proceeds to the vectorial
% mapping of radials onto a cartesian grid generated 
% by create_cartesian_grid_newcastle.m


clc; clear all; close all;

path = '/media/nbourg/One Touch/PhD/Separation_HFR_EAC/Data_Processing/Gap_Filling/run_newcastle/';
addpath([path 'pre_post_processing/Functions/Function_matlab/']);
addpath([path 'pre_post_processing/Functions/Function_carto/']);

%addpath('/home/natachab/Bureau/eac_chloro_hfr_analysis/hfr_data_processing/qc/merged_qc/');

% We take Lon,Lat, and angles from this file
ini_file = {[path 'pre_post_processing/hfr_hourly_gridded_fromfile_RHED_Y2019_M7.nc'],...
    [path 'pre_post_processing/hfr_hourly_gridded_fromfile_SEAL_Y2019_M7.nc']};

% We take DINEOF outputs from this file
path_result = [path 'my_result_folder/log2/'];
data_file = {[path_result 'daily_2019_2021_RHED_din.nc'],...
    [path_result 'daily_2019_2021_SEAL_din.nc']};

pre_file = [path 'pre_post_processing/daily_2019_2021_SEAL_pre.nc'];


vr1 = ncread(data_file{1},'v');
ang1 = ncread(ini_file{1},'vr_dir');
ang1 = nanmean(ang1,3);
lon_rhed = ncread(ini_file{1},'lon');
lat_rhed = ncread(ini_file{1},'lat');
lon0_rhed = 151.72;
lat0_rhed = -33.01;
[xr1, yr1] = lonlat2km(lon0_rhed, lat0_rhed, lon_rhed, lat_rhed);

vr2 = ncread(data_file{2}, 'v');
ang2 = ncread(ini_file{2}, 'vr_dir');
ang2 = nanmean(ang2, 3);

lon_seal = ncread(ini_file{2},'lon');
lat_seal = ncread(ini_file{2},'lat');
lon0_seal = 152.53;
lat0_seal = -32.44;
[xr2, yr2] = lonlat2km(lon0_seal, lat0_seal, lon_seal, lat_seal);

lon0 = {lon0_rhed, lon0_seal};
lat0 = {lat0_rhed, lat0_seal};
STA  = {'RHED', 'SEAL'};

% Post process the data (Remove bad points, see notebook for explanations)

mask_rhed = readNPY('PostProcessNewcastleMasks_maskrhed.npy')
mask_seal = readNPY('PostProcessNewcastleMasks_maskseal.npy')

mask_rhed_time = readNPY('PostProcessNewcastleMasks_maskrhed_time.npy')
mask_seal_time = readNPY('PostProcessNewcastleMasks_maskseal_time.npy')

mask_all_time = readNPY('PostProcessNewcastleMasks_maskall_time.npy')

vr1_masked = vr1.*mask_rhed';
vr2_masked = vr2.*mask_seal';

vr1_masked(:,:,isnan(mask_rhed_time)) = NaN;
vr2_masked(:,:,isnan(mask_seal_time)) = NaN;

vr1_masked(:,:,isnan(mask_all_time)) = NaN;
vr2_masked(:,:,isnan(mask_all_time)) = NaN;


% Put the data in a structure needed for the vector mapping function
for i =1:2
    lonr = ncread(ini_file{i},'lon');
    latr = ncread(ini_file{i},'lat');
    
    [xr, yr] = lonlat2km(lon0{i}, lat0{i}, lonr, latr);

    
    ang = ncread(ini_file{i},'vr_dir');
    angr = -nanmean(ang, 3)+90;
    
    DATEjulian = ncread(pre_file,'time');
    vr = ncread(data_file{i},'v');
    
    
    vr(abs(vr)>10)=NaN;
    time0 = ncreadatt(ini_file{i},'time','units');
    time0 = time0(end-18:end);

    data.name    = STA{i};
    data.xr      = xr;
    data.yr      = yr;
    data.lonr    = lonr;
    data.latr    = latr;
    data.mask    = ones(size(lonr));
    data.angr    = angr;
    data.time    = DATEjulian;

    if i==1
        data.vr = vr1_masked;
    elseif i==2
        data.vr = vr2_masked;
    end

    data.lon0    = lon0;
    data.lat0    = lat0;
    data.time0   = time0;

    radial_data(i)=data;
end

%%
CONFIGURATION_newcastle
% je dois generer ma cartesian_grid.mat
% construct the total velocity
[currents grid] = vector_mapping(radial_data, cartesian_data_params);

N_times = length(currents);
[N_y, N_x] = size(currents(1).u);

% Define the variables to be written
u = nan(N_times,N_y,N_x);
v = nan(N_times,N_y,N_x);
for i_time = 1 : N_times
    u(i_time,:,:) = currents(i_time).u;
    v(i_time,:,:) = currents(i_time).v;
end

speed = sqrt(u.^2+v.^2);
u(abs(u) > 2) = NaN;
v(abs(v) > 2) = NaN;
u(speed>2)=NaN;
v(speed>2)=NaN;

%%

time                  = [currents.time];
x                     = grid.x;
y                     = grid.y;
lon                   = grid.lon;
lat                   = grid.lat;
bistatic_distance     = grid.bistatic_distance;
bistatic_angle        = grid.bistatic_angle;
radial_direction      = grid.radial_direction;
GDOP_error_u          = grid.err_GDOP_u;
GDOP_error_v          = grid.err_GDOP_v;
angle_between_radials = grid.angle_between_radials;

% Define the attributes to be written
time0               = currents(1).time0;  % time attribute
lon0                = grid.lon0;          % global attribute
lat0                = grid.lat0;          % global attribute
grid_resol          = grid.step;          % global attribute
GDOP_threshold      = grid.GDOP_thresh;   % global attribute
angle_threshold     = grid.ang_thresh;    % global attribute

%%

u                     = permute(u,[3,2,1]);                  %%% (t,y,x) -> (x,y,t)
v                     = permute(v,[3,2,1]);                  %%% (t,y,x) -> (x,y,t)
x                     = x';                                  %%% (y,x)   -> (x,y)
y                     = y';                                  %%% (y,x)   -> (x,y)
lon                   = lon';                                %%% (y,x)   -> (x,y)
lat                   = lat';                                %%% (y,x)   -> (x,y)
GDOP_error_u          = GDOP_error_u';                       %%% (y,x)   -> (x,y)
GDOP_error_v          = GDOP_error_v';                       %%% (y,x)   -> (x,y)
angle_between_radials = angle_between_radials';              %%% (y,x)   -> (x,y)
bistatic_distance_1   = squeeze(bistatic_distance(1,:,:))';  %%% (y,x)   -> (x,y)
bistatic_distance_2   = squeeze(bistatic_distance(2,:,:))';  %%% (y,x)   -> (x,y)
bistatic_angle_1      = squeeze(bistatic_angle(1,:,:))';     %%% (y,x)   -> (x,y)
bistatic_angle_2      = squeeze(bistatic_angle(2,:,:))';     %%% (y,x)   -> (x,y)
radial_direction_1    = squeeze(radial_direction(1,:,:))';   %%% (y,x)   -> (x,y)
radial_direction_2    = squeeze(radial_direction(2,:,:))';   %%% (y,x)   -> (x,y)


%%
ncfile = [path_result 'currents_dineof_NEWC_Y2019M07_Y2021M12.nc'];

[N_x,N_y,N_times]=size(u);

nccreate(ncfile,'xv',...
         'Dimensions',{'x',N_x,'y',N_y},'Format','classic');
nccreate(ncfile,'yv',...
         'Dimensions',{'x',N_x,'y',N_y},'Format','classic');
nccreate(ncfile,'lon',...
         'Dimensions',{'x',N_x,'y',N_y},'Format','classic');
nccreate(ncfile,'lat',...
         'Dimensions',{'x',N_x,'y',N_y},'Format','classic');
nccreate(ncfile,'u',...
         'Dimensions',{'x',N_x,'y',N_y,'time',N_times}, 'Format','classic');
nccreate(ncfile,'v',...
         'Dimensions',{'x',N_x,'y',N_y,'time',N_times}, 'Format','classic');
nccreate(ncfile,'time',...
         'Dimensions',{'time',N_times},'Format','classic');


ncwriteatt(ncfile,'xv','long_name', char('x-coordinate'));
ncwriteatt(ncfile,'xv','units',     char('km'));

ncwriteatt(ncfile,'yv','long_name', char('y-coordinate'));
ncwriteatt(ncfile,'yv','units',     char('km'));

ncwriteatt(ncfile,'lon','long_name', char('Longitude'));
ncwriteatt(ncfile,'lon','units',     char('decimal deg'));

ncwriteatt(ncfile,'lat','long_name', char('Latitude'));
ncwriteatt(ncfile,'lat','units',     char('decimal deg'));

ncwriteatt(ncfile,'time','long_name', char('Time'));
ncwriteatt(ncfile, 'time','units', char('Days since 01-Jul-2019'))

ncwriteatt(ncfile,'u','long_name',    char('Zonal current speed component'));
ncwriteatt(ncfile,'u','units',        char('m/s'));
ncwriteatt(ncfile,'u','scale_factor', 1);
ncwriteatt(ncfile,'u','add_offset',   0);

ncwriteatt(ncfile,'v','long_name',    char('Meridional current speed component'));
ncwriteatt(ncfile,'v','units',        char('m/s'));
ncwriteatt(ncfile,'v','scale_factor', 1);
ncwriteatt(ncfile,'v','add_offset',   0);





ncwrite(ncfile,'xv',x);
ncwrite(ncfile,'yv',y);
ncwrite(ncfile,'lon',lon);
ncwrite(ncfile,'lat',lat);
ncwrite(ncfile,'u',u);
ncwrite(ncfile,'v',v);
ncwrite(ncfile,'time',time);

