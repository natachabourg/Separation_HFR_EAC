function phi=aprioricovmattrend(externaldrift,w,delta,sigma2,apriorivar,M)
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
%  phi=aprioricovmattrend(externaldrift,w,delta,sigma2,apriorivar,M)
%  
%  calculates the a priori covariance matrix for the approximating linear
%  regression model.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

nw=size(w,2);
k=0;
for m=1:M+1
    if m==1
       d=1;
    else
       d=2;
    end
    for j=1:nw
        k=k+1;
        phi1(k)=d*delta(j);
    end
end

k=0;
for m=2:M+1
    for j=1:nw
       k=k+1;
       phi2(k)=2*delta(j);
   end
end

phi12=diag([phi1,phi2])/sigma2;
n12=size(phi12,1);
n3=size(apriorivar,1);
if  ~isempty(externaldrift)
    phidrift=externaldrift{4};
    m=size(externaldrift{2},2);
    n=n3+m+n12;
    phi=zeros(n,n);
    phi(1:n3,1:n3)=apriorivar/sigma2;
    phi(n3+1:n3+m,n3+1:n3+m)=phidrift/sigma2;
    phi(n3+m+1:n,n3+m+1:n)=phi12;
else
    n=n3+n12;
    phi=zeros(n,n);
    phi(1:n3,1:n3)=apriorivar/sigma2;
    phi(n3+1:n,n3+1:n)=phi12;
end
