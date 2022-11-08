%
% jul2d: transforme la date en julien en date 01/07
% date en entrée: le julien
% Ici : non bissextile
%
function ju=jul2d(date)
nm=[31 28 31 30 31 30 31 31 30 31 30 31]; %année non bissextile  
kju=0;
for j=1:12; for i=1:nm(j);
    kju=kju+1; mo(kju)=j; jo(kju)=i;
end; end
jour=jo(date); 
if jour<10 jour=['0' num2str(jour)]; 
else; jour=num2str(jour); end
mois=mo(date);
if mois<10 mois=['0' num2str(mois)]; 
else; mois=num2str(mois); end
ju=[jour '/' mois];
