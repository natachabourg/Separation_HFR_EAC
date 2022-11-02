
%
% min_arr: Evaluates the minimum value and indices of input array
% N.B.: Maximum input array dimension supported: 4
% 
% INPUTS
% - in: input array
%
% OUTPUTS
% - m: minimum value
% - i1: index along 1st direction (optional)
% - i2: index along 2nd direction (optional)
% - i3: index along 3rd direction (optional)
% - i4: index along 4th direction (optional)
% 

function varargout = min_arr(in)

in = squeeze(in);
N = size(in);

switch length(N)
    case 1
        [m i1] = min(in);
    case 2
        [m_tmp i_tmp] = min(in);
        [m i2]        = min(m_tmp);
        i1 = i_tmp(i2);
    case 3
        [m_tmp2 i_tmp2] = min(in);
        m_tmp2 = squeeze(m_tmp2);
        i_tmp2 = squeeze(i_tmp2);
        [m_tmp i_tmp]   = min(m_tmp2);
        [m i3]          = min(m_tmp);
        i2 = i_tmp(i3);
        i1 = i_tmp2(i2,i3);
    case 4
        [m_tmp3 i_tmp3] = min(in);
        m_tmp3 = squeeze(m_tmp3);
        i_tmp3 = squeeze(i_tmp3);
        [m_tmp2 i_tmp2] = min(m_tmp3);
        m_tmp2 = squeeze(m_tmp2);
        i_tmp2 = squeeze(i_tmp2);
        [m_tmp i_tmp]   = min(m_tmp2);
        [m i4]          = min(m_tmp);
        i3 = i_tmp(i4);
        i2 = i_tmp2(i3,i4);
        i1 = i_tmp3(i2,i3,i4);
    otherwise
        error('The input array is more than 4D!!');
end

varargout{1} = m;
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
