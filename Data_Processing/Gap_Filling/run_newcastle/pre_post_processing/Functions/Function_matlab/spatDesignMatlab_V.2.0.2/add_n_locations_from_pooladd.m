function [xx,yy,avgkrigemsep,infM_1]=add_n_locations_from_pooladd(externaldrift,U,x0,y0,pooladdxy,sigma2,apriorivar,w,M,delta,xlower,xupper,ylower,yupper,polygon,nx,ny,n,calc,infM_1,criterion)
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
%  [xx,yy,avgkrigemsep]=add_n_locations_from_pooladd(externaldrift,U,x0,y0,pooladdxy,sigma2,apriorivar,w,M,delta,xlower,xupper,ylower,yupper,polygon,nx,ny,n,calc,infM_1,criterion)
%
%  calculates a spatial sampling design by adding n
%  designpoints to allready available sampling points (x0,y0). The 
%  designpoints are selected in such a way that either the integrated mean 
%  square kriging error of prediction or a D-optimality criterion is
%  minimized. 
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
%                 design points
%
%  y0.............the y-coordinates of the available 
%                 design points
%
%  pooladdxy......a matrix giving the x- and y-coordinates of the 
%                 designpoints onto which the algorithm
%                 should be applied. These design points may be added to
%                 the design. The sets [x0,y0] and pooladdxy must be
%                 disjunct.
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
%  polygon........the polygonal area of importance calculated by 
%                 means of the function polygon.
%
%  nx.............the number of points in the x-direction, where the
%                 design functionals should be calculated
%
%  ny.............the number of points in the y-direction, where the
%                 design functionals should be calculated
%
%  n..............the number of designpoints to be added to the already
%                 available design(x0,y0)
%
%  calc...........if calc==1, the informationmatrix is calculated
%
%  criterion......if criterion=="i" the integrated tmsep over an area of interest is minimized;
%                 if criterion=="d" a d-optimality criterion is minimized.
%
%
%  Outputs:
%
%  xx.............a cell array with vectors. Each vector giving the optimal x-coordinates of the i-point
%                 design, i=1,2,..n     
%
%  yy.............a cell array with vectors. Each vector giving the optimal y-coordinates of the i-point
%                 design,i=1,2,..n
%
%  avgkrigemsep...the average kriging tmsep of the calculated design
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
n11=length(x0);
x11=(xlower+xupper)/2;
y11=(ylower+yupper)/2;
x0=x0-x11;
y0=y0-y11;
pooladdx=pooladdxy(:,1);
pooladdy=pooladdxy(:,2);
pooladdx=pooladdx-x11;
pooladdy=pooladdy-y11;
xlower=xlower-x11;
xupper=xupper-x11;
ylower=ylower-y11;
yupper=yupper-y11;
polygon.x=polygon.x-x11;
polygon.y=polygon.y-y11;
if ~isempty(externaldrift)
   externaldrift{1}(:,1)=externaldrift{1}(:,1)-x11;
   externaldrift{1}(:,2)=externaldrift{1}(:,2)-y11;
   m=size(externaldrift{2},2);
else
   m=0;
end


% a priori covariance matrix
phi=aprioricovmattrend(externaldrift,w,delta,sigma2,apriorivar,M);

% calculate first informationmatrix
ninf=size(phi,1);
infM1=inv(phi(1:3+m,1:3+m));
infM2=diag(1./diag(phi(4+m:end,4+m:end)));
invphi=zeros(ninf,ninf);
invphi(1:3+m,1:3+m)=infM1;
invphi(4+m:end,4+m:end)=infM2;

if isempty(x0)
    calc=0;
    n11=0;
    infM=invphi;
    infM_1=phi;
end

if calc==1
infM=invphi;
rf=regressionfunctiontrend(externaldrift,x0(1),y0(1),w,M);
infM=rf*rf'+infM; 
A_1=phi;
infM_1=A_1-(1/(1+rf'*A_1*rf))*A_1*(rf*rf')*A_1;
end

if calc==1
for s=2:n11
  s
   rf=regressionfunctiontrend(externaldrift,x0(s),y0(s),w,M);
   infM_1rf=infM_1*rf;
   infM_1=(s/(s-1))*(infM_1-(infM_1rf*infM_1rf')/((s-1)+infM_1rf'*rf));
   
end  
end

x111=xlower:(xupper-xlower)/(nx-1):xupper;
y111=ylower:(yupper-ylower)/(ny-1):yupper;
for i=1:length(x111)
   for j=1:length(y111)
       [zzz(i,j),zzzz(i,j)]=inpolygon1([x111(i);y111(j)],w,M,U,infM_1,i,polygon,criterion,externaldrift);
       XX(i,j)=x111(i);
       YY(i,j)=y111(j);
   end
end
ind0=find(zzzz==0);
xxx=XX(ind0);
yyx=YY(ind0);

for s=n11+1:n+n11  
   % in each iteration minimize
   fprintf('Iteration: %f \n',s-n11);
   z=[];
   for i=1:length(pooladdx)
      h=i
      z(i)=optimxiyiadd([pooladdx(i),pooladdy(i)]',w,M,U,infM_1,s-1,polygon,criterion,externaldrift);
   end
   ind=find(z==min(z));
   ind=ind(1);
   addedx=pooladdx(ind);
   addedy=pooladdy(ind);
   if ind==1
     pooladdx=pooladdx(ind+1:end);
     pooladdy=pooladdy(ind+1:end);
   else
     pooladdx=[pooladdx(1:ind-1);pooladdx(ind+1:end)];
     pooladdy=[pooladdy(1:ind-1);pooladdy(ind+1:end)];
   end
   
   clear z 
   fprintf('proposed x = %f \n',addedx+x11);
   fprintf('proposed y = %f \n',addedy+y11); 
   x(s-n11)=addedx;
   y(s-n11)=addedy;
   
   % calculate information matrix
   rf=regressionfunctiontrend(externaldrift,addedx,addedy,w,M);
   infM_1rf=infM_1*rf;
   infM_1=(s/max([(s-1),1]))*(infM_1-(infM_1rf*infM_1rf')/(max([(s-1),1])+infM_1rf'*rf));
   avgkrigemsep(s-n11)=sigma2*(1+trace(U*infM_1)/s);
   xxxx{s-n11}=x;
   yyyy{s-n11}=y;
end

for i=1:n
   xx{i}=xxxx{i}+x11;
   yy{i}=yyyy{i}+y11;
end














