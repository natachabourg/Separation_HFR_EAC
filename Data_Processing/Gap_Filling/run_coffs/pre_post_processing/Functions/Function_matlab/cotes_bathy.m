%%% JM
%%% 31/03/2010
%%% script pour tracer les côtes et la bathy
%%% recadrage sur la zone définie par w, et conservation des proportions

%%% lon/lat ou km

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%   
lonlat=1;  %% lon/lat=1; km=0;
ibath=0;
lw=1;                   %linewidth du gca
lwc=1.5;                %linewidth des cotes
fsb=10;                 %fontsize des labels de bathy
levels=[130 1000 2000 ];%2300 2500 2600 2700];    %isobathes
% cotes et bathy

if lonlat==1
    
plot(xcot,ycot,'k','linewidth',lwc); hold on

if ibath==1
[c h]=contour(lon_bath,lat_bath,prof,levels,'k');hold on
    h1=clabel(c,h);
    for iba=1:length(h1);
        set(h1(iba),'fontsize',fsb,'fontweight','bold');
    end
end

a=get(gca,'plotboxaspectratio');
set(gca,'plotboxaspectratio', ...
    [a(1) a(2)*(w(4)-w(3))/(w(2)-w(1))/cos(d2r(0.5*(w(3)+w(4)))) a(3)]);
set(gca,'xlim',w(1:2),'ylim',w(3:4),'linewidth',lw);
box on

end

if lonlat==0
    
    plot(xcot,ycot,'k','linewidth',lwc); hold on
    
    if ibath==1
        [c h]=contour(lon_bath,lat_bath,prof,levels,'k');hold on
%         h1=clabel(c,h);
%         for iba=1:length(h1);
%             set(h1(iba),'fontsize',fsb,'fontweight','bold');
%         end
    end
    
% a=get(gca,'plotboxaspectratio');
% set(gca,'plotboxaspectratio', ...
%     [a(1) a(2)*(w(4)-w(3))/(w(2)-w(1))/cos(d2r(0.5*(w(3)+w(4)))) a(3)]);
set(gca,'xlim',w(1:2),'ylim',w(3:4),'linewidth',lw);
box on

end

 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%   
