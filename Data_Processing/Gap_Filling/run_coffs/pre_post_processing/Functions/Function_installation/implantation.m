% 
% Plots the location of the RADAR site(s) and their spatial coverage
% 
% INPUTS:
% - map_opts: structure, containing the map informations, with fields:
%       - lon_lim/lat_lim: 2-element vectors with lon/lat limits of the
%                          region to be plotted
%       - lon0/lat0:       reference lon/lat used if an x/y plot is asked (lonlat_xy==2)
%       - lonlat_xy:       1: plot in lon/lat coordinates
%                          2: plot in x/y coordinates in km
%       - plot_bath:       plot isobaths (0: no, 1: yes)
% - RADAR_infos: n-element structure (n is the number of sites),
%                containing the RADAR site(s) informations, with fields:
%       - name:          string with the name or acronym
%       - lon_rx/lat_rx: lon/lat coordinates
%       - x_rx/y_rx:     x/y coordinates in km if map_opts.lonlat_xy==2
%       - range:         2-element vector with the range min and max limits [km]
%       - ouv_angle:     aperture angle of the RADAR site [deg]
%       - orientation:   orientation of the RX array wrt the geographic North [deg]
% - plot_coverage: plot the coverage region of each site (0: no, 1: yes)
% 
% OUTPUTS: none
% 
% revu PB 06/2003
% revu PFO 13/12/11 pour tosca
% revu Lucio Bellomo 12/06/2011 pour TOSCA
% 

function implantation(map_opts,RADAR_infos,plot_coverage)


%% Trace coast and bathymetry
trace_coast(map_opts);


%% Plot RADAR coordinates and coverage
col = ['b' 'r' 'g' 'k'];

for i_radar = 1 : length(RADAR_infos)
    
    % RADAR coordinates
    if map_opts.lonlat_xy == 1
        m_plot(RADAR_infos(i_radar).lon_rx,RADAR_infos(i_radar).lat_rx,['x' col(i_radar)],'MarkerSize',8);
    else
        plot(RADAR_infos(i_radar).x_rx,RADAR_infos(i_radar).y_rx,['x' col(i_radar)],'MarkerSize',8);
    end

    % RADAR name
    if map_opts.lonlat_xy == 1
        m_text(RADAR_infos(i_radar).lon_rx,RADAR_infos(i_radar).lat_rx,['  ' RADAR_infos(i_radar).name], ...
         'Color',col(i_radar),'FontSize',12,'FontWeight','bold');
    else
        text(RADAR_infos(i_radar).x_rx,RADAR_infos(i_radar).y_rx,['  ' RADAR_infos(i_radar).name], ...
         'Color',col(i_radar),'FontSize',12,'FontWeight','bold');
    end

    % RADAR coverage
    if plot_coverage == 1
        % min and max coverage (ii=1,2)
        for ii = 1 : 2
            [x(ii,:),y(ii,:),lon(ii,:),lat(ii,:)] = circle(RADAR_infos(i_radar).lon_rx,RADAR_infos(i_radar).lat_rx, ...
                           RADAR_infos(i_radar).x_rx,RADAR_infos(i_radar).y_rx, ...
                           RADAR_infos(i_radar).orientation-270,RADAR_infos(i_radar).range(ii), ...
                           RADAR_infos(i_radar).ouv_angle/2);
            % - Plot the arc of circle
            if map_opts.lonlat_xy == 1
                m_plot(lon(ii,:),lat(ii,:),['--' col(i_radar)],'LineWidth',1.5);
            else
                plot(x(ii,:),y(ii,:),['--' col(i_radar)],'LineWidth',1.5);
            end
            % N.B.: -270 because the orientation is given wrt the geographic North
        end
        % - Plot the ouverture boundaries
        if map_opts.lonlat_xy == 1
            m_plot([lon(1,1)   lon(2,1)],  [lat(1,1)   lat(2,1)],  ['--' col(i_radar)],'LineWidth',1.5);
            m_plot([lon(1,end) lon(2,end)],[lat(1,end) lat(2,end)],['--' col(i_radar)],'LineWidth',1.5);
        else
            plot([x(1,1)   x(2,1)],  [y(1,1)   y(2,1)],  ['--' col(i_radar)],'LineWidth',1.5);
            plot([x(1,end) x(2,end)],[y(1,end) y(2,end)],['--' col(i_radar)],'LineWidth',1.5);
        end
    end
end

clear col x y ii hor_rx vert_rx
