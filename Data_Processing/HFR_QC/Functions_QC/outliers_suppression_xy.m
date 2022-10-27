
% 
% Suppresses the outliers from a space domain statistics analysis
% 
% 
% Lucio Bellomo from Philippe Forget, 2012/06/28
% 
% Modif MARMAIN: find JM
% 

function [vr, threshold] = outliers_suppression_xy(time, xr, yr, vr,meth,help_thresh,box)

params.space          = 1;      % outliers based on the statistics of the space-domain gradient of current values ("filtre_t")
                                                       %       1: on, 0: off
params.space_method   = meth;      % method for the evaluation of the maximum allowed current velocity space-domain gradient
                                                        %       1: percentage of the maximum overall pdf of the current gradients
                                                        %       2: percentage of the maximum pixel-by-pixedl pdf of the current gradients
                                                        %       3: hard-coded maximum current speed gradient
params.space_percent  = 3;     % percentage of the maximum pdf of the current velocity space-domain gradient (method == 1)
params.space_tresh_grad_std  = 2; % JM; 0=no use; else value of factor for gradient standard deviation use as treshold
params.space_max_grad = 0.2;
%
vr  = permute(vr, [3 2 1]);


disp('Outlier suppression - Space domain ...');


delta_x = sqrt( diff(xr,1,2).^2 + diff(yr,1,2).^2 );
delta_y = sqrt( diff(xr,1,1).^2 + diff(yr,1,1).^2 );


%% Check the number of available time snapshots
tmp = size(vr);
if length(tmp) == 2
    N_times = 1;
    N_y     = tmp(1);
    N_x     = tmp(2);
else
    N_times = tmp(1);
    N_y     = tmp(2);
    N_x     = tmp(3);
end
clear tmp


%% Compute the statistic of the time-domain current gradient over the whole coverage area
if params.space_method == 1
    grad_x = abs(diff(vr,1,3))./repmat(shiftdim(delta_x,-1),[N_times 1 1]);
    grad_y = abs(diff(vr,1,2))./repmat(shiftdim(delta_y,-1),[N_times 1 1]);
    grad = [grad_x(:); grad_y(:)];
    grad = grad(~isnan(grad));
    [pdf, values] = hist(grad,min([100 round(length(grad)/500)]));  % RATHER EMPIRIC, NOT SO CLEAN...
%     figure;
%     stem(values,pdf);
    a = size(values);
    if le(a(2),2)
        threshold = params.space_max_grad;
    else
        values_resolution = values(2) - values(1);                      % resolution of the histogram
        pdf_thresh        = max(pdf)*params.space_percent/100;                % threshold on the pdf (nb. of gradients found at the threshold current gradient value)
        ind_last          = find(pdf >= pdf_thresh,1,'last');           % index of the last valid bin of the histogram
        threshold         = values(ind_last+1) - values_resolution/2;	% threshold on the current gradient [m/s/km]
    end
    
    if  params.space_tresh_grad_std ~= 0 % JM
        grad_std=std(grad); % JM
        threshold=params.space_tresh_grad_std.*grad_std;% JM
    end% JM
    
    disp(['    The threshold value for current velocity space-domain gradient is ' num2str(threshold,'%.2f') ' m/s/km']);
elseif params.space_method == 2
    % 
elseif params.space_method == 3
    threshold = params.space_max_grad;
end


%% For each pixel, remove the outliers with a gradient above or equal threshold_value
% h = waitbar(0,'Outlier suppression - Space domain');
for i_time = 1 : N_times
        vr_xy = squeeze(vr(i_time,:,:));
        
        % Compute the threshold value if the method is time-by-time
        if params.space_method == 2
            grad_x = abs(diff(vr_xy,1,2))./delta_x;
            grad_y = abs(diff(vr_xy,1,1))./delta_y;
            grad = [grad_x(:); grad_y(:)];
            grad = grad(~isnan(grad));
            [pdf, values] = hist(grad,min([100 round(length(grad)/500)]));
            a = size(values);
            if le(a(2),2)
                threshold = help_thresh;
            else
                values_resolution = values(2) - values(1);                      % resolution of the histogram
                pdf_thresh        = max(pdf)*params.space_percent/100;                % threshold on the pdf (nb. of gradients found at the threshold current gradient value)
                ind_last          = find(pdf >= pdf_thresh,1,'last');           % index of the last valid bin of the histogram
                threshold         = values(ind_last) - values_resolution/2;%NB values(ind_last+1) - values_resolution/2;
            end

        end
        data.threshold_current_gradient_xy(i_time) = params.space_max_grad;
        % Suppress the outliers
        if any(~isnan(vr_xy(:)))
            [ind_y ind_x] = find(~isnan(vr_xy));
            for i_ok = 1 : length(ind_y)
                ind = [ind_y(i_ok), ind_x(i_ok)];
                xr_ok = xr(ind(1),ind(2));
                yr_ok = yr(ind(1),ind(2));
                vr_ok = vr_xy(ind(1),ind(2));
                % - Consider a box of -2/+2 points centered at the hole position
                %   (handle the case of holes at the first/last x/y grid point)
                ind_y_min = max(ind(1)-box,box);
                ind_y_max = min(ind(1)+box,N_y);
                ind_x_min  = max(ind(2)-box,box);
                ind_x_max  = min(ind(2)+box,N_x);
                xr_near = xr(ind_y_min:ind_y_max, ind_x_min:ind_x_max);
                yr_near = yr(ind_y_min:ind_y_max, ind_x_min:ind_x_max);
                vr_near = vr_xy(ind_y_min:ind_y_max, ind_x_min:ind_x_max);
                % - Compute the median gradient and compare against the threshold
                dist_near     = sqrt( (xr_ok - xr_near).^2 + (yr_ok - yr_near).^2 );
                delta_vr_near = abs( vr_ok - vr_near );
                grad = delta_vr_near./dist_near;
                grad = grad(~isnan(grad));  % this also removes the gradient wrt to the pixel itself (0/0 gives NaN)
                grad = grad(:);
                if nanmedian(grad) > threshold %NB&& length(grad) >= 2  % at least two neighbors must be present
                    vr(i_time,ind(1),ind(2)) = NaN;
                end
            end
        end
        
%         waitbar(i_time/N_times);

end
% close(h);
% pause(0.1);


%% Update the output structure
data.vr = vr;
