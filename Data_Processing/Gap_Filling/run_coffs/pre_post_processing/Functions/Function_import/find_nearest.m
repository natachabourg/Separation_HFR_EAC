
% 
% Finds the nearest element of the input array wrt the given value
% 
% INPUTS
% - arr_unsort: input array
% - val: value to be found (in the nearest sense)
% 
% OUTPUTS
% - val_out: nearest value
% - ind_out: (not mandatory) its index
% - ind: (not mandatory) [ind_before ind_after]
% 

function varargout = find_nearest(arr_unsort,val)

if any(~isreal(arr_unsort))
    warning('Attention, complex values!!! The ''find'' will work only on the real part.');
end

val = real(val);
arr_unsort = real(arr_unsort);

[arr ind_sort] = sort(real(arr_unsort));

ind_last  = find(arr<=val,1,'last');
ind_first = find(arr>=val,1,'first');

if isempty(ind_first) %%% MRN - pb au dernier pas de temps
    ind_first = ind_last;
end
if isempty(ind_last) %%% MRN - pb au premier pas de temps
    ind_last = ind_first;
end

%%%
if ind_last == ind_first
    ind_out = ind_last;
else
    if abs(arr(ind_last)-val)<=abs(arr(ind_first)-val)
        ind_out = ind_last;
    else
        ind_out = ind_first;
    end
end

val_out = arr_unsort(ind_out);

varargout{1} = val_out;
if nargout >= 2
    ind_out = ind_sort(ind_out);
    varargout{2} = ind_out;
end
if nargout == 3
    ind_last  = ind_sort(ind_last);
    ind_first = ind_sort(ind_first);
    varargout{3} = [ind_last ind_first];
end
