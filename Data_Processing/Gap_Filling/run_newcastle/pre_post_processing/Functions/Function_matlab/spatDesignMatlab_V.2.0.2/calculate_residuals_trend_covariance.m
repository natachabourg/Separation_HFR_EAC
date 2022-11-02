function [residuals,regressioncoeff,covmatrix,covparameters]=calculate_residuals_trend_covariance(externaldrift,x,y,z,lagclass,delta0,numiterations,type,gridsize,ncontours)
%
%  Copyright (C) 2010 Gunter Spöck, email: gunter.spoeck@uni-klu.ac.at
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
% [residuals,regressioncoeff,covmatrix,covparameters]=calculate_residuals_trend_covariance(externaldrift,x,y,z,lagclass,delta0,numiterations,type,gridsize,ncontours) 
%
%  calculates residuals, regression coefficients and covariance parameters of residuals 
%  by means of an iterative algorithm that sukzessivelly fits the trend by
%  generalized least squares, calculates residuals, the covariance function
%  of the residuals and uses in each step the calculated covariance matrix
%  from the last step.
%
%  Inputs:
%
%  externaldrift.....is a cell array
%
%  externaldrift{1}..a 2-column matrix containing the grid of the 
%                    x- and y-coordinates of the external drift
%
%  externaldrift{2}..a matrix with the number of columns equal to the number
%                    of external drift variables and the same number of rows as 
%                    externaldrift{1}
%  externaldrift{3}..a row vector with the same number of columns as
%                    externaldrift{2} giving the a priori mean for the
%                    regression coefficients of the linear external drift.
%  externeldrift{4}..the a priori covariance matrix for the linear external
%                    drift regression coefficients.
%
%  x.................column vector containing the x-coordinates of the  data
%
%  y.................column vector containing the y-coordinates of the data
%
%  z.................column vector containing the concentrations 
%
%  lagclass..........the lag classes for empirical semi-variogram
%                    estimation
%
%  delta0............starting values of covariance parameters to start weighted
%                    least squares variogram fitting
%
%  numiterations.....the number of iterations
%
%  type..............can be 'constant' or 'linear'. (linear or constant
%                    trend depending on coordinates)
%
%  gridsize..........size of the grid in the residual surface
% 
%  ncontours.........the number of contours in a residuals surface
%
%  Outputs:
%
%  residuals.........the residuals
%
%  regressioncoeff...the vector of regression coefficients
%
%  covmatrix.........the covariance matrix of the estimated regression parameters
%
%  covparameters.....the estimated covariance parameters of the covariance
%                    function of the residuals.
%
%  Example:
%
%  least squares regression:
%  
%  nx=length(Gomel.x);
%  K=diag(ones(1,nx));
%  [residuals,regressioncoeff,covmatrix,covparameters]=calculate_residuals_trend_covariance({},Gomel.x,Gomel.y,BoxGomeliso.z,0:5:150,delta0BoxGomeliso,10,'linear',3,8);
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
nx=length(x);
K=diag(ones(1,nx));

for i=1:numiterations
    [residuals,regressioncoeff,covmatrix]=residualsfromgeneralizedleastsquaresregression(externaldrift,x,y,z,K,type,gridsize,ncontours);
    empvario= empvariogram(x,y,residuals,lagclass);
    nugget0=delta0(1);
    sill0=delta0(2);
    rangee0=delta0(3);
    rangeg0=delta0(4);
    alpha0=delta0(5);
    [delta0,exitflag]=weightedleastsquares(empvario,nugget0,sill0,rangee0,rangeg0,alpha0,[1,1,1,1,1]);
    for i=1:nx
       for j=1:nx
          h=sqrt((x(i)-x(j)).^2+(y(i)-y(j)).^2);
          K(i,j)=covar(h,delta0);
       end
    end
end
covparameters=delta0; 

% figure()
% [xi,yi] = meshgrid(min(x):gridsize:max(x),min(y):gridsize:max(y));
% residuals11 = griddata(x,y,residuals,xi,yi,'cubic'); 
% contourf(xi,yi,residuals11,ncontours)
% colorbar
% title('residuals')
% axis equal

function rf=regressionfunctiontrend1(externaldrift,x,y,type)
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
%  internal function:
%
%  rf=regressionfunctiontrend1(externaldrift,x,y,type)
%  vector containing all regression functions
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if ~isempty(externaldrift)
   X=externaldrift{1}(:,1);
   Y=externaldrift{1}(:,2);
   Z=sqrt((X-x).^2+(Y-y).^2);
   [dummy,ind]=min(Z);
   z=externaldrift{2}(ind,:);
   if strcmp(type,'linear')
      rf=[1,x,y,z]';
   end
   if strcmp(type,'constant')
       rf=[1,z];
   end
else
   if strcmp(type,'linear')
      rf=[1,x,y]';
   end
   if strcmp(type,'constant')
      rf=1;
   end
end

function cov=covar(h,delta)
 
if delta(3)==0 
  delta(3)=0.0000000000000001;
end
if delta(4)==0 
  delta(4)=0.0000000000000001;
end

if h==0
  cov=delta(2)+delta(1);
else
  cov=delta(2)*((1-delta(5))*exp(-3*h/delta(3))+delta(5)*exp((-3*h.^2)/(delta(4)^2)));
end


