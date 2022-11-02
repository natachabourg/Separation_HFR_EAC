function [ VAR , nav ,  DATE ] = METEO_MODEL_reader( GLname , PARAM )
% MARMAIN 
% 2012/07/12
% To read a list of METEO FRANCE Model.
%
%   INPUT:  GLname: the list of file with full path created with
%                   GLazur_list
%           PARAM: the parameter to extract
%           time_origin: to define if the one of GLazur file is wrong. 
%           If it is not defined, we read the netcdf time_origin attribut.
%           format is "yyyy-mm-dd HH:MM:SS".
%           
%   OUTPUT: nav.lon: longitude
%           nav.lat: latitude
%           VAR: variable value associated to PARAM with dimension x,y,z,t
%           DATE: date structure with radar time (DATE.radar), julian day since
%           time_origin (DATE.julian) and DATE.calendar with a more
%           classical format YYYY-MM-DD hh:mm:ss
%
% This function allows to load only one variable in the netcdf file.
% Run it for each variable you want to load. 

%disp(['loading METEO FRANCE - ' PARAM.CONF '  ' PARAM.name])
disp(['loading METEO FRANCE - ' PARAM.name])
%%% number of index to consider for zoom
nbx=PARAM.zoom.x(2)-PARAM.zoom.x(1)+1;
nby=PARAM.zoom.y(2)-PARAM.zoom.y(1)+1;


%%% Load VAR
VAR=double(ncread(GLname,PARAM.name,...
    [PARAM.zoom.x(1) PARAM.zoom.y(1) 1],[nbx nby inf]));

%%% Load time_counter

time_counter=double(ncread(GLname,'time'));


if myIsField(PARAM,'time_origin') == 0
    
    tmp=ncreadatt(GLname,'time','units');
    PARAM.time_origin=tmp(end-19:end);
    % else use the time_origin handly defined 
end
  
    
if nargout ~= 1
    
    
    nav.lon=double(ncread(GLname,'longitude',...
        [PARAM.zoom.x(1)],[nbx]));
    nav.lat=double(ncread(GLname,'latitude',...
        [PARAM.zoom.y(1)],[nby]));
    

    %%% time
    
    DATE=hour2DATE(time_counter,PARAM.time_origin);
    
end

end

