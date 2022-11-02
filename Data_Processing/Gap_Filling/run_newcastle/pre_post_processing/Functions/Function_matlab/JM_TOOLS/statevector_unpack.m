function varargout = statevector_unpack(s,x,fillvalue)

if (nargin ==  2)
  fillvalue = 0;
end

k = size(x,2);

for i=1:s.nvar
  v = zeros(s.numels_all(i),k);
  v(:) = fillvalue;
  
  ind = find(s.mask{i}==1);

  v(ind,:) = x(s.ind(i)+1:s.ind(i+1),:);
  
  varargout{i} = reshape(v,[s.size{i} k]);
end



% Copyright (C) 2009 Alexander Barth <a.barth@ulg.ac.be>
%
% This program is free software; you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation; either version 2 of the License, or
% (at your option) any later version.
%
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with this program; If not, see <http://www.gnu.org/licenses/>.

