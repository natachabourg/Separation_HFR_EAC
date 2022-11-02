function [ AAAA,MM,DD,hh,mm,ss ] = juliansec2date( sss,AA )
% 4/11/2010
% JM
% Donne la date a partir du nombre de seconde ecoule depuis le debut de
% l'annee de reference.
%   sss= nbre de seconde ecoule
%   AA= annee de reference

if AA==1996||2000||2004||2008||2012||2016
    days_in_prev_months = [0 31 60 91 121 152 182 213 244 274 305 335];
else
    days_in_prev_months = [0 31 59 90 120 151 181 212 243 273 304 334];
end
n=3;
DD=floor(sss/86400);
temp=sss/86400-DD;
temp=round(10^n*temp)/10^n;
hh=floor(temp*24);
temp=temp*24-hh;
mm=round(temp*60);
temp=temp*60-mm;
ss=round(temp);

temp=DD-days_in_prev_months;
temp(temp<0)=[];
MM=length(temp);
DD=DD-days_in_prev_months(MM)+1;

AAAA=AA;


end

