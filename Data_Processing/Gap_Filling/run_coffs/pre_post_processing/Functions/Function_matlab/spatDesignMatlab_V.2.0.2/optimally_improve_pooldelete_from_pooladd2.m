function [x,y,avgkrigemsep,infM_1,pooladdx,pooladdy,pooldeletex,pooldeletey]=optimally_improve_pooldelete_from_pooladd2(externaldrift,U,x0,y0,pooladdxy,pooldeletexy,sigma2,apriorivar,w,M,delta,xlower,xupper,ylower,yupper,maxiterations,polygon,nx,ny,calc,infM_1,criterion)
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
%  [x,y,avgkrigemsep]=optimally_improve_pooldelete_from_pooladd2(externaldrift,U,x0,y0,pooladdxy,pooldeletexy,sigma2,apriorivar,w,M,delta,xlower,xupper,ylower,yupper,maxiterations,polygon,nx,ny,calc,infM_1,criterion)
%
%  calculates an optimal spatial sampling design. Design points from 
%  "pooldelete" are exchanged to design points from "pooladd". The 
%  design points are selected in such a way that either the integrated mean 
%  square kriging error of prediction or a D-optimality criterion is 
%  minimised. An exchange type algorithm is used for calculating the
%  optimal spatial design of n design points.
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
%  U..............a matrix calculated by the function weightingmatUtrend, 
%                 giving part of the necessary information on the 
%                 integrated mean square error of prediction.
%
%  x0.............the x-coordinates of the available 
%                 designpoints
%
%  y0.............the y-coordinates of the available 
%                 designpoints
%
%  pooladdxy......a matrix giving the x- and y-coordinates of the 
%                 designpoints onto which the exchange type algorithm
%                 should be applied. These design points may be added to
%                 the design. The sets [x0,y0] and pooladdxy must be
%                 disjunct.
%
%  pooldeletexy...a matrix giving the x- and y-coordinates of the 
%                 designpoints onto which the exchange type algorithm
%                 should be applied. These design points may be deleted
%                 from the design. The set pooldeletexy must be a subset of
%                 [x0,y0].
%
%  sigma2.........the nugget effect not accounted for by the 
%                 approximation through a linear regression model
%
%  apriorivar.....the a priori variance matrix. 
%
%  w..............a vector containing the frequencies for the bessel 
%                 approximations
%
%  M..............an integer number giving the highest frequency for the
%                 cosinus-sinus approximation
% 
%  delta..........the contributions to the polar spectral distribution
%                 function, calculated from the function step. 
%
%  xlower.........the lower x-limit for the area of importance
%
%  xupper.........the upper x-limit for the area of importance
%
%  ylower.........the lower y-limit for the area of importance
%
%  yupper.........the upper y-limit for the area of importance
%
%  maxiterations..the maximum number of iterations to be used for
%                 adding and deleting points
%
%  polygon........the polygonal area of importance calculated by 
%                  means of the function polygon.
%
%  nx.............the number of points in the x-direction, where the
%                 design functionals should be calculated
%
%  ny.............the number of points in the y-direction, where the
%                 design functionals should be calculated
%  calc...........if calc==1 the information matrix and inverse information matrix is calculated
%
%  infM...........the information matrix
%
%  infM_1.........the inverse information matrix
%
%  criterion......if criterion=="i" the integrated tmsep over an area of interest is minimised;
%                 if criterion=="d" a D-optimality criterion is minimized.
%
%  Outputs:
%
%  x............. a vector giving the optimal x-coordinates of the 
%                 design points for an n-point design. 
%
%  y..............a vector giving the optimal y-coordinates of the
%                 design points for an n-point design.
%
%  avgkrigemsep...the average kriging msep of the calculated design
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
epsilon=0.001;
n1=length(x0);

x11=(xlower+xupper)/2;
y11=(ylower+yupper)/2;
x0=x0-x11;
y0=y0-y11;
xlower=xlower-x11;
xupper=xupper-x11;
ylower=ylower-y11;
yupper=yupper-y11;
polygon.x=polygon.x-x11;
polygon.y=polygon.y-y11;

pooladdx=pooladdxy(:,1);
pooladdy=pooladdxy(:,2);
pooladdx=pooladdx-x11;
pooladdy=pooladdy-y11;

pooldeletex=pooldeletexy(:,1);
pooldeletey=pooldeletexy(:,2);
pooldeletex=pooldeletex-x11;
pooldeletey=pooldeletey-y11;

if ~isempty(externaldrift)
   externaldrift{1}(:,1)=externaldrift{1}(:,1)-x11;
   externaldrift{1}(:,2)=externaldrift{1}(:,2)-y11;
   m=size(externaldrift{2},2);
else
   m=0;
end

clear pooladdxy pooldeletexy

