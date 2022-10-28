% Natacha 
% 03/05/2022
% Create radial grid for Newcastle radar data
% For the moment the script only works for monostatic radials so only
% Newcastle
%
% Grids have already been generated but
% This script has been run on Respore, so need to update paths and download needed file in local if we need to re-compute the grid
% 
%

clc; clear all; close all;

path_to_git = '/home/natachab/Bureau/eac_chloro_hfr_analysis/';
path_bureau = '/home/natachab/Bureau/';

addpath([path_to_git 'download_data_from_thredds/create_radial_grid/'])


sta = 'RHED';
lonOrg = 151.7268;
latOrg = -33.0109167;
bearing = 90-144+360; %antenna bearing [deg]
deltaAng = 2.;%angle resolution [deg]
deltaRange = 13.591; %range resolution [km]
maxRange = 20*deltaRange; %max range [km]


[dist,angle,xr,yr,lonr,latr] = calcRadialGrid(lonOrg,latOrg,...
                                            bearing,deltaAng,...
                                            maxRange,deltaRange);


test = [path_bureau 'IMOS_ACORN_RV_20190701T180000Z_RHED_FV00_radial.nc'];
loni = ncread(test,'LONGITUDE');
lati = ncread(test, 'LATITUDE');

figure;
hold on;
title(sta);
pcolor(lonr,latr,ones(size(dist)));
scatter(loni,lati,'k');
hold off

grid_radial = [path_to_git 'download_data_from_thredds/create_radial_grid/grid_radial_' sta '.mat'];
save(grid_radial,'lonr','latr','xr','yr','dist','angle');

%%
clc; clear all; close all;

path_to_git = '/home/natachab/Bureau/eac_chloro_hfr_analysis/';
path_bureau = '/home/natachab/Bureau/';

sta = 'SEAL';
lonOrg = 152.5390833;
latOrg = -32.4414667;
bearing = 90-174+360; %antenna bearing [deg]
deltaAng = 2.;%angle resolution [deg]
deltaRange = 13.591; %range resolution [km]
maxRange = 20*deltaRange; %max range [km]


[dist,angle,xr,yr,lonr,latr] = calcRadialGrid(lonOrg,latOrg,...
                                            bearing,deltaAng,...
                                            maxRange,deltaRange);


test = [path_bureau 'IMOS_ACORN_RV_20210302T010000Z_SEAL_FV00_radial.nc'];
loni = ncread(test,'LONGITUDE');
lati = ncread(test, 'LATITUDE');

figure;
hold on;
title(sta);
pcolor(lonr,latr,ones(size(dist)));
scatter(loni,lati,'k');
hold off

grid_radial = [path_to_git 'download_data_from_thredds/create_radial_grid/grid_radial_' sta '.mat'];
save(grid_radial,'lonr','latr','xr','yr','dist','angle');

% 
% 
% %%
% 
% 
% sta = 'RRK';
% lonOrg = 153.2311111;
% latOrg = -29.9838888;
% bearing = 90-135+360; %antenna bearing [deg]
% deltaAng = 2.;%angle resolution [deg]
% deltaRange = 1.5; %range resolution [km]
% maxRange = 50*deltaRange; %max range [km]
% 
% 
% [dist,angle,xr,yr,lonr,latr] = calcRadialGrid(lonOrg,latOrg,...
%                                             bearing,deltaAng,...
%                                             maxRange,deltaRange);
% 
% 
% test = '/home/natachab/Bureau/IMOS_ACORN_RV_20190701T000000Z_RRK_FV01_radial.nc';
% loni = ncread(test,'LONGITUDE');
% lati = ncread(test, 'LATITUDE');
% 
% figure;
% hold on;
% title(sta);
% pcolor(lonr,latr,ones(size(dist)));
% scatter(loni,lati,'k');
% hold off
% 
% 
% %%
% 
% 
% sta = 'NNB';
% lonOrg = 153.23;
% latOrg = -29.98;
% bearing = 285.; %antenna bearing [deg]
% deltaAng = 2.;%angle resolution [deg]
% deltaRange = 1.5; %range resolution [km]
% maxRange = 100.; %max range [km]
% 
% 
% [dist,angle,xr,yr,lonr,latr] = calcRadialGrid(lonOrg,latOrg,...
%                                             bearing,deltaAng,...
%                                             maxRange,deltaRange);
% 
% 
% test = '/home/natachab/Bureau/IMOS_ACORN_RV_20190701T001500Z_NNB_FV00_radial.nc';
% loni = ncread(test,'LONGITUDE');
% lati = ncread(test, 'LATITUDE');
% 
% figure;
% hold on;
% title(sta);
% pcolor(lonr,latr,ones(size(dist)));
% scatter(loni,lati,'k');
% hold off
% 
% 
