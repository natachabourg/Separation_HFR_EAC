function [vr_out] = despike_run(vr, time, thresh, runber, N_std)
%DESPIKE_RUN loop to apply the despike everywhere lol 

    rd = nan(size(vr));
    for i = 1:size(vr,1)
        for j = 1:size(vr,2)
            if sum(~isnan(vr(i,j,:))) > 0
                radial = squeeze(squeeze(vr(i,j,:)));
                [rd_back,~] = despike(flipud(radial),thresh,runber);                           
                [rd(i,j,:),df] = despike(flipud(rd_back),thresh,runber);
                clear rd_back
            end
        end
    end
    
    days = 30; %# of days running mean
    dt = 60/60; % sampling interval
    [vr_out] = RADqc(rd, N_std, days, time, dt); % Radials despiked + std outliers removed matrix - Rds
    
end

