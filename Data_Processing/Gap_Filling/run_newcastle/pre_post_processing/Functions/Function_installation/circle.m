
% 
% Computes the coordinates of an arc of circle
% 
% INPUTS:
% - lonc,latc: lon/lat of the center of the circle
% - xc,yc:     x/y of the center of the circle
% - alpha:     reference direction angle (deg)
% - rad:       radius of the circle (km)
% - dteta:     half of the valid angle (deg)
% - plot_lonlat_xy: output in
%       - 1: lon/lat coordiantes
%       - 2: x/y coordinates (km)
% 
% OUTPUTS:
% - x,y:     x/y of the points of the circle
% - lon,lat: lon/lat of the points of the circle
% 

function [x, y, lon, lat] = circle(lonc,latc,xc,yc,alpha,rad,dteta)

% Build the circle in cartesian coordinates
teta_min = alpha - dteta;
teta_max = alpha + dteta;
teta = [teta_min:1:teta_max];
xt = rad*cos(teta*pi/180);
yt = rad*sin(teta*pi/180);

% lon/lat plot: transform the circle into lon/lat
[lon, lat] = xy2lonlat(xt,yt,lonc,latc,2);

% x/y plot: add the center coordinates
x = xc + xt;
y = yc + yt;
