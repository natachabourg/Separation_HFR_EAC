%
% Convert multiple radial files of a given RADAR site
% from .cll or .xyv format into a single NetCDF file
%   N.B.: The time origin in the NetCDF file is 2010-01-01 00:00:00, and
%         the time is in days
%
% INPUTS:
% - radial_data_params: structure with fields:
%       - path_read_cll_xyv: root path of the cll/xyv files to be read (do not include the decadal directories)
%       - path_write_NetCDF:      path of the NetCDF file to be written
%       - ext:          'cll' (monostatic) or 'xyv' (bistatic)
%       - dates:        2-element vector with initial and final dates to be used [string]
% - RADAR_infos: n-element structure (n is the number of RADAR sites),
%                containing the RADAR site(s) informations, with fields:
%       - name:      same as the cll/xyv files suffix
%       - mono_bi:   1: monostatic RADAR; 2: bistatic RADAR
%       - lon0/lat0: lon/lat coordinate of the origin of the radial grid [decimal deg]
%
% OUTPUTS:
%
%
% MARMAIN
% 2012/05/24
% cll_xyv2nc.m
% BELLOMO from MARMAIN (transformation into a function)
% 2012/06/13
%
% Modif: MARMAIN 2014/03/28: include the monthly processing
%                            include the filling of missing time with NaN

function cll_xyv2nc(radial_data_params,RADAR_infos)

%%% cll or xyv path
%%% This directory contains files sorted either in decadal directories or not
PATH_ORI = radial_data_params.path_cll_xyv;

%%% NetCDF path
PATH_NC = radial_data_params.path_NetCDF;

%%% file name extension: cll or xyv
EXT = radial_data_params.ext;

%%% STATION suffix: PEY, BEN, POB
STA = RADAR_infos.name;

% processing level for NC name
if strcmp(RADAR_infos.obs_id,'L0') == 0    
    warning('The resulting file must be ##L0## type >>> correction is done...')
    ProcLev='L0';
else
    ProcLev=RADAR_infos.obs_id;   
end
%%% Origin coordinates for the radial grid
lon0 = RADAR_infos.lon0;
lat0 = RADAR_infos.lat0;

%%% TX and RX sites coordinates
lon_tx = RADAR_infos.lon_tx;
lat_tx = RADAR_infos.lat_tx;
lon_rx = RADAR_infos.lon_rx;
lat_rx = RADAR_infos.lat_rx;

%%% Date range
if ~isempty(radial_data_params.dates)  % range date case
    cxfile1 = radial_data_params.dates(1,:);   % first valid date
    cxfile2 = radial_data_params.dates(2,:);   % last valid date

    [DATESrange]=julrad2date(radial_data_params.dates);  % used in time filling
    
else % monthly case
    NY=radial_data_params.NY;
    NM=radial_data_params.NM;
    NDmin=radial_data_params.NDmin;
    NDmax=radial_data_params.NDmax;
    
    %%% first time of the month
    dates(1,:)=datenum(NY,NM,NDmin,0,0,0)-datenum(2010,1,1,0,0,0);
    %%% last time of the month
    dates(2,:)=datenum(NY,NM,NDmax,23,59,0)-datenum(2010,1,1,0,0,0);
    
    [DATESrange]=julday2date(dates);  % used in time filling
   
    cxfile1 = DATESrange.radar(1,:);   % first valid date
    cxfile2 = DATESrange.radar(2,:);   % last valid date
   
end

cxfile1_num = str2double(cxfile1);
cxfile2_num = str2double(cxfile2);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Importing the data
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
disp(['import ' STA ' from ' cxfile1 ' to ' cxfile2]);

%%% build the list of files
[ cxname ] = cll_xyv_list( PATH_ORI , EXT , STA );

%%% select only the file range specified by cxfile1-cxfile2
for ii = 1 : size(cxname,1)
    [~, cxname_file, ~] = fileparts(cxname(ii,:));
    if str2double(cxname_file(1:11)) >= cxfile1_num
        i1 = ii;
        break;
    end
end
for ii = size(cxname,1) : -1 : 1
    [~, cxname_file, ~] = fileparts(cxname(ii,:));
    if str2double(cxname_file(1:11)) <= cxfile2_num
        i2 = ii;
        break;
    end
