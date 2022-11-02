% ecr_cou.m
% ecriture sur "fichier" des angles,distances,courants

function ecr_cou(fichier,teta,dist,courant)


n_teta=length(teta);
n_dist=length(dist);
tmp=nan(size(courant)+1);
tmp(2:n_dist+1,1)=dist';
tmp(1,2:n_teta+1)=teta;
tmp(2:n_dist+1,2:n_teta+1)=courant;
dlmwrite(fichier,tmp,' ')


end