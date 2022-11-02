function [ Xr,Yr ] = cll_xyv_reader_mask( cxname )
% BELLOMO
% 2012/07/03
%   To read a list of cll or xyv file.
%
%   INPUT:  cxname: where the files are stored
%
%   OUTPUT: Xr: abscisses of the grid
%           Yr: ordinates of the grid
%
%!!! BE AWARE !!!
% in xyv mode, origin of the grid in Peyras (for each radar)
% in cll mode, origin of the grid in the RADAR defined in cxname!!!
%%%########################################################################

%%% define file extension (cll or xyv ?)
EXT = cxname(1,end-2:end);
disp([EXT '  case']);
cxname

%%%########################################################################
if strcmp(EXT,'xyv')
    
    % Bistatic case

    %%% GRID AND VR
    discorde = dlmread(cxname);     % whole content of the xyv file
    taille_brute = size(discorde);
    n_ellipse = taille_brute(1,1);          % nb of ellipses
    n_dir     = taille_brute(1,2)/5;        % nb of azimuths
    biscorde = reshape(discorde,n_ellipse,n_dir,5);

    Xr = biscorde(:,:,1)/1000;  % x-coordinate [km]
    Yr = biscorde(:,:,2)/1000;  % y-coordinate [km]

%%%########################################################################
elseif strcmp(EXT,'cll')
    
    % Monostatic case
    
    % N.B.: BORDEL pour passage 40x31 a 31x31 du 20112980800 au 20112981000
    %       Take into account this case if the two grids are melt 
    %       WATCH OUT!!! Only one grid change is allowed!!!!
    cllfile = load(cxname);
    dist = cllfile(2:size(cllfile,1),1);             %%% km
    teta = cllfile(1,2:size(cllfile,2));             %%% degree
    
    %%% Keep the first grid which has to be equal or larger than the 2nd
    Xr = dist*cos(teta*pi/180);
    Yr = dist*sin(teta*pi/180);

end
%%%########################################################################

end
