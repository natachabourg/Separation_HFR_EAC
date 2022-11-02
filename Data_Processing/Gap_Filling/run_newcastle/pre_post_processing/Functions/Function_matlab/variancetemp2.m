function [varu,umean] = variancetemp2(u)
%%% permet de calculer la variance temporelle
%%% d'une matrice (temps*espace)

[dimt,dimx]=size(u);

for x=1:dimx
    
        umean(x)=sum(u(:,x))/dimt;
    
end
for x=1:dimx
    
        varu(x)=sum((u(:,x)-umean(x)).^2);
    
end
varu=varu/(dimt-1);

return
end