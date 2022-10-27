%%  DATA QUALITY CONTROL
function [Rd] = RADqc(rad, N, days, time, dt)

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

%% Remove data points greater than N STD from a *-day running temporal mean
Rd = nan(size(rad));

% INDEXING
st = days*24*dt; % Give # of data points in the running mean window
st2 = st/2; % Half value
stM = st - 1; % For indexing
st2M = st2 - 1;st2P = st2 + 1; % For indexing

% FIRST DAYS/2  
tic
        R1 = nanstd(rad(:,:,1:st),0,3); % Use unbiased N-1 data points
        RM = nanmean(rad(:,:,1:st),3);
        RMsp = RM + (N*R1); % Above mean threshold
        RMsn = RM - (N*R1); % Below mean threshold
        
        for k =1:st2 %because after st2 can start the running window
            q = rad(:,:,k);
            q(q > RMsp) = NaN;
            q(q < RMsn) = NaN;
            Rd(:,:,k) = q;
            clear q
        end
        clear k RMsp RMsn RM R1
toc        
% LAST DAYS/2 
tic
        index = (length(time)- stM):length(time); % index of last s days
        R1 = nanstd(rad(:,:,index),0,3); % Use unbiased N-1 data points
        RM = nanmean(rad(:,:,index),3);
        RMsp = RM + (N*R1); % Above mean threshold
        RMsn = RM - (N*R1); % Below mean threshold
        
        for k = index(end-st2M):index(end)
            q = rad(:,:,k);
            q(q > RMsp) = NaN;
            q(q < RMsn) = NaN;
            Rd(:,:,k) = q;
            clear q
        end
        clear k RMsp RMsn RM R1 index
toc        
% THE MIDDLE (slowish -> 24 minutes for 112 days)
tic
        for k = st2P:length(time)-st2
            %display([k '/' length(time)-st2])
            R1 = nanstd(rad(:,:,k-st2:k+st2M),0,3); % Use unbiased N-1 data points
            RM = nanmean(rad(:,:,k-st2:k+st2M),3);

            RMsp = RM + (N*R1); % Above mean threshold
            RMsn = RM - (N*R1); % Below mean threshold

            q = rad(:,:,k);
            q(q > RMsp) = NaN;
            q(q < RMsn) = NaN;
            Rd(:,:,k) = q;
            clear q
        end
toc        
        clear k RMsp RMsn RM R1

%% Do a general sweep to remove big outliers
% This is used to remove areas in time where they are bad in relation to
% the whole time series.
% 
% Ns = N + .5; % N sweep
% 
% R1 = nanstd(rad,0,3); 
% RM = nanmean(rad,3);
% 
% RMsp1 = RM + (Ns*R1); 
% RMsp = repmat(RMsp1,1,1,length(Rd));% Above mean threshold
% RMsn1 = RM - (Ns*R1); 
% RMsn = repmat(RMsn1,1,1,length(Rd));% Below mean threshold
% 
% qu = Rd;
% qu(qu > RMsp) = NaN;
% qu(qu < RMsn) = NaN;
% Rd2 = qu;
% clear qu
% 
% RDC = Rd2;
% %% Remove Rings - using the gradient as a diagnostic tool
% stdRDC = nanstd(RDC,0,3);
% [fx,fy] = gradient(stdRDC);
% F = sqrt(fx.^2 + fy.^2);
% 
% for i = 1:size(lon,1)
%     for j = 1:size(lon,2)
%         if (~isnan(F(i,j)) && abs(fy(i,j)) > 0.05);
%             RDC(i,j,:) = nan;%(length(Rdc),1);
%         end
%     end
% end
% 
% Utot=zeros(size(RDC,1),size(RDC,2));
% for i=1:size(RDC,1)
%     for j=1:size(RDC,2)
%         Utot(i,j)=100 - ((sum(isnan(RDC(i,j,:)))/length(RDC))*100);
%     end
% end

end