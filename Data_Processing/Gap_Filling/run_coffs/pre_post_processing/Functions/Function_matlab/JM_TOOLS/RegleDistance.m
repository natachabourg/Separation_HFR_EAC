function [ lon_regle,lat_regle ] = RegleDistance( dl,nb_dl,lon_ori,lat_ori,inclinaison,regleWidth )
% MARMAIN - 2014/02/10
% RegleDistance.m
%   trace une regle en km
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%dl             en km
%nb_dl          nb de portion a tracer
%lon_ori        en deg
%lat_ori        en deg
%inclinaison    'vertical';'horizontal';
%regleWidth     largeur de la regle
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if strcmp(inclinaison,'vertical')==1  
    xregle=zeros(1,nb_dl+1);
    yregle=0:dl:nb_dl*dl;
end
if strcmp(inclinaison,'horizontal')==1
    xregle=0:dl:nb_dl*dl;
    yregle=zeros(1,nb_dl+1);
end

[lon_regle,lat_regle]=xylonlat(xregle,yregle,lon_ori,lat_ori,2);  %%% lat/lon

for iregle=1:nb_dl
    if mod(iregle,2) == 1  %%% noir
        plot(lon_regle(iregle:iregle+1),lat_regle(iregle:iregle+1),'k-','linewidth',regleWidth)
    else
        plot(lon_regle(iregle:iregle+1),lat_regle(iregle:iregle+1),'-','color',[0.8 0.8 0.8],'linewidth',regleWidth)
    end
end


end

