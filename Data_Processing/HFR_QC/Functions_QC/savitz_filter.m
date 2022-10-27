function [vr_out] = savitz_filter(vr, len_filter)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

len_filter = 7;
vr_out = vr;
% get the high frequency from the signal
order = 2;

sgf = nan(size(vr));

for i = 1:size(vr,1)
    for j = 1:size(vr,2)
        sgf(i,j,:) = sgolayfilt(squeeze(vr(i,j,:)), order, len_filter);
    end
end

hf_vr = vr - sgf;


plot(squeeze(vr(6,140,:)),'LineWidth',1.5)
hold on
plot(squeeze(hf_vr(6,140,:)))
hold off


%define the thresholds
vr_max = prctile(hf_vr, 99, "all");
vr_min = prctile(hf_vr, 1, "all");

bool_outliers = (hf_vr > vr_max) | (hf_vr < vr_min);
bool_outliers(isnan(sgf)) = false;
%eliminate them
vr_out(bool_outliers) = NaN;

plot(squeeze(vr(6,140,:)),'LineWidth',1.5)
hold on
plot(squeeze(vr_out(6,140,:)))
hold off

end