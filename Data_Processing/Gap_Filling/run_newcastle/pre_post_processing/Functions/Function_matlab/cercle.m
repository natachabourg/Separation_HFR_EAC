% fichier cercle_s
%  calcule les coordonnees des points d'un cercle centre en (xc,yc)
%  de rayon "dist", a l'interieur d'un secteur de d_teta de part et d'autre
%  de l' azimut central du radar dont le reseau est defini par alpha
%  PB 02/2002
%  version geometrie spherique approchee
% PB 11/2006

function  [xt,yt]=cercle(xc,yc,alpha,dist,d_teta)
%       xc et yc xont les longitude et latitude du centre
%       xt et yt sont les longitude et latitude du point courant

deg2rad=pi/180;     % conversion degres-radians
rayon_terre=6370;   % rayon terrestre (km)
km2deg=180/(pi*rayon_terre);    % conversion km-degre
tetacentre=180+alpha;
tetamin=tetacentre-d_teta;tetamax=tetacentre+d_teta;
teta=tetamin:1:tetamax;
xt=xc+km2deg*dist*cos(deg2rad*teta)/cos(deg2rad*yc);
yt=yc+km2deg*dist*sin(deg2rad*teta);
end

