function daily_filtered_radial(radial_data_params,RADAR_infos,data)
% NB 16/07/2020 
% from L2 nc files, computes daily averaged maps, 
% adds filters to prevent outliers 
% interpolate all radial maps onto the highest resolution grid (2019)
% also creates files for empty months
% writes in a L3 nc file 

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

%useful when the month is entirely empty (no L0 or Retraitements nc file
%available)
t_first = DATESrange.julian(1);
t_end = DATESrange.julian(2);
t_first = t_first;
t_end = t_end;
    
if isempty(radial_data_params.dates)  % range date case
    ncname = [STA '_' ProcLev '_Y' n2s(NY) 'M' num2str(NM,'%02i') '.nc'];
end


ncfile = fullfile(PATH_NC,ncname);
if ~exist(PATH_NC,'dir')
    mkdir(PATH_NC);
end
if exist(ncfile,'file')
    delete(ncfile);
end


%% get L2 data, compute averages and apply filters

if isequal(STA,'PEY')
    threshold = 0.45;
    mask = ncread('/data/MIO/natachab/DINEOF/PRE/PEY_MaskDineof.nc','mask');
    mask(mask==0) = NaN;
    xr_mask = ncread('/data/MIO/natachab/monthly_averaged/month_concat/PEY_L2_Y2014M10.nc','xr');
    yr_mask = ncread('/data/MIO/natachab/monthly_averaged/month_concat/PEY_L2_Y2014M10.nc','yr');
   
elseif isequal(STA, 'POB')
    threshold = 0.4;
    mask = ncread('/data/MIO/natachab/DINEOF/PRE/POB_MaskDineof.nc','mask');
    mask(mask==0) = NaN;
    xr_mask = ncread('/data/MIO/natachab/monthly_averaged/month_concat/POB_L2_Y2014M10.nc','xr');
    yr_mask = ncread('/data/MIO/natachab/monthly_averaged/month_concat/POB_L2_Y2014M10.nc','yr');
else
    error('WRONG STATION ENTRY')
end

nc_ref = [radial_data_params.path_NetCDF STA '_L2_Y2019M02.nc']; %takes higher resolution  
xr_ref = ncread(nc_ref,'xr');       
yr_ref = ncread(nc_ref,'yr'); 
lonr_ref = ncread(nc_ref,'lon');         
latr_ref = ncread(nc_ref,'lat');         
angr_ref = ncread(nc_ref,'ang');
size_x_ref = size(xr_ref,1);
size_y_ref = size(xr_ref,2);
%read data from L2 files 
nc_L2_name = [radial_data_params.path_NetCDF STA '_L2_Y' n2s(NY) 'M' num2str(NM,'%02i') '.nc'];

%for months with chgt resolution occurring in the middle 
nc_L2_broken{1} = [radial_data_params.path_NetCDF STA '_L2_Y' n2s(NY) 'M' num2str(NM,'%02i') '_1.nc'];
nc_L2_broken{2} = [radial_data_params.path_NetCDF STA '_L2_Y' n2s(NY) 'M' num2str(NM,'%02i') '_2.nc'];

