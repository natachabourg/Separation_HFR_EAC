% 
% Imports multiple radial files of a given RADAR site
% in .cll or .xyv format
% 
% INPUTS:
% - radial_data_params: structure with fields:
%       - path_read_cll_xyv: root path of the cll/xyv files to be read (do not include the decadal directories)
%       - path_write_NetCDF: path of the NetCDF file to be written
%       - ext:               'cll' (monostatic) or 'xyv' (bistatic)
%       - dates:             2-element vector with initial and final dates to be used [string]
% - RADAR_infos:        n-element structure (n is the number of RADAR sites),
%                       containing the RADAR site(s) informations, with fields:
%       - name:      same as the cll/xyv files suffix
%       - mono_bi:   1: monostatic RADAR; 2: bistatic RADAR
%       - lon0/lat0: lon/lat coordinate of the origin of the radial grid [decimal deg]
% - lonlat0_out:        wished lon/lat origin of the radial grid
% 
% OUTPUTS:
% - data: structure containing all the radial data with fields
%       - xr/yr:     x/y meshgrid coordinates of the radial grid               [km]
%       - lonr/latr: lon/lat meshgrid coordinates of the radial grid  [decimal deg]
%       - mask:	     mask to be applied to the data (empty for the time being)
%       - time:      array of the dates of each dataset                [julian day]
%       - vr:        radial velocities for all the dates and over the grid    [m/s]
%       - lon0/lat0: lon/lat coordinate of the origin of the x/y grid [decimal deg]
%       - time0    : time origin for the dates                             [string]
% 
% BELLOMO from MARMAIN
% 2012/06/14
% 

function data = import_ncdata(radial_data_params,RADAR_infos,lonlat0_out)

% STATION suffix: PEY, BEN, POB 
STA = RADAR_infos.name;
ProcLev=RADAR_infos.obs_id;   

disp(['Importing ' STA '-' ProcLev ' data ...']);
    

% Date range
if ~isempty(radial_data_params.dates)  % range date case
cxfile1 = radial_data_params.dates(1,:);   % first valid date
cxfile2 = radial_data_params.dates(2,:);   % last valid date
cxfile1_num = str2double(cxfile1);
cxfile2_num = str2double(cxfile2);

[DATESrange]=julrad2date(radial_data_params.dates);  % used in time filling
    
% NetCDF file
ncname = [cxfile1 '_' cxfile2 '_' STA '_' ProcLev '.nc'];

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
    
    cxfile1_num = str2double(cxfile1);
    cxfile2_num = str2double(cxfile2);
    
   % NetCDF file
    ncname = [STA '_' ProcLev '_Y' n2s(NY) 'M' num2str(NM,'%02i') '.nc'];
    DATEjulian = DATESrange;
end

path_write_NetCDF = radial_data_params.path_output;%radial_data_params.path_write_NetCDF;
ncfile = fullfile(path_write_NetCDF,ncname);
disp(['from: ' ncfile]);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Importing the data
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if radial_data_params.use_NetCDF == 0
 TOTO=1
    
elseif exist(ncfile,'file')
    
    %% NetCDF file
    % Read from NetCDF
    % - Data
   % xr         = double(ncread(ncfile,'xr'));
   % yr         = double(ncread(ncfile,'yr'));
   % distr      = double(ncread(ncfile,'dist'));
    angr       = double(ncread(ncfile,'ang'));
   % angr_rx    = double(ncread(ncfile,'ang_rx'));
    lonr       = double(ncread(ncfile,'lon'));
    latr       = double(ncread(ncfile,'lat'));
    DATEjulian = double(ncread(ncfile,'time'));
    vr         = double(ncread(ncfile,'v'));
    
    % - Attributes
    tmp = ncreadatt(ncfile,'/','grid origin coordinates');
    [tmp1 tmp2] = strtok(tmp,',');
    lon0  = str2double(strtok(tmp1,'lon:'));
    lat0  = str2double(strtok(tmp2,', lat:'));
    
    time0 = ncreadatt(ncfile,'time','units');
    time0 = time0(end-18:end);
    
    tmp = ncreadatt(ncfile,'/','TX site coordinates');
    [tmp1 tmp2] = strtok(tmp,',');
    lon_tx  = str2double(strtok(tmp1,'lon:'));          % not in the output, for the time being
    lat_tx  = str2double(strtok(tmp2,', lat:'));        % not in the output, for the time being
    
    tmp = ncreadatt(ncfile,'/','RX site coordinates');
    [tmp1 tmp2] = strtok(tmp,',');
    lon_rx  = str2double(strtok(tmp1,'lon:'));          % not in the output, for the time being
    lat_rx  = str2double(strtok(tmp2,', lat:'));        % not in the output, for the time being

    % Re-arrange data according to Matlab's spatial convention (y,x)
    % starting from Ferret's convention (x,y,z,t)
    %xr      = xr';                    %%% (x,y)   -> (y,x)
    %yr      = yr';                    %%% (x,y)   -> (y,x)
    %distr   = distr';                 %%% (x,y)   -> (y,x)
    angr    = angr';                  %%% (x,y)   -> (y,x)
    %angr_rx = angr_rx';               %%% (x,y)   -> (y,x)
    lonr    = lonr';                  %%% (x,y)   -> (y,x)
    latr    = latr';                  %%% (x,y)   -> (y,x)
    vr      = permute(vr,[3,2,1]);    %%% (x,y,t) -> (t,y,x)
    
else
    data = 0;%nb
    disp(['NO DATA HERE!!' ncfile]);
    return;%nb
    %error(['The NetCDF file to be read does not exist!  ' ncfile]);
end

%% Project the x/y coordinates with respect to the lon0/lat0 given as input


lon0 = lonlat0_out(1);
lat0 = lonlat0_out(2);
[dx, dy] = xy2lonlat(lon0,lat0,lonlat0_out(1),lonlat0_out(2),1);
[xr,yr]=xy2lonlat(lonr,latr,lon0,lat0,1);%AM
xr = xr - dx; %???AJM
yr = yr - dy; %???AJM
%% Build the output structure
data.name    = STA;
data.xr      = xr;%AM
data.yr      = yr;%AM
data.lonr    = lonr;
data.latr    = latr;
data.mask    = ones(size(lonr));   % build an empty mask (1 means not to be masked)
% data.distr   = distr;
data.angr    = angr;
% data.angr_rx = angr_rx;
data.time    = DATEjulian;
data.vr      = vr;
data.lon0    = lon0;
data.lat0    = lat0;
data.time0   = time0;

