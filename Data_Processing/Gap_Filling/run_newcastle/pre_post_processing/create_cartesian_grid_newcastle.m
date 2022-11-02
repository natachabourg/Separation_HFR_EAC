
addpath('/media/nbourg/One Touch/PhD/Separation_HFR_EAC/Data_Processing/Gap_Filling/run_newcastle/pre_post_processing/Functions/Function_import/')
addpath('/media/nbourg/One Touch/PhD/Separation_HFR_EAC/Data_Processing/Gap_Filling/run_newcastle/pre_post_processing/Functions/Function_installation/')


map.lonlat_xy = 1;              % use 1: lon/lat coordinates
                                %     2: x/y coordinates in km
map.plot_bath=0;% plot isobaths (0 or 1) whose values are in installation/trace_coast.m
map.bath_levels= [-100 -1000 -2000]; % isobaths levels to plot
map.plot_land=0; %%% 0: trace les terres en couleurs; 0: rien

map.lon0      = 152;       % reference lon for x/y maps (only if map.lonlat_xy==2)
map.lat0      = -33;      % reference lat for x/y maps (only if map.lonlat_xy==2)

%%%radiale:
map.lon_lim   = [151  154]';% longitude range of the map [decimal deg]
map.lat_lim   = [-35 -32]';   % latitude range of the map  [decimal deg]

                              
% Peyras
RADAR_infos(1).name        = 'RHED';     % same as the cll/xyv files suffix
RADAR_infos(1).lon_rx      = 151.72;  % RX longitude [decimal deg]
RADAR_infos(1).lat_rx      = -33.01; % RX latitude  [decimal deg]
RADAR_infos(1).lon_tx      = 151.72;  % TX longitude [decimal deg]
RADAR_infos(1).lat_tx      = -33.01; % TX latitude  [decimal deg]
RADAR_infos(1).integr_time = 1;
RADAR_infos(1).lon0        = 151.72;  % Origin of the radial grid, longitude [decimal deg]
RADAR_infos(1).lat0        = -33.01; % Origin of the radial grid, latitude  [decimal deg]
RADAR_infos(1).mono_bi = 1;
RADAR_infos(1).obs_id      ='L2bis';%'L2_Dineof';%'L1'; %'L2_Dineof';%     % descriptif observation original


% Bénat - Porquerolles
RADAR_infos(2).name        = 'SEAL';     % same as the cll/xyv files suffix
RADAR_infos(2).lon_rx      = 152.53;  % RX longitude [decimal deg]
RADAR_infos(2).lat_rx      = -32.44; % RX latitude  [decimal deg]
RADAR_infos(2).lon_tx      = 152.53;  % TX longitude [decimal deg]
RADAR_infos(2).lat_tx      = -32.44; % TX latitude  [decimal deg]
RADAR_infos(2).lon0        = 152.53;  % Origin of the radial grid, longitude [decimal deg]
RADAR_infos(2).lat0        = -32.44; % Origin of the radial grid, latitude  [decimal deg]
RADAR_infos(2).integr_time = 1;
RADAR_infos(2).mono_bi = 1;                                           %                   n for n*the_reference_time)
RADAR_infos(2).obs_id      = RADAR_infos(1).obs_id ;%'L2_Dineof';%'L1';%'L2_Dineof';%      % descriptif observation original


for i_radar = 1 : length(RADAR_infos)
    [RADAR_infos(i_radar).x_rx RADAR_infos(i_radar).y_rx] = ...
                    xy2lonlat(RADAR_infos(i_radar).lon_rx,RADAR_infos(i_radar).lat_rx, ...
                              map.lon0,map.lat0,1);
    [RADAR_infos(i_radar).x_tx RADAR_infos(i_radar).y_tx] = ...
                    xy2lonlat(RADAR_infos(i_radar).lon_tx,RADAR_infos(i_radar).lat_tx, ...
                              map.lon0,map.lat0,1);

    if RADAR_infos(i_radar).lon_tx == RADAR_infos(i_radar).lon_rx && ...
       RADAR_infos(i_radar).lat_tx == RADAR_infos(i_radar).lat_rx
        RADAR_infos(i_radar).mono_bi = 1;
    else
        RADAR_infos(i_radar).mono_bi = 2;
    end
    
    radial_data_params(i_radar).name = RADAR_infos(i_radar).name;
end




cartesian_grid.lon_lim    = [150.7 155.2]';%[5.7 6.7]'; %%     % longitude limits
cartesian_grid.lat_lim    = [-34.6 -30.5]';%[42.45 43.05]';%  % latitude limits
cartesian_grid.step       = 6;%2;               % grid step (same for x and y) [km]
cartesian_grid.rot_angle  = 0;               % counterclockwise rotation angle of the grid wrt the WE axis
cartesian_grid.GDOP_thresh = 2.5;            % maximum allowed normalized GDOP error
cartesian_grid.ang_thresh  = 30;             % minimum allowed angle between "radial" directions [deg]




cartesian_grid = install_grid(map,RADAR_infos,cartesian_grid);

