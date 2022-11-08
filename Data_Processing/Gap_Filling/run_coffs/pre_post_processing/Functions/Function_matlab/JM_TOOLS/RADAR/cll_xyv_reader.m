function [ Vr,NAV,DATE ] = cll_xyv_reader( cxname , time_origin )
% MARMAIN
% 2012/05/24
%   To read a list of cll or xyv file.
%
%   INPUT:  cxname: where the files are stored
%           time_origin: time origin to compute the time axis in days
%                           default is "2010-01-01 00:00:00"
%
%   OUTPUT: Vr: Radial velocity from the file list
%           NAV.xr: abscisses of the grid
%           NAV.yr: ordinates of the grid
%           NAV.alpha: velocity projection direction
%           NAV.teta: azimuth of the grid (only for cll)
%           NAV.dist: range of the grid   (only for cll)
%           DATE: structure with radar time (DATE.radar), julian day since
%           time_origin (DATE.julian) and DATE.calendar with a more
%           classical format YYYY-MM-DD hh:mm:ss
%           dist: range (cll), NaN (xyv)
%           teta: azimuth (cll), NaN (xyv)
%
%!!! BE AWARE !!!
% in xyv mode, origin of the grid in Peyras (for each radar)
% in cll mode, origin of the grid in the radar define in cxname!!!
%%%########################################################################


%%% define file extension (cll or xyv ?)
EXT=cxname(1,end-2:end); disp([EXT '  case']);

%%% define time origin
if nargin==1  %%% default case
    time_origin='20100101000000';  %%% YYYYMMDDhhmmss
end

%%%########################################################################
if EXT == 'xyv'
    
%     if nargout == 6
%         dist=NaN;
%         teta=NaN;
%     end
    NAV.dist=NaN;
    NAV.teta=NaN; 
    
    for tindex=1:size(cxname,1)
        
        DATEr(tindex,:)=cxname(tindex,end-18:end-8);    %%% yyyyjjjhhmm
        
        %DATE(tindex,1)=julrad2date(DATEr,time_origin);
        
        discorde=dlmread(cxname(tindex,:));
        taille_brute=size(discorde);
        n_ellipse=taille_brute(1,1); n_dir=taille_brute(1,2)/5;
        biscorde=reshape(discorde,n_ellipse,n_dir,5);
        t1=size(biscorde);
        

        if exist( 'NAV.xr') == 0   
            NAV.xr=biscorde(:,:,1)/1000; NAV.yr=biscorde(:,:,2)/1000; %x-y
            NAV.alpha=biscorde(:,:,3);   % velocity projection direction
        end
        
        vr=biscorde(:,:,4);
   
        Vr(tindex,:,:)=vr;
        
    end
    
    DATE=radar2date(DATEr,time_origin);
    
    %%% compare la taille de Xr et de la dernière Vr si changement de
    %%% grille accidentel
    if size(squeeze(Vr(end,:,:))) ==  size(NAV.xr)
        
    else
        disp('PROBLEM in grid dimension between Vr and Xr')
        stop
    end
    
end

%%%########################################################################

if EXT == 'cll'
    
    %%% BORDEL pour passage 40x31 a 31x31 du 20112980800 au 20112981000 
    %%% Take into account this case if the two grids are melt 
    %%% KEEP OUT!!! Only one grid changement is allowed!!!!
    
    cllfile1=load(cxname(1,:));
    cllfile2=load(cxname(end,:));
    dist1=cllfile1(2:size(cllfile1,1),1);             %%% km
    teta1=cllfile1(1,2:size(cllfile1,2));             %%% degree
    dist2=cllfile1(2:size(cllfile2,1),1);             %%% km
    teta2=cllfile1(1,2:size(cllfile2,2));             %%% degree
    
    if length(dist1) > length(dist2)
        disp('!!!! Two different radar grids are melt !!!!')
        disp('We keep the largest')
    
    elseif length(dist1) == length(dist2)
       disp(['Same radar grids -> dist x teta = ' num2str(length(dist1)) 'x' num2str(length(teta1)) ]) 
       
       
    else
        disp('!!!! Two different radar grids are melt !!!!')
        disp('The second one is larger ==> STOP')
        stop
       
    end
    
    %%% Keep the first grid which has to be equal or larger than the 2nd
    NAV.dist=dist1;
    NAV.teta=teta1;
    NAV.xr=NAV.dist*cos(d2r(NAV.teta));
    NAV.yr=NAV.dist*sin(d2r(NAV.teta));
    
    
    Vr=nan(size(cxname,1),length(NAV.dist),length(NAV.teta));
    
    for tindex=1:size(cxname,1)
        
        clear vr
        
        %%% DATE
        DATEr(tindex,:)=cxname(tindex,end-18:end-8);    %%% yyyyjjjhhmm
        
        %DATE(tindex,1)=julrad2date(DATEr,time_origin);
        
        
        %%% GRID and VR
        
        %%% BORDEL pour passage 40x31 a 31x31 du 20112980800 au 20112981000 
        %%% Take into account this case if the two grids are melt 
        cllfile=load(cxname(tindex,:));
        
        vr=cllfile(2:size(cllfile,1),2:size(cllfile,2));      %%% m/s
        
        if size(vr,1) == size(Vr,2)
        
            Vr(tindex,:,:)=vr;
        
        else
             Vr(tindex,3:33,:)=vr;
            
        end
        
%         if exist('Xr')==0
%             dist=cllfile(2:size(cllfile,1),1);             %%% km
%             teta=cllfile(1,2:size(cllfile,2));             %%% degree
%             Xr=dist*cos(d2r(teta));
%             Yr=dist*sin(d2r(teta));
%         end
        
    end
    
    DATE=radar2date(DATEr,time_origin);
    
end

end

