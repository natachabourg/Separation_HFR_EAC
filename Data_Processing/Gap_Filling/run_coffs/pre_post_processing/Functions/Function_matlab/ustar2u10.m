% Conversion ustar en u10
% Utilisation de la formule de Lee 1996
% entrée: ustar en m/s
% sortie: u10 en m/s
function u10=ustar2u10(ustar)
ustar=ustar*100;
z0=0.684./ustar+4.28e-5*ustar.*ustar-0.0443;   %en cm
u10=(ustar/100/0.41).*log(1000./z0); %1000:10m en cm