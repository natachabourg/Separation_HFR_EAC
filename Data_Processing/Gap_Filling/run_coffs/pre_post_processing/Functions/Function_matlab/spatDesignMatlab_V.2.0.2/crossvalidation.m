function crossvalidationtransf=crossvalidation(x,y,z,apriorimean,apriorivar,searchradius,delta0,lambda0,A0,int,upper,quant,threshold)
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
% crossvalidationtransf=crossvalidation(x,y,z,apriorimean,apriorivar,searchradius,delta0,lambda0,A0,int,upper,quant,threshold)
% calculates crossvalidation results for trans-Gaussian kriging.
%
% Inputs:
%
%  x.................column vector containing the x-coordinates of the  data
%
%  y.................column vector containing the y-coordinates of the data
%
%  z.................column vector containing the concentrations 
% 
%  apriorimean.......the apriorimean. In the case of ordinary kriging 
%                    set it to 0 and give apriorivar a very high value
%                    (100000 or higher).
% 
%  apriorivar........the a priori variance
%
%  searchradius......the radius of the kriging neighbourhood
%
%  delta0............the covariance parameters 
%                    [nugget, sill, exp. range, Gaussian range, mixing parameter]
%
%  lambda0...........the Box-Cox-parameters or log-log transformation 
%                    parameters.
%
%  A0................the anisotropy transformation matrix
%  
%  int...............thickness of the boxes when the posterior distribution is
%                    approximated by a histogram
%
%  upper.............maximum x-value for predictive distribution
%
%  quant.............the quantiles 
%
%  threshold.........the thresholds
%
%  Output:
%
%  crossvalidationtransf.grid.........................the locations of the
%                                                     samples
%  crossvalidationtransf.x............................x-axes of the predictive distribution
%
%  crossvalidationtransf.predictive...................predictive distribution
%
%  crossvalidationtransf.modal........................the modal value of the predictive distribution
%
%  crossvalidationtransf.median.......................the median of the predictive distribution
%
%  crossvalidationtransf.mean.........................the mean of the predictive distribution;
%
%  crossvalidationtransf.quantiles....................the quantiles
%
%  crossvalidationtransf.percent......................the quantiles
%
%  crossvalidationtransf.probs........................the probabilities of beeing larger than the thresholds
%
%  crossvalidationtransf.threshold....................the thresholds
%  
%  Example:  
%
%  crossvalidationBoxGomelaniso=crossvalidation(Gomel.x,Gomel.y,Gomel.zaver,0,10000,120,delta0BoxGomelaniso,lambda0BoxGomelaniso,A0BoxGomelaniso,0.25,150,0.05:0.05:0.95,2.5:2.5:50);
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
n=length(x);

for i=1:n
    i
    xxx=[x(1:i-1);x(i+1:n)];
    yyy=[y(1:i-1);y(i+1:n)];
    zzz=[z(1:i-1);z(i+1:n)];
    x0=x(i);
    y0=y(i);
    predictivetransf=transGaussiankriging(x0,y0,xxx,yyy,zzz,apriorimean,apriorivar,searchradius,delta0,lambda0,A0,int,upper);
    xx=predictivetransf.x;
    int=xx(2)-xx(1);
    predictivedist(i,:)=predictivetransf.predictive;
    predictivedist(i,:)=predictivedist(i,:)/sum(predictivedist(i,:));
    cumdistribfunction=cumsum(predictivedist(i,:));
    indmedian=max(find(cumdistribfunction<=0.5));
    indmodal=find(predictivedist(i,:)==max(predictivedist(i,:)));
    if ~isempty(indmedian)
    median(i)=xx(indmedian(1));
    else
    median(i)=NaN;
    end
    if ~isempty(indmodal)
    modal(i)=xx(indmodal(1));
    else
    modal(i)=NaN;
    end
    mean1(i)=sum(predictivedist(i,:).*xx);
    for j=1:length(quant)
    ind=max(find(cumdistribfunction<=quant(j)));
    if ~isempty(ind)
       quantil1(i,j)=xx(ind(1));
    else
       quantil1(i,j)=NaN;
    end
    end
end 
crossvalidationtransf.grid.x=x;
crossvalidationtransf.grid.y=y;
crossvalidationtransf.x=xx;
crossvalidationtransf.predictive=predictivedist;
crossvalidationtransf.modal=modal;
crossvalidationtransf.median=median;
crossvalidationtransf.mean=mean1;
crossvalidationtransf.quantiles=quantil1;
crossvalidationtransf.percent=quant*100;

xx=crossvalidationtransf.x;
predictivedist=crossvalidationtransf.predictive;
n=size(predictivedist,1);
    
    for j=1:length(threshold)
    for i=1:n  
        ind=find(xx>=threshold(j));
        ind=min(ind);
    probs1(i,j)=sum(predictivedist(i,ind:end))/sum(predictivedist(i,:));
    end
    end
    
crossvalidationtransf.probs=probs1;
crossvalidationtransf.threshold=threshold;



