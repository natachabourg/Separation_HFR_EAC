% fichier rayon_s
%  calcule les coordonnees approximatives des extremites des rayons
%  d'un cercle centre en (xc,yc) de rayon "dist", 
% PB 02/2002
% version geometrie spherique
% PB 11/2006

    function  [xr,yr]=rayon_s(xc,yc,alpha,dist,i,d_teta)
%    INPUT
%       xc,yc: longitude et latitude du centre
%       alpha: angle de pointage du reseau
%       dist: rayon du cercle
%       d_teta: demi-ouverture du cercle
%    OUTPUT
%       xr,yr: longitude et latitude du point
   
    deg2rad=pi/180;    % conversion degres-radians
    rayon_terre=6370;   % rayon terrestre (km)
    km2deg=180/(pi*rayon_terre);    % conversion km-degre
    tetacentre=180+alpha;
    teta=tetacentre+(2*i-3)*d_teta;
    xr=xc+km2deg*dist*cos(deg2rad*teta)/cos(deg2rad*yc);
    yr=yc+km2deg*dist*sin(deg2rad*teta);
end

