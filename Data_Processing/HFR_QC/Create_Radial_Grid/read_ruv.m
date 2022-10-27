% read radar RUV radial files 
% from Carlo to create a MAT file
% containing all data
%
% based on scripts by Lucio Bellomo
% itimu Apr 2013

clear all; close all;
addpath /home/molcard/Function_matlab/
addpath /home/molcard/RADAR_SP/Function_import/

cm2meters = 0.01;
deg2rad = pi/180;fillval = -9.9999e+32;

%% define matlab output file
outpath = '/home/molcard/RADAR_SP/Anne/';
matOutFile = [outpath,'Radials_RUV_Carlo.mat'];
inpath = outpath;

%% switches
PLOTRAW = 0 ; %to plot raw data

%% specs Sites/Antennas and common parts for reading RUV files
prefix{1} = [inpath,'VIAR/RDLm_VIAR_']; %RDli menas not calibrated
prefix{2} = [inpath,'PCOR/RDLm_PCOR_']; %RDli means not calibrated
prefix{3} = [inpath,'TINO/RDLm_TINO_']; %RDLm means CALIBRATED

Nsite = length(prefix);

SiteSource = struct('NameAn',{{'VIAR','PCOR','TINO'}},...
                    'lonOrg',[10.2373 9.6593 9.8492167],...
                    'latOrg',[43.8579 44.1435167 44.0263667],...
                    'bearin',[275.0 227.0 282.0],... %Antenna bearing [deg]
                    'Dangle',[5.0 5.0 5.0],... %angle resolution [deg]
                    'Drange',[0.9945 0.9945 0.9945],... %range resol. [km]
                    'Mrange',[28. 44. 45.],... %max range [km]
                    'colAnt',{{'b','r','g'}} );
                
NnoUseLine1 = 6;                
NnoUseLine3 = 4;
posfix = '.ruv';
STA=SiteSource.NameAn;

%% define time limits
inidate = datenum(2019,04,01,00,00,00);
enddate = datenum(2019,06,30,23,00,00);
deltaT = 1/24 ; %one hour
time = inidate:deltaT:enddate;
NT = length(time);


%% calculates grids for each site 
for iSite = 1 : 3
    bearing = SiteSource.bearin(iSite);
    deltaAng{iSite} = SiteSource.Dangle(iSite);
    maxRange = SiteSource.Mrange(iSite);
    deltaRange = SiteSource.Drange(iSite);
    lonOrg = SiteSource.lonOrg(iSite);
    latOrg = SiteSource.latOrg(iSite);
    [dist{iSite},angle{iSite},xr{iSite},yr{iSite},lonr{iSite},latr{iSite}] = calcRadialGrid(lonOrg,latOrg,bearing,deltaAng{iSite},maxRange,deltaRange);
    
    %% initialize velocity fields 
    [Nangl,Ndist] =  size(dist{iSite});
    vr{iSite} = NaN*ones(Nangl,Ndist,NT);    
end
pause
%% initialize timeStamp
timeStamp = NaN*ones(NT,1);

if(PLOTRAW)
    figure(1)
end

