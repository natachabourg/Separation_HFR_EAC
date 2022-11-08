function [ VAR , nav ,  DATE ] = GLazur_reader( GLname , PARAM, ProfilPos )
% MARMAIN
% 2012/07/12
% To read a list of Glazur64 files
%
%   INPUT:  GLname: the list of file with full path created with
%                   GLazur_list
%           PARAM: the parameter to extract
%           time_origin: to define if the one of GLazur file is wrong (yes,
%           it is possible - ex: case of PHYOCE Run T24_PHYOCE_freeslip).
%           If it is not defined, we read the netcdf time_origin attribut.
%           format is "yyyy-mmm-dd HH:MM:SS" and mmm is letters (JAN, FEB
%           ...)
%           ProfilPos: ProfilPos.lon, ProfilPos.lat are position in lon/lat
%           of the profil to extract
%
%   OUTPUT: nav.lon: longitude
%           nav.lat: latitude
%           nav.depth: depth
%           VAR: variable value associated to PARAM with dimension x,y,z,t
%           DATE: date structure with radar time (DATE.radar), julian day since
%           time_origin (DATE.julian) and DATE.calendar with a more
%           classical format YYYY-MM-DD hh:mm:ss
%
% This function allows to load only one variable in the netcdf file.
% Run it for each variable you want to load.

disp(['loading GLazur64 - ' PARAM.name])

if strcmp(PARAM.name,'votemper') == 1 || strcmp(PARAM.name,'vosaline') ==1
    depth = 'deptht';
elseif strcmp(PARAM.name,'vozocrtx') == 1
    depth = 'depthu';
elseif strcmp(PARAM.name,'vomecrty') == 1
    depth = 'depthv';
else
    depth = 'deptht';
end


%%% number of index to consider for zoom
nbz=PARAM.zoom.z(2)-PARAM.zoom.z(1)+1;

if nargin == 2
    
    disp('Extract data in a cube')
    
    %%% number of index to consider for zoom
    nbx=PARAM.zoom.x(2)-PARAM.zoom.x(1)+1;
    nby=PARAM.zoom.y(2)-PARAM.zoom.y(1)+1;
    %nbz=PARAM.zoom.z(2)-PARAM.zoom.z(1)+1;
    
    %%% depth definition
    
    for tindex=1:size(GLname,1)
        
        disp(['tindex = ' num2str(tindex) '/' num2str(size(GLname,1))])
        
        if tindex == 1  %%% load VAR spatial dimensions
            
            vinfo=ncinfo(GLname(tindex,:),PARAM.name);
            
            N=size(vinfo.Dimensions,2);
            
            
        end
        
        %%% Load VAR
        
        %     tmp=double(ncread(GLname(tindex,:),PARAM.name));
        %
        %     if tindex == 1  %%% load VAR spatial dimensions
        %
        %         N = ndims(tmp);
        %
        %     end
        %
        %VAR(x,y,z,t)
        
        if N == 3   %%% 2D
            
            VAR(:,:,1,tindex)=double(ncread(GLname(tindex,:),PARAM.name,...
                [PARAM.zoom.x(1) PARAM.zoom.y(1) 1],[nbx nby 1]));
            
        elseif N == 4        %%% 3D
            
            VAR(:,:,:,tindex)=double(ncread(GLname(tindex,:),PARAM.name,...
                [PARAM.zoom.x(1) PARAM.zoom.y(1) PARAM.zoom.z(1) 1],[nbx nby nbz 1]));
            
        else
            
            error(['PROBLEM WITH ' PARAM.name ' DIMENSION' num2str(size(vinfo.Dimensions,2))])
            
        end
        
        %%% Load time_counter
        time_counter(tindex,1)=double(ncread(GLname(tindex,:),'time_counter'));
        
    end
    
    if myIsField(PARAM,'time_origin') == 0
        
        PARAM.time_origin=ncreadatt(GLname(1,:),'time_counter','time_origin')
        % else use the time_origin handly defined
    end
    
    % if nargin == 2
    %     %%% time origine used in the GLazur file
    %     time_origin=ncreadatt(GLname(1,:),'time_counter','time_origin');
    %
    %     % else use the time_origin handly defined
    %
    % end
    %
    if nargout ~= 1
        
        %%% nav_lon
        %     nav.lon=double(ncread(GLname(1,:),'nav_lon'));
        %     nav.lat=double(ncread(GLname(1,:),'nav_lat'));
        nav.lon=double(ncread(GLname(1,:),'nav_lon',...
            [PARAM.zoom.x(1) PARAM.zoom.y(1)],[nbx nby]));
        nav.lat=double(ncread(GLname(1,:),'nav_lat',...
            [PARAM.zoom.x(1) PARAM.zoom.y(1)],[nbx nby]));
        
        if N == 4
            nav.depth=double(ncread(GLname(1,:),depth,...
                [PARAM.zoom.z(1)],[nbz]));
        end
        
        %%% time
        
        DATE=second2DATE(time_counter,PARAM.time_origin);
        
    end
    
