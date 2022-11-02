function plotcovarianceapprox(w,M,delta,ldelta,xcoordinates,ycoordinate,xpoint,xlower,xupper,ylower,yupper)
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
%  plotcovarianceapprox(w,M,delta,ldelta,xcoordinates,ycoordinate,xpoint)
%
%  plots the true covariance function and its worst case
%  approximation from the linear regression model of
%  cosinus-sinus-bessel surfaceharmonics.
%
%  Inputs:
%
%  w............a vector giving the frequencies of the bessel functions
%
%  M............an integer giving maximum frequency of the sinus and 
%               cosinus harmonics
%
%  delta........the contributions to the spectral density calculated from
%               the function step2.
%
%  ldelta.......a row vector giving the parameters of the true covariance
%               function. ldelta=[nugget,sill,exponential range, 
%                                 gaussian range,mixing factor]
%
%  xcoordinates...coordinates along the x-axes.
%
%  ycoordinate....extrem y-coordinate,
%
%  xpoint.........x-coordinate of a point (xpoint,ycoordinate)
%
%  xlower.........the lower x-limit for the area of importance
%
%  xupper.........the upper x-limit for the area of importance
%
%  ylower.........the lower y-limit for the area of importance
%
%  yupper.........the upper y-limit for the area of importance
%
%
%  The covariance is calculated between the points
%  (xcoordinates(i),ycoordinate) and (xpoint,ycoordinate).
%
%  Example:
%
%  plotcovarianceapprox(wBoxGomeliso,35,deltaBoxGomeliso,delta0BoxGomeliso,-100:3:200,250,-100,-100,200,-50,250);
%
%  plotcovarianceapprox(wBoxGomelaniso,35,deltaBoxGomelaniso,delta0BoxGomelaniso,-100:3:150,350,-100,-75,150,-50,350);
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
nx2=length(xcoordinates);
x11=(xlower+xupper)/2;
y11=(ylower+yupper)/2;
xpoint=xpoint-x11;
xcoordinates=xcoordinates-x11;
ycoordinate=ycoordinate-y11;

for i=1:nx2
  covapprox1(i)= covarianceapprox(xpoint,ycoordinate,xcoordinates(i),ycoordinate,w,M,delta);
end
minlag=min(abs(xpoint-xcoordinates));
maxlag=max(abs(xpoint-xcoordinates));
step=xcoordinates-xpoint;
plot(step,covapprox1)
hold on
plot(step,covar(step,ldelta),'r-')
title('covariance function and its approximation')

function cov=covar(h,ldelta)
 
if ldelta(3)==0 
  ldelta(3)=0.0000000000000001;
end
if ldelta(4)==0 
  ldelta(4)=0.0000000000000001;
end

if h==0
  cov=ldelta(2)+ldelta(1);
else
  %cov=delta(2)*exp(-3*h/delta(3));
  cov=ldelta(2)*((1-ldelta(5))*exp(-3*h/ldelta(3))+ldelta(5)*exp((-3*h.^2)/(ldelta(4)^2)));
end

function covapprox= covarianceapprox(x1,y1,x2,y2,w,M,delta)
nw=size(w,2);
t1=sqrt(x1^2+y1^2);
t2=sqrt(x2^2+y2^2);
if x1==0
  x1=0.0000000001;
end
if x2==0
  x2=0.0000000001;
end

phi1=arctan(x1,y1);
phi2=arctan(x2,y2);

covapprox=0;
for i=0:M
  if i==0
    d=1;
  else
    d=2;
  end
  for j=1:nw
    covapprox=covapprox+d*cos(i*(phi2-phi1)).*real(besselj(i,w(j)*t1)).*real(besselj(i,w(j)*t2))*delta(j);
  end
end

  