end
clear ii cxname_file cxfile1_num cxfile2_num
if ~exist('i1','var')
    error([STA ': The first date of "radial_data_params" might be posterior to the most recent existing file!']);
end
if ~exist('i2','var')
    error([STA ': The last date of "radial_data_params" might be anterior to the oldest existing file!']);
end
cxname = cxname(i1:i2,:);

%%% read radial velocities, x/y grid and date
[ vr, xr, yr, DATE ] = cll_xyv_reader( cxname );

%%% compute the grid in lon/lat
[ lonr, latr ] = xy2lonlat(xr, yr, lon0, lat0, 2);

%%% compute the grid in distance/"radial" angle
%%% N.B.#1: the angle is counted counterclockwise from the WE direction
%%% N.B.#2: the "radial" angle is the normal to the circle (mono-) or
%%%         ellipse (bi-static) at the given point
[x_tx, y_tx] = xy2lonlat(lon_tx,lat_tx,lon0,lat0,1);
[x_rx, y_rx] = xy2lonlat(lon_rx,lat_rx,lon0,lat0,1);
[distr, angr, angr_rx] = dist_angle(x_tx,y_tx,x_rx,y_rx,RADAR_infos.mono_bi,xr,yr);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 disp('######## Fill missing time ######################## ')
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

[ VR_EXT, DATE_EXT , TIME_NONAN ] = ...
    FILL_miss_time_NAN_withoutBorE( vr , DATE.julian , DATESrange.julian );

vr=VR_EXT;
DATE=DATE_EXT;


%%% write julian day into a matrix (needed to properly write the NetCDF)
for ii = 1 : size(vr,1)
    DATEjulian(ii,:)   = DATE.julian(ii);
    DATEcalendar(ii,:) = DATE.calendar(ii); % nor written in the NetCDF, as for today (2012/06/14 LB)
end

DATEtime_origin=DATE_EXT.time_origin;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Writing in NetCDF format
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Fill value for NetCDF file
fillval = -9.9999e+32;
vr(isnan(vr)) = fillval;

%%% Arrange data according to Ferret's convention (x,y,z,t)
%%% starting from Matlab's spatial convention (y,x)
xr      = xr';                  %%% (y,x)   -> (x,y)
yr      = yr';                  %%% (y,x)   -> (x,y)
distr   = distr';               %%% (y,x)   -> (x,y)
angr    = angr';                %%% (y,x)   -> (x,y)
angr_rx = angr_rx';             %%% (y,x)   -> (x,y)
lonr    = lonr';                %%% (y,x)   -> (x,y)
latr    = latr';                %%% (y,x)   -> (x,y)
vr      = permute(vr,[3,2,1]);	%%% (t,y,x) -> (x,y,t)

% ncname = [cxname(1,end-18:end-8) '_' cxname(end,end-18:end-8) '_' STA '.nc'];

if ~isempty(radial_data_params.dates)  % range date case
    ncname = [cxfile1 '_' cxfile2 '_' STA '_' ProcLev '.nc'];
else 
    ncname = [STA '_' ProcLev '_Y' n2s(NY) 'M' num2str(NM,'%02i') '.nc'];
end

ncfile = fullfile(PATH_NC,ncname);
if ~exist(PATH_NC,'dir')
    mkdir(PATH_NC);
end
if exist(ncfile,'file')
    delete(ncfile);
end

%%% Creation
s = size(xr);
nccreate(ncfile,'xr',...
    'Dimensions',{'x',s(1),'y',s(2)}, 'Format','classic');
nccreate(ncfile,'yr',...
    'Dimensions',{'x',s(1),'y',s(2)}, 'Format','classic');
nccreate(ncfile,'dist',...
    'Dimensions',{'x',s(1),'y',s(2)}, 'Format','classic');
nccreate(ncfile,'ang',...
    'Dimensions',{'x',s(1),'y',s(2)}, 'Format','classic');
nccreate(ncfile,'ang_rx',...
    'Dimensions',{'x',s(1),'y',s(2)}, 'Format','classic');
nccreate(ncfile,'lon',...
    'Dimensions',{'x',s(1),'y',s(2)}, 'Format','classic');
