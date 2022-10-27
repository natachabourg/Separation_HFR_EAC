%%  RADmask
function [vr_out] = RADmask(vr_in, lon, lat, range, site)

% Remove gridpoints outside a range

% INPUT %
% lon/lat = the lon/lat vector from the radial data
% range = range threshold for site (in km)
% site = enter site 3-character name as a string; e.g. 'RRK' for Red Rock

% OUTPUT %
% index = vector of indices where gridpoints exceed range threshold

% Written by Matt A. @ UNSW
% 2016

if strcmp(site,'RRK')
x = 153.2312;
y = -29.9839;
sx = x*ones(size(lon));
sy = y*ones(size(lat));
[east,north] = lonlat2km(sx,sy,lon,lat);
dist = sqrt(east.^2 + north.^2);
%figure;contourf(LON,LAT,dist)

elseif strcmp(site,'NNB')
x = 153.0111;
y = -30.624;
sx = x*ones(size(lon));
sy = y*ones(size(lat));
[east,north] = lonlat2km(sx,sy,lon,lat);
dist = sqrt(east.^2 + north.^2);
% figure;contourf(LON,LAT,dist)


elseif strcmp(site,'RHED')
x = 151.7268;
y = -33.0109167;
sx = x*ones(size(lon));
sy = y*ones(size(lat));
[east,north] = lonlat2km(sx,sy,lon,lat);
dist = sqrt(east.^2 + north.^2);
% figure;
% pcolor(lon,lat,dist);
% colorbar


elseif strcmp(site,'SEAL')
x = 152.5390833;
y = -32.4414667;
sx = x*ones(size(lon));
sy = y*ones(size(lat));
[east,north] = lonlat2km(sx,sy,lon,lat);
dist = sqrt(east.^2 + north.^2);


else display('Please enter either RRK, NNB, RHED or SEAL')
    return
end

mask = double(dist<range);
mask(mask==0)=NaN;

vr_out = vr_in.*mask;
end