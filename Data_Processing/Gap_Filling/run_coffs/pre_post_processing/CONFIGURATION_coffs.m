% MARMAIN - 2014/03/26
% Adaptation pour utilisation du formatage mensuel


%% Rectangular cartesian grid for mapping plots
cartesian_grid.lon_lim    = [153.010561 154.775963+3/111]';%[5.7 6.7]'; %%     % longitude limits
cartesian_grid.lat_lim    = [-31.609578 -29.363513]';%[42.45 43.05]';%  % latitude limits
cartesian_grid.step       = 1.5;%2;               % grid step (same for x and y) [km]
cartesian_grid.rot_angle  = 0;               % counterclockwise rotation angle of the grid wrt the WE axis
cartesian_grid.GDOP_thresh = 2.5;            % maximum allowed normalized GDOP error
cartesian_grid.ang_thresh  = [-30 -150];   %40 according to schaeffer          % minimum allowed angle between "radial" directions [deg]


%% Cartesian mapping processing
cartesian_data_params.use_geo_mask      = 0;        % use the geographic mask in grid_cartesian.mat
cartesian_data_params.use_err_mask      = 1;        % use the error mask (GDOP or angle) in grid_cartesian.mat
cartesian_data_params.time_accuracy     = 25;       % maximum allowed time difference to "mix" two radial maps [min]
cartesian_data_params.master_RADAR      = 'RRK';    % Nb. of the master RADAR nb. (1 or 2) used as time reference
cartesian_data_params.mapping.method    = 5;        % Type of mapping algorithm
                                                    %       5: classic interpolation + MSE (local)
                                                    %       6: MSE mapping (local)
cartesian_data_params.mapping.radius    = 10;        % for the mapping step, maximum valid radius to consider a radial velocity in the interpolation process       [km]
cartesian_data_params.map.plot          = 0;        % plot current maps right after computing them
cartesian_data_params.map.save          = 0;        % save current maps in png format (only if map.plot == 1)
cartesian_data_params.map.path          = '/home/natachab/RADAR/';
% cartesian_data_params.map.path          = '~/HF_RADAR/Results/Vector/figures/'; % path for saving .png current maps (only if map.save == 1)
cartesian_data_params.save_currents     = 0;        % save current velocities (the data, not the figure)
                                                    %       0: do not save,
                                                    %       1: in raw binary and ASCII format
                                                    %       2: in NetCDF format
                                                    %       3: in both ASCII and NetCDF formats
cartesian_data_params.path_read_write   = '/data/MIO/natachab/hfr_data/vectors_L3/';%'/home/molcard/RADAR/CARTO/2012-2019/';%'/home/molcard/RADAR_NEW/COMPARISON/DINEOF/';%/CARTO/';%VECTO/';
cartesian_data_params.read_NetCDF       = 0;        % read current maps from a NetCDF file (0: no, so read from ASCII, 1: yes)
cartesian_data_params.NetCDF_filename   = 'current_L3_LIar_L1_Y2014M01.nc'; % name of the NetCDF file to be read for offline plotting of the maps
cartesian_data_params.ProcLev            = 'L3_vec';%'L3_fillxt';%'L3_LIar_L2_Dineof';%'L3_LIar_L1';%'L3_2dVAR_L1';%L3_2dVAR_L2_DinMulti';%'L3_2dVAR_L2_DinMultiSmo';%'L3_2dVAR_L2_DinMultiWindSmo';%'L3_LIar_L1';%'L3_LIar_L2_DinMultiSmo';%'L3_LIar_L2_DinMultiWindSmo';%'L3_2dVAR';%'L3_LIar';%'L3_LIc';%'L3_2dVAR';%            % range of dates to be used


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% diagnostic results  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

diagnostic_param.map.path               = '~/Bureau/CARTO_RADAR/figures/'; %%% chemin d'enregistrement des figures diagnostiques


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% plot_parameters %%%%%%%%%
plot_param.ste=2;4;                % pas pour fleches de courant
plot_param.sca=0.1;0.4;            % echelle des fleches de courant
plot_param.lw=1;                   % linewidth du gca
plot_param.lwl=1.5;
plot_param.lwc=1.5;                % linewidth des cotes
plot_param.lwb=0.5;                % linewidth bathy
plot_param.fsb=10;                 % fontsize des labels de bathy
plot_param.levels=[50 100 1000];   % isobathes
plot_param.lwcont=0.5;             % linewidth des contours
plot_param.lwfl=0.5;               % linewidth des fleches
plot_param.cax_min=-0.5;  cax_max=0.5;  %caxis des vecteurs projetes (99: pas de caxis)
plot_param.fst=14;                 %fontsize du texte
plot_param.msr=20;                 %markersize des radars
plot_param.lwl=2;                  %linewidth des axes radar lateraux
plot_param.fstl=16;% 8;%   %16             % fontsize du texte axes
plot_param.fstl2=14;               % fontsize du texte legendes
plot_param.pw=15;                   % point width

plot_param.caxis(1).ca=[-0.6 0.6];   %%% caxis des vitesses radiales
plot_param.caxis(2).ca=[-0.6 0.6];
plot_param.caxis(3).ca=[-0.6 0.6];


%% Options for all geographic plots
map.lonlat_xy = 1;              % use 1: lon/lat coordinates
                                %     2: x/y coordinates in km
map.plot_bath=0;% plot isobaths (0 or 1) whose values are in installation/trace_coast.m
map.bath_levels= [-100 -1000 -2000]; % isobaths levels to plot
map.plot_land=0; %%% 0: trace les terres en couleurs; 0: rien

map.lon0      = 5.861066;       % reference lon for x/y maps (only if map.lonlat_xy==2)
map.lat0      = 43.063078;      % reference lat for x/y maps (only if map.lonlat_xy==2)

% map.lon_lim   = [5.1  7.1]';% longitude range of the map [decimal deg]
% map.lat_lim   = [42.1 43.15]';   % latitude range of the map  [decimal deg]
% map.lon_lim   = [2. 8]';% longitude range of the map [decimal deg]
% map.lat_lim   = [41.2 43.9]';   % latitude range of the map  [decimal deg]

%%%radiale:
map.lon_lim   = [5.1  7.1]';% longitude range of the map [decimal deg]
map.lat_lim   = [42.1 43.15]';   % latitude range of the map  [decimal deg]
% %%% vecteur
% map.lon_lim   = [5.6 6.8]';      % longitude limits
% map.lat_lim   = [42.4 43.15]';  % latitude limits


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% N.B.: All the plots are done either in lon/lat or in x/y  %
%       coordinates according to the value of map.lonlat_xy %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
