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
%  This is an example session demonstrating the capabilities of the spatial
%  sampling design toolbox. The data set considered is the
%  designPakistan.mat data set. It comprises 51 locations distributed
%  allover Pakistan, where monthly rainfall during monsoon for July and 
%  August has been measured. Monthly rainfalls over 27 years (1974-2000) 
%  have been stored for both months. 
%  The coordinates of the locations are Lambert-projected coordinates.
%  Thus, arc-distances on the earth's sphere correspond to Euclidean
%  distances in the plane.
%  We are interested in improving the existing network of monitoring stations
%  for the prediction of monthly rainfall during July and August over the whole
%  region of Pakistan.
%  All variables calculated during this session have been stored in the
%  file designPakistan.mat. The exceptions are Ujuly and Uaugust. These
%  matrices are very large in storage space and have to be recalculated in point 5.) 
%  before doing spatial sampling design.
%
%
%  1.) Let us  visualize the sampling locations:
%
%   load designPakistan
%
%   We first select the design region:
%
%   plot(coordinates(:,1),coordinates(:,2),'bo')
%   hold on
%   plot( borders(:,1),borders(:,2),'r.')
%   polyPakistan=polygon(-8,8,-8,8,borders(:,1),borders(:,2));
%
%   Select the appropriate design region with the mouse and hit "return",
%   when you have finished.
%
%   figure()
%   plot(polyPakistan.x,polyPakistan.y,'-r')
%   hold on
%   gaugedPakistan.x=coordinates(:,1);
%   gaugedPakistan.y=coordinates(:,2);
%   plot(gaugedPakistan.x,gaugedPakistan.y,'ob')
%   save designPakistan
%
%
%  2.) Linear trend removal and variogram calculation
%
%  Now for both months, July and August, and every of the 27 years a
%  linear trend depending on coordinates is removed by means of generalized
%  least squares and the corresponding variograms are estimated from the
%  residuals.
%  We found numerically more stable results when fixing in the 
%  weightedleastsquares function in calculate_residuals_trend_covariance.m
%  the parameter estimatedelta=[1,1,0,0,1]. That means that exponential
%  and Gaussian ranges are fixed at the prespecified values 0 and 1.5, (0
%  and 2). 
%
%  for i=1:27
%     [residualsjuly{i},betajuly(:,i),covmatrix,deltajuly1{i}]=calculate_residuals_trend_covariance({},coordinates(:,1),coordinates(:,2),july(:,i),0:0.25:6,[5000,7000,0,1.5,1],10,'linear',0.1,8);
%  end
%  for i=1:27
%     h=0:0.25:6;
%     cov{i}=vario(h,deltajuly1{i});
%     plot(h,cov{i})
%     hold on
%  end
%  delta0july=[5000,7000,0,1.5,1];
%  plot(h, vario(h,delta0july),'-r')
%  title('estimated variograms for July')
%  figure()
%  for i=1:27
%     h=0:0.25:6;
%     cor{i}=variocorr(h,deltajuly1{i});
%     plot(h,cor{i})
%     hold on
%  end
%  plot(h, variocorr(h,delta0july),'-r')
%  title('estimated correlograms for July')
% 
%  for i=1:27 
%     [residualsaugust{i},betaaugust(:,i),covmatrix,deltaaugust1{i}]=calculate_residuals_trend_covariance({},coordinates(:,1),coordinates(:,2),august(:,i),0:0.25:6,[6000,6000,0,2,1],10,'linear',0.1,8);
%  end  
%  for i=1:27
%     h=0:0.25:6;
%     cov{i}=vario(h,deltaaugust1{i});
%     plot(h,cov{i})
%     hold on
%  end
%  delta0august=[6000,6000,0,2,1];
%  plot(h, vario(h,delta0august),'-r')
%  title('estimated variograms for August')
%  figure()
%  for i=1:27
%     h=0:0.25:6;
%     cor{i}=variocorr(h,deltaaugust1{i});
%     plot(h,cor{i})
%     hold on
%  end
%  plot(h, variocorr(h,delta0august),'-r')
%  title('estimated correlograms for August')
%  clear betajuly betaugust residualsjuly residualsaugust covmatrix cov cor h i
%
%  We have selected by hand the variogram with parameters 
%  delta0july=[5000,7000,0,1.5,1], (delta0august=[6000,6000,0,2,1]) as
%  representative for all 27 July-variograms (August-variograms). Looking
%  at the correlograms, we see that those have some kind of minimax
%  optimality: least possible range and maximum nugget effect (see the 
%  attached paper Spöck and Pilz (2009)). For spatial sampling design
%  actually only the correlograms are important and the selected ones for July
%  and August are good representatives of all other 27 correlograms in the minimax sense.
%
%  We now predict the rainfall for July and August 2000 by means of
%  universal kriging with a linear trend depending on coordinates.
%
%  grid=generategrid2(-8,8,-8,8,61,61,polyPakistan);
%  predictionkrigelinearbayes_rain_july=krigelinearbayesongrid({},coordinates(:,1),coordinates(:,2),july(:,27),[100000000,0,0;0,100000000,0;0,0,100000000],[0;0;0],100,delta0july,[1,0;0,1],grid,0.1,8);
%  imgsqrttmsep_rain_july=reshape(predictionkrigelinearbayes_rain_july.sqrttmsep,61,61);
%  figure()
%  imagesc(imgsqrttmsep_rain_july(end:-1:1,:))
%  colorbar
%  title('sqrt(TMSEP)')
%  krige_rain_july=reshape(predictionkrigelinearbayes_rain_july.predictivemean,61,61);
%  figure()
%  imagesc(krige_rain_july(end:-1:1,:))
%  colorbar
%  title('predictive mean')
%   
%  predictionkrigelinearbayes_rain_august=krigelinearbayesongrid({},coordinates(:,1),coordinates(:,2),august(:,27),[100000000,0,0;0,100000000,0;0,0,100000000],[0;0;0],100,delta0august,[1,0;0,1],grid,0.1,8);
%  imgsqrttmsep_rain_august=reshape(predictionkrigelinearbayes_rain_august.sqrttmsep,61,61);
%  figure()
%  imagesc(imgsqrttmsep_rain_august(end:-1:1,:))
%  colorbar
%  title('sqrt(TMSEP)')
%  krige_rain_august=reshape(predictionkrigelinearbayes_rain_august.predictivemean,61,61);
%  figure()
%  imagesc(krige_rain_august(end:-1:1,:))
%  colorbar
%  title('predictive mean')
%
%
%  3.) Next comes the approximation of the two isotropic random fields, rainfall
%  for July and August by means of two linear regression models, whose regression functions are
%  cosine-sine-Bessel surface harmonics, and whose regression coefficients
%  are random:
%
%  For this purpose let us first of all calculate the polar spectral
%  distribution function:
%
%   plotspectraldist(0:0.5:8,delta0july);
%   plotspectraldist(0:0.05:8,delta0august);
%
%  Obviously at about w=6 (w=6) the polar spectral distribution function
%  attains 95% of its maximum value.
%  (It may happen that you have to change the integration limits in the
%  function polarspectraldist.m to get the polar spectral distribution
%  function properly calculated.)
%
%  Next is the approximation of the polar spectral distribution function by
%  means of a step function. The hight of the different steps gives the
%  variances of the random regression coefficients in the approximating
%  cosine-sine-Bessel surface harmonics regression model.
%
%  load wscaled
%
%  wscaled is a vector of frequencies w and has to be properly scaled:
%  
%  wjuly=wscaled*6;
%  waugust=wscaled*6;
%  save designPakistan
%
%  The next function calculates the steps deltajuly (deltaaugust) at frequencies
%  wjuly (waugust). The steps are a discrete spectrum:
%
%  [wjuly,deltajuly]=step(wjuly,delta0july);
%  [waugust,deltaaugust]=step(waugust,delta0august);
%  save designPakistan
%  plot(wjuly,deltajuly,'o')
%  figure()
%  plot(waugust,deltaaugust,'o')
%
%
%  4.) Next let's see how good the worst approximating covariance function
%  from the linear cosine-sine-Bessel surface harmonics regression model with random
%  coefficients  approximates close to the border of the design region the   
%  true covariance function. We calculate this worst approximating 
%  covariance function at 8 Northing and assume for our approximating 
%  regression model a largest frequency M=35:
%
%  plotcovarianceapprox(wjuly,35,deltajuly,delta0july,-8:0.1:-3,8,-8,8,-8,-10,8);
%  figure()
%  plotcovarianceapprox(waugust,35,deltaaugust,delta0august,-8:0.1:-3,8,-8,8,-8,-10,8);
%
%  Obviously the blue approximating covariance function approximates the
%  true covariance function quite well. Only close to lag 0 there is some
%  larger difference. Zooming into the plot we see that this difference at
%  lag 0 is about 800 (250) . This is variance of the true random field not taken
%  into account by the random amplitudes of the approximating regression
%  model. We will thus later add this value 800 (250) to the nugget effect
%  delta0july(1) (delta0august(1)) and assume an error variance of 5800 (6250) 
%  for the approximating regression model. Thus, small scale variation 
%  of the true random field not taken into account by the approximating 
%  regression model will be modelled as a pure nugget effect.
% 
%  M=35 and wjuly (waugust) result together with a linear trend function for
%  the random field in an approximating mixed linear model with 2417
%  regression functions.
%
%
%  5.) Now we have everything that we need to do spatial sampling design by
%  means of doing experimental design for the approximating mixed linear 
%  regression model. Powerful tools can be borrowed from experimental
%  design theory to calculate spatial sampling designs. Details on the now
%  following experimental (spatial) sampling design algorithms are given in
%  the accompanying paper serra09_spoeck_pilz.pdf.
%
%  First of all we have to calculate the matrix U described in this paper
%  containing information on the average (over the design region) total
%  mean squared error of the Bayesian kriging predictor:
%
%  load polyPakistan
%  Ujuly=weightingmatUtrend({},wjuly,35,-8,8,-8,8,100,100,polyPakistan);
%  save designPakistan
%  Uaugust=weightingmatUtrend({},waugust,35,-8,8,-8,8,100,100,polyPakistan);
%  save designPakistan
%
%
%  6.) Since we want to improve the existing design we next consider the optimal 
%  deletion of 24 sampling locations, such that the resulting design has only 27
%  sampling locations. An exchange algorithm from optimal experimental
%  design theory is applied to the approximating regression model. See the
%  accompanying paper serra09_spoeck_pilz.pdf for details on this deletion
%  algorithm. The minimization of the average kriging variance over the
%  design region and universal kriging with a linear trend depending on the 
%  coordinates are considered. Since a linear deterministic trend is modelled
%  in the approximating regression model and Bayesin kriging is considered there,
%  one can get universal kriging by means of giving the diagonal elements of the a 
%  priori covariance matrix a very large a priori variance and all the other components
%  the value 0. 
%  This procedure results in the a priori covariance matrix
%  apriorivar=[100000000,0,0;0,100000000,0;0,0,100000000].
%  If one wants to consider instead of the minimization of the average
%  kriging variance over the design region a D-optimality criterion one has
%  to set criterion='d'.
%
%  [xoptimallydeletefrompooldeletejuly_i,yoptimallydeletefrompooldeletejuly_i,avgkrigevaroptimallydeletefrompooldeletejuly_i]=optimally_delete_n_locations_from_pooldelete({},Ujuly,coordinates(:,1),coordinates(:,2),[coordinates(:,1),coordinates(:,2)],800+delta0july(1),[100000000,0,0;0,100000000,0;0,0,100000000],wjuly,35,deltajuly,24,-8,8,-8,8,1000,polyPakistan,41,41,'i');
%  save designPakistan
%  figure()
%  plot(xoptimallydeletefrompooldeletejuly_i{12},yoptimallydeletefrompooldeletejuly_i{12},'o')
%  hold on
%  plot(polyPakistan.x,polyPakistan.y,'r-')
%  title('27 point design for July')
% 
%  [xoptimallydeletefrompooldeleteaugust_i,yoptimallydeletefrompooldeleteaugust_i,avgkrigevaroptimallydeletefrompooldeleteaugust_i]=optimally_delete_n_locations_from_pooldelete({},Uaugust,coordinates(:,1),coordinates(:,2),[coordinates(:,1),coordinates(:,2)],250+delta0august(1),[100000000,0,0;0,100000000,0;0,0,100000000],waugust,35,deltaaugust,24,-8,8,-8,8,1000,polyPakistan,41,41,'i');
%  save designPakistan
%  figure()
%  plot(xoptimallydeletefrompooldeleteaugust_i{12},yoptimallydeletefrompooldeleteaugust_i{12},'o')
%  hold on
%  plot(polyPakistan.x,polyPakistan.y,'r-')
%  title('27 point design for August')
%
%  Obviously those sample locations are removed first that are very close to
%  other samples and thus are redundant. The August-design with 27 sample
%  locations and 24 locations removed is very similar to a space filling
%  design. A look at Figure 1500 shows how the average kriging varince
%  calculated over the admissible design area only slightly increases.
%  From now on we will use the August-27 point design for adding design
%  locations in both July and August, because it is more space-filling than
%  the July-design.
%
%
%  7.) Preparation of data: the pool of locations to be added to the design
%  should contain no already gauged design points.
%
%  Identify the 24 design points that have been deleted:
%
%  l=0;
%  k=0;
%  for i=1:51
%      if isempty(find(abs(coordinates(i,1)-xoptimallydeletefrompooldeleteaugust_i{12})<=0.001 & abs(coordinates(i,2)-yoptimallydeletefrompooldeleteaugust_i{12})<=0.001));
%         k=k+1;
%         inddeleted(k)=i;
%      else
%         l=l+1;
%         indretained(l)=i;
%      end
%  end
%     
%  retainedcoordinates.x=coordinates(indretained,1);
%  retainedcoordinates.y=coordinates(indretained,2);
%  deletedcoordinates.x=coordinates(inddeleted,1);
%  deletedcoordinates.y=coordinates(inddeleted,2);
%     
%  
%  The matrix newloc containes coordinates of design locations (cities) that are
%  possible candidates to be added to the 27-point design. Since these are
%  so many locations, we retain only such locations that are a distance
%  greater than 0.3 apart from the already available design locations.
%
%  l=0;
%  k=0;
%  for i=1:411
%      ind=find(abs(newloc(i,2)-coordinates(:,2))<=0.3 & abs(newloc(i,1)-coordinates(:,1))<=0.3)
%      if isempty(ind);
%         k=k+1;
%         indretainednewloc(k)=i;
%      else
%         l=l+1;
%         inddeletednewloc(l)=i;
%      end
%  end
%     
%  retainednewloc.x=newloc(indretainednewloc,1);
%  retainednewloc.y=newloc(indretainednewloc,2);
    

