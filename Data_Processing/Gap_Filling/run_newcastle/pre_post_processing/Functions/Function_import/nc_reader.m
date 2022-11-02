function [Vr,lonr,latr, angr, DATE] = nc_reader( cxname , time_origin )
% MARMAIN
%function datadata = nc_reader( cxname , time_origin )
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
EXT = cxname(1,end-1:end);
disp(['    ' EXT ' case']);
STA=cxname(1,end-5:end-3);
disp(['    ' STA ' station']);
% %%AJM
% path_write_NetCDF = radial_data_params.path_NetCDF;%radial_data_params.path_write_NetCDF;
% ncfile = fullfile(path_write_NetCDF,ncname);
% disp(['from: ' ncfile]);
%%AJM


%%% define time origin
if nargin == 1  %%% default case
    time_origin = '20100101000000';  %%% YYYYMMDDhhmmss
end

%%% read the files one by one
deg_to_rad = pi/180;

for tindex = 1 : size(cxname,1)
    %%% DATE
    DATEr(tindex,:) = cxname(tindex,end-17:end-7);   %%% yyyyjjjhhmm
    %DATE(tindex) = julrad2date(DATEr,time_origin); %#ok<AGROW>
   
ncfile = cxname(tindex,:);
  if exist(ncfile,'file')

%%%%AJM
   %% NetCDF file
    % Read from NetCDF
    % - Data
    %xr         = double(ncread(ncfile,'xr'));
    %yr         = double(ncread(ncfile,'yr'));
    %distr      = double(ncread(ncfile,'dist'));

   if tindex==1
     cord = 180/pi;	% conversion radians-degres

%    angr       = double(ncread(ncfile,'angr '));
    normEll    = double(ncread(ncfile,'normEll')); % Angle de la normale aux ellipses, nord clockwise, radians
    angr   =  (3*pi/2-normEll)*cord; %angle from west, counter clockwise (trigonometric orientation)
    lonr       = double(ncread(ncfile,'lonCell'));
    latr       = double(ncread(ncfile,'latCell'));

   end

    %DATEjulian = double(ncread(ncfile,'time'));
    vr         = double(ncread(ncfile,'Vrad'));
    Vr(tindex,:,:) = vr;
    %Xr             = xr;
    %Yr             = yr;

    % - Attributes
%     tmp = ncreadatt(ncfile,'/','grid origin coordinates');
%     [tmp1 tmp2] = strtok(tmp,',');
%     lon0  = str2double(strtok(tmp1,'lon:'));
%     lat0  = str2double(strtok(tmp2,', lat:'));
% 
%     time0 = ncreadatt(ncfile,'time','units');
%     time0 = time0(end-18:end);
% 
%     tmp = ncreadatt(ncfile,'/','TX site coordinates');
%     [tmp1 tmp2] = strtok(tmp,',');
%     lon_tx  = str2double(strtok(tmp1,'lon:'));          % not in the output, for the time being
%     lat_tx  = str2double(strtok(tmp2,', lat:'));        % not in the output, for the time being
% 
%     tmp = ncreadatt(ncfile,'/','RX site coordinates');
%     [tmp1 tmp2] = strtok(tmp,',');
%     lon_rx  = str2double(strtok(tmp1,'lon:'));          % not in the output, for the time being
%     lat_rx  = str2double(strtok(tmp2,', lat:'));        % not in the output, for the time being
 
% Re-arrange data according to Matlab's spatial convention (y,x)
% starting from Ferret's convention (x,y,z,t)
    %xr      = xr';                    %%% (x,y)   -> (y,x)
    %yr      = yr';                    %%% (x,y)   -> (y,x)
    %distr   = distr';                 %%% (x,y)   -> (y,x)


else
    error(['The NetCDF file to be read does not exist!  ' ncfile]);
end

end

%% Build the output structure
%data.name    = STA;
%data.xr      = xr;
%data.yr      = yr;
% data.lonr    = lonr;
% data.latr    = latr;
% data.mask    = ones(size(lonr));   % build an empty mask (1 means not to be masked)
%data.distr   = distr;
% data.angr    = angr;
%data.angr_rx = angr_rx;
%data.time    = DATEjulian;
% data.vr      = Vr;
% data.lon0    = lon0;
% data.lat0    = lat0;
% data.time0   = time0;

%%%AJM

  DATE=julrad2dateAJM(DATEr,time_origin); %#ok<AGROW>
 
 %patch_correction_grid_problem


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
