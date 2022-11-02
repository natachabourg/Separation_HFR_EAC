function visualizepostdistribution(x0,y0,predictivedist,grid)
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
%  visualizepostdistribution(x0,y0,predictivedist,grid)
%
%  visualizes the predictive distribution from trans-Gaussian kriging.
%
%  Input:
%
%  x0 ...................a vector of x-data locations
%
%  y0....................a vector of y-data locations
%
%  predictivedist.......object from transGaussiankrigingongrid.m 
%
%  grid.................object calculated from generategrid2.m
%
%  Example:
%
%  visualizepostdistribution([175,120],[200,150],predictivedistBoxGomelaniso,grid);
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


x=grid.x;
y=grid.y;

n0=size(x0,2);
n=size(x,2);
xxx=predictivedist.x;

for i=1:n0
    [zz,ind(i)]=min(sqrt((x0(i)-x).^2+(y0(i)-y).^2)); 
    ppredictivedist=predictivedist.predictive(ind(i),:);
    cumdistribfunction=cumsum(ppredictivedist)/sum(ppredictivedist);               
    ind1=max(find(cumdistribfunction<=0.05));
    ind2=max(find(cumdistribfunction<=0.95));
    ind3=max(find(cumdistribfunction<=0.25));
    ind4=max(find(cumdistribfunction<=0.75));
    indmedian=max(find(cumdistribfunction<=0.5));
    indmodal=find(ppredictivedist==max(ppredictivedist));
    mean1=sum(ppredictivedist.*xxx);
   if ~isempty(indmedian)
   median1=xxx(indmedian(1));
   else
   median1=NaN;
   end
   if ~isempty(indmodal)
   modal1=xxx(indmodal(1));
   else
   modal1=NaN;
   end
   if ~isempty(ind1)
   q005=xxx(ind1(1));
   else
   q005=xxx(1);
   end
   if ~isempty(ind2)
   q095=xxx(ind2(1));
   else
   q095=NaN;
   end
   if ~isempty(ind3)
   q025=xxx(ind3(1));
   else
   q025=xxx(1);
   end
   if ~isempty(ind4)
   q075=xxx(ind4(1));
   else
   q075=NaN;
   end

    figure
    plot(xxx,ppredictivedist,'-b')
    title(['(x,y)=','(',num2str(x(ind(i))),',',num2str(y(ind(i))),')'])
    hold on
    plot(q005,0,'yo')
    plot(q095,0,'yo')
    plot(q025,0,'go')
    plot(q075,0,'go')
    plot(median1,0,'r*')
    plot(modal1,0,'g*')
    plot(mean1,0,'b*')
    pause(0.1)
    hold off
end    
        
