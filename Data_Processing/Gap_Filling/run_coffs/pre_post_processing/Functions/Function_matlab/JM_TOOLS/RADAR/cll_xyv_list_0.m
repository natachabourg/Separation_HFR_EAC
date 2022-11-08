function [ cxname ] = cll_xyv_list( PATH_ORI , EXT , STA , MTIME)
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
    
    rlist=dir([PATH_ORI '/2*']);%%% 2 because all file are measured in 201*
    
    k=0;
    for i=1:size(rlist,1);
        
        rname(i,:)=fullfile(PATH_ORI,rlist(i,1).name);
        
        flist1=dir([rname(i,:) '/*' MTIME '_' STA '.' EXT]);
        
        if isempty(flist1)==0 %%% il y a des fichiers qu'on recherche
            
            for j=1:size(flist1,1);
                k=k+1;
                cxname.long(k,:)=fullfile(rname(i,:),flist1(j,1).name);
                
                cxname.short(k,:)=flist1(j,1).name;
                   
            end
            
        end
    end
    
else %%% isempty(flist)==0 -> not sorted in decade
    disp('NOT Decadal case')
    
    for i=1:size(flist,1);
        
        cxname.long(i,:)=fullfile(PATH_ORI,flist(i,1).name);

        cxname.short(i,:)=flist(i,1).name;

    end
    
end

end

