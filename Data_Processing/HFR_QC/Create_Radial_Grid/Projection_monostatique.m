%Géometrie_bistatique

% lon_Rx, lon_Tx, lat_Rx, lat_Tx sont les coordonnées lonlat des émetteur
% et récepteur, elles sont définies dans mainTLN.m,  section i_site
%Pour RRK :

lon_Rx = 115.746;
lat_Rx = -32.031;

resolution = 1.5;%km en range
n_porte = 70; %calcul d'apothicaire 100/1.5=67
n_dir

%% Initialisation des paramètres

phi =  azimd(iazimdir);% Secteurs angulaires des cellules radar par rapport à l'est.
R = zeros(n_porte,n_dir);
Rx = zeros(n_porte,n_dir);
Ry = zeros(n_porte,n_dir);

%% Positionnement lonlat des cellules radar.
    for i_range = 1:n_range
        for idir = 1:n_dir
            % calcul de la distance R2 (cible-récepteur)
            R(i_range,idir) = resolution*(i_range-1);
            Rx(i_range,idir) = R(i_range,idir)*cosd(phi(idir));
            Ry(i_range,idir) = R(i_range,idir)*sind(phi(idir));
        end
    end       
        
deltalatR = Ry/6371*180/pi;
deltalonR = Rx/6371./cosd(lat_Rx+deltalatR/2)*180/pi;

latCell = lat_Rx+deltalatR;
lonCell = lon_Rx+deltalonR;

NormEllx = -Rx./sqrt(Rx.^2+Ry.^2);
NormElly = -Ry./sqrt(Rx.^2+Ry.^2); 

anglebi = zeros(n_porte,n_dir);
FB = sqrt(9.81/(pi*lambda)*cosd(anglebi));
mask = 1;


% compatibilité avec le masque bistatique
masque_anglebi = 1;
portemin = 1; % Indice de la première case distance bistatique