%  8.) Next, let us add to the previously generated 27 point August-sampling
%  design in an optimal way again 24 locations from a pool of 326
%  locations:
%
%  pooladdxy.x=[retainednewloc.x;deletedcoordinates.x];
%  pooladdxy.y=[retainednewloc.y;deletedcoordinates.y];
%  pooladdxy=[pooladdxy.x,pooladdxy.y];
% 
%  [xoptimallyaddfrompooladdjuly_i,yoptimallyaddfrompooladdjuly_i,avgkrigevaroptimallyaddfrompooladdjuly_i]=optimally_add_n_locations_from_pooladd({},Ujuly,retainedcoordinates.x,retainedcoordinates.y,pooladdxy,800+delta0july(1),[100000000,0,0;0,100000000,0;0,0,100000000],wjuly,35,deltajuly,24,-8,8,-8,8,1000,polyPakistan,41,41,'i');
%  save designPakistan
% 
%  [xoptimallyaddfrompooladdaugust_i,yoptimallyaddfrompooladdaugust_i,avgkrigevaroptimallyaddfrompooladdaugust_i]=optimally_add_n_locations_from_pooladd({},Uaugust,retainedcoordinates.x,retainedcoordinates.y,pooladdxy,250+delta0august(1),[100000000,0,0;0,100000000,0;0,0,100000000],waugust,35,deltaaugust,24,-8,8,-8,8,1000,polyPakistan,41,41,'i');
%  save designPakistan
%
%  We consider the July design to be the optimal design for both months.
%
%  k=0;
%  for i=1:24
%      ind=find(abs(xoptimallyaddfrompooladdjuly_i{12}(i)-pooladdxy(:,1))<=0.01 & abs(yoptimallyaddfrompooladdjuly_i{12}(i)-pooladdxy(:,2))<=0.01)
%      if ~isempty(ind);
%         k=k+1;
%         indretainedindesign(k)=ind(1);
%      end
%  end
%
%  
%  9. Next let us calculate the kriging standarddeviations for the
%  resulting design.
%
%  grid=generategrid2(-8,8,-8,8,61,61,polyPakistan);
%  dummy=krigelinearbayesongrid({},[retainedcoordinates.x;xoptimallyaddfrompooladdjuly_i{12}],[retainedcoordinates.y;yoptimallyaddfrompooladdjuly_i{12}],ones(51,1),[1000000000,0,0;0,1000000000,0;0,0,1000000000],[0;0;0],100,delta0july,[1,0;0,1],grid,0.1,8);
%  dummysqrttmsep_july=reshape(dummy.sqrttmsep,61,61);
%  figure()
%  imagesc(dummysqrttmsep_july(end:-1:1,:))
%  colorbar
%  title('sqrt(TMSEP) for July')
%  meanvarfinal_july=mean(dummysqrttmsep_july(~isnan(dummysqrttmsep_july)).^2);
% 
% 
%  dummy=krigelinearbayesongrid({},[retainedcoordinates.x;xoptimallyaddfrompooladdjuly_i{12}],[retainedcoordinates.y;yoptimallyaddfrompooladdjuly_i{12}],ones(51,1),[1000000000,0,0;0,1000000000,0;0,0,1000000000],[0;0;0],100,delta0august,[1,0;0,1],grid,0.1,8);
%  dummysqrttmsep_august=reshape(dummy.sqrttmsep,61,61);
%  figure()
%  imagesc(dummysqrttmsep_august(end:-1:1,:))
%  colorbar
%  title('sqrt(TMSEP) for August')
%  meanvarfinal_august=mean(dummysqrttmsep_august(~isnan(dummysqrttmsep_august)).^2);
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


