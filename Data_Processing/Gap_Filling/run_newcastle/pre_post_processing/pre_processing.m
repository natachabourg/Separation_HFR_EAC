% @ Julien Marmain 
% Script to pre process radial current file 
%to a format accepted by DINEOF algorithm
% % Variables to change :
% %
% - PATH_NC_in : path where the HFR radial file to fill is located
% - ncname_in : name of the HFR radial file to fill
% - PATH_NC : path where to put the preprocessed nc file 
% - ncname : name of the preprocessed nc file
% - STA : Name of your station
% - DATEtime_origin : the origin of your time variable in string format
% (only for meta data purposes)
% %
% 

clc; clear all; close all;

disk = '/home/natachab/Bureau/';
git = [disk 'eac_chloro_hfr_analysis/'];

path_out = [git 'hfr_data_processing/gap_filling/run_newcastle/pre_post_processing/'];
functions = [git 'hfr_data_processing/gap_filling/functions/'];
addpath(functions)


stations = {'RHED','SEAL'};
ncname_in_all = {'RHED_daily_Y2019_M07_Y2021_M12.nc','SEAL_daily_Y2019_M07_Y2021_M12.nc'};

for i = 1:2
    sta = stations{i};

    path_data = [git 'hfr_data_processing/gap_filling/run_newcastle/original_data/'];

    ncname_in = ncname_in_all{i};
    
    input_file = fullfile(path_data, ncname_in);


    if ~exist(input_file,'file')
        disp('File in input not found');
    end

    %%% Name of your output file 
    ncname = ['daily_2019_2021_' sta '_pre.nc'];

    ncfile = fullfile(path_out, ncname);
    ncmask = fullfile(path_out, ['mask_2019_2021_' sta '.nc'])

    if exist(ncfile,'file')
        delete(ncfile);
    end

    if exist(ncmask,'file')
        delete(ncmask);
    end

    %% data           
    lonr    = ncread(input_file,'lon');    
    latr    = ncread(input_file,'lat');      
    time    = ncread(input_file,'time');
    vr = ncread(input_file,'vr');

    %%% Creation
    s = size(lonr);
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

    ncwriteatt(ncfile,'lon','long_name',char('Longitude'));
    ncwriteatt(ncfile,'lon','units',    char('decimal deg'));

    ncwriteatt(ncfile,'lat','long_name',char('Latitude'));
    ncwriteatt(ncfile,'lat','units',    char('decimal deg'));

    ncwriteatt(ncfile,'time','long_name',char('Valid Time'));

    ncwriteatt(ncfile,'v','long_name',   char(['Radial velocity preprocessed from ' sta]));
    ncwriteatt(ncfile,'v','units',       char('m/s'));

    %%% Write variables
    ncwrite(ncfile,'lon',lonr);
    ncwrite(ncfile,'lat',latr);
    ncwrite(ncfile,'time',time);
    ncwrite(ncfile,'v',vr);

    % create mask of temporal coverage
    
    for i = 1:size(vr,1)
        for j = 1:size(vr,2)
            pix = squeeze(vr(i,j,:));
            temp_cov(i,j) = length(pix(~isnan(pix)))/length(time);
        end
    end

    figure; 
    hold on;
    title([sta ' temporal coverage']);
    pcolor(lonr,latr,temp_cov); 
    shading flat; 
    colormap(jet);
    colorbar
    hold off;

    thresh_input = inputdlg('Enter minimum temporal coverage :');
    close all;
    
    thresh = str2double(thresh_input{1});
    mask_bool = temp_cov >= thresh;
    
    mask = double(mask_bool);


    nccreate(ncmask,'lon',...
        'Dimensions',{'x',s(1),'y',s(2)}, 'Format','classic');
    nccreate(ncmask,'lat',...
        'Dimensions',{'x',s(1),'y',s(2)}, 'Format','classic');

    nccreate(ncmask,'mask',...
        'Dimensions',{'x',s(1),'y',s(2)},'Format','classic');

    ncwriteatt(ncmask,'lon','long_name',char('Longitude'));
    ncwriteatt(ncmask,'lon','units',    char('decimal deg'));

    ncwriteatt(ncmask,'lat','long_name',char('Latitude'));
    ncwriteatt(ncmask,'lat','units',    char('decimal deg'));

    ncwriteatt(ncmask,'mask','long_name',   char(['Mask for dineof for ' sta '. Threshold of temporal coverage : ' num2str(thresh)]));

    %%% Write variables
    ncwrite(ncmask,'lon',lonr);
    ncwrite(ncmask,'lat',latr);
    ncwrite(ncmask,'mask',mask); 

    disp(['Processing done for ' sta]); 

end