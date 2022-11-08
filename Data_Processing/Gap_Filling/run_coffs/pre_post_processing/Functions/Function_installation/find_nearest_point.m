
% 
% Finds the nearest element of the input array wrt the given value
% 
% INPUTS
% - points: input array of points
% - point:  value to be found (in the nearest sense)
% 
% OUTPUTS
% - point_out: nearest value
% - ind_out: (not mandatory) its index
% 

function varargout = find_nearest_point(points,point)

ind_last  = find(points <= point,1,'last');
ind_first = find(points >= point,1,'first');

if isempty(ind_last)
    ind_last = 1;
end
if isempty(ind_first)
    ind_first = length(points);
end

if ind_last == ind_first
    ind_out = ind_last;
else
    if abs(points(ind_last)-point) <= abs(points(ind_first)-point)
        ind_out = ind_last;
    else
        ind_out = ind_first;
    end
end
point_out = points(ind_out);

varargout{1} = point_out;
if nargout == 2
    varargout{2} = ind_out;
end