if calc==1
% a priori covariance matrix
phi=aprioricovmattrend(externaldrift,w,delta,sigma2,apriorivar,M);

% calculate first informationmatrix
ninf=size(phi,1);
infM1=inv(phi(1:3+m,1:3+m));
infM2=diag(1./diag(phi(4+m:end,4+m:end)));
invphi=zeros(ninf,ninf);
invphi(1:3+m,1:3+m)=infM1;
invphi(4+m:end,4+m:end)=infM2;

rf=regressionfunctiontrend(externaldrift,x0(1),y0(1),w,M);
infM=invphi;
infM=rf*rf'+infM;
A_1=phi;
infM_1=A_1-(1/(1+rf'*A_1*rf))*A_1*(rf*rf')*A_1;

for s=2:n1
   s
   rf=regressionfunctiontrend(externaldrift,x0(s),y0(s),w,M);
   infM_1rf=infM_1*rf;
   infM_1=(s/(s-1))*(infM_1-(infM_1rf*infM_1rf')/((s-1)+infM_1rf'*rf));
end
end

for s=1:maxiterations
   fprintf('Iteration: %f \n',s); 
   
   % the point tob deleted from design
   for i=1:length(pooldeletex)
      h=i
      zz(i)=optimxiyidelete(pooldeletex(i),pooldeletey(i),w,M,U,infM_1,n1-1,polygon,criterion,externaldrift);
   end
   kd=find(zz==min(zz)); %the index of the point to be deleted
   kd=kd(1);
   clear zz i
   deletedx=pooldeletex(kd);
   deletedy=pooldeletey(kd); 
   fprintf('proposed x to be deleted from design = %f \n',deletedx+x11);
   fprintf('proposed y to be deleted from design = %f \n',deletedy+y11);
   if kd==1
     pooldeletex=pooldeletex(kd+1:end);
     pooldeletey=pooldeletey(kd+1:end);
   else
     pooldeletex=[pooldeletex(1:kd-1);pooldeletex(kd+1:end)];
     pooldeletey=[pooldeletey(1:kd-1);pooldeletey(kd+1:end)];
   end
   pooladdx=[pooladdx;deletedx];
   pooladdy=[pooladdy;deletedy];
   
   kd=find(sqrt((x0-deletedx).^2 + (y0-deletedy).^2)<=epsilon);
   kd=kd(1);
   if kd==1
     x0=x0(kd+1:end);
     y0=y0(kd+1:end);
   else
     x0=[x0(1:kd-1);x0(kd+1:end)];
     y0=[y0(1:kd-1);y0(kd+1:end)];
   end
 
   %calculate information matrix
   rf=regressionfunctiontrend(externaldrift,deletedx,deletedy,w,M);
   infM_1rf=infM_1*rf;
   infM_1=((n1-1)/n1)*(infM_1+(infM_1rf*infM_1rf')/(n1-infM_1rf'*rf));
 
   % the point to be added to design  
   for i=1:length(pooladdx)
      h=i
      zz(i)=optimxiyiadd([pooladdx(i),pooladdy(i)],w,M,U,infM_1,n1-1,polygon,criterion,externaldrift);
   end
   kd=find(zz==min(zz)); %the index of the point to be deleted
   kd=kd(1);
   clear zz i
   addedx=pooladdx(kd);
   addedy=pooladdy(kd); 
   fprintf('proposed x to be added to design = %f \n',addedx+x11);
   fprintf('proposed y to be added to design = %f \n',addedy+y11);
   pooldeletex=[pooldeletex;addedx];
   pooldeletey=[pooldeletey;addedy];
   if kd==1
     pooladdx=pooladdx(kd+1:end);
     pooladdy=pooladdy(kd+1:end);
   else
     pooladdx=[pooladdx(1:kd-1);pooladdx(kd+1:end)];
     pooladdy=[pooladdy(1:kd-1);pooladdy(kd+1:end)];
   end 
   x0=[x0;addedx];
   y0=[y0;addedy];
   
   rf=regressionfunctiontrend(externaldrift,addedx,addedy,w,M);
   infM_1rf=infM_1*rf;
   infM_1=(n1/(n1-1))*(infM_1-(infM_1rf*infM_1rf')/((n1-1)+infM_1rf'*rf));
   if sqrt((addedx-deletedx)^2 + (addedy-deletedy)^2)<=epsilon
       break;
   end 
end

n=length(x0);
UinfM_1=U*infM_1;
trUinfM_1=trace(UinfM_1);
avgkrigemsep=sigma2*(1+(1/n)*trUinfM_1);
x=x0+x11;
y=y0+y11;
pooldeletex=pooldeletex+x11;
pooldeletey=pooldeletey+y11;
pooladdx=pooladdx+x11;
pooladdy=pooladdy+y11;











