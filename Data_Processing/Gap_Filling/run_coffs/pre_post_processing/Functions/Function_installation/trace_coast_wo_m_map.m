
%
% Plots coast and bathymetry
% 

function varargout = trace_coast_wo_m_map(map_opts)


%% Font settings
lw  = 1;    % linewidth of figure box
lwc = 1.5;  % linewidth of coastline
lwb = 0.5;  % fontsize of bathy labels
fst = 14;   % fontsize of axes labels


%% Some aliases
lon_lim        = map_opts.lon_lim(:)';
lat_lim        = map_opts.lat_lim(:)';
lon0           = map_opts.lon0;
lat0           = map_opts.lat0;
plot_lonlat_xy = map_opts.lonlat_xy;
plot_bath      = map_opts.plot_bath;


%% Coastline
load coast_med.mat;
xcoast = coast(:,1); %#ok<NODEF>
ycoast = coast(:,2);

if plot_lonlat_xy == 1
    h_coast = plot(xcoast,ycoast,'b','Linewidth',lwc);
else
    [xcoast,ycoast] = xy2lonlat(xcoast,ycoast,lon0,lat0,1);
    [x_lim(1),y_lim(1)] = xy2lonlat(lon_lim(1),lat_lim(1),lon0,lat0,1);
    [x_lim(2),y_lim(2)] = xy2lonlat(lon_lim(2),lat_lim(2),lon0,lat0,1);
    h_coast = plot(xcoast,ycoast,'b','Linewidth',lwc);
end


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
    
    levels = [-100 -1000 -2000]';   % isobaths to be plotted [m]
    
    if plot_lonlat_xy == 1
        [C, h_bathy] = contour(xbath,ybath,zbath,levels,'Color',[0.5 0.5 0.5],'Linewidth',lwb);
    else
        [xbath, ybath] = xy2lonlat(xbath,ybath,lon0,lat0,1);
        [C h_bathy] = contour(xbath,ybath,zbath,levels,'Color',[0.5 0.5 0.5],'Linewidth',lwb);
    end
    clabel(C,h_bathy,'LabelSpacing',500,'FontSize',9,'Color',[0.5 0.5 0.5]);
end


%% Axes limits and aspectratio
if plot_lonlat_xy == 1
    set(gca,'Xlim',lon_lim,'Ylim',lat_lim,'Linewidth',lw);
    set(gca,'Plotboxaspectratio',[1 1*diff(lat_lim)/diff(lon_lim)/cos( 0.5*sum(lat_lim)*pi/180 ) 1]);
    box on;
    axis vis3d
    
    xlabel('Longitude (deg E)','fontsize',fst);
    ylabel('Latitude (deg N)','fontsize',fst);
else
    set(gca,'Xlim',x_lim,'Ylim',y_lim,'Linewidth',lw);
    set(gca,'Plotboxaspectratio',[1 1*diff(y_lim)/diff(x_lim) 1]);
    box on;
    axis vis3d;
    xlabel('Distance (km)','fontsize',fst);
    ylabel('Distance (km)','fontsize',fst);
end
set(gca, 'FontSize', fst,'tickdir','out');


%% Output arguments
if nargout == 2
    varargout{1} = h_coast;
    varargout{2} = h_bathy;
end
