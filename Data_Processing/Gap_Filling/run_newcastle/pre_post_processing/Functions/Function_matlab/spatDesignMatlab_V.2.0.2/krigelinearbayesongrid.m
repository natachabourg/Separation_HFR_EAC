function predictionkrigelinearbayes=krigelinearbayesongrid(externaldrift,x,y,z,apriorivar,apriorimean,searchradius,delta0,A0,grid,gridsize,ncontours)
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
%  predictionkrigelinearbayes=krigelinearbayesongrid(externaldrift,x,y,z,apriorivar,apriorimean,searchradius,delta0,A0,grid,gridsize,ncontours)
%
%
%  calculates the Bayesian-kriging predictor for a linear trend on a regular 
%  grid.
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
%  apriorimean.......the apriorimean of the trend parameter vector for a 
%                    linear trend. In the case of universal kriging 
%                    set it to [0;0;0] and give apriorivar a very high value
%                    (10000 or higher) at its diagonal.
% 
%  apriorivar........the a priori covariance matrix for a linear trend
%
%  searchradius......the radius of the kriging neighbourhood
%
%  delta0............the parameters of the theoretical variogram model.
%                    delta0=[nugget,sill,exponential range, gaussian 
%                    range, mixing parameter]
%
%  A0................the anisotropy transformation matrix 
%
%  grid..............contains locations grid.x and grid.y, where
%                    predictions are to be made; calculated by means of
%                    function generategrid2.m
%
%  gridsize..........the size of the grid for cubic spline interpolation
%
%  ncontours.........the number of contours
%
%  Outputs:
%
%  predictionkrigelinearbayes.predictivemean....the Bayes-kriging predictor
%
%  predictionkrigelinearbayes.sqrttmsep.........the square root of the 
%                                               total mean square error of
%                                               prediction
%
%  predictionkrigelinearbayes.grid..............the grid of coordinates
%                                               where prediction takes place
%
%  Example:
%  
%  grid=generategrid2(-100,200,-50,250,61,61,polyBoxGomeliso);
%  predictionkrigelinearbayesBoxGomelaniso=krigelinearbayesongrid({},Gomel.x,Gomel.y,BoxGomelaniso.z,[10000,0,0;0,0.0001,0;0,0,0.0001],[0;0;0],120,delta0BoxGomelaniso,A0BoxGomelaniso,grid,3,8);
%  imgsqrttmsepBoxGomelaniso=reshape(predictionkrigelinearbayesBoxGomelaniso.sqrttmsep,61,61);
%  figure()
%  imagesc(imgsqrttmsepBoxGomelaniso(end:-1:1,:))
%  colorbar
%  title('sqrt(TMSEP)')
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

n=length(grid.x)

for i=1:n
    i
    if ~isnan(grid.x(i))
      [xx,yy,zz]=searchrad(grid.x(i),grid.y(i),x,y,z,searchradius);
      tot=totalcovariancematrix(externaldrift,delta0,A0,apriorivar,grid.x(i),grid.y(i),xx,yy);
      tot_1=inv(tot);
      if ~isempty(externaldrift)
          apriorimean1=[apriorimean;externaldrift{3}'];
      else
          apriorimean1=apriorimean;
      end
      trend0=regressionfunctiontrend1(externaldrift,grid.x(i),grid.y(i))' * apriorimean1;
      m=length(xx);
      for j=1:m
          F(j,:)=regressionfunctiontrend1(externaldrift,xx(j),yy(j))';
      end
      trend1=F*apriorimean1;
      clear F
      c0invK=tot(1,2:end)*inv(tot(2:end,2:end));
      c0invKc0=c0invK*(tot(1,2:end))';
      predictivemean(i)=trend0+c0invK*(zz-trend1);
      sqrttmsep(i)=sqrt(max([tot(1,1)-c0invKc0,0]));       
    else
      predictivemean(i)=NaN;
      sqrttmsep(i)=NaN;
    end   
end
[xi,yi] = meshgrid(min(grid.x):gridsize:max(grid.x),min(grid.y):gridsize:max(grid.y));
figure()
predictivemean12=predictivemean(~isnan(grid.x));
mean11 = griddata(grid.x(~isnan(grid.x)),grid.y(~isnan(grid.x)),predictivemean12,xi,yi,'cubic'); 
contourf(xi,yi,mean11,ncontours)
colorbar
title('predictive mean')
axis equal

figure()
sqrttmsep12=sqrttmsep(~isnan(grid.x));
sqrttmsep11 = griddata(grid.x(~isnan(grid.x)),grid.y(~isnan(grid.x)),sqrttmsep12,xi,yi,'cubic'); 
contourf(xi,yi,sqrttmsep11,ncontours)
colorbar
title('sqrt(TMSEP)')
axis equal

predictionkrigelinearbayes.predictivemean=predictivemean;
predictionkrigelinearbayes.sqrttmsep=sqrttmsep;
predictionkrigelinearbayes.grid=grid;

function cov= totalcovariancematrix(externaldrift,delta,A,apriorivar,x0,y0,x,y)

x=[x0;x];
y=[y0;y];
xxxyyy=[x';y'];
xxx=xxxyyy(1,:)';
yyy=xxxyyy(2,:)';
nx=length(xxx);

for i=1:nx
    F(i,:)=regressionfunctiontrend1(externaldrift,xxx(i),yyy(i))';
end
phi=aprioricovmattrend1(externaldrift,apriorivar);
FPhiF=F*phi*F';
xxyy=A*xxxyyy;
xx=xxyy(1,:);
yy=xxyy(2,:);
for i=1:nx
   for j=1:nx
       h=sqrt((xx(i)-xx(j)).^2+(yy(i)-yy(j)).^2);
       cov(i,j)=covar(h,delta)+FPhiF(i,j);
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

function [xx,yy,zz]=searchrad(x0,y0,x,y,z,searchradius)

dist=sqrt((x0-x).^2+(y0-y).^2);
ind=find(dist<=searchradius);
zz=z(ind);
xx=x(ind);
yy=y(ind);

function rf=regressionfunctiontrend1(externaldrift,x,y)
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
%  rf=regressionfunctiontrend1(externaldrift,x,y)
%  vector containing all regression functions
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if ~isempty(externaldrift)
   X=externaldrift{1}(:,1);
   Y=externaldrift{1}(:,2);
   Z=sqrt((X-x).^2+(Y-y).^2);
   [dummy,ind]=min(Z);
   z=externaldrift{2}(ind,:);
   rf=[1,x,y,z]';
else
   rf=[1,x,y]';
end

function phi=aprioricovmattrend1(externaldrift,apriorivar)
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
%  phi=aprioricovmattrend1(externaldrift,apriorivar)
%  
%  calculates the a priori covariance matrix for the linear drift.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
n3=size(apriorivar,1);
if  ~isempty(externaldrift)
    phidrift=externaldrift{4};
    m=size(externaldrift{2},2);
    n=n3+m;
    phi=zeros(n,n);
    phi(1:n3,1:n3)=apriorivar;
    phi(n3+1:n3+m,n3+1:n3+m)=phidrift;
else
    n=n3;
    phi=zeros(n,n);
    phi(1:n3,1:n3)=apriorivar;
end

