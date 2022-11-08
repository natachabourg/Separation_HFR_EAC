% 
%   programme masque
%       permet de retirer les points de la grille inutiles
%       PB 02/2002
%       Lucio Bellomo 12/06/2012
% 

function mask = adjust_mask(cartesian_grid,lonlat_xy,h)

mask = ones(size(cartesian_grid.x));

% Create an OK "psuedo" button
a = get(gca);
x_ok = a.XLim(2)-diff(a.XLim)/10;
y_ok = a.YLim(2)-diff(a.YLim)/10;
h_ok = text(x_ok,y_ok,'OK','FontSize',20,'BackGroundColor','y');

% Get the geographic boundaries of the plot
if lonlat_xy == 1
    x_max = cartesian_grid.lon(1,end);
    y_max = cartesian_grid.lat(end,1);
    [x_max, y_max] = m_ll2xy(x_max,y_max);
else
    x_max = cartesian_grid.x(1,end);
    y_max = cartesian_grid.y(end,1);
end

% Remove the grid points one after the other
for ii = 1 : (size(cartesian_grid.x,2)-1)*(size(cartesian_grid.x,1)-1);
    [xi,yi] = ginput(1);
    
    if sqrt((xi-x_ok)^2+(yi-y_ok)^2) < sqrt((xi-x_max)^2+(yi-y_max)^2)
        % the user clicked over OK
        delete(h_ok);
        delete(h);
        if lonlat_xy == 1
            h = m_plot(cartesian_grid.lon.*mask,cartesian_grid.lat.*mask,'.b');
        else
            h = plot(cartesian_grid.x.*mask,cartesian_grid.y.*mask,'.b');
        end
        return;
    else
        % the user clicked over a valid grid point
        if lonlat_xy == 1
            [xi, yi] = m_xy2ll(xi,yi);
            [~,ic] = find_nearest_point(cartesian_grid.lon(1,:),xi);
            [~,il] = find_nearest_point(cartesian_grid.lat(:,1),yi);
        else
            [~,ic] = find_nearest_point(cartesian_grid.x(1,:),xi);
            [~,il] = find_nearest_point(cartesian_grid.y(:,1),yi);
        end
        mask(il,ic) = NaN;
    end
    
    % Update the grid plot
    % - Remove the previous grid
    delete(h);
    % - Plot the new one
    if lonlat_xy == 1
        h = m_plot(cartesian_grid.lon.*mask,cartesian_grid.lat.*mask,'*r');
    else
        h = plot(cartesian_grid.x.*mask,cartesian_grid.y.*mask,'*r');
    end
end

