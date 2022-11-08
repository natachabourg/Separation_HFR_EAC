
% 
% Weighted Mean Square Error (MSE) local interpolation of radial velocities
% 
% This function computes the full current velocity by minimizing the
% weighted square error of all the radial velocities available within a
% given influce radius around each pixel.
% The wieghts of the error keep into account the association of a radial
% current to a RADAR site, but the minimization is run over all the
% available data.
% 
% INPUTS:
% - data: radial data structure with 2 elements (the 2 sites) and fields:
%       - lonr,latr: lon/lat coordinates (in meshgrid format) of the radial grid [dec deg]
%       - angr:      "radial" direction                                  [km]
%       - vr:        radial velocity matrix                              [m/s]
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


function [u, v] = mapping_LI_all_radial(radial_data,data,cartesian_grid,params)
data = radial_data;

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
        lon = cartesian_grid.lon(i_y,i_x);                    % longitude of the present pixel
        lat = cartesian_grid.lat(i_y,i_x);                    % latitude of the present pixel
        
        % For each site, fetch the available radial currents
        % in the neighborhood of the pixel
        distr_pixel  = [];
        angr_pixel   = [];
        vr_pixel     = [];
        weight_pixel = [];
        lack_of_site = 0;
        for i_site = 1 : N_sites
            % - radial map quantities
            lonr = data(i_site).lonr(:);                % radial map x-coordinates
            latr = data(i_site).latr(:);                % radial map y-coordinates
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
            
            %vvv = vr(~isnan(vr));
            %disp(size(vvv));
            
            angr(is_NaN) = [];  % among neighbor values
            vr(is_NaN)   = [];
            dist(is_NaN) = [];
            
            % - either pass to the next pixel or compute the MSE weights
            if isempty(dist)            % do not compute a vector if no radial value available within a "radius" distance
                lack_of_site = 1;
                break;
            else
                distr_pixel  = [distr_pixel; dist]; %#ok<*AGROW>
                angr_pixel   = [angr_pixel;  angr];
                vr_pixel     = [vr_pixel;    vr];
%                 weight_tmp   = 1./distance.^2;                % distance^-2 weight
                weight_tmp   = 1./exp((dist./max(dist)).^2);    % exponetial(distance^-2) weight
                weight_tmp   = weight_tmp/sum(weight_tmp);
                weight_pixel = [weight_pixel; weight_tmp];
            end
        end
        
        % Find the u and v that minimize the weighted MSE
        if lack_of_site ~= 1
            % - Build the matrix and vector of the linear system
            %   (the matrix is obtained by deriving the cost function wrt u and v)
            A = [    sum( weight_pixel .* cos(angr_pixel*deg_to_rad).^2 ), 0.5*sum( weight_pixel .* sin(2*angr_pixel*deg_to_rad) ) ;
                 0.5*sum( weight_pixel .* sin(2*angr_pixel*deg_to_rad) ),      sum( weight_pixel .* sin(angr_pixel*deg_to_rad).^2 )];
            b = [sum( weight_pixel .* vr_pixel .* cos(angr_pixel*deg_to_rad) ) ;
                 sum( weight_pixel .* vr_pixel .* sin(angr_pixel*deg_to_rad) )];
            % - Inverse the system
            tmp = A \ b;
%             warning('off','MATLAB:nearlySingularMatrix');
%             warning('off','MATLAB:singularMatrix');
            u(i_y,i_x) = tmp(1);
            v(i_y,i_x) = tmp(2);
        end
    end
end
