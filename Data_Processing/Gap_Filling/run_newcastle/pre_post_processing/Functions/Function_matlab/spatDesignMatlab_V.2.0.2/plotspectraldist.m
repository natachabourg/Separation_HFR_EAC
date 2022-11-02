function plotspectraldist(w,ldelta)
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
%  plotspectraldist(w,ldelta)
%  
%  plots the polar spectral distribution function of a mixture of
%  an exponential and Gaussian covariance function.
%  
%  Inputs:
%
%  w............a vector of frequencies
%
%  ldelta...... a vector of covariance parameters.
%               ldelta=[nugget, sill, exponential range, Gaussian range,
%                       mixing parameter]
%  
%  Example:
%
%  plotspectraldist(0:0.01:2,delta0BoxGomeliso);
%  
%  plotspectraldist(0:0.01:2,delta0BoxGomelaniso);
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for i=1:length(w)
  G(i)=polarspectraldist(w(i),ldelta);
end

plot(w,G)
title('polar spectral distribution function')

