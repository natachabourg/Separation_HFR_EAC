function U=weightingmatUtrend(externaldrift,w,M,xlower,xupper,ylower,yupper,nx,ny,poly)
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
%  U=weightingmatUtrend(externaldrift,w,M,xlower,xupper,ylower,yupper,nx,ny,poly)
%
%  calculates the matrix U, which contains part of the information on the
%  integrated mean square error of prediction.
%
%  Inputs:
%
%  externaldrift....is a cell array
%
%  externaldrift{1}.a 2-column matrix containing the grid of the 
%                   x- and y-coordinates of the external drift
%
%  externaldrift{2}.a matrix with the number of columns equal to the number
%                   of external drift variables and the same number of rows as 
%                   externaldrift{1}
%  externaldrift{3}.a row vector with the same number of columns as
%                   externaldrift{2} giving the a priori mean for the
%                   regression coefficients of the linear external drift.
%  externeldrift{4}.the a priori covariance matrix for the linear external
%                   drift regression coefficients.
%
%  w...............a vector containing the frequencies for the
%                  Bessel harmonics
%
%  M...............an integer giving the maximum frequency for the
%                  sine-cosine harmonics
%
%  xlower..........the smallest x-coordinate of the area of importance
%
%  xupper..........the largest x-coordinate of the area of importance
%
%  ylower..........the smallest y-coordinate of the area of importance
%
%  yupper..........the largest y-coordinate of the area of importance
%
%  nx..............the number of points in the x-direction, where the
%                  mean square error of prediction should be calculated
%
%  ny..............the number of points in the y-direction, where the
%                  mean square error of prediction should be calculated
%
%  poly............poly calculated from the function polygon and giving
%                  the area of importance
%
%  Output:
%
%  U................the matrix containing part of the information on the
%                   integrated mean square error of prediction
%
%  Example:
%
%  UBoxGomeliso=weightingmatUtrend({},wBoxGomeliso,35,-100,200,-50,250,100,100,polyBoxGomeliso);
%
%  UBoxGomelaniso=weightingmatUtrend({},wBoxGomelaniso,35,-75,150,-50,350,100,100,polyBoxGomelaniso);
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
X=poly.x;
Y=poly.y;
x=(xlower:(xupper-xlower)/(nx-1):xupper)';
y=(ylower:(yupper-ylower)/(ny-1):yupper)';

x11=(xlower+xupper)/2;
y11=(ylower+yupper)/2;
x=x-x11;
y=y-y11;
xlower=xlower-x11;
xupper=xupper-x11;
ylower=ylower-y11;
yupper=yupper-y11;
X=X-x11;
Y=Y-y11;
if ~isempty(externaldrift)
   externaldrift{1}(:,1)=externaldrift{1}(:,1)-x11;
   externaldrift{1}(:,2)=externaldrift{1}(:,2)-y11;
end

U=0;
k=0;
l=0;
for i=1:nx
    for j=1:ny
        k=k+1
        ind=inside(x(i)+sqrt(-1)*y(j),X'+sqrt(-1)*Y');
        %ind=inpolygon(x(i),y(j),X',Y'); 
        if ~isempty(ind)
           rf=regressionfunctiontrend(externaldrift,x(i),y(j),w,M);
           U=U+rf*rf';
           l=l+1;
        end
    end
end
U=U/l;

