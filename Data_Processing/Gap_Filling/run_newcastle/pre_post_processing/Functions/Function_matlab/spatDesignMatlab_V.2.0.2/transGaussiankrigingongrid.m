function predictivedist=transGaussiankrigingongrid(x,y,z,apriorivar,apriorimean,searchradius,delta0,lambda0,A0,grid,int,upper)   
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
%  predictivedist=transGaussiankrigingongrid(x,y,z,apriorivar,apriorimean,searchradius,delta0,lambda0,A0,grid,int,upper)
%
%  performs trans-Gaussian kriging on a grid by means of a
%  Box-Cox-transformation. It also takes into account
%  geometric anisotropy.
%
%  Inputs:
%
%  x.................column vector containing the x-coordinates of the  data
%
%  y.................column vector containing the y-coordinates of the data
%
%  z.................column vector containing the concentrations 
% 
%  apriorimean.......the apriorimean. In the case of ordinary kriging 
%                    set it to 0 and give apriorivar a very high value
%                    (100000 or higher).
% 
%  apriorivar........the a priori variance
%
%  searchradius......the radius of the kriging neighbourhood
%
%  delta0............the covariance parameters 
%                    [nugget, sill, exp. range, Gaussian range, mixing parameter]
%
%  lambda0...........the Box-Cox-parameter
%
%  A0................the anisotropy transformation matrix
%
%  grid..............contains locations grid.x and grid.y, where
%                    predictions are to be made
%  
%  int...............thickness of the boxes when the predictive distribution is
%                    discretized
%
%  upper.............maximum x-value for predictive distribution
%
%  Output:
%
%  predictivedist.x..............x-axes of the predictive distributions
%
%  predictivedist.predictive.....predictive distributions
%
%  predictivedist.grid...........the grid where prediction takes place
%
%  Example:
%
%  grid=generategrid2(-100,200,-50,250,61,61,polyBoxGomeliso);
%  predictivedistBoxGomelaniso=transGaussiankrigingongrid(Gomel.x,Gomel.y,Gomel.zaver,10000,0,120,delta0BoxGomelaniso,lambda0BoxGomelaniso,A0BoxGomelaniso,grid,0.25,120);    
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
x0=grid.x;
y0=grid.y;
n = length(x0);

   for j=1:n
       j
       xx=searchrad(x0(j),y0(j),x,y,z,searchradius);
       if (~isempty(xx)) && (~isnan(grid.x(j))) && (~isnan(grid.y(j)))
         predictive=transGaussiankriging(x0(j),y0(j),x,y,z,apriorimean,apriorivar,searchradius,delta0,lambda0,A0,int,upper); 
         ppredictive{j}=predictive.predictive;                  
       else
         ppredictive{j}=NaN;
       end
   end

 predictivedist.x=predictive.x;
 predictivedist.predictive=ones(n,length(predictive.x))*NaN;
 for j=1:n
     if ~isnan(ppredictive{j})
        predictivedist.predictive(j,:)=ppredictive{j};
     end
 end
predictivedist.grid=grid;

function [xx,yy,zz]=searchrad(x0,y0,x,y,z,searchradius)

dist=sqrt((x0-x).^2+(y0-y).^2);
ind=find(dist<=searchradius);
zz=z(ind);
xx=x(ind);
yy=y(ind);