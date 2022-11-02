
% 
% Computes the radial mask adapted to the present grid
% and applies it to the radial data
% 
% INPUTS:
% - data: radial data structure with fields:
%       - lonr,latr: lon/lat coordinates of the radial grid [dec deg]
%       - vr:        current velocities                     [m/s]
% 
% OUTPUTS:
% - data: same as input with the mask field updated
% 


function data = apply_radial_mask(data)

disp('Apply radial mask ...');

%% Load the generic mask (built for a given grid size)
load(['/home/natachab/RADAR_NATACHA/grid_' data.name '.mat']);


%% Find the corresponding grid points to be masked in the present grid
ind_mask = find(isnan(rad_grid.mask));
lon_mask = rad_grid.lonr(ind_mask);
lat_mask = rad_grid.latr(ind_mask);
toto=0;
for i_mask = 1 : length(ind_mask)
    [dx, dy] = xy2lonlat(data.lonr,data.latr,lon_mask(i_mask),lat_mask(i_mask),1);    % distance [km]
    dist = sqrt(dx.^2 + dy.^2);
    [dist, ind_lon, ind_lat] = min_arr(dist);
    if dist < 1 % less than 1 m distance to be acceptable
        data.mask(ind_lon,ind_lat) = NaN;
	toto=toto+1;
    end
end
toto

%% Mask the radial current velocities
mask_tmp = permute( repmat(data.mask,[1 1 size(data.vr,1)]), [3 1 2] );  % (t,y,x)
data.vr = data.vr .* mask_tmp;
