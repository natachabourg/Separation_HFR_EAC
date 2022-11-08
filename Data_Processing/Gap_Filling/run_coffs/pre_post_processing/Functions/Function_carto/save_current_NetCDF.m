
%
% Saves the full current over the given period of time
% in one single NetCDF file
%
% currents -> u,v,time,time0
% grid -> x,y,lon0,lat0,lon,lat,err_type,err_threshold
% radial_params -> use_radial_mask
%                  outliers -> remove,method,percent,max_gradient
%                  fill_holes -> time,time_resol,space
% cartesian_params -> use_geo_mask,use_err_mask,time_accuracy,master_RADAR,mapping.method,mapping.radius
% 

function save_current_NetCDF(currents,grid,radial_params,cartesian_params)

disp('Writing NetCDF file ...');

N_times = length(currents);
[N_y, N_x] = size(currents(1).u);

% Define the variables to be written
u = nan(N_times,N_y,N_x);
v = nan(N_times,N_y,N_x);
for i_time = 1 : N_times
    u(i_time,:,:) = currents(i_time).u;
    v(i_time,:,:) = currents(i_time).v;
end
time                  = [currents.time];
x                     = grid.x;
y                     = grid.y;
lon                   = grid.lon;
lat                   = grid.lat;
coverage              = grid.coverage;
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
remove_outliers_t   = [radial_params(1).outliers.time;
                       radial_params(2).outliers.time];             % global attribute
outliers_method_t   = [radial_params(1).outliers.time_method;
                       radial_params(2).outliers.time_method];      % global attribute
outliers_percent_t  = [radial_params(1).outliers.time_percent;
                       radial_params(2).outliers.time_percent];     % global attribute
outliers_thresh_t   = [radial_params(1).outliers.time_max_grad;
                       radial_params(2).outliers.time_max_grad];    % global attribute
remove_outliers_xy  = [radial_params(1).outliers.space;
                       radial_params(2).outliers.space];            % global attribute
outliers_method_xy  = [radial_params(1).outliers.space_method;
                       radial_params(2).outliers.space_method];     % global attribute
outliers_percent_xy = [radial_params(1).outliers.space_percent;
                       radial_params(2).outliers.space_percent];    % global attribute
outliers_thresh_xy  = [radial_params(1).outliers.space_max_grad;
                       radial_params(2).outliers.space_max_grad];   % global attribute
fill_holes_t        = [radial_params(1).fill_holes.time;
                       radial_params(2).fill_holes.time];           % global attribute
fill_holes_t_res    = [radial_params(1).fill_holes.time_resol;
                       radial_params(2).fill_holes.time_resol];     % global attribute
fill_holes_xy       = [radial_params(1).fill_holes.space;
                       radial_params(2).fill_holes.space];          % global attribute
RADAR_names         = [radial_params(1).name; ...
                       radial_params(2).name];                      % bistatic_distance,bistatic_angle,radial_direction attribute
master_RADAR        = radial_params(1).name;                        % global attribute
use_radial_mask     = [radial_params(1).use_radial_mask; ...
                       radial_params(2).use_radial_mask];           % global attribute
use_geo_mask        = cartesian_params.use_geo_mask;                % global attribute
use_err_mask        = cartesian_params.use_err_mask;                % global attribute
time_accuracy       = cartesian_params.time_accuracy;               % global attribute
mapping_method      = cartesian_params.mapping.method;              % global attribute
switch mapping_method
    case 5
        mapping_radius = cartesian_params.mapping.radius;
    case 6
        mapping_radius = cartesian_params.mapping.radius;
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Writing in NetCDF format
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Fill value for NetCDF file
fillval = -9.9999e+32;
u(isnan(u)) = fillval;
v(isnan(v)) = fillval;


