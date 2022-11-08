%%% JM
%%% 30/03/2010
%%% tracé des radar et axe latéraux

msr=20;                 %markersize des radars
lwl=2;                  %linewidth des axes radar lateraux

for irad=i_station:i_station
   % plot(lonrad(irad),latrad(irad),'kv','markersize',msr);
   plot(lonrad(irad),latrad(irad),'v','markersize',msr,'MarkerEdgeColor','k',...
                'MarkerFaceColor','k');
    x11=(0:.1:portee(irad))*cos(d2r(visee(irad)-azmin));
    y11=(0:.1:portee(irad))*sin(d2r(visee(irad)-azmin));
    lat11=latrad(irad)+y11/111.12;
    lon11=lonrad(irad)+x11./(111.12*cos(d2r(lat11)));
    plot(lon11,lat11,'k','linewidth',lwl);
    x11=(0:portee(irad))*cos(d2r(visee(irad)+azmin));
    y11=(0:portee(irad))*sin(d2r(visee(irad)+azmin));
    lat11=latrad(irad)+y11/111.12;
    lon11=lonrad(irad)+x11./(111.12*cos(d2r(lat11)));
    plot(lon11,lat11,'k','linewidth',lwl);
    
    %%% pour représenter l'arc de cercle
    delta_teta=2;  %%%résolution angulaire en degré
    dist=portee(irad);
    teta=-azmin:delta_teta:azmin;
    x11=dist'*cos(d2r(visee(irad)+teta));
    y11=dist'*sin(d2r(visee(irad)+teta));
    lat11=latrad(irad)+y11/111.12;
    lon11=lonrad(irad)+x11./(111.12*cos(d2r(lat11)));
    plot(lon11,lat11,'k','linewidth',lwl);
    
end

