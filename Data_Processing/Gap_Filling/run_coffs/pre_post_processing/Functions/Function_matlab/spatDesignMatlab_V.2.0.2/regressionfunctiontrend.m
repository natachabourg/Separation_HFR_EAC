function rf=regressionfunctiontrend(externaldrift,x,y,w,M)
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
%  rf=regressionfunctiontrend(externaldrift,x,y,w,M)
%  vector containing all Cosinus-Sinus-Bessel surfaceharmonics.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
nw=size(w,2);
k=0;
for m=1:M+1
    for j=1:nw
        k=k+1;
        cbrf(k)=cosinusbessel(x,y,m-1,w(j));
    end
end

k=0;
for m=2:M+1
    for j=1:nw
       k=k+1;
       sbrf(k)=sinusbessel(x,y,m-1,w(j));
   end
end
if ~isempty(externaldrift)
   X=externaldrift{1}(:,1);
   Y=externaldrift{1}(:,2);
   Z=sqrt((X-x).^2+(Y-y).^2);
   [dummy,ind]=min(Z);
   if size(externaldrift{2},2)>1
      z=externaldrift{2}(ind,:);
   else
      z=externaldrift{2}(ind);
   end
   rf=[1,x,y,z,cbrf,sbrf]';
else
   rf=[1,x,y,cbrf,sbrf]';
end
