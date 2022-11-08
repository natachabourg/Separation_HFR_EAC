%programmes de
%http://www.wam.umd.edu/~toh/spectrum/InteractiveSmoothing.htm

% après essais (voir testliss.m), je choisis la boxcar qui me parait etre
% mieux (voir l'exemple avec nliss=2)


% % liss.m
% %********
% %Lissage de y(x) sur un certain nombre de points nb
% function SmoothY=liss(Y,smoothwidth)
% % function SmoothY=fastsmooth(Y,smoothwidth)
% %  fastsmooth(Y,w) smooths vector Y by triangular
% % smooth of width = smoothwidth. Works well with signals up to 
% % 100,000 points in length and smooth widths up to 1000 points. 
% % Faster than tsmooth for smooth widths above 600 points.
% %  T. C. O'Haver, 2006.
% w=round(smoothwidth);
% SumPoints=sum(Y(1:w));
% s=zeros(size(Y));
% halfw=round(w/2);
% for k=1:length(Y)-w,
%    s(k+halfw)=SumPoints;
%    SumPoints=SumPoints-Y(k);
%    SumPoints=SumPoints+Y(k+w);
% end
% s=s./w;
% SumPoints=sum(s(1:w));
% SmoothY=zeros(size(s));
% for k=1:length(s)-w,
%    SmoothY(k+halfw)=SumPoints;
%    SumPoints=SumPoints-s(k);
%    SumPoints=SumPoints+s(k+w);
% end
% SmoothY=SmoothY./w;



function s=liss(a,w)
%  Convolution-based boxcar smooth
% bsmooth(a,w) smooths vector a by a boxcar (rectangular window) of width w
%  T. C. O'Haver, 1988.
s=a;
if w>0
v=ones(1,w);%boxcar(w);
S=conv(a,v);
startpoint=round((length(v) + 1)/2);
endpoint=round(length(a)+startpoint-1);
s=S(startpoint:endpoint) ./ sum(v);
end
