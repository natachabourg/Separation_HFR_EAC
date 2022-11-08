function y=transform(x,lambda)
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
%  y=transform(x,lambda)
%
%  calculates the Box-Cox transformed data.
%
%  Inputs:
%
%  x.........the data vector
%
%  lambda ...the Box-Cox parameter 
%
%  Outputs:
%
%  y.........the transformed data vector
%
%  Example:
%
%  BoxGomeliso.z=transform(Gomel.zaver,lambda0BoxGomeliso);
%
%  BoxGomelaniso.z=transform(Gomel.zaver,lambda0BoxGomelaniso);
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if ~(lambda==0)
   y=((x.^lambda)-1)/lambda;
else
   y=log(x);
end

