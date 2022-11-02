function [varu,umean] = variancetemp_nan(u)
%%% JM 2010
%%% permet de calculer la moyenne et variance temporelle
%%% d'une matrice (temps*lat*lon)
%%% Donne une carte de moyenne et variance en sortie
%%% Permet de traiter les cas avec des valeurs Nan

[dimt,dimy,dimx]=size(u);

for x=1:dimx
    for y=1:dimy
        temp=u(:,y,x); temp(isnan(temp)==1)=[];
        umean(y,x)=mean(temp);
    end
end
for x=1:dimx
    for y=1:dimy
        temp=u(:,y,x); temp(isnan(temp)==1)=[];
        varu(y,x)=sum((temp-umean(y,x)).^2);
    end
end
varu=varu/(dimt-1);

return
end
