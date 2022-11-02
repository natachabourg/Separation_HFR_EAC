function predictivedist=transGaussiankriging(x0,y0,x,y,z,apriorimean,apriorivar,searchradius,delta0,lambda0,A0,int,upper)
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
%  predictivedist=transGaussiankriging(x0,y0,x,y,z,apriorimean,apriorivar,searchradius,delta0,lambda0,A0,int,upper)
%
%  performs trans-Gaussian kriging in a point (x0,y0) by means of a
%  Box-Cox-transformation. It also takes into account
%  geometric anisotropy.
%
%  Inputs:
%
%  x0................the x-coordinate of the point to be predicted
%
%  y0................the y-coordinate of the point to be predicted
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
%  int...............thickness of the boxes when the predictive distribution is
%                    approximated by a histogram
%
%  upper.............maximum x-value for predictive distribution
%
%  Output:
%
%  predictivedist.x..............x-axes of predictive distribution
%
%  predictivedist.predictive.....predictive distribution
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[x,y,z]=searchrad(x0,y0,x,y,z,searchradius);
n=size(lambda0,1);

x0y0new=A0*[x0;y0];
x0new=x0y0new(1);
y0new=x0y0new(2);
xynew=A0*[x';y'];
xnew=xynew(1,:)';
ynew=xynew(2,:)';
   
cov= totalcovariancematrix(delta0,apriorivar,x0new,y0new,xnew,ynew);
K=cov(2:end,2:end);
znormal=transform(z,lambda0);

[V,D]=eig(K);
D=diag(D);
detK=prod(D);
K_1=V*diag(1./D)*V';
c0=cov(1,2:end);
c0K_1=c0*K_1;
aposteriorivar=cov(1,1)-c0K_1*c0';
aposteriorimean=apriorimean+c0K_1*(znormal-apriorimean);

xx=int:int:upper;
xn=transform(xx,lambda0);
distnorm=normal(xn,aposteriorimean,aposteriorivar);
jac=jacobi(xx,lambda0);
dist=distnorm.*jac;

figure(1)
plot(xx,dist,'-b')
pause(0.1)
predictivedist.x=xx;
predictivedist.predictive=dist;


function cov= totalcovariancematrix(delta0,apriorivar,x0,y0,x,y)

x=[x0;x];
y=[y0;y];

nx=length(x);
for i=1:nx
   for j=i+1:nx
       h=sqrt((x(i)-x(j)).^2+(y(i)-y(j)).^2);
       cov(i,j)=covar(h,delta0)+apriorivar;
       cov(j,i)=cov(i,j);
   end
   cov(i,i)=covar(0,delta0)+apriorivar;
end

function cov=covar(h,delta0)
 
if delta0(3)==0 
  delta0(3)=0.0000000000000001;
end
if delta0(4)==0 
  delta0(4)=0.0000000000000001;
end

if h==0
  cov=delta0(2)+delta0(1);
else
  cov=delta0(2)*((1-delta0(5))*exp(-3*h/delta0(3))+delta0(5)*exp((-3*h.^2)/(delta0(4)^2)));
end

function [xx,yy,zz]=searchrad(x0,y0,x,y,z,searchradius)

dist=sqrt((x0-x).^2+(y0-y).^2);
ind=find(dist<=searchradius);
zz=z(ind);
xx=x(ind);
yy=y(ind);

function z=normal(x,m,v)
z=(1/sqrt(2*pi*v))*exp(-0.5*((x-m).^2)/v);

function y=transform(x,lambda0)
if ~(lambda0==0)
   y=((x.^lambda0)-1)/lambda0;
else
   y=log(x);
end

function z=jacobi(x,lambda0)
if ~(lambda0==0)
  z=abs((x.^(lambda0-1)));
else
  z=abs(1./x);
end

