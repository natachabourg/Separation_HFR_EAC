% lec_cou.m
% lecture du fichier *.cou
% en entree: le fichier
% en sortie: distances-teta-courant

function [dist teta cou]=lec_cou(fich)
courant=dlmread(fich);
dist=courant(2:end,1);
teta=courant(1,2:end); 
teta=teta';
cou=courant(2:end,2:end);
