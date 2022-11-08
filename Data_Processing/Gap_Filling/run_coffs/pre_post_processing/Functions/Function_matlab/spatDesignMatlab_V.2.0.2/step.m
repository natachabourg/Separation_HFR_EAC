function [w,delta]=step(w,ldelta)
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
%  [w,delta]=step(w,ldelta)
%
%  calculates the contributions delta to the step function approximation of the 
%  polar spectral distribution function.
%
%  Inputs:
%
%  w...............the frequencies at which contributions should be 
%                  calculated.
%  
%  ldelta..........the parameters of the variogram function.
%                  ldelta=[nugget, sill, exponential range, Gaussian range,
%                          mixing factor]
%  
%  Outputs:
%  
%  delta...........the contributions (steps) to the polar spectral distribution 
%                  function
%
%  Example:
%
%  [wBoxGomeliso,deltaBoxGomeliso]=step(wBoxGomeliso,delta0BoxGomeliso);
%
%  [wBoxGomelaniso,deltaBoxGomelaniso]=step(wBoxGomelaniso,delta0BoxGomelaniso);
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for i=1:length(w)
   G(i)=polarspectraldist(w(i),ldelta);
end

for i=1:length(w)-1
   delta(i)=G(i+1)-G(i);
end

w=w(2:length(w));
delta(delta<0)=0.00001*min(delta(delta>0));
