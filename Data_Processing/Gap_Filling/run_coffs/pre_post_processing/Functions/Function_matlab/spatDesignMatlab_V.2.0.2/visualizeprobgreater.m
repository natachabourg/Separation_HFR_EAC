function prob=visualizeprobgreater(threshold,predictivedist,ncontours,gridsize)
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
%  prob=visualizeprobgreater(threshold,predictivedist,ncontours,gridsize)
%
%  visualizes the probability of getting larger values than a threshold.
%
%  Input:
%
%  threshold............the vector of thresholds
%
%  predictivedist.......object from transGaussiankrigingongrid.m
%
%  ncontours............the number of contours
%
%  gridsize.............the size of the grid for cubic spline interpolation
%
%  Output:
%
%  prob.probs............the probabilities of beeing larger than a threshold
%
%  prob.threshold........the treshholds
%
%  Example:
%
%  probBoxGomelaniso=visualizeprobgreater([10,20,30,40,50],predictivedistBoxGomelaniso,8,3);
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
    
    for j=1:length(threshold)
    for i=1:n  
        ind=find(xx>=threshold(j));
        ind=min(ind);
    probs1(i,j)=sum(ppredictivedist(i,ind:end))/sum(ppredictivedist(i,:));
    end
    end
    
    probs11=probs1(~isnan(grid.x),:);
    for j=1:length(threshold)
    figure()
    probs111 = griddata(x,y,probs11(:,j),xi,yi,'cubic'); 
    contourf(xi,yi,probs111,ncontours)
    title(['threshold ',num2str(threshold(j))])
    colorbar
    end
    
prob.probs=probs1;
prob.treshold=threshold;

 
    
   