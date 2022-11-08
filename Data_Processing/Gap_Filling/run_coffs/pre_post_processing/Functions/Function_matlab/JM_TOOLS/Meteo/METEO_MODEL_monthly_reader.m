function [ VAR , nav ,  DATE ] = METEO_MODEL_monthly_reader( GLname , PARAM, time_origin )
% MARMAIN 
% 2012/07/12
% To read a list of METEO FRANCE Model.
%
%   INPUT:  GLname: the list of file with full path created with
%                   METEO_MODEL_monthly_reader
%           PARAM: the parameter to extract
%           time_origin: all input files have their time origin redefine to
%           that value
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

if nargin == 2
    time_origin='2010-01-01 00:00:00';
end


%%% number of index to consider for zoom
nbx=PARAM.zoom.x(2)-PARAM.zoom.x(1)+1;
nby=PARAM.zoom.y(2)-PARAM.zoom.y(1)+1;

if nargout ~= 1
      
    nav.lon=double(ncread(GLname(1,:),'longitude',...
        [PARAM.zoom.x(1)],[nbx]));
    nav.lat=double(ncread(GLname(1,:),'latitude',...
        [PARAM.zoom.y(1)],[nby]));
    
end



for i= 1:size(GLname,1)
    
    disp(['loading METEO FRANCE - ' PARAM.name ' - ' GLname(i,:)])
    
    
    %%% Load VAR
    clear VARtmp
    VARtmp=double(ncread(GLname(i,:),PARAM.name,...
        [PARAM.zoom.x(1) PARAM.zoom.y(1) 1],[nbx nby inf]));
    
    if exist('VAR','var') == 0
        VAR = VARtmp;
    else
        VAR = cat(3,VAR,VARtmp);
    end
    
    if nargout ~= 1
        
        clear time_counter DATEtmp1 DATEtmp2 PARAM.time_origin
        %%% Load time_counter
        time_counter=double(ncread(GLname(i,:),'time'));
        
        %if myIsField(PARAM,'time_origin') == 0
            
            tmp=ncreadatt(GLname(i,:),'time','units');
            PARAM.time_origin=tmp(end-19:end);
            % else use the time_origin handly defined
       % end
        
        %%% time
        
        DATEtmp1=hour2DATE(time_counter,PARAM.time_origin);
        
        DATEtmp2=DATE_since_time_origin(DATEtmp1.julian,PARAM.time_origin,time_origin);
        
        if exist('DATE','var') == 0
            DATE = DATEtmp2;
        else
            DATE.julian = cat(1,DATE.julian,DATEtmp2.julian);
            DATE.calendar = cat(1,DATE.calendar,DATEtmp2.calendar);
            DATE.radar = cat(1,DATE.radar,DATEtmp2.radar);
        end
        
        clear PARAM.time_origin
    end
    
    
end

end

