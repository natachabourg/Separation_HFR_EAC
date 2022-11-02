function [varu,umean] = variancespace2(u)
%%% permet de calculer la variance spatiale
%%% d'une matrice (temps*espace)

[dimt,dimx]=size(u);

for t=1:dimt
    
        umean(t)=sum(u(t,:))/dimx;
    
end
for t=1:dimt
    
        varu(t)=sum((u(t,:)-umean(t)).^2);
    
end
varu=varu/(dimx-1);

return
end