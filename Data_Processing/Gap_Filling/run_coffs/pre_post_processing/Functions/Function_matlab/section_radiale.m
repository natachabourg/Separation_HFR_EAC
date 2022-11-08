function [ secrad,distance ] = section_radiale( param,X,Y,lon,lat) 
% Permet d'obtenir une section verticale le long d'une radiale determinee
% par X,Y, pour un temps donné.


[dimz,dimy,dimx]=size(param);

dsample=100;%1000;% Distance d'echantillonnage

dX=(X(2)-X(1))/dsample;
dY=(Y(2)-Y(1))/dsample;

if X(1)==X(2)
    X1=X(1);
else X1=X(1):dX:X(2);
end
if Y(1)==Y(2)
    Y1=Y(1);
else Y1=Y(1):dY:Y(2);
end

distance=111.12*sqrt(dX.*dX+dY.*dY);

for z=1:dimz
   
     p=reshape(param(z,:,:),dimy,dimx);
     
     secrad(z,:)=interp2(lon,lat,p,X1,Y1);
end


return
end

