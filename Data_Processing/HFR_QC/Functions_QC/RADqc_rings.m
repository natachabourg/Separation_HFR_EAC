%%  DATA QUALITY CONTROL
function [RDC] = RADqc(rad, lon, lat)

% Quality control procedures.

% INPUT %
% rad = radial matrix (or accuracy or variance)
% N = chosen # of STDs to threshold
% days = # of days running mean
% dt = sampling interval (in hours)

% OUTPUT %
% Rdc = new data-controlled matrix

%  Written by Matt A. February 2015 ---------------------------------------

%keyboard

%% Remove Rings - using the gradient as a diagnostic tool
RDC = rad;
stdRDC = nanstd(RDC,0,3);
[fx,fy] = gradient(stdRDC);
F = sqrt(fx.^2 + fy.^2);

for i = 1:size(lon,1)
    for j = 1:size(lon,2)
        if (~isnan(F(i,j)) && abs(fy(i,j)) > 0.05);
            RDC(i,j,:) = nan;%(length(Rdc),1);
        end
    end
end


end