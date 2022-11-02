
% 
% Trace coast line and bathymetry using the m_map toolbox
% 

function m_trace_coast(map)


%% Font settings
lw  = 1;    % linewidth of figure box
lwc = 1.5;  % linewidth of coastline
lwb = 0.5;  % fontsize of bathy labels
fst = 14;   % fontsize of axes labels


%% Some aliases
lon_lim        = map.lon_lim(:)';
lat_lim        = map.lat_lim(:)';
lon0           = map.lon0;
lat0           = map.lat0;
plot_lonlat_xy = map.lonlat_xy;
plot_bath      = map.plot_bath;


%% Set the projection type
m_proj('mercator','lon',lon_lim,'lat',lat_lim);


%% Coastline
load coast_med.mat;
xcoast = coast(:,1); %#ok<NODEF>
ycoast = coast(:,2);

m_plot(xcoast,ycoast,'k','Linewidth',lwc);


%% Bathymetry
if plot_bath == 1
    load bathyrelief_med.mat;
    xbath = bathy(:,1); %#ok<NODEF>
    ybath = bathy(:,2);
    zbath = bathy(:,3);
    valid = (xbath >= lon_lim(1) & xbath <= lon_lim(2)) & (ybath >= lat_lim(1) & ybath <= lat_lim(2));
    xbath = xbath(valid);
    ybath = ybath(valid);
    zbath = zbath(valid);
    xbath_un = unique(xbath);
    ybath_un = unique(ybath);
    xbath = reshape(xbath,[length(xbath_un) length(ybath_un)]);
    ybath = reshape(ybath,[length(xbath_un) length(ybath_un)]);
    zbath = reshape(zbath,[length(xbath_un) length(ybath_un)]);
    clear bathy xbath_un ybath_un
    
    levels = [-100 -1000 -2000]';
    [C, h] = m_contour(xbath,ybath,zbath,levels,'Color',[0.5 0.5 0.5],'Linewidth',lwb);
    clabel(C,h,'LabelSpacing',1000,'FontSize',9,'Color',[0.5 0.5 0.5]);
    hold on;
end


%% Fancy stuff
m_grid('box','fancy','tickdir','in');
xlabel('Longitude','fontsize',fst);
ylabel('Latitude','fontsize',fst);
