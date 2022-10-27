% 27 oct. 2022 Natacha Bourg
% QC for WERA data off Coffs Harbour (RRK and NNB)
% 
% Steps : 
% - Mask Land
% - Mask data further than 150 km
% - Apply IMOS QC
% - Remove outliers (detected with standard deviation and spatial gradient)
% - Remove data below and over N_std = 3
% - Remove poor temporal coverage pixels
% - Removes outliers of Spatial/Temporal gradient (under 3% of gradient
% histogram)
% - Despike using acceleration, remove over 3 stds on a moving average
% - Removes isolated points
% - Linear interpolation of well-surrounded missing points
%
% Thresholds have been chosen after sensitivity tests


clc; clear all; 


stations = {'RRK';'NNB'};

for s = 1:2
        sta = stations{s};

    for year = 2019:2021

        if strcmp(sta,'RRK')
            % This happens because some day there is no data and you still
            % need to grid your NaNs
            lon_ori = 153.231111;
            lat_ori = -29.983888;
            dim_x_good = 123;
            dim_y_good = 112;
        else
            if strcmp(sta,'NNB')
                lon_ori = 153.0111;
                lat_ori = -30.624;
                dim_x_good = 154;
                dim_y_good = 97;
            end
        end
    
        if year == 2019
            months_deb = [7];
            months_fin = [12];
        else
            months_deb = [1, 4, 7, 10];
            months_fin = [3, 6, 9, 12];
        end
    
        for i=1:length(months_deb)
            
    
            month_deb = months_deb(i);
            month_fin = months_fin(i);
            

            disk = '/media/nbourg/One Touch/PhD/';
            git = [disk 'Separation_HFR_EAC/'];
            path_data = [git 'Data/HFR/' sta '/Gridded/'];
            
            functions = [git 'Data_Processing/HFR_QC/Functions_QC/'];
            addpath(functions)
            
            path_data_qc = [git 'Data/HFR/' sta '/QCed/'];
            
            grid = load([git 'Data_Processing/HFR_QC/Create_Radial_Grid/grid_radial_' sta '.mat']);
            vr_ori = [];
            qc_vr = [];
            vr_dir = [];

            
            for month = month_deb:month_fin
                
                % Read data for one file for the test
                filename = [path_data 'hfr_hourly_gridded_fromfile_' sta '_Y' num2str(year) '_M' num2str(month) '.nc'];
                good = [path_data 'hfr_hourly_gridded_fromfile_NNB_Y2019_M7.nc'];
        
                lon = ncread(filename, 'lon');
                lat = ncread(filename, 'lat');
                vr_file = ncread(filename, 'vr');
                vr_dir_file = ncread(filename, 'vr_dir');
                [dim_x_file, dim_y_file, dim_t_file] = size(vr_file);
    
                if dim_x_file ~= dim_x_good
                    disp([num2str(year) ' M' num2str(month) ' is empty'])
                    vr_file = NaN*ones(dim_x_good, dim_y_good, dim_t_file);
                    vr_dir_file = NaN*ones(dim_x_good, dim_y_good, dim_t_file);
                    lon = ncread(good, 'lon');
                    lat = ncread(good, 'lat');
                end
                vr_ori = cat(3, vr_ori, vr_file);
                vr_dir = cat(3, vr_dir, vr_dir_file);
    
    
            end
            
    
    
            time = transpose(1:size(vr_dir,3));
            
            [xr, yr] = lonlat2km(lon_ori, lat_ori, lon, lat);
            grid.xr = transpose(xr);
            grid.yr = transpose(yr);
            
            
            % mask land
            ocean = double(~landmask(lat,lon,'australia'));
            ocean(ocean==0) = NaN;
    
            vr_ori = vr_ori.*ocean;
            
            % Mask where no vr_dir 
            vr_ori(isnan(vr_dir)) = NaN;
            
            % Mask above a certain range
            range_max = 150; % in km
            vr1 = RADmask(vr_ori, lon, lat, range_max, sta);
            
            % Apply IMOS QC
            vr1(abs(vr1)>1.5) = NaN;
            
            vr1b = RADqc_rings(vr1, lon, lat);
    
            % Big outliers 
            std_thresh = 1; % NB
            grad_thresh = 0.20; % m/s/km
            vr2 = big_outliers(sta, grid, vr1b, lon, lat, std_thresh, grad_thresh);
    
            vr2b = outliers_std_diff_wera(lon, lat, vr2, 1, false);
    
    
            % Remove std + remove poor temporal coverage stuff
            N_std = 3;
            cov_thresh = 0.3;
            vr3 = outliers_bycell(vr2b, N_std, cov_thresh);
            
            % Outliers tln 
            [vr4, thresh] = outliers_suppression_t(time, grid.xr, grid.yr, vr3, 1, []);
            
            vr5 = permute(vr4, [3 2 1]);
    
            [vr6a, thresh_x] = outliers_suppression_xy(time, grid.xr, grid.yr, vr5, 1, [], 5);
            vr6 = permute(vr6a, [3 2 1]);

            % Despike with acceleration + std with moving average
            thresh = 0.8; % MA
            runber = 2; % MA
            N_std = 3; 
            vr8 = despike_run(vr6, time, thresh, runber, N_std); % MA    
            
            vr9a = isolated_points(time, grid.xr, grid.yr, vr8);
            vr9b = permute(vr9a, [3 2 1]);
            
            % Linear interpolation
            time_resol = 3; %hours on which you interpolate
            vr9 = permute(fill_radial_holes_t(vr9b, time, time_resol), [3 2 1]); %TLN
            vr10 = permute(fill_radial_holes_xy(grid.xr, grid.yr, vr9), [3 2 1]); %TLN
            
            vr_fin = vr10;
            
            % Write file 
            write_ncfile(lon, lat, transpose(grid.xr), transpose(grid.yr), vr_ori, vr8, vr_fin,...
                time, path_data_qc, year, month_deb, month_fin, sta);
            
    
            vr_fin = vr10;
            vr_ori_test = vr_ori;
    
            vr_ori_test(~isnan(vr_fin)) = NaN;
    
        end
    
    end
end