elseif nargin == 3
    
    disp('Extract data along a profil')
    
    %%% load the whole grid
    nav.lon=double(ncread(GLname(1,:),'nav_lon'));
    nav.lat=double(ncread(GLname(1,:),'nav_lat'));
    
    indice_lon=dsearchn(nav.lon(:,1), ProfilPos.lon);
    indice_lat=dsearchn(nav.lat(1,:)',ProfilPos.lat);
    disp(['at ' num2str(ProfilPos.lon) '(' num2str(indice_lon) ')/' ...
        num2str(ProfilPos.lat) '(' num2str(indice_lat) ')'])
    
    for tindex=1:size(GLname,1)
        
        disp(['tindex = ' num2str(tindex) '/' num2str(size(GLname,1))])
        
        if tindex == 1  %%% load VAR spatial dimensions
            
            vinfo=ncinfo(GLname(tindex,:),PARAM.name);
            
            N=size(vinfo.Dimensions,2);
            
            
        end
        
        
        if N == 3   %%% 2D
            
            VAR(:,:,1,tindex)=double(ncread(GLname(tindex,:),PARAM.name,...
                [indice_lon indice_lat 1],[1 1 1]));
            
        elseif N == 4        %%% 3D
            
            VAR(:,:,:,tindex)=double(ncread(GLname(tindex,:),PARAM.name,...
                [indice_lon indice_lat PARAM.zoom.z(1) 1],[1 1 nbz 1]));
            
        else
            
            error(['PROBLEM WITH ' PARAM.name ' DIMENSION' num2str(size(vinfo.Dimensions,2))])
            
        end
        
        %%% Load time_counter
        time_counter(tindex,1)=double(ncread(GLname(tindex,:),'time_counter'));
        
    end
    
    if myIsField(PARAM,'time_origin') == 0
        
        PARAM.time_origin=ncreadatt(GLname(1,:),'time_counter','time_origin');
        % else use the time_origin handly defined
    end
    
    if nargout ~= 1
        
        %%% nav_lon
        %     nav.lon=double(ncread(GLname(1,:),'nav_lon'));
        %     nav.lat=double(ncread(GLname(1,:),'nav_lat'));
        nav.lon=double(ncread(GLname(1,:),'nav_lon',...
            [indice_lon indice_lat],[1 1]));
        nav.lat=double(ncread(GLname(1,:),'nav_lat',...
            [indice_lon indice_lat],[1 1]));
        
        if N == 4
            nav.depth=double(ncread(GLname(1,:),depth,...
                [PARAM.zoom.z(1)],[nbz]));
        end
        
        %%% time
        
        DATE=second2DATE(time_counter,PARAM.time_origin);
        
    end
    
    
    
    
end