if ~exist(nc_L2_name,'file')
    xr = xr_ref;      
    yr = yr_ref;        
    lonr = lonr_ref;
    latr = latr_ref;
    angr = angr_ref;
    mask = griddata(xr_mask,yr_mask,mask,xr_ref,yr_ref);
    DATEtime_origin = DATESrange.time_origin;

    if ~exist(nc_L2_broken{1},'file')
        
        disp('#### Empty month, new nc empty file in creation#####')
        nc_ref = [radial_data_params.path_NetCDF STA '_L2_Y2019M02.nc']; %takes higher resolution  
        vr = NaN(size_x_ref,size_y_ref,NDmax);
        
    else
        disp('#### File scattered by chgt of resolution in reconstruction #####')
        for part=1:2
            nc_L2 = nc_L2_broken{part};
            disp((nc_L2));
            xr = ncread(nc_L2,'xr');       
            yr = ncread(nc_L2,'yr');         
            lonr = ncread(nc_L2,'lon');         
            latr = ncread(nc_L2,'lat');         
            angr = ncread(nc_L2,'ang');         
            vr_L2 = ncread(nc_L2, 'v');
            time_L2 = ncread(nc_L2, 'time');
            len_time = size(time_L2,1);
            %disp(size(vr_L2(abs(vr_L2)>100)));
            %vr_L2(abs(vr_L2)>100) = NaN; %to get rid of fill values
            %disp(size(vr_L2(abs(vr_L2)>100)));
   
            disp('###### Compute averages and filter data #######')
            %group data by day
            vr_day = {};
            time_day = {};
            for i = 1:len_time/24

                vr_day = [vr_day, {vr_L2(:,:,(i-1)*24+1:i*24)}];
                time_day = [time_day, {time_L2((i-1)*24+1:i*24)}];

            end

            %compute averages
            vr = {};
            time_new = {};

            for i = 1: size(vr_day,2)

                t_temp = cell2mat(time_day(i));
                time_new = [time_new, t_temp(1)]; %time array with 1st hour as the timestep
                [size_x,size_y,size_t] = size(vr_day{i});
                v_spat = reshape(vr_day{i},size_x*size_y,size_t);

                %remove maps with less than 10% of spatial coverage and maps with high
                %values (i.e. maps with only errors)
                for i = 1:24

                    data_t = v_spat(:,i);
                    if size(data_t(~isnan(data_t)),1) <= 0.1*size(data_t,1)
                        v_spat(:,i) = NaN(size_x*size_y,1);
                    end

                    if nanmean(abs(data_t))>=threshold
                        v_spat(:,i) = NaN(size_x*size_y,1);
                    end 

                end

                %remove pixels with less than 10% of temporal coverage
                ave_v = {};
                for d = 1:size(v_spat,1)

                    vr_data = v_spat(d,:);
                    if size(vr_data(~isnan(vr_data)),2)>=0.1*24
                        ave_v = [ave_v, nanmean(vr_data)];
                    else
                        ave_v = [ave_v, NaN];
                    end

                end
                v_to_interp = reshape(cell2mat(ave_v),  size_x,size_y);
                v_interp = griddata(xr,yr,v_to_interp,xr_ref,yr_ref);
                v_to_interp = v_interp.*mask;
                vr = [vr, v_interp];

            end
            
            vr = reshape(cell2mat(vr) ,size_x_ref , size_y_ref , size(vr_day,2));
            if isequal(part,1)
                vr_1 = vr;
            else 
                vr_2 = vr;
                
            end

        end
        
        vr = cat(3,vr_1,vr_2);
    end
    vr(:,:,31) = NaN(size_x_ref,size_y_ref); %BRICOLAGE
        
