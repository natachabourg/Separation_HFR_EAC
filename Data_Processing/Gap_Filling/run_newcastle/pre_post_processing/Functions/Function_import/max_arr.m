
%
% max_arr: Evaluates the maximum value and indices of input array
% N.B.: Maximum input array dimension supported: 4
% 
% INPUTS
% - in: input array
%
% OUTPUTS
% - M: maximum value
% - i1: index along 1st direction (optional)
% - i2: index along 2nd direction (optional)
% - i3: index along 3rd direction (optional)
% - i4: index along 4th direction (optional)
% 

function varargout = max_arr(in)

in = squeeze(in);
N = size(in);

switch length(N)
    case 1
        [M i1] = max(in);
    case 2
        [M_tmp i_tmp] = max(in);
        [M i2]        = max(M_tmp);
        i1 = i_tmp(i2);
    case 3
        [M_tmp2 i_tmp2] = max(in);
        M_tmp2 = squeeze(M_tmp2);
        i_tmp2 = squeeze(i_tmp2);
        [M_tmp i_tmp]   = max(M_tmp2);
        [M i3]          = max(M_tmp);
        i2 = i_tmp(i3);
        i1 = i_tmp2(i2,i3);
    case 4
        [M_tmp3 i_tmp3] = max(in);
        M_tmp3 = squeeze(M_tmp3);
        i_tmp3 = squeeze(i_tmp3);
        [M_tmp2 i_tmp2] = max(M_tmp3);
        M_tmp2 = squeeze(M_tmp2);
        i_tmp2 = squeeze(i_tmp2);
        [M_tmp i_tmp]   = max(M_tmp2);
        [M i4]          = max(M_tmp);
        i3 = i_tmp(i4);
        i2 = i_tmp2(i3,i4);
        i1 = i_tmp3(i2,i3,i4);
    otherwise
        error('The input array is more than 4D!!');
end

varargout{1} = M;
if nargout >= 2
    varargout{2} = i1;
end
if nargout >= 3
    varargout{3} = i2;
end
if nargout >= 4
    varargout{4} = i3;
end
if nargout == 5
    varargout{5} = i4;
end
