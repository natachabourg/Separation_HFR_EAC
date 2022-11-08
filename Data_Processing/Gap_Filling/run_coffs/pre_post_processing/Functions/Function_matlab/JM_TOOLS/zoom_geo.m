function [ PARAM_zoom ] = zoom_geo( PARAM,NAV,ZOOM )
%%% MARMAIN
%%% 2012/10/04
%%% 
%%% geographical zoom 
%%% 
%%% INPUT:  -PARAM: parameter to zoom ( dim= x,y(,z,t) )
%%%         -NAV (NAV.lon, NAV.lat): grid where PARAM is defined (dim=x,y)
%%%         -ZOOM (ZOOM.lon, ZOOM.lat): geographical limit of zoom
%%%
%%% OUTPUT: -PARAM_zoom: parameter zoomed with the same dimension as PARAM
%%%                     (dim= x,y(,z,t) ) where value not in the range define 
%%%			by ZOOM are set to NaN.

zoom.condition1=NaN.*NAV.lon;
zoom.condition2=NaN.*NAV.lon;

for i_lat = 1 : size(NAV.lon,2)
    
    zoom.condition1(  NAV.lon(:,i_lat) >= ZOOM.lon(1) & ...
        NAV.lon(:,i_lat) <= ZOOM.lon(2),i_lat) =1;
      
end
for i_lon = 1 : size(NAV.lon,1)
    
    zoom.condition2(i_lon,  NAV.lat(i_lon,:) >= ZOOM.lat(1) & ...
        NAV.lat(i_lon,:) <= ZOOM.lat(2)) =1;
    
end
zoom.condition=zoom.condition1 + zoom.condition2;
zoom.condition(zoom.condition == 2) = 1;


NDIMS=ndims(PARAM);

if NDIMS == 4
    for i_z = 1:size(PARAM,3)
        for i_t = 1:size(PARAM,4)
            PARAM_zoom(:,:,i_z,i_t)=squeeze(PARAM(:,:,i_z,i_t)).*zoom.condition;
        end
    end
    
elseif NDIMS == 3
    for i_t = 1:size(PARAM,3)
        PARAM_zoom(:,:,i_t)=squeeze(PARAM(:,:,i_t)).*zoom.condition;
    end
elseif NDIMS == 2
    
    PARAM_zoom(:,:)=squeeze(PARAM(:,:)).*zoom.condition;
end

end

