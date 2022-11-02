function [ VAR , nav ,  DATE ] = MERCATOR_reader( GLname , PARAM, ProfilPos )
% MARMAIN
% 2012/07/12
% To read a list of Glazur64 files
%
%   INPUT:  GLname: the list of file with full path created with
%                   GLazur_list
%                   It's a structure GLname.|ANALYSE.
%                                           |FORECAST.
%                                                    |short
%                                                    |long
%
%           PARAM.name: the parameter to extract
%           PARAM.type: ANALYSE (default) or FORECAST
%
%           time_origin: to define if the one of GLazur file is wrong (yes,
%           it is possible - ex: case of PHYOCE Run T24_PHYOCE_freeslip).
%           If it is not defined, we read the netcdf time_origin attribut.
%           format is "yyyy-mmm-dd HH:MM:SS" and mmm is letters (JAN, FEB
%           ...)
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

%%%########################################################################

%%% INITIALISATION

if strcmp(PARAM.CONF,'PSY2V4R1') == 1 || strcmp(PARAM.CONF,'PSY2V4R2') == 1 || strcmp(PARAM.CONF,'PSY2V4R4') == 1
    depth = 'deptht';
end
if strcmp(PARAM.CONF,'PSY2V3R1') == 1 && strcmp(PARAM.name,'vozocrtx') == 1
    depth = 'depthu';
end
if strcmp(PARAM.CONF,'PSY2V3R1') == 1 && strcmp(PARAM.name,'vomecrty') == 1
    depth = 'depthv';
end
if strcmp(PARAM.CONF,'PSY2V3R1') == 1 && strcmp(PARAM.name,'vomecrty') == 0 ...
        && strcmp(PARAM.name,'vozocrtx') == 0
    depth = 'deptht';
end


if myIsField(PARAM,'type') == 0
    
    %%% default case : type = 'ANALYSE'
    PARAM.type='ANALYSE';
    
elseif isempty(PARAM.type) == 1
    
    %%% default case : type = 'ANALYSE'
    PARAM.type='ANALYSE';
    
end

stamp1= 0;

%%% number of index to consider for zoom
nbz=PARAM.zoom.z(2)-PARAM.zoom.z(1)+1;


%% LOADING ANALYSE

if strcmp(PARAM.type,'ANALYSE') == 1
    
    %%% what you are loading:
    disp(['Reading  ' PARAM.name '-' PARAM.type '-' PARAM.CONF])
    
    if nargin == 2
        
        disp('Extract data in a cube')
        
        %%% number of index to consider for zoom
        nbx=PARAM.zoom.x(2)-PARAM.zoom.x(1)+1;
        nby=PARAM.zoom.y(2)-PARAM.zoom.y(1)+1;
        %nbz=PARAM.zoom.z(2)-PARAM.zoom.z(1)+1;
    else
        disp('Extract data along a profil')
        nbx=1;
        nby=1;
    end
    
    for tindex=1:size(GLname.ANALYSE,1) %%% loop over time
        
        disp(['tindex = ' num2str(tindex) '/' num2str(size(GLname.ANALYSE,1))])
        
        %%% gunzip the file and change the name in GLname list
        if strcmp(GLname.ANALYSE(tindex,1).long(1,end-1:end),'gz') == 1
            disp(['gunzip' GLname.ANALYSE(tindex,:).long])
            eval(['! gzip -d ' GLname.ANALYSE(tindex,:).long])
            GLname.ANALYSE(tindex,1).long=...
                GLname.ANALYSE(tindex,1).long(1,1:end-3);
            
        end
        
        if nargin == 3 && stamp1 == 0
            stamp1 = 1;
            %%% load the whole grid
            nav.lon=double(ncread(GLname.ANALYSE(1,:).long,'nav_lon'));
            nav.lat=double(ncread(GLname.ANALYSE(1,:).long,'nav_lat'));
            
            [ Pos] = FindNearestPoint( nav, ProfilPos );
            
