% trace_cotes_bathy.m. Comme le nom l'indique
% script pour nce_2.m & test_filtrage_fft.m

%Chargement des cotes et de la bathy
if exist('xcot')==0
    
    % cotes
%    cotes=load('/home/marmain/Data/BATHY_COAST/cotes253.dat');
     cotes=load('/home/molcard/RADAR/BATHY_COAST/cotes_global.dat');
    xcot=cotes(:,1);ycot=cotes(:,2);
    
    %     % bathy
    %     if map.plot_bath==0
    %         fiche='/home/marmain/Data/BATHY_COAST/GLazur_bath3.nc';
    %         nc=netcdf.open(fiche,'NC_NOWRITE');
    %         lon_bath=nc_new2old(netcdf.getvar(nc,0));
    %         lat_bath=nc_new2old(netcdf.getvar(nc,1));
    %         prof=nc_new2old(netcdf.getvar(nc,4));
    %     end
    
    % bathy
    if map.plot_bath==1
        %fiche='/home/marmain/Data/BATHY_COAST/BathyMed_3km_ZoomMedoc.nc';
        fiche='/home/molcard/Bureau/CARTO_RADAR/BATHY_COAST/BathyMed_3km.nc';
        lon_bath=ncread(fiche,'lon');
        lat_bath=ncread(fiche,'lat');
        prof=ncread(fiche,'topo');
    end
    
    if map.plot_land==1
        fiche='/home/molcard/Bureau/CARTO_RADAR/BATHY_COAST/BathyMed_3km_ZoomMedoc.nc';
        lon_land=ncread(fiche,'lon');
        lat_land=ncread(fiche,'lat');
        topo=ncread(fiche,'topo');
        
        topo(topo<0)=NaN;
        topo(isnan(topo)==0)=1;
        
    end
    
    
end

% trac� des cotes et de la bathy



plot(xcot,ycot,'k','linewidth',plot_param.lwc); hold on

set(gca,'xlim',map.lon_lim,'ylim',map.lat_lim,'linewidth',plot_param.lw);
set(gca,'plotboxaspectratio', ...
    [1 1*(map.lat_lim(2)-map.lat_lim(1))/(map.lon_lim(2)-map.lon_lim(1))/cos(d2r(0.5*(map.lat_lim(1)+map.lat_lim(2)))) 1]);
box on



if map.plot_bath==1
    %[c h]=contour(lon_bath,lat_bath,prof,map.bath_levels,'k');
    
    [c_bathy h_bathy]=contour(lon_bath,lat_bath,prof,map.bath_levels,'Color',[0.5 0.5 0.5],'Linewidth',plot_param.lwb);

    hold on
    %     h1=clabel(c,h);
    %     for i=1:length(h1);
    %         set(h1(i),'fontsize',plot_param.fsb,'fontweight','bold');
    %     end
    %clabel(c_bathy,h_bathy,'LabelSpacing',300,'FontSize',9,'Color',[0.5 0.5 0.5],'Rotation',0);
    
    %clabel(c_bathy,h_bathy,'manual','FontSize',9,'Color',[0.5 0.5 0.5],'Rotation',0)
end

if map.plot_land==1
    
    axh=pcolor(lon_land,lat_land,topo); shading flat
    colormap([1 0.9 0.7]);freezeColors(axh)
    
end

