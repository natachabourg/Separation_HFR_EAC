
% 
% Fills the holes in the data, at each time instant, by computing a linear
% regression between all the available values around the unavailable pixel.
% 
% 
% Lucio Bellomo from Philippe Forget, 2012/06/15
% 


function vr_out = fill_radial_holes_xy(xr, yr, vr)

vr_in  = permute(vr, [3 2 1]);
vr_out = vr_in;

tmp = size(vr_in);

N_time = tmp(1);
N_line = tmp(2);
N_col  = tmp(3);


disp('Hole filling - Space domain ...');
% h = waitbar(0,'Hole filling - Space domain');
for i_time = 1 : N_time    % loop on time values
    if N_time ~= 1
        vr = squeeze(vr_in(i_time,:,:));
    else
        vr = vr_in;
    end
    
    % Get position and number of the holes
    [ind_line ind_col] = find(isnan(vr));
    N_holes = length(ind_line);

    for i_hole = 1 : N_holes  % loop on the holes
        ind = [ind_line(i_hole), ind_col(i_hole)];
        xr_hole = xr(ind(1),ind(2));
        yr_hole = yr(ind(1),ind(2));
        
        % Consider a box of -1/+1 points centered at the hole position
        % - Handle the case of holes at the first/last x/y grid point
        ind_line_min = max(ind(1)-1,1);
        ind_line_max = min(ind(1)+1,N_line);
        ind_col_min  = max(ind(2)-1,1);
        ind_col_max  = min(ind(2)+1,N_col);


        xr_near = xr(ind_line_min:ind_line_max, ind_col_min:ind_col_max);
        yr_near = yr(ind_line_min:ind_line_max, ind_col_min:ind_col_max);
        vr_near = vr(ind_line_min:ind_line_max, ind_col_min:ind_col_max);
        % - Find the non-NaN points in the neighborhood
        near_valid = find( ~isnan( vr_near ) );
        N_valid = length(near_valid);
        
        if N_valid >= 2
            % Compute the distances between the hole and the valid points
            delta_xr_near = xr_near(near_valid) - xr_hole;
            delta_yr_near = yr_near(near_valid) - yr_hole;
            distr_near    = sqrt( delta_xr_near.^2 + delta_yr_near.^2 );
            vr_near       = vr_near(near_valid);
            
            % Compute the barycenter of the valid neighbors
            barycenter = (1/N_valid) * sqrt( sum(delta_xr_near)^2 + sum(delta_yr_near)^2 );
            
            % Do the interpolation only if
            % 1: the barycenter distance is smaller than the smaller valid
            %    point distance (to avoid the case of valid points only on
            %    one side of the hole)
            % OR
            % 2: the nb of valid points is larger than 5 (this assures that
            %    the hole is surrounded on at least two sides) 
            if barycenter < min(distr_near) || N_valid >= 3
                if N_valid == 2                    
                    % Take a simple mean
                    vr_out(i_time,ind(1),ind(2)) = mean(vr_near);
                else
                    % Method 1: Multivariate linear regression
                    % (the multiple variables are the valid points in the neighborhood)
                    G = ones(N_valid,3);
                    G(:,2) = delta_xr_near(:);
                    G(:,3) = delta_yr_near(:);
                    F = vr_near(:);
                    tmp = pinv(G)*F;
                    vr_interp = tmp(1,1);
                    
%                     % Method 2: Least Squares weighted with the distances
%                     %           Gives worse results
%                     ponderation   = 1./dist_near.^2;
%                     normalization = 1./sum(ponderation);
%                     vr_interp = normalization * mean(vr_near.*ponderation);

                    % - Be sure that the interpolated value is between the
                    %   min and the max of the near values
                    if vr_interp < max(vr_near) && vr_interp > min(vr_near)
                        vr_out(i_time,ind(1),ind(2)) = vr_interp;
                    end
                end
            end
        end
    end
    
%     waitbar(i_time/N_time);
    
end
% close(h);
