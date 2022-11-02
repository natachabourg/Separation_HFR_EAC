function [xx,yy,avgkrigemsep]=optimally_add_n_locations_from_poolcomplete(externaldrift,U,x0,y0,sigma2,apriorivar,w,M,delta,n,xlower,xupper,ylower,yupper,maxiterations,polygon,nx,ny,criterion)
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
% [xx,yy,avgkrigemsep]=optimally_add_n_locations_from_poolcomplete(externaldrift,U,x0,y0,sigma2,apriorivar,w,M,delta,n,xlower,xupper,ylower,yupper,maxiterations,polygon,nx,ny,criterion)
%
%  calculates an optimal spatial sampling design by means of adding n
%  designpoints to allready available sampling points (x0,y0). The 
%  designpoints are selected in such a way that either the integrated mean 
%  square kriging error of prediction or a D-optimality criterion is 
%  minimized. An exchange type algorithm is used for calculating the
%  optimal spatial design.
%
%  Inputs:
%
%  externaldrift....is a cell array
%
%  externaldrift{1}.a 2-column matrix containing the grid of the 
%                   x- and y-coordinates of the external drift
%
%  externaldrift{2}.a matrix with the number of columns equal to the number
%                   of external drift variables and the same number of rows as 
%                   externaldrift{1}
%  externaldrift{3}.a row vector with the same number of columns as
%                   externaldrift{2} giving the a priori mean for the
%                   regression coefficients of the linear external drift.
%  externeldrift{4}.the a priori covariance matrix for the linear external
%                   drift regression coefficients.
%
%  U..............a matrix calculated by the function weightingmatUtrend, 
%                 giving part of the necessary information on the 
%                 integrated mean square error of prediction.
%
%  x0.............the x-coordinates of the available 
%                 design points
%
%  y0.............the y-coordinates of the available 
%                 design points
%
%  sigma2.........the nugget effect not accounted for by the 
%                 approximation through a linear regression model
%
%  apriorivar.....the a priori variance matrx.
%
%  w..............a vector containing the frequencies for the bessel 
%                 approximations
%
%  M..............an integer number giving the highest frequency for the
%                 cosinus-sinus approximation
% 
%  delta..........the contributions to the polar spectral distribution
%                 function, calculated from the function step. 
%
%  n..............the number of designpoints to be added
%
%  xlower........the lower x-limit for the area of importance
%
%  xupper........the upper x-limit for the area of importance
%
%  ylower........the lower y-limit for the area of importance
%
%  yupper........the upper y-limit for the area of importance
%
%  maxiterations..the maximum number of iterations to be used for
%                 adding and deleting points
%
%  polygon........the polygonal area of importance calculated by 
%                 means of the function polygon.
%
%  nx.............the number of points in the x-direction, where the
%                 design functionals should be calculated
%
%  ny.............the number of points in the y-direction, where the
%                 design functionals should be calculated
%
%  criterion......if criterion=="i" the integrated tmsep over an area of interest is minimised;
%                 if criterion=="d" a D-optimality criterion is minimized.
%
%  Outputs:
%
%  xx.............a cell array of size n. cell{i} gives the optimal
%                 x-coordinates of the design points for an i*2-point
%                 design. 
%
%  yy.............a cell array of size n. cell{i} gives the optimal
%                 y-coordinates of the design points for an i*2-point
%                 design.
%
%  avgkrigemsep...the average kriging tmsep of the calculated designs
%
%  Example: 
%
%  [xoptimallyaddfrompoolcompleteBoxGomeliso_i,yoptimallyaddfrompoolcompleteBoxGomeliso_i,avgkrigevaroptimallyaddfrompoolcompleteBoxGomeliso_i]=optimally_add_n_locations_from_poolcomplete({},UBoxGomeliso,xBoxGomeldeleteiso_i{146},yBoxGomeldeleteiso_i{146},0.22+delta0BoxGomeliso(1),[10000000,0,0;0,0.00000001,0;0,0,0.00000001],wBoxGomeliso,35,deltaBoxGomeliso,100,-100,200,-50,250,1000,polyBoxGomeliso,41,41,'i');  
%
%  [xoptimallyaddfrompoolcompleteBoxGomelisoscratch_i,yoptimallyaddfrompoolcompleteBoxGomelisoscratch_i,avgkrigevaroptimallyaddfrompoolcompleteBoxGomelisoscratch_i]=optimally_add_n_locations_from_poolcomplete({},UBoxGomeliso,[],[],0.22+delta0BoxGomeliso(1),[10000000,0,0;0,0.00000001,0;0,0,0.00000001],wBoxGomeliso,35,deltaBoxGomeliso,100,-100,200,-50,250,1000,polyBoxGomeliso,41,41,'i'); 
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
n=ceil(n/2)*2;
x=[];
y=[];
pooldeletex=[];
pooldeletey=[];
optimalityavg=[];
optimalitymax=[];
infM=0;
infM_1=0;
for i=1:ceil(n/2)
    if i==1
        calc=1;
    else 
        calc=0;
    end
    
 starting=i
 x1=[x0;x];
 y1=[y0;y];
 [xstarting,ystarting,avgmsep,infM_1]=add_n_locations_from_poolcomplete(externaldrift,U,x1,y1,sigma2,apriorivar,w,M,delta,xlower,xupper,ylower,yupper,polygon,2,nx,ny,calc,infM_1,criterion);
 pooldeletex=[x;xstarting{2}']; 
 pooldeletey=[y;ystarting{2}'];
 [x,y,optimality1,infM_1]=optimally_improve_pooldelete_from_poolcomplete(externaldrift,U,x0,y0,[pooldeletex,pooldeletey],sigma2,apriorivar,w,M,delta,xlower,xupper,ylower,yupper,maxiterations,polygon,nx,ny,0,infM_1,criterion);
 xx{i}=x;
 yy{i}=y;
 optimalityavg=[optimalityavg,optimality1];
 figure(1500)
 plot(2:2:length(optimalityavg)*2,optimalityavg,'*-')
 title('average kriging mean square error')
 pause(3)
 figure(i)
 plot(polygon.x,polygon.y,'r-')
 hold on
 plot(x0,y0,'.')
 hold on
 plot(x,y,'r*')
 hold on
 plot(x,y,'ro')
 axis equal
 title(i*2)
 pause(5)
end
avgkrigemsep=optimalityavg;