for ii = 1:1%NT
    
    thisTime = time(ii);
    yyyy = datestr(thisTime,10);
    mm = datestr(thisTime,5);
    dd = datestr(thisTime,7);
    hhmnss = datestr(thisTime,13);
    hh = hhmnss(1:2);
    mn = hhmnss(4:5);

    for iSite = 1:3
                   
        ruvFile = [prefix{iSite},yyyy,'_',mm,'_',dd,'_',hh,mn,posfix];   
     
        if(~exist(ruvFile,'file'))
            disp(' ');
            disp(['NOTE : ',ruvFile,' does not exist!']);               
        else
            disp(' ');
            disp(['Reading file : ',ruvFile]); 
            fid = fopen(ruvFile);                            
            % skip useless lines at the beginning of the file
            for iline = 1:NnoUseLine1
                blank = fgetl(fid);
            end
            % gets TimeStamp and check it is consistent with thisTime
            line = fgetl(fid);
            [~, tmp] = strtok(line,':');
            tmp = tmp(2:end);
            tmp(isspace(tmp)) = [];         % remove all white spaces
            timeSt = [str2double(tmp(1:4)),   ...    % year
                      str2double(tmp(5:6)),   ...    % month
                      str2double(tmp(7:8)),   ...    % day
                      str2double(tmp(9:10)),  ...    % hour
                      str2double(tmp(11:12)), ...    % minute
                      str2double(tmp(13:14))];       % second
            timeStamp(ii) = datenum(timeSt); % days since 01-Jan-0000 00:00:00
            
            %use single for comparison not to have precision issues
            if(single(timeStamp) ~= single(thisTime)) 
                disp(' ');
                disp(['timeStamp: ',datestr(timeStamp,0)]);
                disp(['thisTime:  ',datestr(thisTime,0)]);
                error(['ERROR : timeStamp not consistent with thisTime']);               
            end
            
            % gets TimeCoverage
            line = fgetl(fid);
            [~, tmp] = strtok(line,':');
            tmp = tmp(2:end);
            [tmp, ~] = strtok(tmp,'.');
            tmp(isspace(tmp)) = [];         % remove all white spaces
            timeCoverage = str2double(tmp); % minutes
            
            % gets Origin (antenna coordinates)
            % note that CODAR is by definition monostatic
            % (emission antenna coincides with receiving antenna). 
            % Hence, lon_tx=lon_rx and lat_tx=lon_rx
            line = fgetl(fid);
            [~, tmp] = strtok(line,':');
            tmp = tmp(2:end);
            tmp = strtrim(tmp);             % remove leading white spaces
            ind = strfind(tmp,' ');
            lat_tx = str2double(tmp(1:ind(1)-1));
            lat_rx = lat_tx;
            tmp = strtrim(tmp(ind(1):end));
            lon_tx = tmp(1:end);
            lon_rx = lon_tx;
            
            % skip some other useless lines in the middle of the file
            % note that if antenna is calibrated there is one line less
            NnoUseLine2 = 42;
            if(iSite == 3)
                NnoUseLine2 = NnoUseLine2 - 1;
            end
            for iline = 1:NnoUseLine2
                blank = fgetl(fid);
            end
            
            % reads the number of data (rows) in each file
            dummy = textscan(fid,'%s%d',1);
            NdataLines = dummy{2}(:)
            clear dummy
            % skip other useless lines
            for iline = 1:NnoUseLine3
                blank = fgetl(fid);
            end               
            % reads data from one line, NdataLines times
            Data = textscan(fid,'%f%f%f%f%d%f%f%f%f%d%d%f%f%f%f%f%f%d',NdataLines);
            % close file
            fclose(fid);
            
            % gets radial velocity in the 16th column of data
            vel = Data{16}(:);
                   
            % gets radial grid index as spectral
            % range cell in the last column of data
            RadPos = Data{18}(:);
            
            % gets angular grid index using bearing angle in the 15th
            % column of data and considering that CODAR angles are degrees 
            % from North so they must be transformed in 90-angle
            AngEast = 90-Data{15}(:);
            AngEast(AngEast<0) = AngEast(AngEast<0) + 360;
            AngPos = (AngEast-angle{iSite}(1))/deltaAng{iSite} + 1;
        
            % insert data in m/sec and in the correct positions
            for idata = 1 : NdataLines
                vr{iSite}( AngPos(idata),RadPos(idata),ii ) = vel(idata)*cm2meters;
            end

            
        end
           
   end %iSite   
     
   if (PLOTRAW)
        t_str = datestr(thisTime,0);
        minlon = 13.15;
        maxlon = 13.85;
        minlat = 45.40;
        maxlat = 45.80;
        m_proj('mercator','lon',[minlon maxlon],'lat',[minlat maxlat]);
        hold on
        m_usercoast('NordAdr_FullCoast.mat','patch',[.6 .6 .6]);
        m_grid('tickdir','out','yaxisloc','left');            
        for iSite = 1 : Nsite
            lon = Data{iSite}{1};
            lat = Data{iSite}{2};
            outside = find(lon < minlon | lon > maxlon | lat < minlat | lat > maxlat);
            lon(outside) = NaN;
            lat(outside) = NaN;
            m_plot(lon,lat,'.','color',char(SiteSource.colAnt(iSite)));
            m_plot(SiteSource.lonOrg(iSite),SiteSource.latOrg(iSite),'+','color',char(SiteSource.colAnt(iSite)),'markersize',14);
            m_text(SiteSource.lonOrg(iSite)+.01,SiteSource.latOrg(iSite),SiteSource.NameAn(iSite),'color',char(SiteSource.colAnt(iSite)),'fontweight','bold','fontsize',14);
        end
        hold off
        ht = title(['Radial RUV data for Trieste 2012 Campaign, Time = ',t_str,' UTC']);
        set(ht,'fontsize',12)

        pause(2)
        clf
   
   end %if PLOTRAW
   
   %clear Data
    
end %ii

% set also dates in 
time_origin = '2010/01/01 00:00:00';
julianDay = timeStamp - datenum(time_origin);
date3format = julday2date(julianDay,time_origin);


%% save matlab output file
disp(['Creating file ---> ',matOutFile]);
save(matOutFile,'lonr','latr','xr','yr','dist','angle','vr',...
    'time_origin','date3format','SiteSource');
disp(' ');
disp('Done!');

