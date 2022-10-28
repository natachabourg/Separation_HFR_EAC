% 12 Jul. 2022 Natacha
% Script to lowpass filter (using pl66tn at a 38hrs frequency)
% hourly HFR data from AUS. And daily average them.
% Put all data of the same station in one same file
%

clc;
clear all;
close all;

%% load data
sta = 'RHED';
path = ['/media/nbourg/One Touch/PhD/Separation_HFR_EAC/Data/HFR/Radials/' sta '/QCed/'];

files = {'Y2019_M07_M12_QC.nc';...
    'Y2020_M01_M03_QC.nc'; 'Y2020_M04_M06_QC.nc';...
    'Y2020_M07_M09_QC.nc'; 'Y2020_M10_M12_QC.nc'; ...
    'Y2021_M01_M03_QC.nc'; 'Y2021_M04_M06_QC.nc';...
    'Y2021_M07_M09_QC.nc'; 'Y2021_M10_M12_QC.nc';};

ncfile = [path sta '_daily_Y2019_M07_Y2021_M12.nc'];

vr = [];
for i = 1:length(files)
    file = [path sta '_' files{i}];
    vr = cat(3,vr, ncread(file,'vr'));
end


%%

lon = ncread(file, 'lon');
lat = ncread(file, 'lat');
xr = ncread(file,'xr');
yr = ncread(file,'yr');

%% low pass filter 

vr_filtered = NaN*ones(size(vr));
[N_x, N_y, N_times] = size(vr);
dt = 1;
T = 38;
time = 1:N_times;
for i=1:N_x
    for j=1:N_y
        test = squeeze(vr(i,j,:));
        is_nan = isnan(test);
        test_to_int = test(~is_nan);
        time_to_int = time(~is_nan);
        
        if length(test_to_int)>1
            test_to_filt = interp1(time_to_int, test_to_int, time);
            filtered = pl66tn(test_to_filt, dt, T);
            filtered(is_nan) = NaN;
            vr_filtered(i,j,:) = filtered;
        end

    end

end


vr_filtered2 = NaN*ones(size(vr));
time = 1:N_times;
for i=1:N_x
    for j=1:N_y
        test = squeeze(vr(i,j,:));
        filtered = pl66tn(test, dt, T);
        vr_filtered2(i,j,:) = filtered;
    end

end


%% daily average

number_days = N_times/24;
vr_daily = ones(N_x,N_y,number_days);
vr_daily_filt = ones(N_x,N_y,number_days);
thresh = 0;

for t=1:number_days

    obj_vrf = vr(:,:,24*(t-1)+1:24*t);
    mean_filt = nanmean(obj_vrf,3);
    vr_daily(:,:,t) = mean_filt;

end



for t=1:number_days

    obj_vrf = vr_filtered(:,:,24*(t-1)+1:24*t);
    mean_filt = nanmean(obj_vrf,3);
    vr_daily_filt(:,:,t) = mean_filt;


end


time_day = datetime(2019,7,1):days(1):datetime(2021,12,31);
time_hour = datetime(2019,7,1,1,0,0):hours(1):datetime(2021,12,31,24,0,0);

time = 0:number_days-1;correct

%% only for illustrative purposes


%% Spatial interpolation of holes in the radial that are always occurring

if strcmp(sta, 'NNB')
    y_min = 30;
    y_max = 65;
    x_min = 72;
    x_max = 120;
    
    for timestep = 1:number_days
        for x = x_min:x_max
            line = vr_daily_filt(x,y_min:y_max,timestep);
            lon_line = lon(x, y_min:y_max);

            lon_line_nonan = lon_line(~isnan(line));
            nonan = line(~isnan(line));
            
            if length(nonan)>3
                interp_line = interp1(lon_line_nonan, nonan, lon_line);
                vr_daily_filt(x, y_min:y_max, timestep) = interp_line;
            end
        end
    end

