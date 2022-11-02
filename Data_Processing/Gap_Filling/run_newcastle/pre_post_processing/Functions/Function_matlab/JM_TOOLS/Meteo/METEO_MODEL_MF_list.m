function [ MODELname ] = METEO_MODEL_MF_list( PATH_MODEL , PARAM  )
% MARMAIN 
% 2012/07/14
% To create a list of Model files based on grib file provided by Meteo
% France and converted in netcdf by ourself. 
% Either analyse (e.g. 8 times step by file for Aladin) or Forecast
% provided during TOSCA experiments
%
% Work on ARPEGE, ALADIN and AROME
%
% We can load only one parameter given in input arguments
%
%   INPUT:  PATH_MODEL: where the files are stored
%           PARAM: the parameter to list U10M, V10M, T2m ...
%           CONF: configuration name: ARPEGE, ALADIN and AROME

%   OUTPUT: MODELname: structure variable with
%               MODELname.short: the list of short name (without path)
%               MODELname.long: the list of long name (with path)



%%% Creation de la liste

flist=dir([PATH_MODEL '/*' PARAM.CONF '_' PARAM.name '*.nc']);

if isempty(flist)==1
    error(['No file in format ' PARAM.CONF '_' PARAM.name '*.nc*'])
end

for i=1:size(flist,1);

    MODELname.long(i,:)=fullfile(PATH_MODEL,flist(i,1).name);
    MODELname.short(i,:)=flist(i,1).name;
    
end



end

