
% 
% 
% 

function coverage = compute_coverage(currents)

[N_y N_x] = size(currents(1).u);
N_time    = length(currents);
coverage = zeros(N_y,N_x);
for i_time = 1 : N_time
    coverage = coverage + ~isnan(currents(i_time).u);
end
coverage = coverage/N_time;
