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
%  This is an example session demonstrating the capabilities of the spatial
%  sampling design toolbox.
%
%
%  The data set that we consider are the so-called Gomel data; a data
%  set of 591 Cesium137 measurements in the region of Gomel, Belarus, ten
%  years after the Chernobyl accident.
%  All variables calculated during this session have been stored in the
%  file designGomel.mat. The exceptions are UBoxGomeliso and UBoxGomelaniso.
%  These matrices are very large in storage space and have to be recalculated
%  in point 6.) and 10.) before doing spatial sampling design.
%
%
%  1.) Let us first visualize the sampling locations:
%
%   load designGomel
%   plot(Gomel.x,Gomel.y,'o')
%
%  Obviously the sampling locations are more dense in the East than in the
%  West.
%
%
%  2.) Next let us look at the histogram of the Cesium137 concentrations:
%
%   hist(Gomel.zaver,25)
%
%  The data are obviously very heavily skewed to the right.
%
%
%  3.) Ordinary kriging supposes the data to be Gaussian. So let's
%  transform the data to Gaussianity by means of a Box-Cox transformation.
%  The next function simultaneously estimates this transformation and the
%  covariance function by means of maximum likelihood.
%
%   options=optimset('LargeScale','on','MaxFunEvals',200,'TolFun',1e-3,'MaxIter',100);
%   [lambda0BoxGomeliso,delta0BoxGomeliso]=estimate_transfo_cov_ml(Gomel.x,Gomel.y,Gomel.zaver,0,[1,0;0,1],[0,2.4,80,80,0.6],0:15:150,10,-20,20,0.01,1,[1,1,1,1,1],0,0.001,0.001,options);
%   save designGomel
%   
%  Now lets transform the concentrations to Gaussianity and visualize their
%  histogram:
%
%   BoxGomeliso.z=transform(Gomel.zaver,lambda0BoxGomeliso);
%   hist(BoxGomeliso.z,25)
%   BoxGomeliso.x=Gomel.x;
%   BoxGomeliso.y=Gomel.y;
%   save designGomel  
%
%  Obviously the histogram of the transformed data is more close to Gaussianity.
%
%  Let's estimate the covariance function once more by means of 
%  calculating the empirical variogram and a weighted least squares fit:
%  
%   empvarioBoxGomeliso= empvariogram(BoxGomeliso.x,BoxGomeliso.y,BoxGomeliso.z, 0:5:150);
%   [delta0BoxGomelisowls,exitflagBoxGomelisowls]=weightedleastsquares(empvarioBoxGomeliso,0,2.4,80,80,0.6,[1,1,1,1,1]);
% 
%  Obviously the weighted least squares fit is somewhat different from the
%  ML-estimate of the variogram.  Let us check now also for geometric
%  anisotropy:
%
%   empvariogramaniso(BoxGomeliso.x,BoxGomeliso.y,BoxGomeliso.z,0:10:150,15);
%
%  There seems to be some anisotropy present. For all that, we will go on to work
%  with the isotropic ML-estimate of the covariance function, calculated 
%  first. We will show later, how to work with anisotropic covariance
%  functions.
%
%
%  4.) Next comes the approximation of the isotropic random field by means
%  of a linear regression model, whose regression functions are
%  cosine-sine-Bessel surface harmonics, and whose regression coefficients
%  are random:
%
%  For this purpose let us first of all calculate the polar spectral
%  distribution function:
%
%   plotspectraldist(0:0.01:2,delta0BoxGomeliso);
%
%  Obviously at about w=1.65 the polar spectral distribution function
%  attains 95% of its maximum value delta0BoxGomeliso(2)=2.8175.
%  (It may happen that you have to change the integration limits in the
%  function polarspectraldist.m to get the polar spectral distribution
%  function properly calculated.)
%
%  Next is the approximation of the polar spectral distribution function by
%  means of a step function. The hight of the different steps gives the
%  variances of the random regression coefficients in the approximating
%  cosine-sine-Bessel surface harmonics regression model.
%
%   load wscaled
%
%  wscaled is vector of frequencies w and has to be properly scaled:
%  
%   wBoxGomeliso=wscaled*1.65;
%   save designGomel
%
%  The next function calculates the steps deltaBoxGomeliso at frequencies
%  wBoxGomeliso. The steps are a discrete spectrum:
%
%   [wBoxGomeliso,deltaBoxGomeliso]=step(wBoxGomeliso,delta0BoxGomeliso);
%   save designGomel
%   plot(wBoxGomeliso,deltaBoxGomeliso,'o')
%
%
%  5.) Next let's see how good the worst approximating covariance function
%  from the linear cosine-sine-Bessel surface harmonics regression model with random
%  coefficients  approximates close to the border of the design region the   
%  true covariance function. We calculate this worst approximating 
%  covariance function at 200 Northing and assume for our approximating 
%  regression model a largest frequency M=35:
%
%    plotcovarianceapprox(wBoxGomeliso,35,deltaBoxGomeliso,delta0BoxGomeliso,-100:3:200,250,-100,-100,200,-50,250);
%
%  Obviously the blue approximating covariance function approximates the
%  true covariance function quite well. Only close to lag 0 there is some
%  larger difference. Zooming into the plot we see that this difference at
%  lag 0 is about 0.22. This is variance of the true random field not taken
%  into account by the random amplitudes of the approximating regression
%  model. We will thus later add this value 0.22 to the nugget effect
%  delta0BoxGomeliso(1)=0.2969 and assume an error variance of 0.22+0.2969 
%  for the approximating regression model. Thus, small scale variation 
%  of the true random field not taken into account by the approximating 
%  regression model will be modelled as a pure nugget effect.
% 
%  M=35 and wBoxGomeliso result together with a linear trend function for
%  the random field in an approximating mixed linear model with 2417
%  regression functions.
%
%
%  6.) Now we have everything that we need to do spatial sampling design by
%  means of doing experimental design for the approximating mixed linear 
%  regression model. Powerful tools can be borrowed from experimental
%  design theory to calculate spatial sampling designs. Details on the now
%  following experimental (spatial) sampling design algorithms are given in
%  the accompanying paper serra09_spoeck_pilz.pdf.
%
%  First of all we have to calculate the matrix U described in this paper
%  containing information on the average (over the design region) total
%  mean squared error of the Bayesian kriging predictor:
%  We first select the design region and then calculate this matrix U of
%  dimension 2417*2417:
%
%   polyBoxGomeliso=polygon(-100,200,-50,250,BoxGomeliso.x,BoxGomeliso.y);
%   save designGomel
%
%  Select the appropriate design region with the mouse and type "return",
%  when you have finished.
%
%   UBoxGomeliso=weightingmatUtrend({},wBoxGomeliso,35,-100,200,-50,250,100,100,polyBoxGomeliso);
%   save designGomel
%
%
%  7.) Since the sampling locations are much more dense in the East of the
%  design region than in the West, we next consider the optimal deletion of
%  292 sampling locations, such that the resulting design has only 299
%  sampling locations. An exchange algorithm from optimal experimental
%  design theory is applied to the approximating regression model. See the
%  accompanying paper serra09_spoeck_pilz.pdf for details on this deletion
%  algorithm. The minimization of the average kriging variance over the
%  design region and ordinary kriging are considered. Since a linear 
%  deterministic trend is modelled in the approximating regression model 
%  and Bayesin kriging is considered there, one can get ordinary kriging by
%  means of giving the first constant deterministic regression function a very large
%  a priori variance and the other components a very small a priori
%  variance. This procedure results in the a priori covariance matrix
%  apriorivar=[10000000,0,0;0,0.00000001,0;0,0,0.00000001].
%  If one wants to consider instead of the minimization of the average
%  kriging variance over the design region a D-optimality criterion one has
%  to set criterion='d'.
%
%   [xoptimallydeletefrompooldeleteBoxGomeliso_i,yoptimallydeletefrompooldeleteBoxGomeliso_i,avgkrigevaroptimallydeletefrompooldeleteBoxGomeliso_i]=optimally_delete_n_locations_from_pooldelete({},UBoxGomeliso,BoxGomeliso.x,BoxGomeliso.y,[BoxGomeliso.x,BoxGomeliso.y],0.22+delta0BoxGomeliso(1),[10000000,0,0;0,0.00000001,0;0,0,0.00000001],wBoxGomeliso,35,deltaBoxGomeliso,292,-100,200,-50,250,1000,polyBoxGomeliso,41,41,'i');
%   save designGomel
%   plot(xoptimallydeletefrompooldeleteBoxGomeliso_i{146},yoptimallydeletefrompooldeleteBoxGomeliso_i{146},'o')
%   hold on
%   plot(polyBoxGomeliso.x,polyBoxGomeliso.y,'r-')
%   title('299 point design')
%
%  Obviously those sample locations are removed first that are very close to
%  other samples and thus are redundant. The design with 299 sample
%  locations and 292 locations removed is very similar to a space filling
%  design. A look at Figure 1500 shows how the average kriging varince
%  calculated over the admissible design area only slightly increases.
%
%  The function optimally_delete_n_locations_from_pooldelete may be used
%  not only to delete locations from the full data set but from a pool of
%  admissible locations, too. In the following we assume that only locations
%  from the first 100 locations in BoxGomeliso may be deleted. We delete 20
%  locations from there.
%
%   pooldeletexy=[BoxGomeliso.x(1:100),BoxGomeliso.y(1:100)];
%   [xoptimallydeletefrompooldeleteBoxGomeliso_i2,yoptimallydeletefrompooldeleteBoxGomeliso_i2,avgkrigevaroptimallydeletefrompooldeleteBoxGomeliso_i2]=optimally_delete_n_locations_from_pooldelete({},UBoxGomeliso,BoxGomeliso.x,BoxGomeliso.y,pooldeletexy,0.22+delta0BoxGomeliso(1),[10000000,0,0;0,0.00000001,0;0,0,0.00000001],wBoxGomeliso,35,deltaBoxGomeliso,20,-100,200,-50,250,1000,polyBoxGomeliso,41,41,'i');
%   save designGomel
%
%
%  8.) Next, let us add to the previously generated 299 point sampling
%  design in an optimal way further 100 locations:
%
%    [xoptimallyaddfrompoolcompleteBoxGomeliso_i,yoptimallyaddfrompoolcompleteBoxGomeliso_i,avgkrigevaroptimallyaddfrompoolcompleteBoxGomeliso_i]=optimally_add_n_locations_from_poolcomplete({},UBoxGomeliso,xoptimallydeletefrompooldeleteBoxGomeliso_i{146},yoptimallydeletefrompooldeleteBoxGomeliso_i{146},0.22+delta0BoxGomeliso(1),[10000000,0,0;0,0.00000001,0;0,0,0.00000001],wBoxGomeliso,35,deltaBoxGomeliso,100,-100,200,-50,250,1000,polyBoxGomeliso,41,41,'i'); 
%    save designGomel
%
%  Areas that are empty are filled first with design locations. Overall the
%  299+100 point sampling design looks very close to a space filling design.
%
%  Besides adding design locations from the complete design region it is
%  also possible to add locations from a pool of locations to be added.
%  Since we have no such pool available we generate a regular grid of
%  design locations to be possibly added:
%
%    [xgrid,ygrid]=generategrid(-100,200,-50,250,41,41,polyBoxGomeliso);
%    pooladdxy=[xgrid,ygrid];
%    [xoptimallyaddfrompooladdBoxGomeliso_i,yoptimallyaddfrompooladdBoxGomeliso_i,avgkrigevaroptimallyaddfrompooladdBoxGomeliso_i]=optimally_add_n_locations_from_pooladd({},UBoxGomeliso,xoptimallydeletefrompooldeleteBoxGomeliso_i{146},yoptimallydeletefrompooldeleteBoxGomeliso_i{146},pooladdxy,0.22+delta0BoxGomeliso(1),[10000000,0,0;0,0.00000001,0;0,0,0.00000001],wBoxGomeliso,35,deltaBoxGomeliso,100,-100,200,-50,250,1000,polyBoxGomeliso,41,41,'i');
%    save designGomel
%
%  If you have no design locations already available but want to start
%  spatial sampling design from scratch, then you can do it in the
%  following way:
%
%    [xoptimallyaddfrompoolcompleteBoxGomelisoscratch_i,yoptimallyaddfrompoolcompleteBoxGomelisoscratch_i,avgkrigevaroptimallyaddfrompoolcompleteBoxGomelisoscratch_i]=optimally_add_n_locations_from_poolcomplete({},UBoxGomeliso,[],[],0.22+delta0BoxGomeliso(1),[10000000,0,0;0,0.00000001,0;0,0,0.00000001],wBoxGomeliso,35,deltaBoxGomeliso,100,-100,200,-50,250,1000,polyBoxGomeliso,41,41,'i'); 
%    save designGomel
% 
%    [xgrid,ygrid]=generategrid(-100,200,-50,250,41,41,polyBoxGomeliso);
%    pooladdxy=[xgrid,ygrid];
%    [xoptimallyaddfrompooladdBoxGomelisoscratch_i,yoptimallyaddfrompooladdBoxGomelisoscratch_i,avgkrigevaroptimallyaddfrompooladdBoxGomelisoscratch_i]=optimally_add_n_locations_from_pooladd({},UBoxGomeliso,[],[],pooladdxy,0.22+delta0BoxGomeliso(1),[10000000,0,0;0,0.00000001,0;0,0,0.00000001],wBoxGomeliso,35,deltaBoxGomeliso,100,-100,200,-50,250,1000,polyBoxGomeliso,41,41,'i');
%    save designGomel
%
%  9.) Besides deleting and adding design locations you can also improve
%  designs by means of moving design locations that are redundant to areas
%  that are only sparsely sampled:
%
%    pooldeletexy=[BoxGomeliso.x,BoxGomeliso.y];
%    [ximprovepooldeletefrompoolcompleteBoxGomeliso_i,yimprovepooldeletefrompoolcompleteBoxGomeliso_i,avgkrigevarimprovepooldeletefrompoolcompleteBoxGomeliso_i]=optimally_improve_pooldelete_from_poolcomplete({},UBoxGomeliso,[],[],pooldeletexy,0.22+delta0BoxGomeliso(1),[10000000,0,0;0,0.00000001,0;0,0,0.00000001],wBoxGomeliso,35,deltaBoxGomeliso,-100,200,-50,250,1800,polyBoxGomeliso,41,41,1,0,'i');
%    save designGomel
%    plot(BoxGomeliso.x,BoxGomeliso.y,'go')
%    hold on
%    plot(ximprovepooldeletefrompoolcompleteBoxGomeliso_i,yimprovepooldeletefrompoolcompleteBoxGomeliso_i,'r*')
%    plot(polyBoxGomeliso.x,polyBoxGomeliso.y,'r-')
%    axis equal
% 
%    pooldeletexy=[BoxGomeliso.x(1:100),BoxGomeliso.y(1:100)];
%    [ximprovepooldeletefrompoolcompleteBoxGomeliso_i2,yimprovepooldeletefrompoolcompleteBoxGomeliso_i2,avgkrigevarimprovepooldeletefrompoolcompleteBoxGomeliso_i2]=optimally_improve_pooldelete_from_poolcomplete({},UBoxGomeliso,BoxGomeliso.x(101:end),BoxGomeliso.y(101:end),pooldeletexy,0.22+delta0BoxGomeliso(1),[10000000,0,0;0,0.00000001,0;0,0,0.00000001],wBoxGomeliso,35,deltaBoxGomeliso,-100,200,-50,250,1800,polyBoxGomeliso,41,41,1,0,'i');
%    save designGomel
%    plot(ximprovepooldeletefrompoolcompleteBoxGomeliso_i2,yimprovepooldeletefrompoolcompleteBoxGomeliso_i2,'r*')
%    hold on
%    plot(BoxGomeliso.x(101:end),BoxGomeliso.y(101:end),'go')
%    plot(BoxGomeliso.x(1:100),BoxGomeliso.y(1:100),'bo')
%    plot(polyBoxGomeliso.x,polyBoxGomeliso.y,'r-')
%    axis equal
%
                              %%%%%%%%%%%%%%%%%
