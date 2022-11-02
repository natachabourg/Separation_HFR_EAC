function [ MODELname ] = METEO_MODEL_MF_monthly_list( PATH_MODEL , PARAM  )
% MARMAIN 
% 2012/07/14
% To create a list of Model files based on grib file provided by Meteo
% France and converted in netcdf by ourself and concatenated by month
%
% Work on ARPEGE, ALADIN and AROME
%
% We can load only one parameter given in input arguments
%
% File must be sorted by year in one directory by year.
%
%   INPUT:  PATH_MODEL: where the files are stored in annual directory
%           PARAM: the parameter to list U10M, V10M, T2m ...
%           

%   OUTPUT: MODELname: structure variable with
%               MODELname.short: the list of short name (without path)
%               MODELname.long: the list of long name (with path)



%%% Creation de la liste

flist=dir([PATH_MODEL '/' PARAM.name '*.nc']);

if isempty(flist)==1 %%% -> decadal case
    
    disp('Files sorted in annual directories -> list contains of each directory')
    
    rlist=dir([PATH_MODEL '/2*']);%%% 2 because all file are measured in 201*
    
    if isempty(rlist)==1
        error(['!!! No directory in format  20* !!!'])
    end
    
    k=0;
    for i=1:size(rlist,1);
        
        rname(i,:)=fullfile(PATH_MODEL,rlist(i,1).name);
        
        flist1=dir([rname(i,:) '/' PARAM.name '*.nc']);
        
        if isempty(flist1)==0 %%% il y a des fichiers qu'on recherche
            
            for j=1:size(flist1,1);
                k=k+1;
                
                MODELname.long(k,:)=fullfile(rname(i,:),flist1(j,1).name);
                
                MODELname.short(k,:)=flist1(j,1).name;
                
            end
        end
               
    end
    
else %%% isempty(flist)==0 
    disp(['We are in the directory ' PATH_MODEL])
    
    for j=1:size(flist,1);
  
        
        MODELname.long(j,:)=fullfile(PATH_MODEL,flist(j,1).name);
        
        MODELname.short(j,:)=flist(j,1).name;
        
    end
    
end
    
end

