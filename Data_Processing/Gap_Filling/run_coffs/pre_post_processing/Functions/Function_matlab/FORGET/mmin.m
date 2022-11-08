% mmin: min(min)
function  [b imin jmin]=mmin(a);
b=min(min(a));
for i=1:size(a,1)
    for j=1:size(a,2)
        if b==a(i,j) imin=i; jmin=j; end
    end
end