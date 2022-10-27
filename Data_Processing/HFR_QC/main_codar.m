clc; clear all; 

sta = 'SEAL';

for year = 2019:2021

    if year == 2019
        months_deb=[7];
        months_fin = [12];
    else
        months_deb = [1, 4, 7, 10];
        months_fin = [3, 6, 9, 12];
    end

    for i=1:length(months_deb)
        % paths
        close all;

        month_deb = months_deb(i);
        month_fin = months_fin(i);
        
        disk = '/media/nbourg/One Touch/PhD/AU_DATA/';
        git = [disk 'eac_chloro_hfr_analysis/'];
        path_data = [disk 'radials_AU/' sta '/MONTHLY/'];
        
        functions = [git 'hfr_data_processing/qc/merged_qc/'];
        addpath(functions)
        
        path_figs = [functions 'comp_figs/'];
        path_data_qc = [path_data 'QC/'];
        
        grid = load([git 'hfr_data_processing/create_radial_grid/grid_radial_' sta '.mat']);
        vr_ori = [];
        qc_vr = [];
        vr_dir = [];
        
        for month = month_deb:month_fin
            
            % Read data for one file for the test
            filename = [path_data 'hfr_hourly_gridded_fromfile_' sta '_Y' num2str(year) '_M' num2str(month) '.nc'];
            
            vr_ori = cat(3, vr_ori, ncread(filename, 'vr'));
            qc_vr = cat(3, qc_vr, ncread(filename, 'qc_vr'));
            vr_dir = cat(3, vr_dir, ncread(filename, 'vr_dir'));
        
        end
        
        lon = ncread(filename, 'lon');
        lat = ncread(filename, 'lat');
        time = transpose(1:size(vr_dir,3));
        
        % mask land
        ocean = double(~landmask(lat,lon,'australia'));
        ocean(ocean==0) = NaN;

        vr_ori = vr_ori.*ocean;
        % mask where no vr_dir 
        vr_ori(isnan(vr_dir)) = NaN;
        
        % mask above a certain range
        range_max = 200;%150; % in km
        vr1 = RADmask(vr_ori, lon, lat, range_max, sta);
        
        % apply IMOS QC
        vr1(qc_vr>2) = NaN; 
        vr1(abs(vr1)>1.5) = NaN;
        
        
        % big outliers 
        std_thresh = 0.7; % NB
        grad_thresh = 0.20; % m/s/km
        vr2 = big_outliers(sta, grid, vr1, lon, lat, std_thresh, grad_thresh);

        vr2b = outliers_std_diff(lon, lat, vr2, 1, true);


        % remove percentiles outliers on velocity + remove std + remove poor temporal coverage stuff
        N_std = 3;
        cov_thresh = 0.3;
        vr3 = outliers_bycell(vr2b, N_std, cov_thresh);
        
        %isolated points tln 
        [vr4, thresh] = outliers_suppression_t(time, grid.xr, grid.yr, vr3, 1, []);
        
        vr5 = permute(vr4, [3 2 1]);

        [vr6a, thresh_x] = outliers_suppression_xy(time, grid.xr, grid.yr, vr5, 1, [], 5);
        vr6 = permute(vr6a, [3 2 1]);
        % despike with acceleration + std with moving average
        thresh = 0.8; % MA
        runber = 2; % MA
        N_std = 3; 
        vr8 = despike_run(vr6, time, thresh, runber, N_std); % MA    
        
        vr9a = isolated_points(time, grid.xr, grid.yr, vr8);
        vr9b = permute(vr9a, [3 2 1]);
        
        % baby filling
        time_resol = 3; %hours on which u interpolate
        vr9 = permute(fill_radial_holes_t(vr9b, time, time_resol), [3 2 1]); %TLN
        vr10 = permute(fill_radial_holes_xy(grid.xr, grid.yr, vr9), [3 2 1]); %TLN
        
        vr_fin = vr10;
        
        % write file & check qc with plots
        write_ncfile(lon, lat, transpose(grid.xr), transpose(grid.yr), vr_ori, vr8, vr_fin,...
            time, path_data_qc, year, month_deb, month_fin, sta);
        
        vr_ori_test = vr_ori;

        vr_ori_test(~isnan(vr_fin)) = NaN;
        
        close all;

        plot_diff(vr_ori_test, vr_fin, lon, lat, true, ...
            path_figs, sta, num2str(year), num2str(month));
    end

end
