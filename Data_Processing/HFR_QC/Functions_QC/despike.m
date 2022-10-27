% Quality Control - remove spikes

function [Ud,df] = despike(U, thresh, runber)

% OUTPUT
% Ud = timeseries with values despiked - 1D
% df = vector of differences

% INPUT
% U = original timeseries of u or v - 1D
% thresh = the chosen threshold 'difference' between datapoints in timeseries
% (2 datapoints in time shouldn't be more than e.g. 1 m/s apart)
% runber - the NUMBER of RUNS! I made up a new word

% Written by Matt Archer, Feb 2016

n = 1;
df = nan(size(U));
UU = U;
j = 0;
rep=0;

% Terrible looping, need to improve
for rb = 1:runber
    
    for k = 1:length(UU)
        
        dp = UU(k); % data point = dp
        
        if ~isnan(dp)
            n = n+1;
            rep(n) = UU(k); % replication in new vector
            if j < 10
            df(k) = rep(n) - rep(n-1); % implies first rep differs from rep(1)=0
            end
            % also df doesn't take into account space between rep! - but
            j = 0;
        else j = j + 1;
        end
        
    end
    
    Ud = UU;
    Ud(abs(df)>thresh)=NaN;
    UU = Ud;
end

% So df gives a vector of the difference between all points

end