%% Arrange data according to Ferret's convention (x,y,z,t)
%  (the data are in Matlab's spatial convention (y,x))
u                     = permute(u,[3,2,1]);                  %%% (t,y,x) -> (x,y,t)
v                     = permute(v,[3,2,1]);                  %%% (t,y,x) -> (x,y,t)
x                     = x';                                  %%% (y,x)   -> (x,y)
y                     = y';                                  %%% (y,x)   -> (x,y)
lon                   = lon';                                %%% (y,x)   -> (x,y)
lat                   = lat';                                %%% (y,x)   -> (x,y)
coverage              = coverage';                           %%% (y,x)   -> (x,y)
GDOP_error_u          = GDOP_error_u';                       %%% (y,x)   -> (x,y)
GDOP_error_v          = GDOP_error_v';                       %%% (y,x)   -> (x,y)
angle_between_radials = angle_between_radials';              %%% (y,x)   -> (x,y)
bistatic_distance_1   = squeeze(bistatic_distance(1,:,:))';  %%% (y,x)   -> (x,y)
bistatic_distance_2   = squeeze(bistatic_distance(2,:,:))';  %%% (y,x)   -> (x,y)
bistatic_angle_1      = squeeze(bistatic_angle(1,:,:))';     %%% (y,x)   -> (x,y)
bistatic_angle_2      = squeeze(bistatic_angle(2,:,:))';     %%% (y,x)   -> (x,y)
radial_direction_1    = squeeze(radial_direction(1,:,:))';   %%% (y,x)   -> (x,y)
radial_direction_2    = squeeze(radial_direction(2,:,:))';   %%% (y,x)   -> (x,y)


%% Build the full file name
PATH_NC = cartesian_params.path_read_write;

if ~isempty(radial_params(1).dates) %% use prescribe date range
    date_init = radial_params(1).dates(1,:);
    date_end  = radial_params(1).dates(2,:);
    ncname = [date_init '_' date_end '_' cartesian_params.ProcLev '.nc'];
    
else
    
    NY=radial_params(1).NY;
    NM=radial_params(1).NM;
    ncname = ['current_' cartesian_params.ProcLev '_Y' n2s(NY) 'M' num2str(NM,'%02i') '.nc'];
   
end



ncfile = fullfile(PATH_NC,ncname);
if ~exist(PATH_NC,'dir')
    mkdir(PATH_NC);
end
if exist(ncfile,'file')
    delete(ncfile);
end


%% Creation
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
nccreate(ncfile,'coverage',...
         'Dimensions',{'x',N_x,'y',N_y},'Format','classic');
nccreate(ncfile,'bistatic_distance_1',...
         'Dimensions',{'x',N_x,'y',N_y},'Format','classic');
nccreate(ncfile,'bistatic_distance_2',...
         'Dimensions',{'x',N_x,'y',N_y},'Format','classic');
nccreate(ncfile,'bistatic_angle_1',...
         'Dimensions',{'x',N_x,'y',N_y},'Format','classic');
nccreate(ncfile,'bistatic_angle_2',...
         'Dimensions',{'x',N_x,'y',N_y},'Format','classic');
nccreate(ncfile,'radial_direction_1',...
         'Dimensions',{'x',N_x,'y',N_y},'Format','classic');
nccreate(ncfile,'radial_direction_2',...
         'Dimensions',{'x',N_x,'y',N_y},'Format','classic');
nccreate(ncfile,'angle_between_radials',...
         'Dimensions',{'x',N_x,'y',N_y},'Format','classic');
nccreate(ncfile,'GDOP_error_u',...
         'Dimensions',{'x',N_x,'y',N_y},'Format','classic');
nccreate(ncfile,'GDOP_error_v',...
         'Dimensions',{'x',N_x,'y',N_y},'Format','classic');


%% Attributes
ncwriteatt(ncfile,'xv','long_name', char('x-coordinate'));
ncwriteatt(ncfile,'xv','units',     char('km'));

ncwriteatt(ncfile,'yv','long_name', char('y-coordinate'));
ncwriteatt(ncfile,'yv','units',     char('km'));

ncwriteatt(ncfile,'lon','long_name', char('Longitude'));
ncwriteatt(ncfile,'lon','units',     char('decimal deg'));

ncwriteatt(ncfile,'lat','long_name', char('Latitude'));
ncwriteatt(ncfile,'lat','units',     char('decimal deg'));

ncwriteatt(ncfile,'coverage','long_name', char('coverage ratio for the given time period'));
ncwriteatt(ncfile,'coverage','units',     char(''));

ncwriteatt(ncfile,'u','long_name',    char('Zonal current speed component'));
ncwriteatt(ncfile,'u','units',        char('m/s'));
ncwriteatt(ncfile,'u','scale_factor', 1);
ncwriteatt(ncfile,'u','add_offset',   0);
ncwriteatt(ncfile,'u','_FillValue',   fillval);

ncwriteatt(ncfile,'v','long_name',    char('Meridional current speed component'));
ncwriteatt(ncfile,'v','units',        char('m/s'));
ncwriteatt(ncfile,'v','scale_factor', 1);
ncwriteatt(ncfile,'v','add_offset',   0);
ncwriteatt(ncfile,'v','_FillValue',   fillval);

ncwriteatt(ncfile,'time','long_name', char('Valid Time'));
YYYYo = time0(1:4);
MMo   = time0(6:7);
DDo   = time0(9:10);
hho   = time0(12:13);
mmo   = time0(15:16);
sso   = time0(18:19);
ncwriteatt(ncfile,'time','units', ...
    char(['days since ' YYYYo '-' MMo '-' DDo ' ' hho ':' mmo ':' sso]));

ncwriteatt(ncfile,'bistatic_distance_1','long_name',char(['Bistatic distance (round-trip) for RADAR site ' RADAR_names(1,:)]));
ncwriteatt(ncfile,'bistatic_distance_1','units',    char('km'));

ncwriteatt(ncfile,'bistatic_distance_2','long_name',char(['Bistatic distance (round-trip) for RADAR site ' RADAR_names(2,:)]));
ncwriteatt(ncfile,'bistatic_distance_2','units',    char('km'));

ncwriteatt(ncfile,'bistatic_angle_1','long_name',char(['Bistatic angle for RADAR site ' RADAR_names(1,:)]));
ncwriteatt(ncfile,'bistatic_angle_1','units',    char('deg'));

ncwriteatt(ncfile,'bistatic_angle_2','long_name',char(['Bistatic angle for RADAR site ' RADAR_names(2,:)]));
ncwriteatt(ncfile,'bistatic_angle_2','units',    char('deg'));

ncwriteatt(ncfile,'radial_direction_1','long_name',char(['Radial direction for RADAR site ' RADAR_names(1,:)]));
ncwriteatt(ncfile,'radial_direction_1','units',    char('deg'));

ncwriteatt(ncfile,'radial_direction_2','long_name',char(['Radial direction for RADAR site ' RADAR_names(2,:)]));
ncwriteatt(ncfile,'radial_direction_2','units',    char('deg'));

ncwriteatt(ncfile,'angle_between_radials','long_name',char('Angle between radial directions'));
ncwriteatt(ncfile,'angle_between_radials','units',    char('deg'));

ncwriteatt(ncfile,'GDOP_error_u','long_name',char('Zonal currentGeometric Dilution Of Precision (GDOP) normalized error'));
ncwriteatt(ncfile,'GDOP_error_u','units',    char(''));
ncwriteatt(ncfile,'GDOP_error_u','comment',  char('Normalized error wrt the error inherent to the Doppler spectrum resolution'));

ncwriteatt(ncfile,'GDOP_error_v','long_name',char('Meridional current Geometric Dilution Of Precision (GDOP) normalized error'));
ncwriteatt(ncfile,'GDOP_error_v','units',    char(''));
ncwriteatt(ncfile,'GDOP_error_v','comment',  char('Normalized error wrt the error inherent to the Doppler spectrum resolution'));



%%% GLOBAL Attributes
ncwriteatt(ncfile,'/','title',                   char(['mapped current velocity from ' num2str(RADAR_names(1,:)) '-' num2str(RADAR_names(2,:)) 'sites']));
ncwriteatt(ncfile,'/','grid origin coordinates', char(['lon: ' num2str(lon0) ', lat: ' num2str(lat0)]));
ncwriteatt(ncfile,'/','grid resolution',         char([num2str(grid_resol) ' km']));
ncwriteatt(ncfile,'/','time accuracy for combining two radial maps', time_accuracy);
ncwriteatt(ncfile,'/','master RADAR',            char(master_RADAR));
if use_geo_mask == 0
    ncwriteatt(ncfile,'/','geographic mask on vector currents', char('not applied'));
else
    ncwriteatt(ncfile,'/','geographic mask on vector currents', char('applied'));
end
if use_err_mask == 0
    ncwriteatt(ncfile,'/','error mask on vector currents', char('not applied'));
else
    ncwriteatt(ncfile,'/','error mask on vector currents', char('applied'));
    ncwriteatt(ncfile,'/','maximum GDOP error',                      GDOP_threshold);
    ncwriteatt(ncfile,'/','minimum angle between radial directions', angle_threshold);
end
switch mapping_method
    case 5
        ncwriteatt(ncfile,'/','mapping method', char('classical local interpolation with weighted interpolation'));
        ncwriteatt(ncfile,'/','influence region radius', char([num2str(mapping_radius) ' km']));
    case 6
        ncwriteatt(ncfile,'/','mapping method', char('mean-square-error local interpolation'));
        ncwriteatt(ncfile,'/','influence region radius', char([num2str(mapping_radius) ' km']));
end
% - Radial specific attributes
ncwriteatt(ncfile,'/','number of RADAR sites', char('2'));
for i_site = 1 : 2
    ncwriteatt(ncfile,'/',['RADAR site ' num2str(i_site) ' name'], char(RADAR_names(i_site,:)));
    
    if use_radial_mask(i_site) == 1
        ncwriteatt(ncfile,'/',[RADAR_names(i_site,:) ': mask on radial currents'], char('applied'));
    else
        ncwriteatt(ncfile,'/',[RADAR_names(i_site,:) ': mask on radial currents'], char('not applied'));
    end
    
    if remove_outliers_t(i_site) == 1
        ncwriteatt(ncfile,'/',[RADAR_names(i_site,:) ': outlier removal algorithm based on statistical analysis of the current velocity time gradient'], char('applied'));
        switch outliers_method_t(i_site)
            case 1
                ncwriteatt(ncfile,'/',[RADAR_names(i_site,:) ': outlier removal algorithm type (time)'], char(['maximum current velocity gradient corresponding to ' num2str(outliers_percent_t(i_site)) 'of the maximum value of the overall pdf']));
                ncwriteatt(ncfile,'/',[RADAR_names(i_site,:) ': outlier removal gradient threshold (time)'],char([num2str(outliers_thresh_t(i_site)) ' m/s/h']));
            case 2
                ncwriteatt(ncfile,'/',[RADAR_names(i_site,:) ': outlier removal algorithm type (time)'], char(['maximum current velocity gradient corresponding to ' num2str(outliers_percent_t(i_site)) 'of the maximum value of the pixel-based pdf']));
            case 3
                ncwriteatt(ncfile,'/',[RADAR_names(i_site,:) ': outlier removal algorithm type (time)'], char('maximum current velocity gradient hard-coded'));
                ncwriteatt(ncfile,'/',[RADAR_names(i_site,:) ': outlier removal gradient threshold (time)'],char([num2str(outliers_thresh_t(i_site)) ' m/s/h']));
        end
    else
        ncwriteatt(ncfile,'/',[RADAR_names(i_site,:) ': outlier removal algorithm based on statistical analysis of the current speed time gradient'], char('not applied'));
    end
    
    if remove_outliers_xy(i_site) == 1
        ncwriteatt(ncfile,'/',[RADAR_names(i_site,:) ': outlier removal algorithm based on statistical analysis of the current velocity space gradient'], char('applied'));
        switch outliers_method_xy(i_site)
            case 1
                ncwriteatt(ncfile,'/',[RADAR_names(i_site,:) ': outlier removal algorithm type (space)'], char(['maximum current velocity space gradient corresponding to ' num2str(outliers_percent_xy(i_site)) 'of the maximum value of the overall pdf']));
                ncwriteatt(ncfile,'/',[RADAR_names(i_site,:) ': outlier removal gradient threshold (space)'],char([num2str(outliers_thresh_xy(i_site)) ' m/s/km']));
            case 2
                ncwriteatt(ncfile,'/',[RADAR_names(i_site,:) ': outlier removal algorithm type (space)'], char(['maximum current velocity space gradient corresponding to ' num2str(outliers_percent_xy(i_site)) 'of the maximum value of the pixel-based pdf']));
            case 3
                ncwriteatt(ncfile,'/',[RADAR_names(i_site,:) ': outlier removal algorithm type (space)'], char('maximum current velocity space gradient hard-coded'));
                ncwriteatt(ncfile,'/',[RADAR_names(i_site,:) ': outlier removal gradient threshold (space)'],char([num2str(outliers_thresh_xy(i_site)) ' m/s/km']));
        end
    else
        ncwriteatt(ncfile,'/',[RADAR_names(i_site,:) ': outlier removal algorithm based on statistical analysis of the current speed space gradient'], char('not applied'));
    end
    
    if fill_holes_t(i_site) == 1
        ncwriteatt(ncfile,'/',[RADAR_names(i_site,:) ': time-domain gap filling technique based on linear regression between neighboring points'], char('applied'));
        ncwriteatt(ncfile,'/',[RADAR_names(i_site,:) ': time-domain gap filling technique accuracy'],     char([num2str(fill_holes_t_res(i_site)) ' hours']));
    else
        ncwriteatt(ncfile,'/',[RADAR_names(i_site,:) ': time-domain gap filling technique based on linear regression between neighboring points'], char('not applied'));
    end
    
    if fill_holes_xy(i_site) == 1
        ncwriteatt(ncfile,'/',[RADAR_names(i_site,:) ': space-domain gap filling technique based on linear regression between neighboring points'], char('applied'));
    else
        ncwriteatt(ncfile,'/',[RADAR_names(i_site,:) ': space-domain gap filling technique based on linear regression between neighboring points'], char('not applied'));
    end
end

ncwriteatt(ncfile,'/','creation_date', char(datestr(now)));


%% Write variables
ncwrite(ncfile,'xv',x);
ncwrite(ncfile,'yv',y);
ncwrite(ncfile,'lon',lon);
ncwrite(ncfile,'lat',lat);
ncwrite(ncfile,'coverage',coverage);
ncwrite(ncfile,'u',u);
ncwrite(ncfile,'v',v);
ncwrite(ncfile,'time',time);
ncwrite(ncfile,'bistatic_distance_1',bistatic_distance_1);
ncwrite(ncfile,'bistatic_distance_2',bistatic_distance_2);
ncwrite(ncfile,'bistatic_angle_1',bistatic_angle_1);
ncwrite(ncfile,'bistatic_angle_2',bistatic_angle_2);
ncwrite(ncfile,'radial_direction_1',radial_direction_1);
ncwrite(ncfile,'radial_direction_2',radial_direction_2);
ncwrite(ncfile,'angle_between_radials',angle_between_radials);
ncwrite(ncfile,'GDOP_error_u',GDOP_error_u);
ncwrite(ncfile,'GDOP_error_v',GDOP_error_v);