elseif strcmp(sta, 'RRK')

    y_min = 5;
    y_max = 40;
    x_min = 52;
    x_max = 67;
    
    for timestep = 1:number_days
        for x = x_min:x_max
            line = vr_daily_filt(x,y_min:y_max,timestep);
            lon_line = lon(x, y_min:y_max);

            lon_line_nonan = lon_line(~isnan(line));
            nonan = line(~isnan(line));
            
            if length(nonan)>3
                interp_line = interp1(lon_line_nonan, nonan, lon_line);
                vr_daily_filt(x, y_min:y_max, timestep) = interp_line;
            end
        end
        
        x_min2 = 52;
        x_max2 = 66;
        y_min2 = 14;
        y_max2 = 37;

        for y = y_min2:y_max2


            line = vr_daily_filt(x_min2:x_max2,y,timestep);
            lat_line = lat(x_min2:x_max2,y);

            lat_line_nonan = lat_line(~isnan(line));
            nonan = line(~isnan(line));
            
            if length(nonan)>2
                interp_line = interp1(lat_line_nonan, nonan, lat_line);
                vr_daily_filt(x_min2:x_max2,y,timestep) = interp_line;
            end
        end

    end
end


if strcmp(sta, 'SEAL')
    x_min = 1;
    x_max = 14;

    for timestep = 1:number_days

        for x = x_min:x_max

            end_line = vr_daily_filt(x, 175:end, timestep);
            size_end = size(end_line,2)

            beg_line = vr_daily_filt(x,1:3, timestep);
            end_lat = lat(x, 175:end);
            beg_lat = lat(x, 1:3);
            
            line = cat(2,end_line, beg_line);
            lat_line = cat(2,end_lat, beg_lat);


            lat_line_nonan = lat_line(~isnan(line));
            nonan = line(~isnan(line));
            
            if length(nonan) > 3
                interp_line = interp1(lat_line_nonan, nonan, lat_line);
                interp_end = interp_line(1:size_end);
                interp_beg = interp_line(size_end+1:end);
                vr_daily_filt(x,175:end,timestep) = interp_end;
            end

        end

    end
end

if strcmp(sta,'RHED')

    x_min = 1;
    x_max = 14;

    for timestep = 1:number_days

        for x = x_min:x_max

            end_line = vr_daily_filt(x, 175:end, timestep);
            size_end = size(end_line,2)

            beg_line = vr_daily_filt(x,1:3, timestep);
            end_lat = lat(x, 175:end);
            beg_lat = lat(x, 1:3);
            
            line = cat(2,end_line, beg_line);
            lat_line = cat(2,end_lat, beg_lat);


            lat_line_nonan = lat_line(~isnan(line));
            nonan = line(~isnan(line));
            
            if length(nonan) > 3
                interp_line = interp1(lat_line_nonan, nonan, lat_line);
                interp_end = interp_line(1:size_end);
                interp_beg = interp_line(size_end+1:end);
                vr_daily_filt(x,175:end,timestep) = interp_end;
            end

        end

    end
end

%% write nc file

if exist(ncfile,'file')
    delete(ncfile);
end

nccreate(ncfile,'xr',...
         'Dimensions',{'x',N_x,'y',N_y},'Format','classic');
nccreate(ncfile,'yr',...
         'Dimensions',{'x',N_x,'y',N_y},'Format','classic');
nccreate(ncfile,'lon',...
         'Dimensions',{'x',N_x,'y',N_y},'Format','classic');
nccreate(ncfile,'lat',...
         'Dimensions',{'x',N_x,'y',N_y},'Format','classic');
nccreate(ncfile,'vr',...
         'Dimensions',{'x',N_x,'y',N_y,'time',number_days}, 'Format','classic');
nccreate(ncfile,'time',...
         'Dimensions',{'time',number_days},'Format','classic');
     

ncwriteatt(ncfile,'xr','long_name', char('x-coordinate'));
ncwriteatt(ncfile,'xr','units',     char('km'));

ncwriteatt(ncfile,'yr','long_name', char('y-coordinate'));
ncwriteatt(ncfile,'yr','units',     char('km'));

ncwriteatt(ncfile,'lon','long_name', char('Longitude'));
ncwriteatt(ncfile,'lon','units',     char('decimal deg'));

ncwriteatt(ncfile,'lat','long_name', char('Latitude'));
ncwriteatt(ncfile,'lat','units',     char('decimal deg'));


ncwriteatt(ncfile,'vr','long_name',    char(['QCed Daily Radial Velocity from ' sta]));
ncwriteatt(ncfile,'vr','units',        char('m/s'));

ncwriteatt(ncfile,'time','long_name', char('Time'));
ncwriteatt(ncfile, 'time','units', char('Days since 01-Jul-2019'))


ncwrite(ncfile,'xr', xr);
ncwrite(ncfile,'yr', yr);
ncwrite(ncfile,'lon', lon);
ncwrite(ncfile,'lat', lat);

ncwrite(ncfile,'vr', vr_daily_filt);
ncwrite(ncfile,'time', time);



