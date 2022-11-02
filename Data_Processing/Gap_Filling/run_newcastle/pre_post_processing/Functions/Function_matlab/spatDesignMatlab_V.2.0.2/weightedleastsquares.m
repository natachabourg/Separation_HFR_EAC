function [delta0,exitflag]=weightedleastsquares(empvario,nugget0,sill0,rangee0,rangeg0,alpha0,estimatedelta)
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
%  [delta0,exitflag]=weightedleastsquares(empvario,nugget0,sill0,rangee0,rangeg0,alpha0,estimatedelta)
%
%  fits an empirical variogram by means of weighted least squares.
%
%  Remark: It may happen that you must change the parameters in the
%  function optimset in order to speed up convergence of the optimization
%  routines. Furthermore it can become necessary to adjust the upper and 
%  lower bounds in the function fmincon.
%
%  Inputs:
%
%  empvario......the empirical variogram calculated from the function 
%                empvariogram
%
%  nugget0.......initial value for the nugget effect close to the true 
%                nugget effect
%
%  sill0.........initial value for the sill close to the true sill
%
%  rangee0.......initial value for the range of the exponential variogram
%                close to the true exponential range
%
%  rangeg0.......initial value for the range of the Gaussian variogram
%                close to the true Gaussian range
%
%  alpha0........initial value for the true mixture parameter. The 
%                variogram is supposed to be a mixture of an
%                exponential and a Gaussian variogram
%
%  estimatedelta..a vector of length 5 of 0's and 1's indicating what
%                 parameters of the covariance function should be estimated
%
%  Output:
%
%  delta0........the estimated variogram parameters
%
%  exitflag......it is 1 if the algorithm has converged 0 else
%
%  Example:
%
%  [delta0BoxGomelisowls,exitflagBoxGomelisowls]=weightedleastsquares(empvarioBoxGomeliso,0,2.4,80,80,0.6,[1,1,1,1,1]);
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
delta0=[nugget0,sill0,rangee0,rangeg0,alpha0];
delta1=delta0(estimatedelta==0);
options=optimset('LargeScale','off','MaxFunEvals',350000,'MaxIter',250000,'TolCon', 1e-6,'TolFun', 1e-6);
[delta0,zz,exitflag]=fmincon(@criterium,delta0,[],[],[],[],[0.0001,0.0001,0.0001,0.0001,0.0001],[1000000,1000000,2000000,2000000,0.9999],[],options,empvario,delta1,estimatedelta);%%%
delta0(estimatedelta==0)=delta1;
figure(2)
plot(empvario.lagh,empvario.v,'-o')
hold on
plot(empvario.lagh,covar(0,delta0)-covar(empvario.lagh,delta0),'r-')
title('empirical semivariogram and weighted least squares fit')
hold off
pause(1)

function z=criterium(delta,empvario,delta1,estimatedelta)
delta(estimatedelta==0)=delta1;
lagh=empvario.lagh;
v=empvario.v;
n=empvario.n;

gamma=covar(0,delta)-covar(lagh,delta);
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