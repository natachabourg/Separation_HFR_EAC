function grid=generategrid2(xlower,xupper,ylower,yupper,nx,ny,polygon)
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
%  grid=generategrid2(xlower,xupper,ylower,yupper,nx,ny,polygon)
%
%  generates a regular grid of points inside a polygonal area.
%
%  Inputs:
%
%  xlower.......the lower x-limit for the area of importance
%
%  xupper.......the upper x-limit for the area of importance
%
%  ylower.......the lower y-limit for the area of importance
%
%  yupper.......the upper y-limit for the area of importance
%
%  nx...........the number of points in x-direction
%
%  ny...........the number of points in y-direction
%
%  polygon......the polygonal area of importance calculated by 
%               means of the function polygon.
%
%  Outputs:
%
%  grid.x...........the x-coordinates of the grid
%
%  grid.y...........the y-coordinates of the grid
%
%  Example: 
%
%  grid=generategrid2(-100,200,-50,250,41,41,polyBoxGomeliso);
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
x111=xlower:(xupper-xlower)/(nx-1):xupper;
y111=ylower:(yupper-ylower)/(ny-1):yupper;
for i=1:length(x111)
   for j=1:length(y111)
      [zzz(i,j),zzzz(i,j)]=inpolygon1([x111(i);y111(j)],0,0,0,0,0,polygon);
       XX(i,j)=x111(i);
       YY(i,j)=y111(j);
   end
end

k=0;
for i=1:length(x111)
    for j=1:length(y111)
        k=k+1;
        if zzzz(i,j)==0
            grid.x(k)=XX(i,j);
            grid.y(k)=YY(i,j);
        else
            grid.x(k)=NaN;
            grid.y(k)=NaN;
        end
    end
end
            
ind0=find(zzzz==0);       
xx=XX(ind0);
yy=YY(ind0);
figure
plot(xx,yy,'b.')
hold on
plot(polygon.x,polygon.y,'r-')
axis equal