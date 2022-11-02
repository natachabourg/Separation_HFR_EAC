function G=polarspectraldist(w,ldelta)
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
%  G=polarspectraldist(w,ldelta)
%
%  calculates the polar spectral distribution function.
%
%  Remark: It may happen that you must change the upper integration limit 
%  (4000) in the function quadl in order to properly calculate the polar
%  spectral distribution function.
%
%  Inputs:
%
%  w................the frequency at which the 
%                   spectral distribution function should be calculated
%
%  ldelta...........the parameters of the theoretical variogram model.
%                   ldelta=[nugget, sill, exponential range, Gaussian
%                           range, mixing parameter]
%
%  Outputs:
%
%  G................the value of the spectral distribution function at 
%                   frequency w
%
%  Example:
%
%  polarspectraldist(0.5,delta0BoxGomeliso);
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
% The polar spectral distribution function

    G=(1/gamma(1))*quadl(@besseljC,0,25000,0.00000000000001,0,w,ldelta);
       
function B=besseljC(x,w,ldelta)

    B=besselj(1,x.*w).*(x.*w).*covar(x,ldelta)./x;
   
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