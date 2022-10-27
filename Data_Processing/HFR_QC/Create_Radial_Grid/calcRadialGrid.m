function [dist,angle,xr,yr,lonr,latr] = calcRadialGrid(lonOrg,latOrg,bear,dAng,range,dRange)

%calculate radar radial grids for each CODAR site
%
% Inputs:
%     lonOrg - Antenna center longitude [degN]
%     latOrg - Antenna center latitude [degE]
%     bear - Antenna bearing [deg]
%     dAng - Antenna angular resolution [deg]
%     range - Antenna maximum radial range [km]
%     dRange - Antenna radial resolution
% 
% Outputs:
%     dist - grid coordinates along the radial dimension [km]
%     angle - grid coordinates along the angular dimension [deg]
%     xr,yr - carthesian coordinates of the grid
%     lonr,latr - spherical coordinates of the grid
%
% itimu Apr 2013

    deg2rad = pi/180;
    dist1D = dRange:dRange:range;
    % CODAR carthesian grid is wrt to degrees from North
    % so the bearing must be transformed in 90-angle
    % and 360 must be added if the result is negative
    bearEast = 90 - bear;
    if(bearEast < 0)
        bearEast = bearEast + 360;
    end
    angle1D = mod(bearEast,dAng):dAng:359;
    [dist,angle] = meshgrid(dist1D,angle1D);
    xr = dist.*cos(angle*deg2rad);
    yr = dist.*sin(angle*deg2rad); 
    [lonr,latr] = km2lonlat(lonOrg,latOrg,xr,yr);

return