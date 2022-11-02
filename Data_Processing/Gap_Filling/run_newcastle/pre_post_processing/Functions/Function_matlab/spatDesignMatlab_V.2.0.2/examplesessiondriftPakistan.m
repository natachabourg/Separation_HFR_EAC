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
%  designdriftPakistan.mat data set. It comprises 51 locations distributed
%  allover Pakistan, where monthly rainfall during monsoon for July and 
%  August has been measured. Monthly rainfalls over 27 years (1974-2000) 
%  have been stored for both months. Additionally to rainfall humidity, wind
%  and elevation have been measured. We will use these variables to model a
%  linear external drift in an universal kriging model.
%  The coordinates of the locations are Lambert-projected coordinates.
%  Thus, arc-distances on the earth's sphere correspond to Euclidean
%  distances in the plane.
%  We are interested in improving the existing network of monitoring stations
%  for the prediction of monthly rainfall during July and August over the whole
%  region of Pakistan.
%  All variables calculated during this session have been stored in the
%  file designdriftPakistan.mat. The exceptions are Ujuly, Uaugust and 
%  Ujuly_voronoipolygonal. These matrices are very large in storage space and
%  have to be recalculated in points 5.) and 10.) before doing spatial sampling design.
%
%
%  1.) Let us first transform some variables to Gaussianity, such that
%  variogram estimation becomes more stable and let us model the external
%  drift by ordinary kriging.
%
%   hist(transform(rain_july,0.1575))
%   hist(transform(rain_august,0.1575))
%   hist(hum_july)
%   hist(log(1+wind_july))
%   hist(elevation)
%   hist(hum_august)
%   hist(log(1+wind_august))
%
%   raintransf_july=transform(rain_july,0.1575);
%   raintransf_august=transform(rain_august,0.1575);
%
%  We take as external drift variables the averages of humidity and wind
%  over all 27 years.
%
%   meanhum_july=mean(hum_july,2);
%   meanwind_july=mean(log(1+wind_july),2);
%   meanhum_august=mean(hum_august,2);
%   meanwind_august=mean(log(1+wind_august),2);
%
%  We are going to model the external drift variables by means of interpolated kriging surfaces for 
%  humidity, wind and elevation. For this reason let us first calculate the
%  variograms for these variables and then use ordinary kriging for
%  interpolation of these variables on a regular grid.
%
%   empvariohum_july= empvariogram(coordinates(:,1),coordinates(:,2),meanhum_july,0:1:15);
%   empvariowind_july= empvariogram(coordinates(:,1),coordinates(:,2),meanwind_july,0:1:15);
%
%   empvariohum_august= empvariogram(coordinates(:,1),coordinates(:,2),meanhum_august,0:1:15);
%   empvariowind_august= empvariogram(coordinates(:,1),coordinates(:,2),meanwind_august,0:1:15);
%   empvarioelevation= empvariogram(coordinates(:,1),coordinates(:,2),elevation,0:1:15);
%
%  The value type='constant' in calculate_residuals_trend_covariance means
%  that no linear trend depending on coordinates is used in variogram
%  fitting. That is, we will use ordinary kriging for the interpolation of the
%  external drift variables.
%
%   [residuals,regressioncoeffhum_july,covmatrix_hum_july,covparametershum_july]=calculate_residuals_trend_covariance({},coordinates(:,1),coordinates(:,2),meanhum_july,0:1:15,[0,200,5,5,0],10,'constant',0.1,8);
%
%   [residuals,regressioncoeffwind_july,covmatrix_wind_july,covparameterwind_july]=calculate_residuals_trend_covariance({},coordinates(:,1),coordinates(:,2),meanwind_july,0:1:15,[0,0.6,5,5,0],10,'constant',0.1,8);
%
%   [residuals,regressioncoeffhum_august,covmatrix_hum_august,covparametershum_august]=calculate_residuals_trend_covariance({},coordinates(:,1),coordinates(:,2),meanhum_august,0:1:15,[0,250,5,5,0],10,'constant',0.1,8);
%
%   [residuals,regressioncoeffwind_august,covmatrix_wind_august,covparameterwind_august]=calculate_residuals_trend_covariance({},coordinates(:,1),coordinates(:,2),meanwind_august,0:1:15,[0,0.6,5,5,0],10,'constant',0.1,8);
%
%   [residuals,regressioncoeffelevation,covmatrix_elevation,covparameterelevation]=calculate_residuals_trend_covariance({},coordinates(:,1),coordinates(:,2),elevation,0:1:15,[0,2,25,25,0],10,'constant',0.1,8);
%
%   clear residuals
%
%  Originally the kriging routines are designed for Bayesian universal linear kriging.
%  One can get ordinary kriging by giving the a priori variance of the
%  constant regression term a very large value, the a priori variances
%  for the linear trend values almost 0 and by giving the a priori mean the
%  value [0;0;0].
%
%   load polyPakistan
%   grid=generategrid2(-8,8,-8,8,61,61,polyPakistan);
%   predictionkrigelinearbayeshum_july=krigelinearbayesongrid({},coordinates(:,1),coordinates(:,2),meanhum_july,[10000,0,0;0,0.00001,0;0,0,0.00001],[0;0;0],100,covparametershum_july,[1,0;0,1],grid,0.1,8);
%   krige_hum_july=reshape(predictionkrigelinearbayeshum_july.predictivemean,61,61);
%   figure()
%   imagesc(krige_hum_july(end:-1:1,:))
%   colorbar
%   title('predictive mean')
%
%   predictionkrigelinearbayeswind_july=krigelinearbayesongrid({},coordinates(:,1),coordinates(:,2),meanwind_july,[10000,0,0;0,0.00001,0;0,0,0.00001],[0;0;0],100,covparameterwind_july,[1,0;0,1],grid,0.1,8);
%   krige_wind_july=reshape(predictionkrigelinearbayeswind_july.predictivemean,61,61);
%   figure()
%   imagesc(krige_wind_july(end:-1:1,:))
%   colorbar
%   title('predictive mean')
%
%   predictionkrigelinearbayeshum_august=krigelinearbayesongrid({},coordinates(:,1),coordinates(:,2),meanhum_august,[10000,0,0;0,0.00001,0;0,0,0.00001],[0;0;0],100,covparametershum_august,[1,0;0,1],grid,0.1,8);
%   krige_hum_august=reshape(predictionkrigelinearbayeshum_august.predictivemean,61,61);
%   figure()
%   imagesc(krige_hum_august(end:-1:1,:))
%   colorbar
%   title('predictive mean')
%
%   predictionkrigelinearbayeswind_august=krigelinearbayesongrid({},coordinates(:,1),coordinates(:,2),meanwind_august,[10000,0,0;0,0.00001,0;0,0,0.00001],[0;0;0],100,covparameterwind_august,[1,0;0,1],grid,0.1,8);
%   krige_wind_august=reshape(predictionkrigelinearbayeswind_august.predictivemean,61,61);
%   figure()
%   imagesc(krige_wind_august(end:-1:1,:))
%   colorbar
%   title('predictive mean')
%
%   predictionkrigelinearbayeselevation=krigelinearbayesongrid({},coordinates(:,1),coordinates(:,2),elevation,[10000,0,0;0,0.00001,0;0,0,0.00001],[0;0;0],100,covparameterelevation,[1,0;0,1],grid,0.1,8);
%   krige_elevation=reshape(predictionkrigelinearbayeselevation.predictivemean,61,61);
%   figure()
%   imagesc(krige_elevation(end:-1:1,:))
%   colorbar
%   title('predictive mean')
%
%  Since we want to use universal kriging with a linear external drift and not Bayesian kriging, we
%  have to give the a priori covariance matrices for the external drift
%  parameters very large a priori variances and a priori mean [0,0,0]:
%
%    externaldriftPakistan_july={[predictionkrigelinearbayeshum_july.grid.x(~isnan(predictionkrigelinearbayeshum_july.grid.x))',predictionkrigelinearbayeshum_july.grid.y(~isnan(predictionkrigelinearbayeshum_july.grid.x))'],[predictionkrigelinearbayeshum_july.predictivemean(~isnan(predictionkrigelinearbayeshum_july.grid.x))',predictionkrigelinearbayeswind_july.predictivemean(~isnan(predictionkrigelinearbayeshum_july.grid.x))',predictionkrigelinearbayeselevation.predictivemean(~isnan(predictionkrigelinearbayeshum_july.grid.x))'],[0,0,0],[10000,0,0;0,10000,0;0,0,10000]};
%    externaldriftPakistan_august={[predictionkrigelinearbayeshum_august.grid.x(~isnan(predictionkrigelinearbayeshum_august.grid.x))',predictionkrigelinearbayeshum_august.grid.y(~isnan(predictionkrigelinearbayeshum_august.grid.x))'],[predictionkrigelinearbayeshum_august.predictivemean(~isnan(predictionkrigelinearbayeshum_august.grid.x))',predictionkrigelinearbayeswind_august.predictivemean(~isnan(predictionkrigelinearbayeshum_august.grid.x))',predictionkrigelinearbayeselevation.predictivemean(~isnan(predictionkrigelinearbayeshum_august.grid.x))'],[0,0,0],[10000,0,0;0,10000,0;0,0,10000]};
%
%
% 2.) Next we estimate the variograms of rainfall for all 27 years and seperately
% for July and August by iteratively generalized least squares of the external
% drift regression coefficients and weighted least squares fitting of the empirical
% variograms. Fixing in the weightedleastsquares function in calculate_residuals_trend_covariance
% the parameter estimatedelta=[1,0,1,1,0] makes variogram estimation more
% stable. All variograms and correlograms are visualized and then by means
% of eye-fitting an average-variogram is fitted to the the variograms for
% the 27 years. In the final correlogram we thereby tried to specify the
% nugget as large as possible and the range as small as possible, because
% such a correlogram has some minimax-optimality properties during kriging
% and sampling design (see Spöck and Pilz 2009).
%
%   for i=1:27
%       [residuals,regressioncoeff,covmatrix,covparametersPakistan_july{i}]=calculate_residuals_trend_covariance(externaldriftPakistan_july,coordinates(:,1),coordinates(:,2),raintransf_july(:,i),1:15,[0,5.5,2.5,2.5,0],10,'constant',0.1,8)
%       Rsquared_july(i)=corr(raintransf_july(:,i),-(residuals-raintransf_july(:,i)))^2;
%       pvalue_july(i)=1-chi2cdf((regressioncoeff)'*inv(covmatrix)*(regressioncoeff),47);
%   end
%   for i=1:27
%       [residuals,regressioncoeff,covmatrix,covparametersPakistan_august{i}]=calculate_residuals_trend_covariance(externaldriftPakistan_august,coordinates(:,1),coordinates(:,2),raintransf_august(:,i),1:15,[0,5.5,2.5,2.5,0],10,'constant',0.1,8)
%       Rsquared_august(i)=corr(raintransf_august(:,i),-(residuals-raintransf_august(:,i)))^2;
%       pvalue_august(i)=1-chi2cdf((regressioncoeff)'*inv(covmatrix)*(regressioncoeff),47);
%   end
%   figure()
%   hist(Rsquared_july)
%   title('R^2 for July')
%   figure()
%   hist(Rsquared_august)
%   title('R^2 for August')
% 
%   figure()
%   for i=1:27
%       plot(1:15,vario(1:15,covparametersPakistan_july{i}));
%       hold on
%   end
%   plot(1:15,vario(1:15,[2,4,6,6,0]),'r')
%   delta0july=[2,4,6,6,0];
%   figure()
%   for i=1:27
%       plot(1:15,vario(1:15,covparametersPakistan_august{i}));
%       hold on
%   end
%   plot(1:15,vario(1:15,[2.5,3.5,7,7,0]),'r')
%   delta0august=[2.5,3.5,7,7,0];
% 
%   figure()
%   for i=1:27
%       plot(1:15,variocorr(1:15,covparametersPakistan_july{i}));
%       hold on
%   end
%   plot(1:15,variocorr(1:15,[2,4,6,6,0]),'r')
%   figure()
%   for i=1:27
%       plot(1:15,variocorr(1:15,covparametersPakistan_august{i}));
%       hold on
%   end
%   plot(1:15,variocorr(1:15,[2.5,3.5,7,7,0]),'r')
%   clear residuals regressioncoeff covmatrix
%
%
%  3.) Next comes the approximation of the two isotropic random fields, rainfall for
%  July and August, by means of two linear regression models, whose regression functions are
%  cosine-sine-Bessel surface harmonics, and whose regression coefficients
%  are random:
%
%  For this purpose let us first of all calculate the polar spectral
%  distribution function:
%
%   plotspectraldist(0:0.1:8,delta0july);
%   plotspectraldist(0:0.1:8,delta0august);
%
%  Obviously at about w=8 (w=8) the polar spectral distribution function
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
%   load wscaled
%
%  wscaled is a vector of frequencies w and has to be properly scaled:
%
%   wjuly=wscaled*8;
%   waugust=wscaled*8;
%
%  The next function calculates the steps deltajuly (deltaaugust) at frequencies
%  wjuly (waugust). The steps are a discrete spectrum:
%
%   [wjuly,deltajuly]=step(wjuly,delta0july);
%   [waugust,deltaaugust]=step(waugust,delta0august);
%   plot(wjuly,deltajuly,'o')
%   plot(waugust,deltaaugust,'o')

%  4.) Next let's see how good the worst approximating covariance function
%  from the linear cosine-sine-Bessel surface harmonics regression model with random
%  coefficients  approximates close to the border of the design region the   
%  true covariance function. We calculate this worst approximating 
%  covariance function at 8 Northing and assume for our approximating 
%  regression model a largest frequency M=35:
%  
%   plotcovarianceapprox(wjuly,35,deltajuly,delta0july,-8:0.1:-3,8,-8,8,-8,-10,8);
%   figure()
%   plotcovarianceapprox(waugust,35,deltaaugust,delta0august,-8:0.1:-3,8,-8,8,-8,-10,8);
%
%  Obviously the blue approximating covariance function approximates the
%  true covariance function quite well. Only close to lag 0 there is some
%  larger difference. Zooming into the plot we see that this difference at
%  lag 0 is about 0.5 (0.4) . This is variance of the true random field not taken
%  into account by the random amplitudes of the approximating regression
%  model. We will thus later add this value 0.5 (0.4) to the nugget effect
%  delta0july(1) (delta0august(1)). Thus, small scale variation 
%  of the true random field not taken into account by the approximating 
%  regression model will be modelled as a pure nugget effect.
% 
%  M=35 and wjuly (waugust) result together with a linear external drift trend function for
%  the random field in an approximating mixed linear model with 2418
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
%  We first select the design region and then calculate this matrix U of
%  dimension 2420*2420:
%
%   load polyPakistan
%
%   Ujuly=weightingmatUtrend(externaldriftPakistan_july,wjuly,35,-8,8,-8,8,100,100,polyPakistan);
%   save designdriftPakistan
%   Uaugust=weightingmatUtrend(externaldriftPakistan_august,waugust,35,-8,8,-8,8,100,100,polyPakistan);
%   save designdriftPakistan
%
%
% 6.) Now let us do kriging for rainfall in July and August 2000 to see especially the
% kriging variance surfaces for the original design of 51 gauged locations.
%
%   predictionkrigelinearbayes_rain_july=krigelinearbayesongrid(externaldriftPakistan_july,coordinates(:,1),coordinates(:,2),raintransf_july(:,27),[10000,0,0;0,0.00001,0;0,0,0.00001],[0;0;0],100,delta0july,[1,0;0,1],grid,0.1,8);
%   imgsqrttmsep_rain_july=reshape(predictionkrigelinearbayes_rain_july.sqrttmsep,61,61);
%   figure()
%   imagesc(imgsqrttmsep_rain_july(end:-1:1,:))
%   colorbar
%   title('sqrt(TMSEP)')
%   krige_rain_july=reshape(predictionkrigelinearbayes_rain_july.predictivemean,61,61);
%   figure()
%   imagesc(krige_rain_july(end:-1:1,:))
%   colorbar
%   title('predictive mean')
%   
%   predictionkrigelinearbayes_rain_august=krigelinearbayesongrid(externaldriftPakistan_august,coordinates(:,1),coordinates(:,2),raintransf_august(:,27),[10000,0,0;0,0.00001,0;0,0,0.00001],[0;0;0],100,delta0august,[1,0;0,1],grid,0.1,8);
%   imgsqrttmsep_rain_august=reshape(predictionkrigelinearbayes_rain_august.sqrttmsep,61,61);
%   figure()
%   imagesc(imgsqrttmsep_rain_august(end:-1:1,:))
%   colorbar
%   title('sqrt(TMSEP)')
%   krige_rain_august=reshape(predictionkrigelinearbayes_rain_august.predictivemean,61,61);
%   figure()
%   imagesc(krige_rain_august(end:-1:1,:))
%   colorbar
%   title('predictive mean')
%
%
%  7.) We next consider the optimal deletion of
%  24 sampling locations, such that the resulting design has only 27
%  sampling locations. An exchange algorithm from optimal experimental
%  design theory is applied to the approximating regression model. See the
%  accompanying paper serra09_spoeck_pilz.pdf for details on this deletion
%  algorithm. The minimization of the average kriging variance over the
%  design region and univeral kriging with external drift are considered. 
%
%  If one wants to consider instead of the minimization of the average
%  kriging variance over the design region a D-optimality criterion one has
%  to set criterion='d'.
%
%   [xoptimallydeletefrompooldeletejuly_i,yoptimallydeletefrompooldeletejuly_i,avgkrigevaroptimallydeletefrompooldeletejuly_i]=optimally_delete_n_locations_from_pooldelete(externaldriftPakistan_july,Ujuly,coordinates(:,1),coordinates(:,2),[coordinates(:,1),coordinates(:,2)],0.5+delta0july(1),[10000,0,0;0,0.00001,0;0,0,0.00001],wjuly,35,deltajuly,24,-8,8,-8,8,1000,polyPakistan,41,41,'i');
%   save designdriftPakistan
%   figure()
%   plot(xoptimallydeletefrompooldeletejuly_i{12},yoptimallydeletefrompooldeletejuly_i{12},'o')
%   hold on
%   plot(polyPakistan.x,polyPakistan.y,'r-')
%   title('27 point design for July')
%
%   We can calculate the kriging variance surface for this design by means
%   of doing kriging with the dummy rain values ones(27,1).
%
%   dummy=krigelinearbayesongrid(externaldriftPakistan_july,xoptimallydeletefrompooldeletejuly_i{12},yoptimallydeletefrompooldeletejuly_i{12},ones(27,1),[10000,0,0;0,0.00001,0;0,0,0.00001],[0;0;0],100,delta0july,[1,0;0,1],grid,0.1,8);
%   dummysqrttmsep_july=reshape(dummy.sqrttmsep,61,61);
%   figure()
%   imagesc(dummysqrttmsep_july(end:-1:1,:))
%   colorbar
%   title('sqrt(TMSEP)')
%   mean(dummysqrttmsep_july(~isnan(dummysqrttmsep_july)).^2)
% 
%   [xoptimallydeletefrompooldeleteaugust_i,yoptimallydeletefrompooldeleteaugust_i,avgkrigevaroptimallydeletefrompooldeleteaugust_i]=optimally_delete_n_locations_from_pooldelete(externaldriftPakistan_august,Uaugust,coordinates(:,1),coordinates(:,2),[coordinates(:,1),coordinates(:,2)],0.4+delta0august(1),[10000,0,0;0,0.00001,0;0,0,0.00001],waugust,35,deltaaugust,24,-8,8,-8,8,1000,polyPakistan,41,41,'i');
%   save designdriftPakistan
%   figure()
%   plot(xoptimallydeletefrompooldeleteaugust_i{12},yoptimallydeletefrompooldeleteaugust_i{12},'o')
%   hold on
%   plot(polyPakistan.x,polyPakistan.y,'r-')
%   title('27 point design for August')
%   dummy=krigelinearbayesongrid(externaldriftPakistan_august,xoptimallydeletefrompooldeletejuly_i{12},yoptimallydeletefrompooldeletejuly_i{12},ones(27,1),[10000,0,0;0,0.00001,0;0,0,0.00001],[0;0;0],100,delta0august,[1,0;0,1],grid,0.1,8);
%   dummysqrttmsep_august=reshape(dummy.sqrttmsep,61,61);
%   figure()
%   imagesc(dummysqrttmsep_august(end:-1:1,:))
%   colorbar
%   title('sqrt(TMSEP)')
%   mean(dummysqrttmsep_august(~isnan(dummysqrttmsep_august)).^2)
%
%  Obviously those sample locations are removed first that are very close to
%  other samples and thus are redundant. The July-design with 27 sample
%  locations and 24 locations removed is very similar to a space filling
%  design. A look at Figure 1500 shows how the average kriging varince
%  calculated over the admissible design area only slightly increases.
%  From now on we will use the July-27 point design for adding design
%  locations in both July and August.
%
%
%  8.) Preparation of data: the pool of locations to be added to the design
%  should contain no already gauged design points.
%
%  Identify the 24 design points that have been deleted:
%
%    l=0;
%    k=0;
%    for i=1:51
%        if isempty(find(abs(coordinates(i,1)-xoptimallydeletefrompooldeletejuly_i{12})<=0.001 & abs(coordinates(i,2)-yoptimallydeletefrompooldeletejuly_i{12})<=0.001));
%           k=k+1;
%           inddeleted(k)=i;
%        else
%           l=l+1;
%           indretained(l)=i;
%        end
%    end
%     
%    retainedcoordinates.x=coordinates(indretained,1);
%    retainedcoordinates.y=coordinates(indretained,2);
%    deletedcoordinates.x=coordinates(inddeleted,1);
%    deletedcoordinates.y=coordinates(inddeleted,2);    
% 
%  The matrix newloc containes coordinates of design locations (cities) that are
%  possible candidates to be added to the 27-point design. Since these are
%  so many locations, we retain only such locations that are a distance
%  greater than 0.3 apart from the already available design locations.
%
%    l=0;
%    k=0;
%    for i=1:411
%        ind=find(abs(newloc(i,2)-coordinates(:,2))<=0.3 & abs(newloc(i,1)-coordinates(:,1))<=0.3)
%        if isempty(ind);
%           k=k+1;
%           indretainednewloc(k)=i;
%        else
%           l=l+1;
%           inddeletednewloc(l)=i;
%        end
%    end
%     
%    retainednewloc.x=newloc(indretainednewloc,1);
%    retainednewloc.y=newloc(indretainednewloc,2);
%     
%
%  9.) Next, let us add to the previously generated 27 point July-sampling
%  design in an optimal way again 24 locations from a pool of 326
%  locations:
%
%    pooladdxy.x=[retainednewloc.x;deletedcoordinates.x];
%    pooladdxy.y=[retainednewloc.y;deletedcoordinates.y];
%    pooladdxy=[pooladdxy.x,pooladdxy.y];
% 
%    [xoptimallyaddfrompooladdjuly_i,yoptimallyaddfrompooladdjuly_i,avgkrigevaroptimallyaddfrompooladdjuly_i]=optimally_add_n_locations_from_pooladd(externaldriftPakistan_july,Ujuly,retainedcoordinates.x,retainedcoordinates.y,pooladdxy,0.5+delta0july(1),[10000,0,0;0,0.00001,0;0,0,0.00001],wjuly,35,deltajuly,24,-8,8,-8,8,1000,polyPakistan,41,41,'i');
%    save designdriftPakistan
%    dummy=krigelinearbayesongrid(externaldriftPakistan_july,[retainedcoordinates.x;xoptimallyaddfrompooladdjuly_i{12}],[retainedcoordinates.y;yoptimallyaddfrompooladdjuly_i{12}],ones(51,1),[10000,0,0;0,0.00001,0;0,0,0.00001],[0;0;0],100,delta0july,[1,0;0,1],grid,0.1,8);
%    dummysqrttmsep_july=reshape(dummy.sqrttmsep,61,61);
%    figure()
%    imagesc(dummysqrttmsep_july(end:-1:1,:))
%    colorbar
%    title('sqrt(TMSEP)')
%    meanvarfinal_july=mean(dummysqrttmsep_july(~isnan(dummysqrttmsep_july)).^2)
%
%    [xoptimallyaddfrompooladdaugust_i,yoptimallyaddfrompooladdaugust_i,avgkrigevaroptimallyaddfrompooladdaugust_i]=optimally_add_n_locations_from_pooladd(externaldriftPakistan_august,Uaugust,retainedcoordinates.x,retainedcoordinates.y,pooladdxy,0.4+delta0august(1),[10000,0,0;0,0.00001,0;0,0,0.00001],waugust,35,deltaaugust,24,-8,8,-8,8,1000,polyPakistan,41,41,'i');
%    save designdriftPakistan
%    dummy=krigelinearbayesongrid(externaldriftPakistan_august,[retainedcoordinates.x;xoptimallyaddfrompooladdjuly_i{12}],[retainedcoordinates.y;yoptimallyaddfrompooladdjuly_i{12}],ones(51,1),[10000,0,0;0,0.00001,0;0,0,0.00001],[0;0;0],100,delta0august,[1,0;0,1],grid,0.1,8);
%    dummysqrttmsep_august=reshape(dummy.sqrttmsep,61,61);
%    figure()
%    imagesc(dummysqrttmsep_august(end:-1:1,:))
%    colorbar
%    title('sqrt(TMSEP)')
%    meanvarfinal_august=mean(dummysqrttmsep_august(~isnan(dummysqrttmsep_august)).^2)
%
%  We consider the July design to be the optimal design for both months.
%
%    k=0;
%    for i=1:24
%        ind=find(abs(xoptimallyaddfrompooladdjuly_i{12}(i)-pooladdxy(:,1))<=0.01 & abs(yoptimallyaddfrompooladdjuly_i{12}(i)-pooladdxy(:,2))<=0.01);
%        if ~isempty(ind);
%           k=k+1;
%           indretainedindesign(k)=ind(1);
%        end
%    end
%
%
% 10.) Besides defining the external drift surfaces via kriging on a
% regular grid it is also possible to define them on a non-regular grid.
% Internally polygonal voronoi interpolation is then used for the external
% drift surfaces. Inside the voronoi polygonal the drift surface is then given
% the value of central point inside the voronoi polygonal and the external
% drift is specified only by these central points. To visualize this voronoi
% polygonal interpolation of the drift surfaces the function voronoipolygonalinterpolationongrid
% has been written. The next function calls reproduce steps 1.)-9.) of before with
% the external drift now specified by means of this voronoi polygonal
% interpolation.
%
%  grid2=generategrid2(-8,8,-8,8,61,61,polyPakistan);
%  prediction_hum_july_voronoipolygonal=voronoipolygonalinterpolationongrid(coordinates(:,1),coordinates(:,2),meanhum_july,grid2);
%  imgprediction_hum_july_voronoipolygonal=reshape(prediction_hum_july_voronoipolygonal.prediction,61,61);
%  figure()
%  imagesc(imgprediction_hum_july_voronoipolygonal(end:-1:1,:))
%  colorbar
%  title('prediction')
%  %
%  prediction_wind_july_voronoipolygonal=voronoipolygonalinterpolationongrid(coordinates(:,1),coordinates(:,2),meanwind_july,grid2);
%  imgprediction_wind_july_voronoipolygonal=reshape(prediction_wind_july_voronoipolygonal.prediction,61,61);
%  figure()
%  imagesc(imgprediction_wind_july_voronoipolygonal(end:-1:1,:))
%  colorbar
%  title('prediction')
%  %
%  prediction_elevation_voronoipolygonal=voronoipolygonalinterpolationongrid(coordinates(:,1),coordinates(:,2),elevation,grid2);
%  imgprediction_elevation_voronoipolygonal=reshape(prediction_elevation_voronoipolygonal.prediction,61,61);
%  figure()
%  imagesc(imgprediction_elevation_voronoipolygonal(end:-1:1,:))
%  colorbar
%  title('prediction')
%
%  externaldriftPakistan_july_voronoipolygonal={[coordinates(:,1),coordinates(:,2)],[meanhum_july,meanwind_july,elevation],[0,0,0],[10000,0,0;0,10000,0;0,0,10000]};
% 
%  for i=1:27
%     [residuals,regressioncoeff,covmatrix,covparametersPakistan_july_voronoipolygonal{i}]=calculate_residuals_trend_covariance(externaldriftPakistan_july_voronoipolygonal,coordinates(:,1),coordinates(:,2),raintransf_july(:,i),1:15,[0,5.5,2.5,2.5,0],10,'constant',0.1,8)
%     Rsquared_july_voronoipolygonal(i)=corr(raintransf_july(:,i),-(residuals-raintransf_july(:,i)))^2;
%     pvalue_july_voronoipolygonal(i)=1-chi2cdf((regressioncoeff)'*inv(covmatrix)*(regressioncoeff),47);
%  end
%  
% figure()
% hist(Rsquared_july_voronoipolygonal)
% title('R^2 for July')
% 
% figure()
% for i=1:27
%     plot(1:15,vario(1:15,covparametersPakistan_july_voronoipolygonal{i}));
%     hold on
% end
% delta0july_voronoipolygonal=[2,4,6,6,0];
% plot(1:15,vario(1:15,delta0july_voronoipolygonal),'r')
% 
% figure()
% for i=1:27
%     plot(1:15,variocorr(1:15,covparametersPakistan_july_voronoipolygonal{i}));
%     hold on
% end
% plot(1:15,variocorr(1:15,delta0july_voronoipolygonal),'r')
% clear residuals regressioncoeff covmatrix
% 
%  predictionkrigelinearbayes_rain_july_voronoipolygonal=krigelinearbayesongrid(externaldriftPakistan_july_voronoipolygonal,coordinates(:,1),coordinates(:,2),raintransf_july(:,27),[10000,0,0;0,0.00001,0;0,0,0.00001],[0;0;0],100,delta0july_voronoipolygonal,[1,0;0,1],grid,0.1,8);
%  imgsqrttmsep_rain_july_voronoipolygonal=reshape(predictionkrigelinearbayes_rain_july_voronoipolygonal.sqrttmsep,61,61);
%  figure()
%  imagesc(imgsqrttmsep_rain_july_voronoipolygonal(end:-1:1,:))
%  colorbar
%  title('sqrt(TMSEP)')
%  krige_rain_july_voronoipolygonal=reshape(predictionkrigelinearbayes_rain_july_voronoipolygonal.predictivemean,61,61);
%  figure()
%  imagesc(krige_rain_july_voronoipolygonal(end:-1:1,:))
%  colorbar
%  title('predictive mean')
%
%  Ujuly_voronoipolygonal=weightingmatUtrend(externaldriftPakistan_july_voronoipolygonal,wjuly,35,-8,8,-8,8,100,100,polyPakistan);
%  save designdriftPakistan
%
%  [xoptimallydeletefrompooldeletejuly_i_voronoipolygonal,yoptimallydeletefrompooldeletejuly_i_voronoipolygonal,avgkrigevaroptimallydeletefrompooldeletejuly_i_voronoipolygonal]=optimally_delete_n_locations_from_pooldelete(externaldriftPakistan_july_voronoipolygonal,Ujuly_voronoipolygonal,coordinates(:,1),coordinates(:,2),[coordinates(:,1),coordinates(:,2)],0.5+delta0july_voronoipolygonal(1),[10000,0,0;0,0.00001,0;0,0,0.00001],wjuly,35,deltajuly,24,-8,8,-8,8,1000,polyPakistan,41,41,'i');
%  save designdriftPakistan
%
%  l=0;
%     k=0;
%     for i=1:51
%         if isempty(find(abs(coordinates(i,1)-xoptimallydeletefrompooldeletejuly_i_voronoipolygonal{12})<=0.001 & abs(coordinates(i,2)-yoptimallydeletefrompooldeletejuly_i_voronoipolygonal{12})<=0.001));
%            k=k+1;
%            inddeleted_voronoipolygonal(k)=i;
%         else
%            l=l+1;
%            indretained_voronoipolygonal(l)=i;
%         end
%     end
%     
%   retainedcoordinates_voronoipolygonal.x=coordinates(indretained_voronoipolygonal,1);
%   retainedcoordinates_voronoipolygonal.y=coordinates(indretained_voronoipolygonal,2);
%   deletedcoordinates_voronoipolygonal.x=coordinates(inddeleted_voronoipolygonal,1);
%   deletedcoordinates_voronoipolygonal.y=coordinates(inddeleted_voronoipolygonal,2);
%   inddeleted_voronoipolygonal
%
%   dummy_voronoipolygonal=krigelinearbayesongrid(externaldriftPakistan_july_voronoipolygonal,xoptimallydeletefrompooldeletejuly_i_voronoipolygonal{12},yoptimallydeletefrompooldeletejuly_i_voronoipolygonal{12},ones(27,1),[10000,0,0;0,0.00001,0;0,0,0.00001],[0;0;0],100,delta0july_voronoipolygonal,[1,0;0,1],grid,0.1,8);
%   dummysqrttmsep_july_voronoipolygonal=reshape(dummy_voronoipolygonal.sqrttmsep,61,61);
%   figure()
%   imagesc(dummysqrttmsep_july_voronoipolygonal(end:-1:1,:))
%   colorbar
%   title('sqrt(TMSEP)')
%   mean(dummysqrttmsep_july_voronoipolygonal(~isnan(dummysqrttmsep_july_voronoipolygonal)).^2)
%
%   pooladdxy_voronoipolygonal.x=[retainednewloc.x;deletedcoordinates_voronoipolygonal.x];
%   pooladdxy_voronoipolygonal.y=[retainednewloc.y;deletedcoordinates_voronoipolygonal.y];
%   pooladdxy_voronoipolygonal=[pooladdxy_voronoipolygonal.x,pooladdxy_voronoipolygonal.y];
% 
%   [xoptimallyaddfrompooladdjuly_i_voronoipolygonal,yoptimallyaddfrompooladdjuly_i_voronoipolygonal,avgkrigevaroptimallyaddfrompooladdjuly_i_voronoipolygonal]=optimally_add_n_locations_from_pooladd(externaldriftPakistan_july_voronoipolygonal,Ujuly_voronoipolygonal,retainedcoordinates_voronoipolygonal.x,retainedcoordinates_voronoipolygonal.y,pooladdxy_voronoipolygonal,0.5+delta0july_voronoipolygonal(1),[10000,0,0;0,0.00001,0;0,0,0.00001],wjuly,35,deltajuly,24,-8,8,-8,8,1000,polyPakistan,41,41,'i');
%   save designdriftPakistan
%   dummy_voronoipolygonal=krigelinearbayesongrid(externaldriftPakistan_july_voronoipolygonal,[retainedcoordinates_voronoipolygonal.x;xoptimallyaddfrompooladdjuly_i_voronoipolygonal{12}],[retainedcoordinates_voronoipolygonal.y;yoptimallyaddfrompooladdjuly_i_voronoipolygonal{12}],ones(51,1),[10000,0,0;0,0.00001,0;0,0,0.00001],[0;0;0],100,delta0july_voronoipolygonal,[1,0;0,1],grid,0.1,8);
%   dummysqrttmsep_july_voronoipolygonal=reshape(dummy_voronoipolygonal.sqrttmsep,61,61);
%   figure()
%   imagesc(dummysqrttmsep_july_voronoipolygonal(end:-1:1,:))
%   colorbar
%   title('sqrt(TMSEP)')
%   meanvarfinal_july_voronoipolygonal=mean(dummysqrttmsep_july_voronoipolygonal(~isnan(dummysqrttmsep_july_voronoipolygonal)).^2) 
%    
%   k=0;
%   for i=1:24
%       ind=find(abs(xoptimallyaddfrompooladdjuly_i_voronoipolygonal{12}(i)-pooladdxy_voronoipolygonal(:,1))<=0.01 & abs(yoptimallyaddfrompooladdjuly_i_voronoipolygonal{12}(i)-pooladdxy_voronoipolygonal(:,2))<=0.01);
%       if ~isempty(ind);
%          k=k+1;
%          indretainedindesign_voronoipolygonal(k)=ind(1);
%       end
%   end
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










