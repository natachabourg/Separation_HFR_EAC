%
% Saves the full RADIAL current over the given period of time
% in one single NetCDF file
%
% modif: MARMAIN 2014/05/28: idem save_radial_NetCDF mais sans les
% attributs

function save_radial_NetCDF_light(data,radial_data_params,RADAR_infos)


%%% NetCDF path
PATH_NC = radial_data_params.path_NetCDF;

%%% STATION suffix: PEY, BEN, POB
STA = RADAR_infos.name;

%%% processing level
ProcLev=radial_data_params.ProcLev;

%%% Origin coordinates for the radial grid
lon0 = RADAR_infos.lon0;
lat0 = RADAR_infos.lat0;

%%% TX and RX sites coordinates
lon_tx = RADAR_infos.lon_tx;
lat_tx = RADAR_infos.lat_tx;
lon_rx = RADAR_infos.lon_rx;
lat_rx = RADAR_infos.lat_rx;

disp('Writing NetCDF file ...');

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

%% data
xr      = data.xr';                  %%% (y,x)   -> (x,y)
yr      = data.yr';                  %%% (y,x)   -> (x,y)
distr   = data.distr';               %%% (y,x)   -> (x,y)
angr    = data.angr';                %%% (y,x)   -> (x,y)
angr_rx = data.angr_rx';             %%% (y,x)   -> (x,y)
lonr    = data.lonr';                %%% (y,x)   -> (x,y)
latr    = data.latr';                %%% (y,x)   -> (x,y)
time    = data.time;
DATEtime_origin=data.time0;
vr      = permute(data.vr,[3,2,1]);	%%% (t,y,x) -> (x,y,t)


%% Attributes

%             remove_outliers_PFO = radial_data_params.outliers_PFO.time ;
%             outliers_percent_PFO = radial_data_params.outliers_PFO.pp ;
%             outliers_method_PFO = radial_data_params.outliers_PFO.meth ;
%             outliers_isole_PFO  = radial_data_params.outliers_PFO.i_isole;
%             outliers_thresh_PFO  =  data.threshold_current_gradient_t(1,1);



%%% Fill value for NetCDF file
fillval = -9.9999e+32;
vr(isnan(vr)) = fillval;


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
    'Dimensions',{'time',length(time)}, ...
    'Format','classic');
nccreate(ncfile,'v',...
    'Dimensions',{'x',s(1),'y',s(2),'time',length(time)}, ...
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
ncwriteatt(ncfile,'v','units',       char('m/s'));
ncwriteatt(ncfile,'v','scale_factor',1);%single(1));
ncwriteatt(ncfile,'v','add_offset',  0);%single(0));
ncwriteatt(ncfile,'v','_FillValue',  fillval);%single(fillval));


%%% GLOBAL Attributes
ncwriteatt(ncfile,'/','title',                   char(['Radial velocity from ' STA ' - ' ProcLev]));
ncwriteatt(ncfile,'/','station',                 char(STA));
ncwriteatt(ncfile,'/','grid origin coordinates', char(['lon: ' num2str(lon0)   ', lat: ' num2str(lat0)  ]));
ncwriteatt(ncfile,'/','TX site coordinates',     char(['lon: ' num2str(lon_tx) ', lat: ' num2str(lat_tx)]));
ncwriteatt(ncfile,'/','RX site coordinates',     char(['lon: ' num2str(lon_rx) ', lat: ' num2str(lat_rx)]));
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
ncwrite(ncfile,'time',time);
ncwrite(ncfile,'v',vr);

disp('Done');
disp(blanks(1)');   % empty line



end