% nc_new2old: utilitaire permettant de travailler avec les conventions d'avant.
% pour faire en sorte que netcdf(fiche) donne des tableaux
% compatibles avec l'ancien netcdf.
% ex. un tableau a(tps,nlat,nlon) est normalement lu par netcdf-mex
% (version native matlab 2008) comme: a(nlon,nlat,tps). Ce programme
% inverse donc les sorties.
% entrée: nom du fichier netcdf fiche 
% sortie: caractéristiques de fiche

function y=nc_new2old(z)

a=[];for i=ndims(z):-1:1 a=[a i]; end
y=permute(z,a);