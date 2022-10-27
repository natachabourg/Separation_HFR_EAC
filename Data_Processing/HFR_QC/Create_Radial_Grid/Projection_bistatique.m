%Géometrie_bistatique
% lon_Rx, lon_Tx, lat_Rx, lat_Tx sont les coordonnées lonlat des émetteur
% et récepteur, elles sont définies dans mainTLN.m,  section i_site

resolution = 1500; %resolution in range [meters]

n_porte=100;




%% Initialisation des paramètres géométriques des ellipses

% NB:le range et le azimd il faut que je les trouve moi même dans les fichiers
% netcdf

phi =  azimd(iazimdir);% Secteurs angulaires des cellules radar par rapport à l'est.

R2 = zeros(n_porte,n_dir); % NB: n_porte et n_dir sont le nombre de cases en range et en azimut
R2x = zeros(n_porte,n_dir);
R2y = zeros(n_porte,n_dir);

dx_RxTx = (lon_Rx-lon_Tx)*pi/180*6371*cosd((lat_Rx+lat_Tx)/2);
dy_RxTx = (lat_Rx-lat_Tx)*pi/180*6371;

dist_Tx_Rx = sqrt(dx_RxTx^2+dy_RxTx^2); % Distance émetteur récepteur

angle_Tx_Rx = atan2(dy_RxTx,dx_RxTx)*180/pi;% Angle entre l'Est et le grand axe de l'ellipse (Rx-Tx)
exc = 0.5*dist_Tx_Rx./range; % Excentricité de l'ellipse d'une case distance donnée



%% Positionnement lonlat des cellules radar via la géométrie bistatique.
   % - Calcul de R1 (distance émetteur-cible) et R2 (distance récepteur - cible)
   % - Calcul des positions lonlat des cellules radar
   % - Calcul des vecteurs unitaires normales aux ellipses
   % - Celcul des angles bistatiques

    for i_range = 1:n_porte
        for idir = 1:n_dir
            % calcul de la distance R2 (cible-récepteur)
            R2(i_range,idir) = range(i_range)*(1-exc(i_range)^2)/(1+exc(i_range)*cosd(phi(idir)-angle_Tx_Rx));
            R2x(i_range,idir) = R2(i_range,idir)*cosd(phi(idir));
            R2y(i_range,idir) = R2(i_range,idir)*sind(phi(idir));
        end
    end       
        
deltalatR2 = R2y/6371*180/pi;
deltalonR2 = R2x/6371./cosd(lat_Rx+deltalatR2/2)*180/pi;

latCell = lat_Rx+deltalatR2;
lonCell = lon_Rx+deltalonR2;

deltalonR1 = lonCell-lon_Tx;
deltalatR1 = latCell-lat_Tx;

R1y = deltalatR1*6371*pi/180;
R1x = deltalonR1*6371*pi/180.*cosd((lat_Tx+latCell)/2);
R1 = sqrt(R1x.^2 + R1y.^2);

NormEllx0 = R1x./sqrt(R1x.^2+R1y.^2) + R2x./sqrt(R2x.^2+R2y.^2);
NormElly0 = R1y./sqrt(R1x.^2+R1y.^2) + R2y./sqrt(R2x.^2+R2y.^2);
NormEllx = -NormEllx0./sqrt(NormEllx0.^2+NormElly0.^2);
NormElly = -NormElly0./sqrt(NormEllx0.^2+NormElly0.^2); 

anglebi = real(acosd((R1x.*R2x + R1y.*R2y)./abs(R1.*R2))/2);
FB = sqrt(9.81/(pi*lambda)*cosd(anglebi));

% Masque bistatique pour masquer les erreurs dues à l'angle bistatique trop
% élevé. Seuil fixé : 37 degrés.
masque_anglebi = nan(size(anglebi));
masque_anglebi(anglebi<=37) = 1;
mask = 1;

portemin = find(exc<1,1)+0; % Indice de la première case distance bistatique

clear NormEllx0 NormElly0