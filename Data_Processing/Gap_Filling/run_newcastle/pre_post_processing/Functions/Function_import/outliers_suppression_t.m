
% 
% Suppresses the outliers from a time domain statistics analysis
% 
% 
% Lucio Bellomo from Philippe Forget, 2012/06/28
% 
% Modif MARMAIN, find JM
% 

function data = outliers_suppression_t(data,params)

disp('Outlier suppression - Time domain ...');

plot_test_point = 0;
i_y_plot = 13;
i_x_plot = 10;

time = data.time*24; % [days] -> [hours]
xr   = data.xr;      % [km]
yr   = data.yr;      % [km]
vr   = data.vr;      % [m/s]
delta_time = diff(time);

%% Check the number of available time snapshots
tmp = size(vr);
if length(tmp) == 2
    warning('No outlier suppression possible: only 1 snapshot is available!'); %#ok<WNTAG>
    return;
else
    N_times = tmp(1);
    N_y     = tmp(2);
    N_x     = tmp(3);

%     if N_times >= ???
%         warning('No outlier suppression possible: less than ??? snapshot is available!');
%         return;
%     end
end

clear tmp

%% Compute the statistic of the time-domain current gradient over the whole coverage area
if params.time_method == 1
    grad = abs(diff(vr,1,1))./repmat(delta_time,[1 N_y N_x]);
    grad = grad(:);
    grad = grad(~isnan(grad));
    [pdf, values] = hist(grad,min([100 round(length(grad)/500)]));  % RATHER EMPIRIC, NOT SO CLEAN...
    %     figure;
%     stem(values,pdf);
    a = size(values);
    disp(a);
    if le(a(2),2)
        threshold = params.time_max_grad;
        disp('woké');
    else
        values_resolution = values(2) - values(1);                      % resolution of the histogram
        pdf_thresh        = max(pdf)*params.time_percent/100;                % threshold on the pdf (nb. of gradients found at the threshold current gradient value)
        ind_last          = find(pdf >= pdf_thresh,1,'last');           % index of the last valid bin of the histogram
        threshold         = values(ind_last+1) - values_resolution/2;	% threshold on the current gradient [m/s/h]
    end
    
    if  params.time_tresh_grad_std ~= 0 % JM
        grad_std=std(grad); % JM
        threshold=params.time_tresh_grad_std.*grad_std;% JM
    end% JM
    
    disp(['    The threshold value for current velocity time-domain gradient is ' num2str(threshold,'%.2f') ' m/s/h']);
elseif params.time_method == 3
    threshold = params.time_max_grad;
end


