function [covaruv,umean,vmean] = covariancetemp2(u,v)
%%% permet de calculer la variance temporelle
%%% d'une matrice (temps*espace)

[dimt,dimx]=size(u);

for x=1:dimx
   
        umean(x)=sum(u(:,x))/dimt;
   
end

for x=1:dimx
  
        vmean(x)=sum(v(:,x))/dimt;
    
end

for x=1:dimx
   
        covaruv(x)=sum((u(:,x)-umean(x)).*(v(:,x)-vmean(x)));
    
end
covaruv=covaruv/(dimt-1);

return
end