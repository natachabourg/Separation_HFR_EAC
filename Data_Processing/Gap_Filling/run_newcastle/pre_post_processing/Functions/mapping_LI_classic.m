
% 
% Local interpolation of radial velocities
% 
% This function computes the full current velocity in two steps:
% 1) it interpolates, for each RADAR site, available within a
% given influce radius around each pixel. The interpolated
% value is a weighted mean of the velocities within a given radius.
% 2) the two interpolated radial velocities are combined
% to compute the full current vector by minimizing the MSE.
% N.B.: If 2 RADAR sites are available, the recombination is exact.
% 
% INPUTS:
% - data: radial data structure with 2 elements (the 2 sites) and fields:
%       - lonr,latr: lon/lat coordinates (in meshgrid format) of the radial grid [dec deg]
%       - angr:      "radial" direction                                          [km]
%       - vr:        radial velocity matrix                                      [m/s]
% - cartesian_grid: cartesian grid information strucutre with fields:
%       - lon,lat:          lon/lat coordinates (in meshgrid format) of the cartesian grid [dec deg]
%       - radial_direction: computed "radial" angles for each RADAR site
% - params: structure with parameters of the interpolation method:
%       - use_geo_mask:   apply the geographical mask
%       - use_err_mask:   apply the mask based either on the GDOP error or on the angle between radial directions
%       - mapping.radius: maximum valid radius to consider a radial velocity in the interpolation process     [km]
% 
% OUTPUTS
% - u,v: x- and y- components of the computed current velocity
%


function [u, v] = mapping_LI_classic(data,cartesian_grid,params)


N_sites   = length(data);
[N_y N_x] = size(cartesian_grid.x);

deg_to_rad = pi/180;


%% Loop on cartesian grid pixels
u = nan(N_y,N_x);
v = nan(N_y,N_x);
for i_x = 1 : N_x
    for i_y = 1 : N_y
        
       % Check whether the present pixel is masked
        if ( params.use_geo_mask == 1 && isnan(cartesian_grid.geo_mask(i_y,i_x)) ) ...
                || ( params.use_err_mask == 1 && isnan(cartesian_grid.err_mask(i_y,i_x)) )
            continue;
        end
        
        % For the present pixel
        lon = cartesian_grid.lon(i_y,i_x);                  % longitude of the present pixel
        lat = cartesian_grid.lat(i_y,i_x);                  % latitude of the present pixel
        ang = cartesian_grid.radial_direction(:,i_y,i_x);   % "radia"l direction of each RADAR site
        
        % For each site, find the interpolated velocity
        % in the neighborhood of the pixel
        vr_pixel = nan(N_sites,1);
        lack_of_site = 0;
        for i_site = 1 : N_sites
            % - radial map quantities
            lonr = data(i_site).lonr(:);                % radial map longitudes
            latr = data(i_site).latr(:);                % radial map latitudes
            angr = data(i_site).angr(:);                % radial map "radial" directions
            vr   = data(i_site).vr(:);                  % radial map velocities
            [dx, dy] = xy2lonlat(lonr,latr,lon,lat,1);
            dist = sqrt(dx.^2 + dy.^2);                 % radial map distances from the pixel center
            
            % - fetch only the currents in the neighborhood of the pixel
            ind = find(dist <= params.mapping.radius);
            angr = angr(ind);
            vr   = vr(ind);
            dist = dist(ind);
            is_NaN = isnan(vr); % remove the NaN's of the current
            angr(is_NaN) = [];  % among neighbor values
            vr(is_NaN)   = [];
            dist(is_NaN) = [];
            
            % - either pass to the next pixel or interpolate the velocity
            if isempty(dist)            % do not compute a vector if no radial value available within a "radius" distance
                lack_of_site = 1;
                break;
            else
                vr_proj = vr .* cos( (angr - ang(i_site))*deg_to_rad ); % project the radial currents around the pixel
%                 weight = 1./distance.^2;                              % onto the radial direction of the present pixel
                weight = 1./exp((dist./max(dist)).^2);
                weight = weight/sum(weight);
                vr_pixel(i_site) = sum(weight .* vr_proj);
            end
        end
        
        % Find the u and v that minimize the MSE
        % (if N_sites == 2 this gives the exact solution
        % since the system is fully determined)
        if lack_of_site ~= 1
            A = [cos(ang*deg_to_rad), sin(ang*deg_to_rad)];
            b = vr_pixel;
            tmp = pinv(A) * b;
            u(i_y,i_x) = tmp(1);
            v(i_y,i_x) = tmp(2);
        end
        
    end
end