%% For each pixel, remove the outliers with a gradient above or equal threshold_value
vr_tmp = vr;
isolated_points = zeros(size(vr));
isolated_pairs  = zeros(size(vr));
for i_x = 1 : N_x
    for i_y = 1 : N_y
        vr_time = squeeze(vr(:,i_y,i_x));
        
        % Compute the threshold value if the method is pixel-by-pixel
        if params.time_method == 2
            grad = abs(diff(vr_time))./delta_time;
            grad = grad(~isnan(grad));
            [pdf, values] = hist(grad,min([100 round(length(grad)/500)]));
            values_resolution = values(2) - values(1);                  % resolution of the histogram
            pdf_thresh        = max(pdf)*params.time_percent/100;            % threshold on the pdf (nb. of gradients found at the threshold current gradient value)
            ind_last          = find(pdf >= pdf_thresh,1,'last');       % index of the last valid bin of the histogram
            threshold         = values(ind_last+1) - values_resolution/2;
        end
        data.threshold_current_gradient_t(i_y,i_x) = threshold;
        
        if ~all(isnan(vr_time))
            % - Remove the points with a too large gradient
            grad_forward  =        [nan;   abs(diff(vr_time(1:1:end)))./delta_time(1:1:end)];
            grad_backward = flipud([nan; abs(diff(vr_time(end:-1:1)))./delta_time(end:-1:1)]);
            invalid = (grad_forward > threshold) & (grad_backward > threshold);
            vr_tmp(invalid,i_y,i_x) = NaN;

            % - Flag isolated points (a NaN before and a NaN after)
            for i_time = 2 : N_times-1
                if ~isnan(vr_time(i_time))
                    if isnan(vr_time(i_time-1)) && isnan(vr_time(i_time+1))
                        isolated_points(i_time,i_y,i_x) = 1;
                    end
                end
            end
            
            % - Flag pairs of isolated points if their gradient is larger than the threshold
            for i_time = 3 : N_times-1
                if ~isnan(vr_time(i_time)) && ~isnan(vr_time(i_time-1))
                    if isnan(vr_time(i_time-2)) && isnan(vr_time(i_time+1))
                        grad = abs( vr_time(i_time) - vr_time(i_time-1) ) / delta_time(i_time-1);
                        if grad > threshold
                            isolated_pairs(i_time,i_y,i_x) = 1;
                        end
                    end
                end
            end
            
            % - Plot the time-domain signal to illustrate the algorithm behavior
            if plot_test_point == 1 && i_y == i_y_plot && i_x == i_x_plot
                kk = 1;
                figure; hold on; grid on;
                h1 = plot(time,vr_time,'-bx');
                if ~isempty(h1)
                    leg_str(kk) = {'Original signal'}; kk = kk+1;             %#ok<AGROW>
                end
                h2 = plot(time(invalid),vr_time(invalid),' go','MarkerSize',2);
                if ~isempty(h2)
                    leg_str(kk) = {'Removed outliers'}; kk = kk+1;            %#ok<AGROW>
                end
                tmp1 = logical(squeeze(isolated_points(:,i_y,i_x)));
                h3 = plot(time(tmp1),vr_time(tmp1),' ro');
                if ~isempty(h3)
                    leg_str(kk) = {'Isolated points'}; kk = kk+1;             %#ok<AGROW>
                end
                tmp2 = logical(squeeze(isolated_pairs(:,i_y,i_x)));
                h4 = plot(time(tmp2),vr_time(tmp2),' mo');
                if ~isempty(h4)
                    leg_str(kk) = {'Isolated pairs with too large gradient'}; %#ok<AGROW>
                end
                xlabel('Time (hours)');
                ylabel('Radial current speed (m/s)');
                legend([h1, h2, h3, h4],leg_str);
                title(['Pixel centered at (x,y) = (' num2str(data.xr(i_y_plot,i_x_plot),'%.1f') ',' ...
                                           num2str(data.yr(i_y_plot,i_x_plot),'%.1f') ') km']);
            end
        end
        
    end
end
vr = vr_tmp;


%% Remove the isolated points if their spatial gradient wrt their neighbor points is too high
%  Fetch the isolated points
ind_isol = find(isolated_points == 1);

if ~isempty(ind_isol)
    % Compute the maximum allowed space gradient
    delta_x = sqrt( diff(xr,1,2).^2 + diff(yr,1,2).^2 );
    delta_y = sqrt( diff(xr,1,1).^2 + diff(yr,1,1).^2 );
    if params.space_method == 1
        grad_x = abs(diff(vr,1,3))./repmat(shiftdim(delta_x,-1),[N_times 1 1]);
        grad_y = abs(diff(vr,1,2))./repmat(shiftdim(delta_y,-1),[N_times 1 1]);
        grad = [grad_x(:); grad_y(:)];
        grad = grad(~isnan(grad));
        [pdf, values] = hist(grad,min([100 round(length(grad)/500)]));  % RATHER EMPIRIC, NOT SO CLEAN...
%         figure;
%         stem(values,pdf);
        a = size(values);
        disp(a);
        if le(a(2),2)
            threshold = params.space_max_grad;
            disp('woké');
        else
            values_resolution = values(2) - values(1);                      % resolution of the histogram
            pdf_thresh        = max(pdf)*params.space_percent/100;                % threshold on the pdf (nb. of gradients found at the threshold current gradient value)
            ind_last          = find(pdf >= pdf_thresh,1,'last');           % index of the last valid bin of the histogram
            threshold         = values(ind_last+1) - values_resolution/2;	% threshold on the current gradient [m/s/km]
            disp(['    The threshold value for current velocity space-domain gradient is ' num2str(threshold,'%.2f') ' m/s/km']);
        end 
        
    elseif params.space_method == 3
        threshold = params.space_max_grad;
    end
    
    % Proceed to the suppression if the gradien is too high
    for i_isol = 1 : length(ind_isol)
        [i_time, i_y, i_x] = ind2sub(size(isolated_points),ind_isol(i_isol));
