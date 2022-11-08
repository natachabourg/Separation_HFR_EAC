function [covaruv,umean,vmean] = covariancetemp(u,v)
%%% permet de calculer la variance temporelle
%%% d'une matrice (temps*lat*lon)

[dimt,dimy,dimx]=size(u);

for x=1:dimx
    for y=1:dimy
        umean(y,x)=sum(u(:,y,x))/dimt;
    end
end

for x=1:dimx
    for y=1:dimy
        vmean(y,x)=sum(v(:,y,x))/dimt;
    end
end

for x=1:dimx
    for y=1:dimy
        covaruv(y,x)=sum((u(:,y,x)-umean(y,x)).*(v(:,y,x)-vmean(y,x)));
    end
end
covaruv=covaruv/(dimt-1);

return
end