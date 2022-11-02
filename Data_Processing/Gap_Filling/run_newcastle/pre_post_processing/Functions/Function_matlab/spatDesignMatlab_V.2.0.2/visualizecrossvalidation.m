function mae=visualizecrossvalidation(crossvalidationtransf,data)
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
%  mae=visualizecrossvalidation(crossvalidationtransf,data)
%
%  visualizes the crossvalidation results.
%
%  Input:
%
%  crossvalidationtransf.grid.........................the locations of the
%                                                     samples
%
%  crossvalidationtransf.x............................x-axes of posterior predictive distribution
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
%  data.x.............................................column vector containing the x-coordinates of the  data
%
%  data.y.............................................column vector containing the y-coordinates of the data
%
%  data.z.............................................column vector containing the concentrations 
%
%  Example:
%  
%  maeBoxGomelaniso=visualizecrossvalidation(crossvalidationBoxGomelaniso,Gomel);
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
mae=meanabsoluteerror(crossvalidationtransf,data);

minimum=min(data.z);
maximum=max(data.z);
figure
plot(data.z,crossvalidationtransf.modal,'o')
hold on
plot(minimum:(maximum-minimum)/100:maximum,minimum:(maximum-minimum)/100:maximum,'r-')
title(['crossvalidation, MAE=',num2str(mae.modal)])
xlabel('data')
ylabel('modal value')

figure
plot(data.z,crossvalidationtransf.median,'o')
hold on
plot(minimum:(maximum-minimum)/100:maximum,minimum:(maximum-minimum)/100:maximum,'r-')
title(['crossvalidation, MAE=',num2str(mae.median)])
xlabel('data')
ylabel('median')

figure
plot(data.z,crossvalidationtransf.mean,'o')
hold on
plot(minimum:(maximum-minimum)/100:maximum,minimum:(maximum-minimum)/100:maximum,'r-')
title(['crossvalidation, MAE=', num2str(mae.mean)])
xlabel('data')
ylabel('mean')

for i=1:length(crossvalidationtransf.percent)
    figure
    plot(data.z,crossvalidationtransf.quantiles(:,i),'o')
    hold on
    plot(minimum:(maximum-minimum)/100:maximum,minimum:(maximum-minimum)/100:maximum,'r-')
    title(['crossvalidation, MAE=', num2str(mae.quantile(i))])
    xlabel('data')
    ylabel([num2str(crossvalidationtransf.percent(i)), ' percent quantile'])
end

for i=1:length(crossvalidationtransf.percent)
    percent(i)=(sum(data.z<=crossvalidationtransf.quantiles(:,i))/(length(data.z)-sum(isnan(crossvalidationtransf.quantiles(:,i)))))*100;
end
figure
plot(crossvalidationtransf.percent,percent,'o')
hold on
plot([0,100],[0,100],'r-')
title('crossvalidation')
xlabel('quantile')
ylabel('percent data below quantile')

for i=1:length(crossvalidationtransf.threshold)
    actualabove(i)=(sum(data.z>=crossvalidationtransf.threshold(i))/length(data.z))*100;
    expectedabove(i)=(sum(crossvalidationtransf.probs(:,i))/(length(data.z)-sum(isnan(crossvalidationtransf.probs(:,i)))))*100;
end
figure
plot(actualabove,expectedabove,'o')
hold on
plot(actualabove,actualabove,'r-')
title('crossvalidation')
xlabel('percent actual data above threshold')
ylabel('expected percent data above threshold')

function mae=meanabsoluteerror(crossvalidationtransf,data)
a=abs(crossvalidationtransf.mean'-data.z);
a=a(~isnan(a));
mae.mean=mean(a);
a=abs(crossvalidationtransf.modal'-data.z);
a=a(~isnan(a));
mae.modal=mean(a);
a=abs(crossvalidationtransf.median'-data.z);
a=a(~isnan(a));
mae.median=mean(a);

for i=1:length(crossvalidationtransf.percent)
    a=abs(crossvalidationtransf.quantiles(:,i)-data.z);
    a=a(~isnan(a));
    mae.quantile(i)=mean(a);
end
    