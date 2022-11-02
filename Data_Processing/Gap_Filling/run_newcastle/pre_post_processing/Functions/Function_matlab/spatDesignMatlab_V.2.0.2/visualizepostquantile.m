function postquantile=visualizepostquantile(quant,predictivedist,ncontours,gridsize)
%
%  Copyright (C) 2009 Gunter Spöck, email: gunter.spoeck@uni-klu.ac.at
%
%  This program is free software; you can redistribute it and/or modify it
%  under the terms of the GNU General Public License as published by the
%  Free Software Foundation; either version 2 of the License, or (at your
%  option) any later version.
%
%  This program is distributed in the hope that it will be useful,
%  but WITHOUT ANY WARRANTY; without even the implied warranty of
%  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
%  See the GNU General Public License for more details.
%
%  You should have received a copy of the GNU General Public License along
%  with this program; if not, write to the Free Software Foundation, Inc.,
%  51 Franklin St, Fifth Floor, Boston, MA  02110-1301 USA
%
%  On Debian GNU/Linux systems, the complete text of the GNU General
%  Public License can be found in /usr/share/common-licenses/GPL-2.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  postquantile=visualizepostquantile(quant,predictivedist,ncontours,gridsize)
%
%  visualizes the quantiles of the predictive distribution  from trans-
%  Gaussian kriging.
%
%  Input:
%
%  quant................the quantiles
%
%  predictivedist.......object from transGaussiankrigingongrid.m 
%
%  ncontours............the number of contours
%
%  gridsize.............the size of the grid for cubic spline interpolation
%
%  Output:
%
%  postquantile.modal...the modal value of the predictive distribution
%
%  postquantile.median..the median of the predictive distribution
%
%  postquantile.mean....the mean of the predictive distribution;
%
%  postquantile.std.....the standard deviation of the predictive density
%
%  postquantile.quantiles...the quantiles
%
%  postquantile.percent.....the quantiles
%
%  Example:
%
%  postquantileBoxGomelaniso=visualizepostquantile([0.05,0.25,0.75,0.9],predictivedistBoxGomelaniso,8,3);
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
grid=predictivedist.grid;
xx=predictivedist.x;
int=xx(2)-xx(1);
x=grid.x(~isnan(grid.x));
y=grid.y(~isnan(grid.y));
[xi,yi] = meshgrid(min(x):gridsize:max(x),min(y):gridsize:max(y));
ppredictivedist=predictivedist.predictive;
n=size(ppredictivedist,1);
   
for i=1:n
    i 
    ppredictivedist(i,:)=ppredictivedist(i,:)/sum(ppredictivedist(i,:));
    cumdistribfunction(i,:)=cumsum(ppredictivedist(i,:));
    indmedian=max(find(cumdistribfunction(i,:)<=0.5));
    indmodal=find(ppredictivedist(i,:)==max(ppredictivedist(i,:)));
    if ~isempty(indmedian)
    median(i)=xx(indmedian(1));
    else
    median(i)=NaN;
    end
    if ~isempty(indmodal)
    modal(i)=xx(indmodal(1));
    else
    modal(i)=NaN;
    end
    mean1(i)=sum(ppredictivedist(i,:).*xx);
    std(i)=sqrt(sum(ppredictivedist(i,:).*(xx.^2))-mean1(i)^2); 
    for j=1:length(quant)
    ind=max(find(cumdistribfunction(i,:)<=quant(j)));
    if ~isempty(ind)
       quantil1(i,j)=xx(ind(1));
    else
       quantil1(i,j)=NaN;
    end
    end
end
    
    quant1=quantil1(~isnan(grid.x),:);
for j=1:length(quant)
    figure()
    quant11 = griddata(x,y,quant1(:,j),xi,yi,'cubic'); 
    contourf(xi,yi,quant11,ncontours)
    title([num2str(quant(j)),'-quantile'])
    colorbar
end
    
figure()
mean12=mean1(~isnan(grid.x));
mean11 = griddata(x,y,mean12,xi,yi,'cubic'); 
contourf(xi,yi,mean11,ncontours)
colorbar
title('mean')

figure()
modal1=modal(~isnan(grid.x));
modal11 = griddata(x,y,modal1,xi,yi,'cubic'); 
contourf(xi,yi,modal11,ncontours)
colorbar
title('modal value')

figure()
median1=median(~isnan(grid.x));
median11 = griddata(x,y,median1,xi,yi,'cubic'); 
contourf(xi,yi,median11,ncontours)
colorbar
title('median')

figure()
std1=std(~isnan(grid.x));
std11 = griddata(x,y,std1,xi,yi,'cubic'); 
contourf(xi,yi,std11,ncontours)
colorbar
title('standard deviation')

postquantile.modal=modal;
postquantile.median=median;
postquantile.mean=mean1;
postquantile.std=std;
postquantile.quantiles=quantil1;
postquantile.percent=100*quant;
 
    
   