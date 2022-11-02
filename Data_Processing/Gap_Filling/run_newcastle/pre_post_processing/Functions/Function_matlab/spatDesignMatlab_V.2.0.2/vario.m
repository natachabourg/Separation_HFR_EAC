function v=vario(h,delta0)
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
%  v=vario(h,delta0)
%
%  calculates a theoretical variogram function, which is a convex
%  combination of an exponential and a Gaussian variogram model.
%
%  Inputs:
%
%  h..................the lag
%
%  delta0.............variogram parameters 
%                     =[nugget, sill, exp. range, Gaussian range, mixing parameter]
%
%  Output:
%
%  v..................the value of the variogram function at lag h
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 
if delta0(3)==0 
  delta0(3)=0.0000000000000001;
end
if delta0(4)==0 
  delta0(4)=0.0000000000000001;
end

if h==0
  v=delta0(1);
else
  v=delta0(2)+delta0(1)-delta0(2)*((1-delta0(5))*exp(-3*h/delta0(3))+delta0(5)*exp((-3*h.^2)/(delta0(4)^2)));
end