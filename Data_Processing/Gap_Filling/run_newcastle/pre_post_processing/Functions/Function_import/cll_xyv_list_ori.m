function [ cxname , cxname_short ] = cll_xyv_list( PATH_ORI , EXT , STA )
% MARMAIN 
% 2012/05/24
%   To create a list of file of cll or xyv file.
%   INPUT:  PATH_ORI: where the files are stored
%           EXT: file extension (cll or xyv)
%           STA: Station identificator (PEY or BEN)
%   OUTPUT: cxname: the list of file with full path
%           cxname_short: the list of short name (without path, EXT and
%           STA)

flist=dir([PATH_ORI filesep '*_' STA '.' EXT]);

if isempty(flist) %%% -> decadal case
    disp('    Decadal case');
    
    rlist=dir([PATH_ORI filesep '2*']);%%% 2 because all files are measured in 201*
    
    k=0;
    for ii=1:size(rlist,1);
        
        rname(ii,:)=fullfile(PATH_ORI,rlist(ii,1).name);
        
        flist1=dir([rname(ii,:) filesep '*_' STA '.' EXT]);
        
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
        
        cxname(ii,:)=fullfile(PATH_ORI,flist(ii,1).name);
        
        if nargout == 2
            cxname_short(ii,:)=flist(ii,1).name;
        end
        
    end
    
end

end

