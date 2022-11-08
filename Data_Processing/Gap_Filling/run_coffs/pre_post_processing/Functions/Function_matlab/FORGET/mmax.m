% mmax: max(max)
function  [b imax jmax]=mmax(a);
b=max(max(a));
for i=1:size(a,1)
    for j=1:size(a,2)
        if b==a(i,j) imax=i; jmax=j; end
    end
end
