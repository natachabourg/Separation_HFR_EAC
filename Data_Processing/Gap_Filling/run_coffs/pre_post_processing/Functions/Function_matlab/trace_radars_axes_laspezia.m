%%% JM
%%% 15/12/2010
%%% tracé des radar et axe latéraux
%%% pour la spezia

lwl=2;                  %linewidth des axes radar lateraux



  %%%% trace des cones radar
    %%% i_station=1;
    x11=(0:.1:dmax1)*cos(d2r((phi1+180)-dtetamax1));
    y11=(0:.1:dmax1)*sin(d2r((phi1+180)-dtetamax1));
    x11=x11+x1; y11=y11+y1; 
     plot(x11,y11,'k','linewidth',lwl);
      x11=(0:.1:dmax1)*cos(d2r((phi1+180)+dtetamax1));
    y11=(0:.1:dmax1)*sin(d2r((phi1+180)+dtetamax1));
    x11=x11+x1; y11=y11+y1; 
     plot(x11,y11,'k','linewidth',lwl);
     
     
%%% i_station=2;
dtetamax2=dtetamax2+5
    x11=(0:.1:dmax2)*cos(d2r((phi2+180)-dtetamax2));
    y11=(0:.1:dmax2)*sin(d2r((phi2+180)-dtetamax2));
       x11=x11+x2; y11=y11+y2; 
     plot(x11,y11,'k','linewidth',lwl);
      x11=(0:.1:dmax2)*cos(d2r((phi2+180)+dtetamax2));
    y11=(0:.1:dmax2)*sin(d2r((phi2+180)+dtetamax2));
    x11=x11+x2; y11=y11+y2; 
     plot(x11,y11,'k','linewidth',lwl);

