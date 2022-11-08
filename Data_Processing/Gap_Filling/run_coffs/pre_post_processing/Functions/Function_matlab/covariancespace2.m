function [covaruv,umean,vmean] = covariancespace2(u,v)
%%% permet de calculer la variance spatiale
%%% d'une matrice (temps*espace)

[dimt,dimx]=size(u);

for t=1:dimt
   
        umean(t)=sum(u(t,:))/dimx;
   
end

for t=1:dimt
  
        vmean(t)=sum(v(t,:))/dimx;
    
end

for t=1:dimt
   
        covaruv(t)=sum((u(t,:)-umean(t)).*(v(t,:)-vmean(t)));
    
end
covaruv=covaruv/(dimx-1);

return
end