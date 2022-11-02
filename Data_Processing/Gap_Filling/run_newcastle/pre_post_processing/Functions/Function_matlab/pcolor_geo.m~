
% pcolor_geographique.m
% Trace des carres centrés sur les points x,y et d'intensité
%   cont=0: contour des pixels en blanc
%        1: contour en noir
%   zmin,zmax: du caxis
%   icolbar: =  0   : pas de colorbar
%             sinon : colorbar
% PF 26/3/8
%
function temp=pcolor_geo(x,y,z,cont,zmin,zmax,icolbar)
global hcolbar      %get(hcolbar): les paramètres du colorbar

dy=max(max(diff(y)));  %resolution
dx=max(max(diff(x)));  %resolution
ds2y=dy/2
ds2x=dx/2
[n m]=size(z);
% pour ne faire le calcul que là où ce n'est pas nan
masque=(x.*y).*z;
masque(isnan(masque)==0)=1;
masque(isnan(masque)==1)=0;
% contour des pixels
if cont==1; coul='k'; else; coul='w';end
for i=1:n
    for j=1:m
        if masque(i,j)==1
            h=rectangle('position',[x(i,j)-ds2x,y(i,j)-ds2y,dx,dy]); 
            bidon=jet;
            indice=floor(64*(z(i,j)-zmin)/(zmax-zmin))+1;
            if indice>64;indice=64;end
            if indice<=0 ;indice=1; end
            qq=num2str(indice);
            if length(qq)>3;qq=qq(1:3);end
            if length(qq)==2;qq=[qq '0'];end
            if length(qq)==1;qq=[qq '0' '0'];end
            if qq=='NaN'; indice=1;end
            couleur=bidon(indice,:);
            set(h,'edgecolor',coul,'FaceColor',couleur);
        end
    end
end
caxis([zmin zmax])
if icolbar~=0 hcolbar=colorbar; end
temp=1;

end

