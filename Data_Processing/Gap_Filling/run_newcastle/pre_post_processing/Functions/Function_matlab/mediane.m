function  imfil  = mediane(im,N )
[maxi,maxj]=size(im);
imfil=im;
k=floor(N/2);
for i=1+k:maxi-k
    for j=1+k:maxj-k
        x=im(i-k:i+k,j-k:j+k);
        x=reshape(x,1,N^2);%vecteur
        x(isnan(x)==1)=[];
        imfil(i,j)=median(x);
    end
end
end

