%%% JM
%%% 30/03/2010
%%% tracé des radar et axe latéraux

msr=10;                 %markersize des radars
lwl=2;                  %linewidth des axes radar lateraux

if i_km==1  %%% en km
    for irad=i_station:i_station
       
        plot(xrad0(irad),yrad0(irad),'v','markersize',msr,'MarkerEdgeColor','k',...
            'MarkerFaceColor','k');
        plot(xkm2(:,i_azmin(irad)),ykm2(:,i_azmin(irad)),'k','linewidth',lwl);
        plot(xkm2(:,i_azmax(irad)),ykm2(:,i_azmax(irad)),'k','linewidth',lwl);
        plot(xkm2(end,i_azmin(irad):i_azmax(irad)),ykm2(end,i_azmin(irad):i_azmax(irad)),'k','linewidth',lwl);
           
    end
    
else  %%% lon/lat
    
    for irad=i_station:i_station

        plot(lonrad(irad),latrad(irad),'v','markersize',msr,'MarkerEdgeColor','k',...
            'MarkerFaceColor','k');  
        plot(lon2(:,i_azmin(irad)),lat2(:,i_azmin(irad)),'k','linewidth',lwl);
        plot(lon2(:,i_azmax(irad)),lat2(:,i_azmax(irad)),'k','linewidth',lwl);
        plot(lon2(end,i_azmin(irad):i_azmax(irad)),lat2(end,i_azmin(irad):i_azmax(irad)),'k','linewidth',lwl);
        
    end
    
end