% 
%   [xgrid,ygrid]=generategrid(-100,200,-50,250,41,41,polyBoxGomeliso);
%   pooladdxy=[xgrid,ygrid];
%   pooldeletexy=[BoxGomeliso.x,BoxGomeliso.y];
%   [ximprovepooldeletefrompooladdBoxGomeliso_i,yimprovepooldeletefrompooladdBoxGomeliso_i,avgkrigevarimprovepooldeletefrompooladdBoxGomeliso_i]=optimally_improve_pooldelete_from_pooladd({},UBoxGomeliso,[],[],pooladdxy,pooldeletexy,0.22+delta0BoxGomeliso(1),[10000000,0,0;0,0.00000001,0;0,0,0.00000001],wBoxGomeliso,35,deltaBoxGomeliso,-100,200,-50,250,1800,polyBoxGomeliso,41,41,1,0,'i');
%   save designGomel
%   plot(BoxGomeliso.x,BoxGomeliso.y,'go')
%   hold on
%   plot(ximprovepooldeletefrompooladdBoxGomeliso_i,yimprovepooldeletefrompooladdBoxGomeliso_i,'r*')
%   plot(polyBoxGomeliso.x,polyBoxGomeliso.y,'r-')
%   axis equal
%
%   pooldeletexy=[BoxGomeliso.x(1:100),BoxGomeliso.y(1:100)]; 
%   [xgrid,ygrid]=generategrid(-100,200,-50,250,41,41,polyBoxGomeliso);
%   pooladdxy=[xgrid,ygrid];
%   [ximprovepooldeletefrompooladdBoxGomeliso_i2,yimprovepooldeletefrompooladdBoxGomeliso_i2,avgkrigevarimprovepooldeletefrompooladdBoxGomeliso_i2]=optimally_improve_pooldelete_from_pooladd({},UBoxGomeliso,BoxGomeliso.x(101:end),BoxGomeliso.y(101:end),pooladdxy,pooldeletexy,0.22+delta0BoxGomeliso(1),[10000000,0,0;0,0.00000001,0;0,0,0.00000001],wBoxGomeliso,35,deltaBoxGomeliso,-100,200,-50,250,1800,polyBoxGomeliso,41,41,1,0,'i');
%   save designGomel
%   plot(ximprovepooldeletefrompooladdBoxGomeliso_i2,yimprovepooldeletefrompooladdBoxGomeliso_i2,'r*')
%   hold on
%   plot(BoxGomeliso.x(101:end),BoxGomeliso.y(101:end),'go')
%   plot(BoxGomeliso.x(1:100),BoxGomeliso.y(1:100),'bo')
%   plot(polyBoxGomeliso.x,polyBoxGomeliso.y,'r-')
%   axis equal
%
%
%  10.) We are now going to discuss spatial sampling design and geometric
%  anisotropy.
%
%  i) First of all let us estimate the geometric anisotropy:
%
%   options=optimset('LargeScale','on','MaxFunEvals',200,'TolFun',1e-3,'MaxIter',100);
%   [lambda0BoxGomelaniso,delta0BoxGomelaniso,A0BoxGomelaniso]=estimate_transfo_cov_ml(Gomel.x,Gomel.y,Gomel.zaver,0,[1,0;0,1],[0,2.4,80,80,0.6],0:15:150,10,-20,20,0.01,1,[1,1,1,1,1],1,0.001,0.001,options);
%   save designGomel
%
%   BoxGomelaniso.z=transform(Gomel.zaver,lambda0BoxGomelaniso);
%   hist(BoxGomelaniso.z,25)
%   save designGomel
%
%   empvarioBoxGomelaniso=empvariogramaniso(Gomel.x,Gomel.y,BoxGomelaniso.z,0:10:150,15);
%   [delta0BoxGomelanisowls,A0BoxGomelanisowls,exitflagBoxGomelanisowls]=weightedleastsquaresaniso(empvarioBoxGomelaniso,0.25,3.4,61,80,0.6,A0BoxGomelaniso,[1,1,1,1,1],1,0.001);
%   save designGomel
%
%  Obviously the two transformation matrices A0BoxGomelaniso and
%  A0BoxGomelanisowls are almost similar, so we decide to go on with
%  A0BoxGomelaniso.
%
%  ii) Next comes the transformation of the geometric anisotropic random
%  field to an isotropic one. This can be achieved by means of linearly 
%  transforming the Gomel-coordinates with the matrix A0BoxGomelaniso:
%
%   xy=[Gomel.x';Gomel.y'];
%   polyxy=[polyBoxGomeliso.x;polyBoxGomeliso.y];
%   xyaniso=A0BoxGomelaniso*xy;
%   polyxyaniso=A0BoxGomelaniso*polyxy;
%   BoxGomelaniso.x=xyaniso(1,:)';
%   BoxGomelaniso.y=xyaniso(2,:)';
%   polyBoxGomelaniso.x=polyxyaniso(1,:);
%   polyBoxGomelaniso.y=polyxyaniso(2,:);
%   save designGomel
%   plot(BoxGomelaniso.x,BoxGomelaniso.y,'o')
%   hold on
%   plot(polyBoxGomelaniso.x,polyBoxGomelaniso.y,'r-')
%   title('isotropic coordinates')
%   axis equal
%
%  iii) Spatial sampling design is now similar to steps 4.) - 9.) from the 
%  isotropic case. Instead of working with the original coordinates you 
%  must use just the isotropic ones and use the variables with the 
%  catchword 'BoxGomelaniso' inside their names. The generated isotropic 
%  design locations then must be transformed back to the original coordinates
%  by means of the inverse of the matrix A0BoxGomelaniso. We give a
%  demonstration of the steps involved:
%
%   plotspectraldist(0:0.01:2,delta0BoxGomelaniso);
%   load wscaled
%   wBoxGomelaniso=wscaled*1.5;  % at about w=1.5 the polar spectral
%   save designGomel             % distribution function reaches almost
%                                % its largest value
%
%   [wBoxGomelaniso,deltaBoxGomelaniso]=step(wBoxGomelaniso,delta0BoxGomelaniso);
%   save designGomel
%   plot(wBoxGomelaniso,deltaBoxGomelaniso,'o')
%
%   plotcovarianceapprox(wBoxGomelaniso,35,deltaBoxGomelaniso,delta0BoxGomelaniso,-100:3:150,350,-100,-75,150,-50,350);
%
%  Observe: the difference at lag 0 between the true and the approximating
%  covariance function is 0.25.
%
%   UBoxGomelaniso=weightingmatUtrend({},wBoxGomelaniso,35,-75,150,-50,350,100,100,polyBoxGomelaniso);
%   save designGomel
%
%   [xoptimallydeletefrompooldeleteBoxGomelaniso_i,yoptimallydeletefrompooldeleteBoxGomelaniso_i,avgkrigevaroptimallydeletefrompooldeleteBoxGomelaniso_i]=optimally_delete_n_locations_from_pooldelete({},UBoxGomelaniso,BoxGomelaniso.x,BoxGomelaniso.y,[BoxGomelaniso.x,BoxGomelaniso.y],0.25+delta0BoxGomelaniso(1),[10000000,0,0;0,0.00000001,0;0,0,0.00000001],wBoxGomelaniso,35,deltaBoxGomelaniso,292,-75,150,-50,350,1000,polyBoxGomelaniso,41,41,'i');
%   save designGomel
%   
%  We will now transform the calculated spatial sampling design back to
%  the original coordinates:
%
%   invA0BoxGomelaniso=inv(A0BoxGomelaniso);
%   for i=1:length(xoptimallydeletefrompooldeleteBoxGomelaniso_i)
%       xytrans=[xoptimallydeletefrompooldeleteBoxGomelaniso_i{i}';yoptimallydeletefrompooldeleteBoxGomelaniso_i{i}'];
%       xytrans=invA0BoxGomelaniso*xytrans;
%       xoptimallydeletefrompooldeleteBoxGomelaniso_i{i}=xytrans(1,:)';
%       yoptimallydeletefrompooldeleteBoxGomelaniso_i{i}=xytrans(2,:)';
%       figure  
%       plot(polyBoxGomeliso.x,polyBoxGomeliso.y,'r-')
%       hold on
%       plot(xoptimallydeletefrompooldeleteBoxGomelaniso_i{i},yoptimallydeletefrompooldeleteBoxGomelaniso_i{i},'o')
%       title(i*2)
%       axis equal
%   end
%   save designGomel
%
%
%  11.) The toolbox provides also some interpolation routines for Bayesian
%  ordinary trans-Gaussian kriging and Bayesian kriging with a linear trend.
%  Both kriging methods are explained in the accompanying paper 
%  serra08_pilz_spoeck.pdf
%
%    grid=generategrid2(-100,200,-50,250,61,61,polyBoxGomeliso);
%    predictivedistBoxGomelaniso=transGaussiankrigingongrid(Gomel.x,Gomel.y,Gomel.zaver,10000,0,120,delta0BoxGomelaniso,lambda0BoxGomelaniso,A0BoxGomelaniso,grid,0.25,150);     
%    save designGomel
%   
%    visualizepostdistribution([175,120],[200,150],predictivedistBoxGomelaniso,grid);
%
%  The following function visualizes the quantiles, the mean-, modal- and
%  median- values of the predictive distribution:
% 
%    postquantileBoxGomelaniso=visualizepostquantile([0.05,0.25,0.75,0.9],predictivedistBoxGomelaniso,8,3);
%    save designGomel
%
%  The next function visualizes the probabilities for the Cesium137 
%  concentrations to be above certain thresholds:
%
%    probBoxGomelaniso=visualizeprobgreater([10,20,30,40,50],predictivedistBoxGomelaniso,8,3);
%
%  The next functions perform crossvalidation for trans-Gaussian kriging:
%
%    crossvalidationBoxGomelaniso=crossvalidation(Gomel.x,Gomel.y,Gomel.zaver,0,10000,120,delta0BoxGomelaniso,lambda0BoxGomelaniso,A0BoxGomelaniso,0.25,150,0.05:0.05:0.95,2.5:2.5:50);
%    Gomel.z=Gomel.zaver;
%    save designGomel
%    maeBoxGomelaniso=visualizecrossvalidation(crossvalidationBoxGomelaniso,Gomel);
% 
%  The next function performs Bayesian linear kriging: Actually it performs
%  ordinary kriging here because the first diagonal entry of apriorivar is
%  given a very large value (10000) and all other values are almost 0.
%
%   grid=generategrid2(-100,200,-50,250,61,61,polyBoxGomeliso);
%   predictionkrigelinearbayesBoxGomelaniso=krigelinearbayesongrid({},Gomel.x,Gomel.y,BoxGomelaniso.z,[10000,0,0;0,0.0001,0;0,0,0.0001],[0;0;0],120,delta0BoxGomelaniso,A0BoxGomelaniso,grid,3,8);
%   imgsqrttmsepBoxGomelaniso=reshape(predictionkrigelinearbayesBoxGomelaniso.sqrttmsep,61,61);
%   figure()
%   imagesc(imgsqrttmsepBoxGomelaniso(end:-1:1,:))
%   colorbar
%   title('sqrt(TMSEP)')
%   save designGomel
%
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%
%  References:
%
%  Pilz J and Spöck G (2008) Why do we need and how should we implement 
%  Bayesian kriging methods. Stoch Environ Res Risk Assess, 22/5: 621-632
%
%  Spöck G and Pilz J (2010) Spatial sampling design and covariance-robust
%  minimax prediction based on convex design ideas. Stoch Environ Res Risk Assess,
%  24/3: 463-482
%
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
