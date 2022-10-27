
% 
% Fill the holes in the data, pixel by pixel, when an unavailable velocity
% value is "surrounded" by valid values within a parametrized time
% interval. The new value is given by the linear regression among all the
% available values.
% 
% 
% Lucio Bellomo from Philippe Forget, 2012/06/28
%  


function vr = fill_radial_holes_t(vr, time, time_resol)

plot_test_point = 0;
i_y_plot = 13;
i_x_plot = 10;

vr  = permute(vr, [3 2 1]);


%% Check the number of available time snapshots
tmp = size(vr);

if length(tmp) == 2
    warning('No time-domain interpolation possible: only 1 snapshot is available!'); %#ok<WNTAG>
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


%% For each pixel, fill the NaN values "surrounded" in time by valid values
disp('Hole filling - Time domain ...');
% h = waitbar(0,'Hole filling - Time domain');
% k = 1;
for i_x = 1 : N_x
    for i_y = 1 : N_y
        vr_time      = squeeze(vr(:,i_y,i_x));
        vr_time_orig = vr_time;
        
        % Find the NaN values surrounded by valid values,
        % and interpolate through a linear regression
        % - separate NaN and non-NaN values (and their respective timestamps)
        is_NaN  = isnan(vr_time);
        ind_NaN = find(is_NaN == 1);
        vr_ok    = vr_time(~is_NaN);
        time_ok  = time(~is_NaN);
        % - do the interpolation part
        filled = [];
        for i_NaN = 1 : length(ind_NaN)
            delta_time = time(ind_NaN(i_NaN)) - time_ok;
            ind_before = find((delta_time > 0) & (    delta_time  <= time_resol));
            ind_after  = find((delta_time < 0) & (abs(delta_time) <= time_resol));
            if ~isempty(ind_before) && ~isempty(ind_after)
                time_interp = time_ok(ind_before:ind_after);
                vr_interp   =   vr_ok(ind_before:ind_after);
                a = covariance(time_interp,vr_interp)/covariance(time_interp,time_interp);
                b = mean(vr_interp) - a*mean(time_interp);
                vr_time(ind_NaN(i_NaN)) = a*time(ind_NaN(i_NaN)) + b;
                filled = [filled; ind_NaN(i_NaN)];                  %#ok<AGROW>
            end
        end
        
%         % Fetch the sequences of consecutive valid values and
%         % 1) interpolate the values onto a regular grid
%         % 2) low-pass filter them
%         % - separate NaN and non-NaN values (and their respective timestamps)
%         is_NaN  = isnan(vr_time);
%         vr_ok   = vr_time(~is_NaN);
%         time_ok = time(~is_NaN);
%         % - fetch the sequences and work on each of them
%         time_diff = [nan; diff(time_ok)];
%         ind_stop = find(time_diff > time_resol);                                % the delta time between consecutive samples must be
%         ind_stop = [1; ind_stop];              	%#ok<AGROW>                     % smaller than time_resol
%         for i_sequence = 2 : length(ind_stop)
%             vr_sequence = vr_ok(ind_stop(i_sequence-1):ind_stop(i_sequence)-1);
%             if length(vr_sequence) > N_points_sequence                          % the sequence must contain at least N_points_sequence
%                 
%             end
%         end
%         vr_time(~is_NaN) = vr_ok;
        
        
        
        % Plot the time-domain signal to illustrate the algorithm behavior
        if plot_test_point == 1 && i_y == i_y_plot && i_x == i_x_plot
            kk = 1;
            figure; hold on; grid on;
            h1 = plot(time,vr_time_orig,'-bx');
            if ~isempty(h1)
                leg_str(kk) = {'Original signal'}; kk = kk+1;             %#ok<AGROW>
            end
            h2 = plot(time(filled),vr_time(filled),' go','MarkerSize',2);
            if ~isempty(h2)
                leg_str(kk) = {'Interpolated signal'};                    %#ok<AGROW>
            end
            xlabel('Time (hours)');
            ylabel('Radial current speed (m/s)');
            legend([h1, h2],leg_str);
            title(['Pixel centered at (x,y) = (' num2str(data.xr(i_y_plot,i_x_plot),'%.1f') ',' ...
                num2str(data.yr(i_y_plot,i_x_plot),'%.1f') ') km']);
        end
        
        % Update the output
        vr(:,i_y,i_x) = vr_time;
        
%         waitbar(k/(N_y*N_x));
%         k = k+1;
    end
end
% close(h);
% pause(0.1);
