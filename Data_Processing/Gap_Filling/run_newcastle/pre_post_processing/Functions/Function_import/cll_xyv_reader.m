function [ Vr,Xr,Yr,DATE ] = cll_xyv_reader( cxname , time_origin )
% MARMAIN
% 2012/05/24
%   To read a list of cll or xyv file.
%
%   INPUT:  cxname: where the files are stored
%           time_origin: time origin to compute the time axis in days
%                           default is "2010-01-01 00:00:00"
%
%   OUTPUT: Vr: Radial velocity from the file list
%           Xr: abscisses of the grid
%           Yr: ordinates of the grid
%           DATE: structure with radar time (DATE.radar), julian day since
%           time_origin (DATE.julian) and DATE.calendar with a more
%           classical format YYYY-MM-DD hh:mm:ss
%
%!!! BE AWARE !!!
% in xyv mode, origin of the grid in Peyras (for each radar)
% in cll mode, origin of the grid in the radar define in cxname!!!
%%%########################################################################

%%% define file extension (cll or xyv ?)
EXT = cxname(1,end-2:end);
disp(['    ' EXT ' case']);

%%% define time origin
if nargin == 1  %%% default case
    time_origin = '20100101000000';  %%% YYYYMMDDhhmmss
end

%%% read the files one by one
deg_to_rad = pi/180;
for tindex = 1 : size(cxname,1)

    %%% DATE
    DATEr(tindex,:) = cxname(tindex,end-18:end-8);    %%% yyyyjjjhhmm
    %DATE(tindex) = julrad2date(DATEr,time_origin); %#ok<AGROW>
    
    %%% GRID AND VR
    if strcmp(EXT,'xyv')    % mono- or bi-static
        discorde = dlmread(cxname(tindex,:));   % whole content of the xyv file
        taille_brute = size(discorde);
        n_ellipse = taille_brute(1,1);          % nb of ellipses
        n_dir     = taille_brute(1,2)/5;        % nb of azimuths
        biscorde = reshape(discorde,n_ellipse,n_dir,5);
        xr = biscorde(:,:,1)/1000;  % x-coordinate      [km]
        yr = biscorde(:,:,2)/1000;  % y-coordinate      [km]
        vr = biscorde(:,:,4);       % "radial" velocity [m/s]
    else                    % mono-static only
        cllfile = load(cxname(tindex,:));
        dist = cllfile(2:size(cllfile,1),1);                    % distance          [km]
        teta = cllfile(1,2:size(cllfile,2));                    % azimuth angle     [deg]
        vr   = cllfile(2:size(cllfile,1),2:size(cllfile,2));   	% "radial" velocity [m/s]
        xr   = dist * cos(teta*deg_to_rad);                     % x-coordinate      [km]
        yr   = dist * sin(teta*deg_to_rad);                     % y-coordinate      [km]
    end
    
    % Chech that the size of the grid has not changed
    % If it has, use the largest one and put NaN's in the
    % appended xr,yr,vr of the smallest grids
    if tindex ~= 1
        [off_y, off_x, larger_smaller] = find_superposition(xr + 1i*yr,Xr +1i*Yr);
        if larger_smaller == 0      % the present grid is the same as the previous ones
            Vr(tindex,:,:) = vr;
            % Xr and Yr stay the same
        elseif larger_smaller == 1  % the present grid is larger than the previous ones
            disp(['Original grid size is ' num2str(size(Xr))])
            disp(['New grid size is ' num2str(size(xr))])          
            Xr = xr;
            Yr = yr;
            for tindex_past = 1 : tindex-1
                Vr_tmp(tindex_past,:,:) = NaN(size(vr)); 
               
                %Vr_tmp(tindex_past,off_y+1:off_y+size(Vr,2),off_x+1:off_x+size(Vr,3)) = Vr(tindex_past,:,:);
                Vr_tmp(tindex_past,off_x+1:off_x+size(Vr,2),off_y+1:off_y+size(Vr,3)) = Vr(tindex_past,:,:); %MRN 
            end
            Vr = Vr_tmp;
            Vr(tindex,:,:) = vr;
        else                        % the present grid is smaller than the previous ones
            Vr(tindex,:,:) = NaN;
            %Vr(tindex,off_y+1:off_y+size(vr,1),off_x+1:off_x+size(vr,2)) = vr;
            Vr(tindex,off_x+1:off_x+size(vr,1),off_y+1:off_y+size(vr,2)) = vr;% MRN
            
            % Xr and Yr stay the same
        end
    else
        Vr(tindex,:,:) = vr;
        Xr             = xr;
        Yr             = yr;
    end

end

 DATE=julrad2date(DATEr,time_origin); %#ok<AGROW>
 
 patch_correction_grid_problem
 

end % end function




%%%########################################################################

function [off2, off1, larger_smaller] = find_superposition(a,b)

size_a = size(a);
size_b = size(b);

if isequal(size_a,size_b)
    if all( all(abs(a - b) < 1e-3) == 1 )
        larger_smaller = 0;
        off1 = 0;
        off2 = 0;
        return;
    else
        error('The grid has the same dimensions but the coordinates are not equal from one file to another');
    end
else
    if (size_a(1) > size_b(1) && size_a(2) >= size_b(2)) || ...
       (size_a(1) >= size_b(1) && size_a(2) > size_b(2))
        larger_smaller = 1;
    else
        larger_smaller = 2;
    end
    for i1 = 0 : abs(size_b(1)-size_a(1))
        for i2 = 0 : abs(size_b(2)-size_a(2))
            if larger_smaller == 1  % a is larger than b
                tmp = a(i1+1:i1+size_b(1),i2+1:i2+size_b(2)) - b;
            else                    % b is larger than a
                tmp = a - b(i1+1:i1+size_a(1),i2+1:i2+size_a(2));
            end
            dist(i1+1,i2+1) = mean(mean(abs(tmp)));
        end
    end
    [val, off1, off2] = min_arr(dist);
    off1 = off1 - 1;
    off2 = off2 - 1;
    if val > 1
        warning(['The  grid has changed but there could not be a valid superposition. The mean distance is ' num2str(val,'%.3f'), ' km']); 
    end
end

end
