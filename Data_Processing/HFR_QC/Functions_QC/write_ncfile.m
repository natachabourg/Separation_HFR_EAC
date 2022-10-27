function [] = write_ncfile(lon, lat, xr, yr, vr_ori, vr_bf_fill, vr_fin, time, path, year, month_deb, month_fin, sta)
%WRITE_NCFILE write file for QCed data


ncname = [sta '_Y' num2str(year) '_M' sprintf('%02d',month_deb) '_M' sprintf('%02d',month_fin) '_QC.nc' ];
ncfile = [path ncname]

[N_x, N_y, N_times] = size(vr_fin);

len_before = length(vr_ori(~isnan(vr_ori)));
len_after = length(vr_bf_fill(~isnan(vr_bf_fill)));

percentage_removed = 100*((len_before - len_after)/len_before);

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
         'Dimensions',{'x',N_x,'y',N_y,'time',N_times}, 'Format','classic');
nccreate(ncfile,'time',...
         'Dimensions',{'time',N_times},'Format','classic');
     

ncwriteatt(ncfile,'xr','long_name', char('x-coordinate'));
ncwriteatt(ncfile,'xr','units',     char('km'));

ncwriteatt(ncfile,'yr','long_name', char('y-coordinate'));
ncwriteatt(ncfile,'yr','units',     char('km'));

ncwriteatt(ncfile,'lon','long_name', char('Longitude'));
ncwriteatt(ncfile,'lon','units',     char('decimal deg'));

ncwriteatt(ncfile,'lat','long_name', char('Latitude'));
ncwriteatt(ncfile,'lat','units',     char('decimal deg'));


ncwriteatt(ncfile,'vr','long_name',    char(['QCed Radial Velocity from ' sta]));
ncwriteatt(ncfile,'vr','units',        char('m/s'));
ncwriteatt(ncfile,'vr','Percentage of data removed by the QC', char(percentage_removed));



ncwriteatt(ncfile,'time','long_name', char('Time'));

ncwrite(ncfile,'xr', xr);
ncwrite(ncfile,'yr', yr);
ncwrite(ncfile,'lon', lon);
ncwrite(ncfile,'lat', lat);

ncwrite(ncfile,'vr', vr_fin);
ncwrite(ncfile,'time', time);








end

