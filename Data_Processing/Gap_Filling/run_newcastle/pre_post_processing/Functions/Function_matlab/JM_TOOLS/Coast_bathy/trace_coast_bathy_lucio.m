
%
% Plots coast and bathymetry
% 


%% Font settings
lw  = 1;        % linewidth of figure box
lwc = 1.5;      % linewidth of coastline
fst = 14;      % fontsize des label des axes


%% Load coast and bathy data
if ~exist('xcot','var')
    load ~/Matlab/outils_oceano/coast_med.mat;
    xcot = coast(:,1);
    ycot = coast(:,2);
end
    
% bathy
if ibath == 1 && ~exist('xbath','var')
    load ~/Matlab/outils_oceano/bathyrelief_med.mat;
    xbath = bathy(:,1);
    ybath = bathy(:,2);
    zbath = bathy(:,3);
    valid = (xbath >= w(1) & xbath <= w(2)) & (ybath >= w(3) & ybath <= w(4));
    xbath = xbath(valid);
    ybath = ybath(valid);
    zbath = zbath(valid);
    xbath_un = unique(xbath);
    ybath_un = unique(ybath);
    xbath = reshape(xbath,[length(xbath_un) length(ybath_un)]);
    ybath = reshape(ybath,[length(xbath_un) length(ybath_un)]);
    zbath = reshape(zbath,[length(xbath_un) length(ybath_un)]);
    clear bathy xbath_un ybath_un
end


%% Plot bathymetry
if ibath == 1
    levels = [-100:-100:-400 -600:-100:-900 -1500 -2500];
    [c h] = contour(xbath,ybath,zbath,levels,'Color',[0.5 0.5 0.5]);
    levels = [-500 -1000 -2000];
    [c h] = contour(xbath,ybath,zbath,levels,'Color',[0.25 0.25 0.25]);
%     levels = [0:-100:-3000]';
%     zbath(zbath >= 0) = NaN;
%     zbath(zbath < min(levels)) = min(levels);
%     cmap = [levels/min(levels) levels/min(levels) ones(length(levels),1)];    
%     hc = contourf(xbath,ybath,zbath,length(levels)-1,'LineStyle','none');
%     cmfit(cmap,[min(levels) 0],levels);
%     c = colorbar;
%     ylabel(c,'Depth (m)');
    hold on;
end

%% Plot coast
plot(xcot,ycot,'k','Linewidth',lwc);


%% Axes limits and aspectratio
set(gca,'Xlim',w(1:2),'Ylim',w(3:4),'Linewidth',lw);
set(gca,'Plotboxaspectratio',[1 1*(w(4)-w(3))/(w(2)-w(1))/cos( 0.5*(w(3)+w(4))*pi/180 ) 1]);
box on;
axis vis3d

set(gca, 'FontSize', fst,'tickdir','out');
xlabel('Long (deg E)','fontsize',fst);
ylabel('Lat (deg N)','fontsize',fst);
