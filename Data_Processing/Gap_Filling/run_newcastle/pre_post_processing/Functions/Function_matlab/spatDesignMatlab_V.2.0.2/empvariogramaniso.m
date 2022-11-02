function empvario= empvariogramaniso(x,y,z,lagclass,nphi)
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
%  empvario=empvariogramaniso(x,y,z,lagclass,nphi)
%
%  calculates the empirical anisotropic variogram.
%
%  Inputs:
%
%  x.................column vector containing the x-coordinates of the  data
%
%  y.................column vector containing the y-coordinates of the data
%
%  z.................column vector containing the concentrations 
%
%  lagclass..........a row vector giving the lag-distances 
%
%  nphi..............a number giving the number of lagclasses in
%                    direction of the angle
%
%  Outputs:
%
%  empvario.v........vector containing the mean squared differences of 
%                    the concentrations
%
%  empvario.laghx....the x-coordinates of the estimated anisotropic variogram
%
%  empvario.laghy....the y-coordinates of the estimated anisotropic variogram
%
%  empvario.n........the number of squared differences in the different lag-angle classes
%
%  empvario.num......the number of samples
%
%  empvario.var......the estimate of the total sill
%
%  Example:
% 
%  empvariogramaniso(BoxGomeliso.x,BoxGomeliso.y,BoxGomeliso.z,0:10:150,15);
%
%  empvarioBoxGomelaniso=empvariogramaniso(Gomel.x,Gomel.y,BoxGomelaniso.z,0:10:150,15);
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
warning off MATLAB:divideByZero
Pi=4*atan(1);
lagclassphi=0:2*Pi/nphi:2*Pi; 
n=length(x);
empvario.var=sum((z-mean(z)).^2)/(n-1); 
k=0;
empvario.num=n;
for i=1:n
    k=k+1; 
    h(k,:)=dist(x(i),y(i),x,y)';
    squareddiff(k,:)=real((z(i)-z).^2)';
end

k=0;

%Calculating the angle lagclasses
for i=1:n
    k=k+1;
    diff{k}=[x(i)*ones(1,n);y(i)*ones(1,n)]-[x';y'];
    for j=1:n
       phi(k,j)=arctan(diff{k}(1,j),diff{k}(2,j));
    end
end

h=h(:);
squareddiff=squareddiff(:);
phi=phi(:);
[h,ind]=sort(h);
squareddiff=squareddiff(ind);
phi=phi(ind);

clear ind

nlc=length(lagclass);
for i=1:nlc-1
   for j=1:nphi-1
      ind=find((h>lagclass(i) & h<=lagclass(i+1) & phi>lagclassphi(j) & phi<=lagclassphi(j+1)));
      v(i,j)=mean(squareddiff(ind))/2; % Empirical Variogram Estimate
      n(i,j)=length(ind);
      lagh(i,j)=mean(h(ind));          % Lag Distance for a lagclass
      lagphi(i,j)=mean(phi(ind));
      xx(i,j)=lagh(i,j)*cos(lagphi(i,j));
      yy(i,j)=lagh(i,j)*sin(lagphi(i,j));
   end
end
v=v(:);
n=n(:);
xx=xx(:);
yy=yy(:);
ind=find(~isnan(xx)&~isnan(yy)&isfinite(xx)&isfinite(yy));
v=v(ind);
n=n(ind);
xx=xx(ind);
yy=yy(ind);


lagh=lagh(:);
lagh=lagh(ind);
lagh=sort(lagh);


empvario.v=v;
empvario.laghx=xx;
empvario.laghy=yy;
empvario.lagh=lagh;
empvario.n=n;

%Code for plotting the Empirical Variogram(commented):
figure(2)
[xi,yi] = meshgrid(-lagh(end):2*lagh(end)/49:lagh(end),-lagh(end):2*lagh(end)/49:lagh(end));
zi = griddata(empvario.laghx,empvario.laghy,empvario.v,xi,yi,'cubic'); 
%zi = griddata(empvario.laghx,empvario.laghy,empvario.v,xi,yi,'v4'); 
contour(xi,yi,zi,15)
title('empirical semivariogram')
colorbar
figure(3)
mesh(xi,yi,zi)
hold on;
plot3(empvario.laghx,empvario.laghy,empvario.v,'o');
title('empirical semivariogram')

function h=dist(x1,y1,x2,y2)
h=sqrt((x1-x2).^2+(y1-y2).^2);

function phi=arctan(x,y)
%
%  phi=arctan(x,y)
%
%  calculates the Arcus Tangens.
%
%  Copyright: Gunter Sp�ck, November 2004
%
if x==0
    x=0.0000000000000001;
end
if x>=0 & y>=0
   phi=atan(y/x);
elseif x<=0 & y>=0
   phi=pi-atan(y/(-x));
elseif x<=0 & y<=0
   phi=pi+atan(-y/-x);
elseif x>=0 &y<=0
   phi=2*pi-atan(-y/x);
end
