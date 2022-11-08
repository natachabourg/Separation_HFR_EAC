function x = statevector_pack(varargin)

s = varargin{1};

k = size(varargin{2},my_ndims(s.mask{1})+1);

x = zeros(s.n,k);

for i=1:s.nvar
    
  tmp = reshape(varargin{i+1},s.numels_all(i),k);
  
  ind = find(s.mask{i}==1);
  
  x(s.ind(i)+1:s.ind(i+1),:) = tmp(ind,:);
end


function d = my_ndims(v)
  if isvector(v)
    d = 1;
  else
    d = ndims(v);
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

