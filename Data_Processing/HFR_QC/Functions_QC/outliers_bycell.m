function [vr_out] = outliers_bycell(vr, N_std, cov_thresh)
    %vr is your data to process
    % N_std is the number of standard deviation you tolerate
    % cov thresh is the minimum temporal coverage threshold that you tolerate 
    
    vr_out = vr;
    dim = 3;
% 
%     % Get 10% outliers values on vel for each grid cell
%     vr_max = prctile(vr, 0.975, dim);
%     vr_min = prctile(vr, 0.025, dim);
% 
%     bool_outliers = (vr > vr_min)&(vr < vr_max);
%     
%     vr_out(bool_outliers) = NaN;

    % Remove data below and over N_std
    med_vr = prctile (vr_out, 50, dim);

    std_vr = std(vr_out, '', dim, 'omitnan');

    bool_std = (vr_out > med_vr-N_std*std_vr)&(vr_out < med_vr+N_std*std_vr);

    vr_out(~bool_std) = NaN;

    %remove cells with poor temporal coverage
    len_time = size(vr_out, 3);
    temp_cov = zeros(size(vr_out,1),size(vr_out,2));
    
    for i = 1:size(vr_out, 1)
        for j = 1:size(vr_out, 2)
            test = squeeze(vr_out(i,j,:));
            temp_cov(i,j) = length(test(~isnan(test)));
        end
    end

    bool_cov = (temp_cov < cov_thresh);
    vr_out(~bool_cov) = NaN;

end