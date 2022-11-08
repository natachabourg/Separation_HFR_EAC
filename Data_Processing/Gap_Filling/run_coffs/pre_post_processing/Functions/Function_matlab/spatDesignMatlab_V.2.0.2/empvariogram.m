function empvario= empvariogram(x,y,z,lagclass)
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
%  empvario=empvariogram(x,y,z,lagclass)
%
%  calculates the empirical isotropic variogram.
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
%  Outputs:
%
%  empvario.v........vector containing the mean squared differences of 
%                    the concentrations
%
%  empvario.lagh.....the average lag-distances
%
%  empvario.n........the number of squared differences in the different lag-classes
%
%  empvario.num......the number of samples
%
%  empvario.var......the estimate of the total sill
%
%  Example:
%
%  empvarioBoxGomeliso= empvariogram(BoxGomeliso.x,BoxGomeliso.y,BoxGomeliso.z, 0:5:150);
%  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
n=length(x);
empvario.var=sum((z-mean(z)).^2)/(n-1);
k=0;
empvario.num=n;
for i=1:n
    k=k+1; 
    h(k,:)=dist(x(i),y(i),x,y)';
    squareddiff(k,:)=((z(i)-z).^2)';
end
h=h(:);
squareddiff=squareddiff(:);
[h,ind]=sort(h);
squareddiff=squareddiff(ind);
clear ind

nlc=length(lagclass);
for i=1:nlc-1
   ind=find(h>lagclass(i) & h<=lagclass(i+1));
   v(i)=mean(squareddiff(ind))/2;
   n(i)=length(ind);
   lagh(i)=mean(h(ind));
end

empvario.v=v;
empvario.lagh=lagh;
empvario.n=n;
%figure
%plot(lagh,v,'-*')
%title('empirical semivariogram')

function h=dist(x1,y1,x2,y2)
h=sqrt((x1-x2).^2+(y1-y2).^2);