function [delta0estimate,Aestimate,exitflag]=weightedleastsquaresaniso(empvario,nugget0,sill0,rangee0,rangeg0,alpha0,A,estimatedelta,estimateanisotropy,exactnesscov)
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
%  [delta0estimate,Aestimate,exitflag]=weightedleastsquaresaniso(empvario,nugget0,sill0,rangee0,rangeg0,alpha0,A,estimatedelta,estimateanisotropy,exactnesscov)
%
%  fits an empirical variogram by means of weighted least squares to find
%  estimates for delta and A
%
%  Remark: It may happen that you must change the parameters in the
%  function optimset in order to speed up convergence of the optimization
%  routines. Furthermore it can become necessary to adjust the upper and
%  lower bounds in the function fmincon.
%
%  Inputs:
%
%  empvario......the empirical variogram calculated from the function 
%                empvariogramaniso
%
%  nugget0.......initial value for the nugget effect close to the true 
%                nugget effect
%
%  sill0.........initial value for the sill close to the true sill
%
%  rangee0.......initial value for the range of the exponential variogram
%                close to the true exponential range
%
%  rangeg0.......initial value for the range of the gaussian variogram
%                close to the true Gaussian range
%
%  alpha0........initial value for the true mixture parameter. The 
%                variogram is supposed to be a mixture of an
%                exponential and a Gaussian variogram
%
%  A.............anisotropy transformation matrix of the isotropic
%                coordinates
%
%  estimatedelta..a vector of length 5 of 0's and 1's indicating what
%                 parameters of the covariance function should be estimated
%
%  estimateanisotropy..if it is 1, the anisotropy is estimated.
%
%  exactnesscov........positiv number giving the exactness
%                      of the estimated covariance parameters and anisotropy
%                      parameters
%
%  Output:
%
%  delta0estimate........the estimated variogram parameters
%
%  Aestimate.............the estimated transformation matrix
%
%  exitflag..............it is 1 if the algorithm has converged 0 else
%
%  Example:
%
%  [delta0BoxGomelanisowls,A0BoxGomelanisowls,exitflagBoxGomelanisowls]=weightedleastsquaresaniso(empvarioBoxGomelaniso,0.25,3.4,61,80,0.6,A0BoxGomelaniso,[1,1,1,1,1],1,0.001);
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
delta0=[nugget0,sill0,rangee0,rangeg0,alpha0];
delta1=delta0(estimatedelta==0);
options=optimset('LargeScale','off','MaxFunEvals',3500000,'MaxIter',2500000,'TolCon',1e-06);
A=(reshape(A,2,2));
A0=A;

[delta0,zz,exitflag1]=fmincon(@criterium1,delta0,[],[],[],[],[0.0001,0.0001,0.0001,0.0001,0.0001],[1000000,1000000,2000000,2000000,0.9999],[],options,A,empvario,delta1,estimatedelta);
delta0(estimatedelta==0)=delta1;
delta0v=10000000000000;
j=0;
zzv=0;
for k=1:250 
   j=j+1;
   delta0v=delta0;
   Av=A0;
   if estimateanisotropy==1
   [A,zz,exitflag2]=fminunc(@criterium2,A,options,delta0,empvario,delta1,estimatedelta);
   else
   A=A0;
   exitflag2=1;
   end
   [delta0,zz,exitflag1]=fmincon(@criterium1,delta0,[],[],[],[],[0.0001,0.0001,0.0001,0.0001,0.0001],[1000000,1000000,2000000,2000000,0.9999],[],options,A,empvario,delta1,estimatedelta); %%%
   delta0(estimatedelta==0)=delta1;
   delta0estimate=delta0;
   
   if abs(zz-zzv)<exactnesscov 
       break;
   else
       zzv=zz;
   end
    
end
exitflag= (exitflag1&exitflag2);
if(j>=250)
    exitflag=0;
end

Aestimate=A;


function z=criterium1(delta,A,empvario,delta1,estimatedelta)
delta(estimatedelta==0)=delta1;
laghx=empvario.laghx;
laghy= empvario.laghy;
nn=length(laghx);

A=(reshape(A,2,2));
B=A'*A;
for i=1:nn   
newh(i,:) = sqrt([laghx(i),laghy(i)]*B*[laghx(i);laghy(i)]);
end
v=empvario.v;
n=empvario.n;
gamma=covar(0,delta)-covar(newh,delta);
var= 2*(gamma.^2)./n;
summand=((gamma-v).^2)./var;
z=sum(summand);

function z=criterium2(A,delta,empvario,delta1,estimatedelta)
delta(estimatedelta==0)=delta1;
laghx=empvario.laghx;
laghy= empvario.laghy;
nn=length(laghx);

A=(reshape(A,2,2));
B=A'*A;
delta;
for i=1:nn   
newh(i,:) = sqrt([laghx(i),laghy(i)]*B*[laghx(i);laghy(i)]);
end
v=empvario.v;
n=empvario.n;
gamma=covar(0,delta)-covar(newh,delta);
var= 2*(gamma.^2)./n;
summand=((gamma-v).^2)./var;
z=sum(summand);


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
  %cov=delta(2)*exp(-3*h/delta(3));
  cov=delta(2)*((1-delta(5))*exp(-3*h/delta(3))+delta(5)*exp((-3*h.^2)/(delta(4)^2)));
end
