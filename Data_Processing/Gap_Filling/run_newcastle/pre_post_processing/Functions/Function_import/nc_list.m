function [ cxname, cxname_short ] = nc_list( PATH_ORI , EXT , STA , MTIME)
% MARMAIN
% 2012/05/24
%   To create a list of file of cll or xyv file.
%   INPUT:  PATH_ORI: where the files are stored
%           EXT: file extension (cll or xyv)
%           STA: Station identificator (PEY or BEN)
%           MTIME: value of the minutes of the file list you want to load.
%           If MTIME is not defined, list all files. In general, it is used
%           to load only files at MTIME '01' (or 21, 41 ...)
%   OUTPUT: cxname.long: the list of file with full path
%           cxname.short: the list of short name (without path, EXT and
%           STA)
%
% updated 2012/07/24 MARMAIN
% updated 2012/09/08 MARMAIN: list all files or only the files at specified
%                             time (01,21,41...)


if nargin == 3; MTIME=''; end

flist=dir([PATH_ORI '/*' MTIME '_' STA '.' EXT]);

if isempty(flist)==1 %%% -> decadal case
    disp('Decadal case')
    
    rlist=dir([PATH_ORI filesep '2*']);%%% 2 because all files are measured in 201*
    
    k=0;
    for ii=1:size(rlist,1);
        
        rname(ii,:)=fullfile(PATH_ORI,rlist(ii,1).name);
        
        flist1=dir([rname(ii,:) filesep '*' MTIME '_' STA '.' EXT]);
        
        if ~isempty(flist1) %%% il y a des fichiers qu'on recherche
            
            for j=1:size(flist1,1);
                k=k+1;
                cxname(k,:)=fullfile(rname(ii,:),flist1(j,1).name);
                
                if nargout == 2
                    cxname_short(k,:)=flist1(j,1).name;
                end
                
            end
            
        end
    end
    
else %%% ~isempty(flist) -> not sorted in decade
    disp('NOT Decadal case')
    
    for ii=1:size(flist,1);
        
        cxname(ii,:)=fullfile(PATH_ORI,flist(ii,1).name)
        
        if nargout == 2
            cxname_short(ii,:)=flist(ii,1).name;
        end
        
    end
    
end

end