%             indice_lon=dsearchn(nav.lon(:,1), ProfilPos.lon);
%             indice_lat=dsearchn(nav.lat(1,:)',ProfilPos.lat);
            indice_lon=Pos.ilon;
            indice_lat=Pos.ilat;
            
            disp(['at ' num2str(ProfilPos.lon) '(' num2str(indice_lon) ')/' ...
                num2str(ProfilPos.lat) '(' num2str(indice_lat) ')'])
            
        end
        
        
        %u_obs=double(ncread(ncfile,'u',[1,1,1,t_obs(1)],[Inf Inf Inf nb_t_obs]));
        %%% Load VAR
        if nargin == 2
            if strcmp(PARAM.name,'sossheig') == 1
                tmp=double(ncread(GLname.ANALYSE(tindex,:).long,PARAM.name,...
                    [PARAM.zoom.x(1) PARAM.zoom.y(1) 1],[nbx nby 1]));
            else
                tmp=double(ncread(GLname.ANALYSE(tindex,:).long,PARAM.name,...
                    [PARAM.zoom.x(1) PARAM.zoom.y(1) PARAM.zoom.z(1) 1],[nbx nby nbz 1]));
                
            end
        elseif nargin == 3
            
            if strcmp(PARAM.name,'sossheig') == 1
                tmp=double(ncread(GLname.ANALYSE(tindex,:).long,PARAM.name,...
                    [indice_lon indice_lat 1],[nbx nby 1]));
            else
                tmp=double(ncread(GLname.ANALYSE(tindex,:).long,PARAM.name,...
                    [indice_lon indice_lat PARAM.zoom.z(1) 1],[nbx nby nbz 1]));
                
            end
            
        end
        
        if tindex == 1  %%% load VAR spatial dimensions
            
            N = ndims(tmp);
            
        end
        
        %VAR(x,y,z,t)
        
        if N == 2   %%% 2D
            
            VAR(:,:,1,tindex)=tmp;
            
        else        %%% 3D
            
            VAR(:,:,:,tindex)=tmp;
            
        end
        
        %%% Load time_counter
        time_counter(tindex,1)=...
            double(ncread(GLname.ANALYSE(tindex,:).long,'time_counter'));
        
    end
    
    
    
    
%      if nargin == 2
%          %%% time origine used in the GLazur file
        time_origin=...
            ncreadatt(GLname.ANALYSE(1,:).long,'time_counter','time_origin');
    
        % else use the time_origin handly defined
    
%     end
    
    if nargout ~= 1
        
        if nargin == 2
            %%% nav
            nav.lon=double(ncread(GLname.ANALYSE(1,:).long,'nav_lon',...
                [PARAM.zoom.x(1) PARAM.zoom.y(1)],[nbx nby]));
            nav.lat=double(ncread(GLname.ANALYSE(1,:).long,'nav_lat',...
                [PARAM.zoom.x(1) PARAM.zoom.y(1)],[nbx nby]));
            nav.depth=double(ncread(GLname.ANALYSE(1,:).long,depth,...
                [PARAM.zoom.z(1)],[nbz]));
            
        elseif  nargin == 3
            
            nav.lon=double(ncread(GLname.ANALYSE(1,:).long,'nav_lon',...
                [indice_lon indice_lat],[nbx nby]));
            nav.lat=double(ncread(GLname.ANALYSE(1,:).long,'nav_lat',...
                [indice_lon indice_lat],[nbx nby]));
            nav.depth=double(ncread(GLname.ANALYSE(1,:).long,depth,...
                [PARAM.zoom.z(1)],[nbz]));
            
        end
        
        %%% time
        DATE=second2DATE(time_counter,time_origin);
    end
 
end


%% LOADING FORECAST

if strcmp(PARAM.type,'FORECAST') == 1
    
    %%% what you are loading:
    disp(['Reading  ' PARAM.name '-' PARAM.type '-' PARAM.CONF])
    
    if nargin == 2
        
        disp('Extract data in a cube')
        
        %%% number of index to consider for zoom
        nbx=PARAM.zoom.x(2)-PARAM.zoom.x(1)+1;
        nby=PARAM.zoom.y(2)-PARAM.zoom.y(1)+1;
        %nbz=PARAM.zoom.z(2)-PARAM.zoom.z(1)+1;
    else
        disp('Extract data along a profil')
        nbx=1;
        nby=1;
    end
    
    for tindex=1:size(GLname.FORECAST,1) %%% loop over time
        
        %%% gunzip the file and change the name in GLname list
        if strcmp(GLname.FORECAST(tindex,1).long(1,end-1:end),'gz') == 1
            disp(['gunzip' GLname.FORECAST(tindex,:).long])
            eval(['! gzip -d ' GLname.FORECAST(tindex,:).long])
            GLname.FORECAST(tindex,1).long=...
                GLname.FORECAST(tindex,1).long(1,1:end-3);
            
        end
        
        if nargin == 3 && stamp1 == 1
            
            %%% load the whole grid
            nav.lon=double(ncread(GLname.FORECAST(1,:).long,'nav_lon'));
            nav.lat=double(ncread(GLname.FORECAST(1,:).long,'nav_lat'));
            
            [ Pos] = FindNearestPoint( nav, ProfilPos );
            
%             indice_lon=dsearchn(nav.lon(:,1), ProfilPos.lon);
%             indice_lat=dsearchn(nav.lat(1,:)',ProfilPos.lat);
            indice_lon=Pos.ilon;
            indice_lat=Pos.ilat;
            
            
            disp(['at ' num2str(ProfilPos.lon) '(' num2str(indice_lon) ')/' ...
                num2str(ProfilPos.lat) '(' num2str(indice_lat) ')'])
            
        end
        
        
        %u_obs=double(ncread(ncfile,'u',[1,1,1,t_obs(1)],[Inf Inf Inf nb_t_obs]));
        %%% Load VAR
        if nargin == 2
            if strcmp(PARAM.name,'sossheig') == 1
                tmp=double(ncread(GLname.FORECAST(tindex,:).long,PARAM.name,...
                    [PARAM.zoom.x(1) PARAM.zoom.y(1) 1],[nbx nby 1]));
            else
                tmp=double(ncread(GLname.FORECAST(tindex,:).long,PARAM.name,...
                    [PARAM.zoom.x(1) PARAM.zoom.y(1) PARAM.zoom.z(1) 1],[nbx nby nbz 1]));
                
            end
        elseif nargin == 3
            
            if strcmp(PARAM.name,'sossheig') == 1
                tmp=double(ncread(GLname.FORECAST(tindex,:).long,PARAM.name,...
                    [indice_lon indice_lat 1],[nbx nby 1]));
            else
                tmp=double(ncread(GLname.FORECAST(tindex,:).long,PARAM.name,...
                    [indice_lon indice_lat PARAM.zoom.z(1) 1],[nbx nby nbz 1]));
                
            end
            
        end
        
        if tindex == 1  %%% load VAR spatial dimensions
            
            N = ndims(tmp);
            
        end
        
        %VAR(x,y,z,t)
        
        if N == 2   %%% 2D
            
            VAR(:,:,1,tindex)=tmp;
            
        else        %%% 3D
            
            VAR(:,:,:,tindex)=tmp;
            
        end
        
        %%% Load time_counter
        time_counter(tindex,1)=...
            double(ncread(GLname.FORECAST(tindex,:).long,'time_counter'));
        
    end
    
    
    
    
    %  if nargin == 2
    %      %%% time origine used in the GLazur file
    %     time_origin=...
    %         ncreadatt(GLname.ANALYSE(1,:).long,'time_counter','time_origin');
    %
    %     % else use the time_origin handly defined
    %
    % end
    
    if nargout ~= 1
        
        if nargin == 2
            %%% nav
            nav.lon=double(ncread(GLname.FORECAST(1,:).long,'nav_lon',...
                [PARAM.zoom.x(1) PARAM.zoom.y(1)],[nbx nby]));
            nav.lat=double(ncread(GLname.FORECAST(1,:).long,'nav_lat',...
                [PARAM.zoom.x(1) PARAM.zoom.y(1)],[nbx nby]));
            nav.depth=double(ncread(GLname.FORECAST(1,:).long,depth,...
                [PARAM.zoom.z(1)],[nbz]));
            
        elseif  nargin == 3
            
            nav.lon=double(ncread(GLname.FORECAST(1,:).long,'nav_lon',...
                [indice_lon indice_lat],[nbx nby]));
            nav.lat=double(ncread(GLname.FORECAST(1,:).long,'nav_lat',...
                [indice_lon indice_lat],[nbx nby]));
            nav.depth=double(ncread(GLname.FORECAST(1,:).long,depth,...
                [PARAM.zoom.z(1)],[nbz]));
            
        end
        
        %%% time
        DATE=second2DATE(time_counter,time_origin);
    end
    
    
    
    
    
end



% 
% 
% %%% LOADING FORECAST
% 
% if strcmp(PARAM.type,'FORECAST') == 1
%     
%     %%% what you are loading:
%     disp(['loading  ' PARAM.name '-' PARAM.type '-' PARAM.CONF])
%     
%     for tindex=1:size(GLname.FORECAST,1) %%% loop over time
%         
%         %%% gunzip the file and change the name in GLname list
%         if strcmp(GLname.FORECAST(tindex,1).long(1,end-1:end),'gz') == 1
%             disp(['gunzip' GLname.FORECAST(tindex,:).long])
%             eval(['! gzip -d ' GLname.FORECAST(tindex,:).long])
%             GLname.FORECAST(tindex,1).long=...
%                 GLname.FORECAST(tindex,1).long(1,1:end-3);
%             
%         end
%         
%         %%% number of index to consider for zoom
%         nbx=PARAM.zoom.x(2)-PARAM.zoom.x(1)+1;
%         nby=PARAM.zoom.y(2)-PARAM.zoom.y(1)+1;
%         nbz=PARAM.zoom.z(2)-PARAM.zoom.z(1)+1;
%         
%         %u_obs=double(ncread(ncfile,'u',[1,1,1,t_obs(1)],[Inf Inf Inf nb_t_obs]));
%         %%% Load VAR
%         
%         tmp=double(ncread(GLname.FORECAST(tindex,:).long,PARAM.name,...
%             [PARAM.zoom.x(1) PARAM.zoom.y(1) PARAM.zoom.z(1) 1],[nbx nby nbz 1]));
%         
%         if tindex == 1  %%% load VAR spatial dimensions
%             
%             N = ndims(tmp);
%             
%         end
%         
%         %VAR(x,y,z,t)
%         
%         if N == 2   %%% 2D
%             
%             VAR(:,:,1,tindex)=tmp;
%             
%         else        %%% 3D
%             
%             VAR(:,:,:,tindex)=tmp;
%             
%         end
%         
%         %%% Load time_counter
%         time_counter(tindex,1)=...
%             double(ncread(GLname.FORECAST(tindex,:).long,'time_counter'));
%         
%     end
%     
%     if nargin == 2
%         %%% time origine used in the GLazur file
%         time_origin=...
%             ncreadatt(GLname.FORECAST(1,:).long,'time_counter','time_origin');
%         
%         % else use the time_origin handly defined
%         
%     end
%     
%     if nargout ~= 1
%         
%         
%         %%% nav
%         nav.lon=double(ncread(GLname.FORECAST(1,:).long,'nav_lon',...
%             [PARAM.zoom.x(1) PARAM.zoom.y(1)],[nbx nby]));
%         nav.lat=double(ncread(GLname.FORECAST(1,:).long,'nav_lat',...
%             [PARAM.zoom.x(1) PARAM.zoom.y(1)],[nbx nby]));
%         nav.depth=double(ncread(GLname.FORECAST(1,:).long,depth,...
%             [PARAM.zoom.z(1)],[nbz]));
%         
%         
%         %%% time
%         DATE=second2DATE(time_counter,time_origin);
%         
%     end
%     
% end


end