%         if i_time == 5
%             disp([i_time i_y i_x]);
%         end
        xr_isol = xr(i_y,i_x);
        yr_isol = yr(i_y,i_x);
        vr_isol = vr(i_time,i_y,i_x);
        % - Fetch the neighboring points (+/-2)
        %   (handle the case of i_x == 1 or N_x, and i_y == 1 or N_y)
        i_y_min = max(i_y-2,1);
        i_y_max = min(i_y+2,N_y);
        i_x_min = max(i_x-2,1);
        i_x_max = min(i_x+2,N_x);
        i_y_neighbor = [i_y_min:i_y_max];
        i_x_neighbor = [i_x_min:i_x_max];
        xr_near = xr(i_y_neighbor,i_x_neighbor);
        yr_near = yr(i_y_neighbor,i_x_neighbor);
        vr_near = squeeze( vr(i_time,i_y_neighbor,i_x_neighbor) );
        vr_near_notNan = vr_near(~isnan(vr_near));
        % - Remove the point if
        %   1) it has no neighbors (conservative choice), or
        %   2) if there are at least 2 neighbors, if the median gradient is larger than threshold
        if length(vr_near_notNan) == 1
            vr_tmp(i_time,i_y,i_x) = NaN;
        elseif length(vr_near_notNan) >= 3
            % - Compute the gradient
            dist_near     = sqrt( (xr_isol - xr_near).^2 + (yr_isol - yr_near).^2 );
            delta_vr_near = abs( vr_isol - vr_near );
            grad = delta_vr_near./dist_near;
            grad = grad(~isnan(grad));          % this also removes the point itself, since 0/0 gives NaN
            grad = grad(:);
            if median(grad) > threshold
                vr_tmp(i_time,i_y,i_x) = NaN;
            end
        end
        
    end
    vr = vr_tmp;
        
end


%% Remove the pairs of isolated points if their spatial gradient wrt their neighbor points is too high
% Fetch the isolated pairs
ind_isol = find(isolated_pairs == 1);

if ~isempty(ind_isol)
    % Compute the maximum allowed space gradient
    for i_isol = 1 : length(ind_isol)
        [i_time, i_y, i_x] = ind2sub(size(isolated_pairs),ind_isol(i_isol));
        xr_isol = xr(i_y,i_x);
        yr_isol = yr(i_y,i_x);
        vr_isol1 = vr(i_time-1,i_y,i_x);
        vr_isol2 = vr(i_time,  i_y,i_x);
        % - Fetch the neighboring points (+/-2)
        %   (handle the case of i_x == 1 or N_x, and i_y == 1 or N_y)
        i_y_min = max(i_y-2,1);
        i_y_max = min(i_y+2,N_y);
        i_x_min = max(i_x-2,1);
        i_x_max = min(i_x+2,N_x);
        i_y_neighbor = [i_y_min:i_y_max];
        i_x_neighbor = [i_x_min:i_x_max];
        xr_near = xr(i_y_neighbor,i_x_neighbor);
        yr_near = yr(i_y_neighbor,i_x_neighbor);
        vr_near1 = squeeze( vr(i_time-1,i_y_neighbor,i_x_neighbor) );
        vr_near2 = squeeze( vr(i_time,  i_y_neighbor,i_x_neighbor) );
        vr_near1_notNan = vr_near1(~isnan(vr_near1));
        vr_near2_notNan = vr_near2(~isnan(vr_near2));
        % - If the isolated points have no neighbors, remove them
        alone = [0 0];
        if length(vr_near1_notNan) == 1
            vr_tmp(i_time-1,i_y,i_x) = NaN;
            alone(1) = 1;
        end
        if length(vr_near2_notNan) == 1
            vr_tmp(i_time,i_y,i_x) = NaN;
            alone(2) = 1;
        end
        % - Else, remove the one that is more different (in the gradient
        %   sense) wrt to its neighbors
        if all(alone == 0)
            dist_near      = sqrt( (xr_isol - xr_near).^2 + (yr_isol - yr_near).^2 );
            delta_vr_near1 = abs( vr_isol1 - vr_near1 );
            grad1 = delta_vr_near1./dist_near;
            grad1 = grad1(~isnan(grad1));               % this also removes the point itself, since 0/0 gives NaN
            grad1 = grad1(:);
            delta_vr_near2 = abs( vr_isol2 - vr_near2 );
            grad2 = delta_vr_near2./dist_near;
            grad2 = grad2(~isnan(grad2));               % this also removes the point itself, since 0/0 gives NaN
            grad2 = grad2(:);
            if median(grad1) > median(grad2)
                vr_tmp(i_time-1,i_y,i_x) = NaN;
            elseif median(grad2) > median(grad1)
                vr_tmp(i_time,i_y,i_x) = NaN;
            else
                % they are equally "different" => leave'em both!
            end
        end
    end
    vr = vr_tmp;

end


%% Update the output structure
data.vr = vr;
