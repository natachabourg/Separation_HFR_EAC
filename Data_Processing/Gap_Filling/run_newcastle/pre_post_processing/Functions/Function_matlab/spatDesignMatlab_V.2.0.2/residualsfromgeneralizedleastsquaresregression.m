function [residuals,regressioncoeff,covmatrix]=residualsfromgeneralizedleastsquaresregression(externaldrift,x,y,z,K,type,gridsize,ncontours)
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
%  [residuals,regressioncoeff,covmatrix]=residualsfromgeneralizedleastsquaresregression(externaldrift,x,y,z,K,type,gridsize,ncontours) 
%
%
%  calculates residuals and regression coefficients from generalized least squares
%  regression
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
%  K.................the covariance matrix of the residuals of the data
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
%  Example:
%
%  least squares regression:
%  
%  n=length(Gomel.x);
%  K=diag(ones(1,n));
%  [residuals,regressioncoeff,covmatrix]=residualsfromgeneralizedleastsquaresregression({},Gomel.x,Gomel.y,BoxGomeliso.z,K,'linear',3,8);
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

nx=length(x);
for i=1:nx
    F(i,:)=regressionfunctiontrend1(externaldrift,x(i),y(i),type)';
end
K_1=inv(K);
FK_1=(F')*K_1;
invFK_1F=inv(FK_1*F);
regressioncoeff=invFK_1F*FK_1*z;
residuals=z-F*regressioncoeff;
covmatrix=invFK_1F;
if K==diag(ones(nx,1))
    sigma2=((residuals')*residuals)/(nx-size(F,2));
    covmatrix=sigma2*covmatrix;
end

%[xi,yi] = meshgrid(min(x):gridsize:max(x),min(y):gridsize:max(y));
%residuals11 = griddata(x,y,residuals,xi,yi,'cubic'); 
%contourf(xi,yi,residuals11,ncontours)
%colorbar
%title('residuals')
%axis equal

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
   if size(externaldrift{2},2)>1
      z=externaldrift{2}(ind,:);
   else
      z=externaldrift{2}(ind);
   end
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