else 
    
    xr = ncread(nc_L2_name,'xr');       
    yr = ncread(nc_L2_name,'yr');         
    lonr = ncread(nc_L2_name,'lon');         
    latr = ncread(nc_L2_name,'lat');         
    angr = ncread(nc_L2_name,'ang');         
    vr_L2 = ncread(nc_L2_name, 'v');
    time_L2 = ncread(nc_L2_name, 'time');    
    len_time = size(time_L2,1);
    mask = griddata(xr_mask,yr_mask,mask,xr_ref,yr_ref);

    disp('###### Compute averages and filter data #######')
    %group data by day
    vr_day = {};
    time_day = {};
    for i = 1:len_time/24

        vr_day = [vr_day, {vr_L2(:,:,(i-1)*24+1:i*24)}];
        time_day = [time_day, {time_L2((i-1)*24+1:i*24)}];

    end

    %compute averages
    vr = {};
    time_new = {};

    for i = 1: size(vr_day,2)

        t_temp = cell2mat(time_day(i));
        time_new = [time_new, t_temp(1)]; %time array with 1st hour as the timestep
        [size_x,size_y,size_t] = size(vr_day{i});
        v_spat = reshape(vr_day{i},size_x*size_y,size_t);

        %remove maps with less than 10% of spatial coverage and maps with high
        %values (i.e. maps with only errors)
        for i = 1:24

            data_t = v_spat(:,i);
            if size(data_t(~isnan(data_t)),1) <= 0.1*size(data_t,1)
                v_spat(:,i) = NaN(size_x*size_y,1);
            end

            if nanmean(abs(data_t))>=threshold
                v_spat(:,i) = NaN(size_x*size_y,1);
            end 

        end

        %remove pixels with less than 10% of temporal coverage
        ave_v = {};
        for d = 1:size(v_spat,1)

            vr_data = v_spat(d,:);
            if size(vr_data(~isnan(vr_data)),2)>=0.1*24
                ave_v = [ave_v, nanmean(vr_data)];
            else
                ave_v = [ave_v, NaN];
            end

        end
        
        %interpolate vr  onto the higher res grid (2019)
        v_to_interp = reshape(cell2mat(ave_v),  size_x,size_y);
        v_interp = griddata(xr,yr,v_to_interp,xr_ref,yr_ref);
        v_to_interp = v_interp.*mask;
        vr = [vr, v_interp];
        %vr = [vr, reshape(cell2mat(ave_v), size_x,size_y) ];

    end

    %final reshape
    vr = reshape(cell2mat(vr) ,size_x_ref , size_y_ref , size(vr_day,2));
    %vr = griddata(xr,yr,vr,xr_ref,yr_ref);
    %mask = griddata(xr,yr,mask,xr_ref,yr_ref);
    %vr = vr.*mask;
    xr = xr_ref;
    yr = yr_ref;
    lonr = lonr_ref;
    latr = latr_ref;
    angr = angr_ref;
    %time = cell2mat(time_new);
    disp(data)
    
    DATEtime_origin = data.time0;
end
time = t_first:1:t_end; 

%if ~exist

%    vr = NaN(size_x,size_y,NDmax);
%    DATEtime_origin = data.time0;
%    for i = 1:NDmax
%        time=[time, DATEtime_origin
        
%    end

%end

disp('Writing NetCDF file ...');


%% Attributes
remove_outliers_t   = [radial_data_params.outliers.time];             % global attribute
outliers_method_t   = [radial_data_params.outliers.time_method];      % global attribute
outliers_percent_t  = [radial_data_params.outliers.time_percent];     % global attribute
%outliers_thresh_t   = [radial_data_params(i_station).outliers.time_max_grad];    % global attribute
if radial_data_params.outliers.time == 1
outliers_thresh_t   = [data.threshold_current_gradient_t(1,1)];
end
remove_outliers_xy  = [radial_data_params.outliers.space];            % global attribute
outliers_method_xy  = [radial_data_params.outliers.space_method];     % global attribute
outliers_percent_xy = [radial_data_params.outliers.space_percent];    % global attribute
%outliers_thresh_xy  = [radial_data_params(i_station).outliers.space_max_grad];   % global attribute
if radial_data_params.outliers.space == 1
    outliers_thresh_xy   = 0;
end
fill_holes_t        = [radial_data_params.fill_holes.time];           % global attribute
fill_holes_t_res    = [radial_data_params.fill_holes.time_resol];     % global attribute
fill_holes_xy       = [radial_data_params.fill_holes.space];          % global attribute
use_radial_mask     = [radial_data_params.use_radial_mask];           % global attribute

%             remove_outliers_PFO = radial_data_params.outliers_PFO.time ;
%             outliers_percent_PFO = radial_data_params.outliers_PFO.pp ;
%             outliers_method_PFO = radial_data_params.outliers_PFO.meth ;
%             outliers_isole_PFO  = radial_data_params.outliers_PFO.i_isole;
%             outliers_thresh_PFO  =  data.threshold_current_gradient_t(1,1);
vr(isnan(vr))=NaN;
%%% Creation
s = size(xr);
nccreate(ncfile,'xr',...
    'Dimensions',{'x',s(1),'y',s(2)}, 'Format','classic');
nccreate(ncfile,'yr',...
    'Dimensions',{'x',s(1),'y',s(2)}, 'Format','classic');
% nccreate(ncfile,'dist',...
%     'Dimensions',{'x',s(1),'y',s(2)}, 'Format','classic');
nccreate(ncfile,'ang',...
    'Dimensions',{'x',s(1),'y',s(2)}, 'Format','classic');
% nccreate(ncfile,'ang_rx',...
%     'Dimensions',{'x',s(1),'y',s(2)}, 'Format','classic');
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

% ncwriteatt(ncfile,'dist','long_name',char('Bistatic distance'));
% ncwriteatt(ncfile,'dist','units',    char('km'));
% ncwriteatt(ncfile,'dist','point_spacing', char('even'));

ncwriteatt(ncfile,'ang','long_name',char('"Radial" direction (toward the RADAR base line)'));
ncwriteatt(ncfile,'ang','units',    char('deg'));
% ncwriteatt(ncfile,'ang','point_spacing', char('even'));

% ncwriteatt(ncfile,'ang_rx','long_name',char('Direction RX -> grid point'));
% ncwriteatt(ncfile,'ang_rx','units',    char('deg'));
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
ncwriteatt(ncfile,'v','_FillValue',  'NaN');%single(fillval));


