%
% d2jul: transforme la date '0107' en julien
% date en entrée '0107' char = 1er juillet
%. Ici : non bissextile
%
function ju=d2jul(date)
nm=[31 28 31 30 31 30 31 31 30 31 30 31]; %année non bissextile  
kju=0;
for j=1:12; for i=1:nm(j);
    kju=kju+1; mo(kju)=j; jo(kju)=i;
end; end
mois=str2num(date(3:4)); jour=str2num(date(1:2));
ju=find(mo==mois&jour==jo);