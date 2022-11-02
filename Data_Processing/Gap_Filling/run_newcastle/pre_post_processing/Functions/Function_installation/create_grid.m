
% 
% Creates a rectangular grid
% 
% INPUT:
% - cartesian_grid: structure with the following fields
%       - lon_lim,lat_lim: min and max longitude/latitude to be covered
%       - step: step of the wished grid [km]
%       - alpha: rotation angle of the grid wrt the WE axis (counterclockwise) [deg]
% 
% OUTPUTS:
% - cartesian_grid: updated input grid structure with additional fields:
%       - x/y:     meshgrid-format x/y grid in km
%       - lon/lat: meshgrid-format lon/lat grid in decimal degrees
% 

function cartesian_grid = create_grid(cartesian_grid)

% Some quantities
lon_lim = cartesian_grid.lon_lim;
lat_lim = cartesian_grid.lat_lim;
step    = cartesian_grid.step;
alpha   = cartesian_grid.rot_angle;
lon0    = cartesian_grid.lon0;
lat0    = cartesian_grid.lat0;

% Dimensions of the rectangular grid
[dist_x dist_y] = xy2lonlat(lon_lim(2),lat_lim(2), ...
                            lon_lim(1),lat_lim(1),1);

% Number of points in the two directions
Nx = floor(dist_x/step) + 1;
Ny = floor(dist_y/step) + 1;

% Create the grid in km
x = [0:Nx-1]*step;
y = [0:Ny-1]*step;
[xx,yy] = meshgrid(x,y);

% Rotate the grid
R = [cos(alpha*pi/180) -sin(alpha*pi/180);
     sin(alpha*pi/180)  cos(alpha*pi/180)];
for ii = 1 : size(xx,2)
    for jj = 1 : size(yy,1)
        tmp = R * [xx(jj,ii); yy(jj,ii)];
        xx(jj,ii) = tmp(1);
        yy(jj,ii) = tmp(2);
    end
end
clear tmp

% Remove the lon_lim/lat_lim fields, which should be updated and are anyway
% implicitly available in lon/lat
cartesian_grid = rmfield(cartesian_grid,'lon_lim');
cartesian_grid = rmfield(cartesian_grid,'lat_lim');

% Center the grid with respect to the lon0/lat0 origin
[off_x off_y] = xy2lonlat(lon_lim(1),lat_lim(1),lon0,lat0,1);
xx = xx + off_x;
yy = yy + off_y;

% Update the input structure with the new x/y and lon/lat fields
cartesian_grid.x = xx;
cartesian_grid.y = yy;
[cartesian_grid.lon cartesian_grid.lat] = xy2lonlat(xx,yy,lon0,lat0,2);