%%% GLOBAL Attributes
ncwriteatt(ncfile,'/','title',                   char(['Radial velocity from ' STA ' - ' ProcLev]));
ncwriteatt(ncfile,'/','station',                 char(STA));
ncwriteatt(ncfile,'/','grid origin coordinates', char(['lon: ' num2str(lon0)   ', lat: ' num2str(lat0)  ]));
ncwriteatt(ncfile,'/','TX site coordinates',     char(['lon: ' num2str(lon_tx) ', lat: ' num2str(lat_tx)]));
ncwriteatt(ncfile,'/','RX site coordinates',     char(['lon: ' num2str(lon_rx) ', lat: ' num2str(lat_rx)]));
ncwriteatt(ncfile,'/','creation_date',           char(datestr(now)));
ncwriteatt(ncfile,'/','author',                  char('Marmain'));



if remove_outliers_t == 1
    ncwriteatt(ncfile,'/',[RADAR_infos.name ': outlier removal algorithm based on statistical analysis of the current velocity time gradient'], char('applied'));
    switch outliers_method_t
        case 1
            ncwriteatt(ncfile,'/',[RADAR_infos.name ': outlier removal algorithm type (time)'], char(['maximum current velocity gradient corresponding to ' num2str(outliers_percent_t) 'of the maximum value of the overall pdf']));
            ncwriteatt(ncfile,'/',[RADAR_infos.name ': outlier removal gradient threshold (time)'],char([num2str(outliers_thresh_t) ' m/s/h']));
        case 2
            ncwriteatt(ncfile,'/',[RADAR_infos.name ': outlier removal algorithm type (time)'], char(['maximum current velocity gradient corresponding to ' num2str(outliers_percent_t) 'of the maximum value of the pixel-based pdf']));
        case 3
            ncwriteatt(ncfile,'/',[RADAR_infos.name ': outlier removal algorithm type (time)'], char('maximum current velocity gradient hard-coded'));
            ncwriteatt(ncfile,'/',[RADAR_infos.name ': outlier removal gradient threshold (time)'],char([num2str(outliers_thresh_t) ' m/s/h']));
    end
else
    ncwriteatt(ncfile,'/',[RADAR_infos.name ': outlier removal algorithm based on statistical analysis of the current speed time gradient'], char('not applied'));
end