nccreate(ncfile,'lat',...
    'Dimensions',{'x',s(1),'y',s(2)}, 'Format','classic');
nccreate(ncfile,'time',...
    'Dimensions',{'time',length(DATEjulian)}, ...
    'Format','classic');
nccreate(ncfile,'v',...
    'Dimensions',{'x',s(1),'y',s(2),'time',length(DATEjulian)}, ...
    'Format','classic')

%%% Attributes
ncwriteatt(ncfile,'xr','long_name',char('Abscisse'));
ncwriteatt(ncfile,'xr','units',    char('km'));
% ncwriteatt(ncfile,'x','point_spacing', char('even'));

ncwriteatt(ncfile,'yr','long_name',char('Ordinate'));
ncwriteatt(ncfile,'yr','units',    char('km'));
% ncwriteatt(ncfile,'y','point_spacing', char('even'));

ncwriteatt(ncfile,'dist','long_name',char('Bistatic distance'));
ncwriteatt(ncfile,'dist','units',    char('km'));
% ncwriteatt(ncfile,'dist','point_spacing', char('even'));

ncwriteatt(ncfile,'ang','long_name',char('"Radial" direction (toward the RADAR base line)'));
ncwriteatt(ncfile,'ang','units',    char('deg'));
% ncwriteatt(ncfile,'ang','point_spacing', char('even'));

ncwriteatt(ncfile,'ang_rx','long_name',char('Direction RX -> grid point'));
ncwriteatt(ncfile,'ang_rx','units',    char('deg'));
% ncwriteatt(ncfile,'ang_rx','point_spacing', char('even'));

ncwriteatt(ncfile,'lon','long_name',char('Longitude'));
ncwriteatt(ncfile,'lon','units',    char('decimal deg'));
% ncwriteatt(ncfile,'lon','point_spacing', char('even'));

ncwriteatt(ncfile,'lat','long_name',char('Latitude'));
ncwriteatt(ncfile,'lat','units',    char('decimal deg'));
% ncwriteatt(ncfile,'lat','point_spacing', char('even'));

ncwriteatt(ncfile,'time','long_name',char('Valid Time'));
ncwriteatt(ncfile,'time','units',char(['days since ' DATEtime_origin]));
ncwriteatt(ncfile,'time','time_origin',DATEtime_origin);

ncwriteatt(ncfile,'v','long_name',   char(['Radial velocity from ' STA]));
ncwriteatt(ncfile,'v','comment',     char(['Original format ' EXT]));
ncwriteatt(ncfile,'v','units',       char('m/s'));
ncwriteatt(ncfile,'v','scale_factor',1);%single(1));
ncwriteatt(ncfile,'v','add_offset',  0);%single(0));
ncwriteatt(ncfile,'v','_FillValue',  fillval);%single(fillval));


%%% GLOBAL Attributes
ncwriteatt(ncfile,'/','title',                   char(['Radial velocity from ' STA]));
ncwriteatt(ncfile,'/','station',                 char(STA));
ncwriteatt(ncfile,'/','grid origin coordinates', char(['lon: ' num2str(lon0)   ', lat: ' num2str(lat0)  ]));
ncwriteatt(ncfile,'/','TX site coordinates',     char(['lon: ' num2str(lon_tx) ', lat: ' num2str(lat_tx)]));
ncwriteatt(ncfile,'/','RX site coordinates',     char(['lon: ' num2str(lon_rx) ', lat: ' num2str(lat_rx)]));
ncwriteatt(ncfile,'/','original_type',           char(EXT));
ncwriteatt(ncfile,'/','creation_date',           char(datestr(now)));
ncwriteatt(ncfile,'/','author',                  char('Marmain'));


%%% Write variables
ncwrite(ncfile,'xr',xr);
ncwrite(ncfile,'yr',yr);
ncwrite(ncfile,'dist',distr);
ncwrite(ncfile,'ang',angr);
ncwrite(ncfile,'ang_rx',angr_rx);
ncwrite(ncfile,'lon',lonr);
ncwrite(ncfile,'lat',latr);
ncwrite(ncfile,'time',DATEjulian);
ncwrite(ncfile,'v',vr);

disp('Done');
disp(blanks(1)');   % empty line
