function [ GLname ] = GLazur_list( PATH_GLAZUR , PARAM , SURF  )
% MARMAIN 
% 2012/07/12
% To create a list of Glazur64 files
%
%   INPUT:  PATH_GLAZUR: where the files are stored
%           PARAM: the parameter to list
%           SURF: to list only 2Dsurf file
%   OUTPUT: GLname: the list of file with full path
%           GLname_short: the list of short name (without path)


if nargin == 2
    flist=dir([PATH_GLAZUR '/*_grid' PARAM '.nc']);
    disp(['list of 3D parameters ' PARAM ])
else
    flist=dir([PATH_GLAZUR '/*_grid' PARAM '_' SURF '.nc']);
    disp(['list of ' SURF ' parameters ' PARAM ])
end

if isempty(flist)==1    
    disp('Bad directory or no file matching PARAM -> Try again')
    stop  
end


for i=1:size(flist,1);
    
    GLname.long(i,:)=fullfile(PATH_GLAZUR,flist(i,1).name);
    
    GLname.short(i,:)=flist(i,1).name;

end


end