if remove_outliers_xy == 1
    ncwriteatt(ncfile,'/',[RADAR_infos.name ': outlier removal algorithm based on statistical analysis of the current velocity space gradient'], char('applied'));
    switch outliers_method_xy
        case 1
            ncwriteatt(ncfile,'/',[RADAR_infos.name ': outlier removal algorithm type (space)'], char(['maximum current velocity space gradient corresponding to ' num2str(outliers_percent_xy) 'of the maximum value of the overall pdf']));
            ncwriteatt(ncfile,'/',[RADAR_infos.name ': outlier removal gradient threshold (space)'],char([num2str(outliers_thresh_xy) ' m/s/km']));
        case 2
            ncwriteatt(ncfile,'/',[RADAR_infos.name ': outlier removal algorithm type (space)'], char(['maximum current velocity space gradient corresponding to ' num2str(outliers_percent_xy) 'of the maximum value of the pixel-based pdf']));
        case 3
            ncwriteatt(ncfile,'/',[RADAR_infos.name ': outlier removal algorithm type (space)'], char('maximum current velocity space gradient hard-coded'));
            ncwriteatt(ncfile,'/',[RADAR_infos.name ': outlier removal gradient threshold (space)'],char([num2str(outliers_thresh_xy) ' m/s/km']));
    end
else
    ncwriteatt(ncfile,'/',[RADAR_infos.name ': outlier removal algorithm based on statistical analysis of the current speed space gradient'], char('not applied'));
end

% if remove_outliers_PFO == 1
%     ncwriteatt(ncfile,'/',[RADAR_infos.name ': outlier removal algorithm based on statistical analysis of the current velocity time gradient'], char('applied'));
%     switch outliers_method_PFO
%         case 1
%             ncwriteatt(ncfile,'/',[RADAR_infos.name ': outlier removal algorithm type (time)'], char(['maximum current velocity gradient corresponding to 1/' num2str(outliers_percent_PFO) 'of the maximum value of the overall pdf']));
%             ncwriteatt(ncfile,'/',[RADAR_infos.name ': outlier removal gradient threshold (time)'],char([num2str(outliers_thresh_PFO) ' m/s/(time_step)']));
%         case 2
%             ncwriteatt(ncfile,'/',[RADAR_infos.name ': outlier removal algorithm type (time)'], char(['maximum current velocity gradient corresponding to ' num2str(outliers_percent_PFO) 'of the maximum value of the pixel-based pdf']));
%     end
% else
%     ncwriteatt(ncfile,'/',[RADAR_infos.name ': outlier removal algorithm based on PFO method'], char('not applied'));
% end

if fill_holes_t == 1
    ncwriteatt(ncfile,'/',[RADAR_infos.name ': time-domain gap filling technique based on linear regression between neighboring points'], char('applied'));
    ncwriteatt(ncfile,'/',[RADAR_infos.name ': time-domain gap filling technique accuracy'],     char([num2str(fill_holes_t_res) ' hours']));
else
    ncwriteatt(ncfile,'/',[RADAR_infos.name ': time-domain gap filling technique based on linear regression between neighboring points'], char('not applied'));
end

if fill_holes_xy == 1
    ncwriteatt(ncfile,'/',[RADAR_infos.name ': space-domain gap filling technique based on linear regression between neighboring points'], char('applied'));
else
    ncwriteatt(ncfile,'/',[RADAR_infos.name ': space-domain gap filling technique based on linear regression between neighboring points'], char('not applied'));
end

if use_radial_mask == 1
    ncwriteatt(ncfile,'/',[RADAR_infos.name ': mask on radial currents'], char('applied'));
else
    ncwriteatt(ncfile,'/',[RADAR_infos.name ': mask on radial currents'], char('not applied'));
end



%%% Write variables
ncwrite(ncfile,'xr',xr);
ncwrite(ncfile,'yr',yr);
ncwrite(ncfile,'ang',angr);
ncwrite(ncfile,'lon',lonr);
ncwrite(ncfile,'lat',latr);
ncwrite(ncfile,'time',time);
ncwrite(ncfile,'v',vr);

disp('Done');
disp(blanks(1)');   % empty line









end

