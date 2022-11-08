function [ div ] = divergence_JM(Uc,Vc,x,y)
%Calcul de la divergence avec un schema centré



[dimy,dimx]=size(Uc);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%% dérivation schéma centré %%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for i=2:dimx-1
    for j=1:dimy
        dxu(j,i)=(Uc(j,i+1)-Uc(j,i-1))/(x(j,i+1)-x(j,i-1));
    end
end
dxu(:,1)=dxu(:,2);
dxu(:,dimx)=dxu(:,dimx-1);

for i=1:dimx
    for j=2:dimy-1
        dyv(j,i)=(Vc(j+1,i)-Vc(j-1,i))/(y(j+1,i)-y(j-1,i));
    end
end
dyv(1,:)=dyv(2,:);
dyv(dimy,:)=dyv(dimy-1,:);

for i=1:dimx
    for j=2:dimy-1
        dyu(j,i)=(Uc(j+1,i)-Uc(j-1,i))/(y(j+1,i)-y(j-1,i));
    end
end
dyu(1,:)=dyu(2,:);
dyu(dimy,:)=dyu(dimy-1,:);

for i=2:dimx-1
    for j=1:dimy
        dxv(j,i)=(Vc(j,i+1)-Vc(j,i-1))/(x(j,i+1)-x(j,i-1));
    end
end
dxv(:,1)=dxv(:,2);
dxv(:,dimx)=dxv(:,dimx-1);

div=dxu+dxv;

return
end