ncfile=[outpath,'SpeziaRadials_RUV_Carlo.nc'];
ang=angle;
v=vr{1};

%%%create nc
%%% Creation
s = size(xr);
% nccreate(ncfile,'xr',...
%     'Dimensions',{'x',s(1),'y',s(2)}, 'Format','classic');
% nccreate(ncfile,'yr',...
%     'Dimensions',{'x',s(1),'y',s(2)}, 'Format','classic');
% nccreate(ncfile,'dist',...
%     'Dimensions',{'x',s(1),'y',s(2)}, 'Format','classic');
% nccreate(ncfile,'ang',...
%     'Dimensions',{'x',s(1),'y',s(2)}, 'Format','classic');
% nccreate(ncfile,'lon',...
%     'Dimensions',{'x',s(1),'y',s(2)}, 'Format','classic');
% nccreate(ncfile,'lat',...
%     'Dimensions',{'x',s(1),'y',s(2)}, 'Format','classic');
% nccreate(ncfile,'time',...
%     'Dimensions',{'time',length(time)}, ...
%     'Format','classic');
% nccreate(ncfile,'v',...
%     'Dimensions',{'x',s(1),'y',s(2),'time',length(time)}, ...
%     'Format','classic')

%%% Attributes
ncwriteatt(ncfile,'xr','long_name',char('Abscisse'));
ncwriteatt(ncfile,'xr','units',    char('km'));
% ncwriteatt(ncfile,'x','point_spacing', char('even'));

ncwriteatt(ncfile,'yr','long_name',char('Ordinate'));
ncwriteatt(ncfile,'yr','units',    char('km'));
% ncwriteatt(ncfile,'y','point_spacing', char('even'));
ncwriteatt(ncfile,'dist','long_name',char('Bistatic distance'));
ncwriteatt(ncfile,'dist','units',    char('km'));
% ncwriteatt(ncfile,'dist','point_spacing', char('even'));

ncwriteatt(ncfile,'ang','long_name',char('"Radial" direction (toward the RADAR base line)'));
ncwriteatt(ncfile,'ang','units',    char('deg'));
% ncwriteatt(ncfile,'ang','point_spacing', char('even'));

ncwriteatt(ncfile,'lon','long_name',char('Longitude'));
ncwriteatt(ncfile,'lon','units',    char('decimal deg'));
% ncwriteatt(ncfile,'lon','point_spacing', char('even'));

ncwriteatt(ncfile,'lat','long_name',char('Latitude'));
ncwriteatt(ncfile,'lat','units',    char('decimal deg'));
% ncwriteatt(ncfile,'lat','point_spacing', char('even'));

ncwriteatt(ncfile,'time','long_name',char('Valid Time'));
ncwriteatt(ncfile,'time','units',char(['days since ' time_origin]));
ncwriteatt(ncfile,'time','time_origin',time_origin);

ncwriteatt(ncfile,'v','long_name',   char(['Radial velocity from ' STA]));
%ncwriteatt(ncfile,'v','comment',     char(['Original format ' EXT]));
ncwriteatt(ncfile,'v','units',       char('m/s'));
ncwriteatt(ncfile,'v','scale_factor',1);%single(1));
ncwriteatt(ncfile,'v','add_offset',  0);%single(0));
ncwriteatt(ncfile,'v','_FillValue',  fillval);%single(fillval));


%%% GLOBAL Attributes
ncwriteatt(ncfile,'/','title',                   char(['Radial velocity from ' STA]));
ncwriteatt(ncfile,'/','station',                 char(STA));
% ncwriteatt(ncfile,'/','grid origin coordinates', char(['lon: ' num2str(lon0)   ', lat: ' num2str(lat0)  ]));
% ncwriteatt(ncfile,'/','TX site coordinates',     char(['lon: ' num2str(lon_tx) ', lat: ' num2str(lat_tx)]));
% ncwriteatt(ncfile,'/','RX site coordinates',     char(['lon: ' num2str(lon_rx) ', lat: ' num2str(lat_rx)]));
% ncwriteatt(ncfile,'/','original_type',           char(EXT));
% ncwriteatt(ncfile,'/','creation_date',           char(datestr(now)));

ncwriteatt(ncfile,'/','author',                  char('Molcard'));


%%% Write variables
ncwrite(ncfile,'xr',xr);
ncwrite(ncfile,'yr',yr);
ncwrite(ncfile,'dist',distr);
ncwrite(ncfile,'ang',angr);
ncwrite(ncfile,'lon',lonr);
ncwrite(ncfile,'lat',latr);
ncwrite(ncfile,'time',DATEjulian);
ncwrite(ncfile,'v',vr);

disp('Done');
disp(blanks(1)');   % empty line

