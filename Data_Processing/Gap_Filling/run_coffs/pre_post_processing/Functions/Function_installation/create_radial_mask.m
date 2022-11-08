
function rad_grid = create_radial_mask(RADAR_infos)

site_name = RADAR_infos.name;
lon0      = RADAR_infos.lon0;
lat0      = RADAR_infos.lat0;

%% Read an example file for fetching the geometry of the radial grid
if strcmp(site_name,'PEY')
    [xr, yr] = cll_xyv_reader_mask(['Function_installation' filesep 'mask_PEY.xyv']);
elseif strcmp(site_name,'BEN')
    [xr, yr] = cll_xyv_reader_mask(['Function_installation' filesep 'mask_BEN.xyv']);
elseif strcmp(site_name,'POB')
    [xr, yr] = cll_xyv_reader_mask(['Function_installation' filesep 'mask_POB.xyv']);

end
[lonr, latr] = xy2lonlat(xr, yr, lon0, lat0, 2);
rad_grid.name = site_name;
rad_grid.xr   = xr;
rad_grid.yr   = yr;
rad_grid.lonr = lonr;
rad_grid.latr = latr;
rad_grid.lon0 = lon0;
rad_grid.lat0 = lat0;
clear xr yr lonr latr


%% Mask the points
[n m] = size(rad_grid.xr);
rad_grid.mask = ones(n,m);
if strcmp(site_name,'PEY')
    % Azimuth Nord
    di = 1:n;
    az = 27:m;
    rad_grid.mask(di,az) = NaN;
    % Giens
    di = 5:6;
    az = 23:26;
    rad_grid.mask(di,az) = NaN;
    % Porquerolles
    di = 7:8;
    az = 22;
    rad_grid.mask(di,az) = NaN;
    di = 8:9;
    az = 23;
    rad_grid.mask(di,az) = NaN;
    % Port Cros - Île du Levant
    di = 12;
    az = 23:24;
    rad_grid.mask(di,az) = NaN;
    di = 12;
    az = 24;
    rad_grid.mask(di,az) = NaN;
    di = 14;
    az = 24;
    rad_grid.mask(di,az) = NaN;
    di = 13;
    az = 23:24;
    rad_grid.mask(di,az) = NaN;
    di = 15;
    az = 24:25;
    rad_grid.mask(di,az) = NaN;
    % Porquerolles "shadow"
    di = 9:31;
    az = 22:31;
    rad_grid.mask(di,az) = NaN;
    
elseif strcmp(site_name,'BEN')
    % W direction
    di = 1:3;
    az = 1:14;
    rad_grid.mask(di,az) = NaN;
    % Port Cros
    di = 2;
    az = 48:55;
    rad_grid.mask(di,az) = NaN;
    % Porquerolles
    di = 1;
    az = 15:20;
    rad_grid.mask(di,az) = NaN;
    di = 2;
    az = 16:19;
    rad_grid.mask(di,az) = NaN;
    % Port Cros - Île du Levant channel
    di = 3:6;
    az = 56:57;
    rad_grid.mask(di,az) = NaN;
    di = 3:n;
    az = 58:61;
    rad_grid.mask(di,az) = NaN;
    % Additional Port Cros - Île du Levant ing
    % for a coverage smaller than 0.4 @ 2011 340-346
    di = 2:5;
    az = 44;
    rad_grid.mask(di,az) = NaN;
    di = 2:11;
    az = 45;
    rad_grid.mask(di,az) = NaN;
    di = 2:n;
    az = 45:55;
    rad_grid.mask(di,az) = NaN;
    
elseif strcmp(site_name,'POB')
    
end


%% Save a .mat file with the grid+mask structure
save(['grid_' site_name '.mat'],'rad_grid');
