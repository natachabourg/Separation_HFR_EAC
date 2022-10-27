function [vr_out] = clean_by_station(filename, sta, vr, ...
    stand_dev_thresh, snr_thresh, stand_err_thresh)

% First treatment of the data using variables defined in the netcdf file
% The variables available are different between NEWC and COFFS
    
    vr_out = vr;
    
    if or(strcmp(sta,'RHED'), strcmp(sta,'SEAL'))
        stand_dev1 = ncread(filename, 'seasonde_LLUV_ESPC'); % Standard deviation of current speed over the scatter patch
        stand_dev2 = ncread(filename, 'seasonde_LLUV_ETMP'); % Standard deviation of current speed during coverage period
        bool_std = stand_dev1 < stand_dev_thresh; %ou stand dev 2 je sais pas encore
        vr_out(~bool_std) = NaN;
    end

    if or(strcmp(sta,'RRK'), strcmp(sta, 'NNB'))
        snr = ncread(filename, 'ssr_Bragg_Signal_To_Noise');
        stand_err = ncread(filename, 'ssr_Surface_Radial_Sea_Water_Speed_Standard_Error');
        
        bool_snr = snr > snr_thresh;
        bool_stand_err = stand_err < stand_err_thresh;
        
        vr_out(~bool_snr) = NaN;
        vr_out(~bool_stan_err) = NaN;
    end
    
    
end