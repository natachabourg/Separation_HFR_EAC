function poly=polygon(xlower,xupper,ylower,yupper,x,y)
%
%  Copyright (C) 2009 Gunter Spöck, email: gunter.spoeck@uni-klu.ac.at
%
%  This program is free software; you can redistribute it and/or modify it
%  under the terms of the GNU General Public License as published by the
%  Free Software Foundation; either version 2 of the License, or (at your
%  option) any later version.
%
%  This program is distributed in the hope that it will be useful,
%  but WITHOUT ANY WARRANTY; without even the implied warranty of
%  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
%  See the GNU General Public License for more details.
%
%  You should have received a copy of the GNU General Public License along
%  with this program; if not, write to the Free Software Foundation, Inc.,
%  51 Franklin St, Fifth Floor, Boston, MA  02110-1301 USA
%
%  On Debian GNU/Linux systems, the complete text of the GNU General
%  Public License can be found in /usr/share/common-licenses/GPL-2.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  poly=polygon(xlower,xupper,ylower,yupper,x,y)
%
%  draws a polygon on a figure. The polygon is drawn  by clicking the
%  left mouse button. After clicking enter the polygon is automatically
%  closed.
%
%  Inputs:
%
%  xlower..........the smallest x-coordinate of the area of importance
%
%  xupper..........the largest x-coordinate of the area of importance
%
%  ylower..........the smallest y-coordinate of the area of importance
%
%  yupper..........the largest y-coordinate of the area of importance
%
%  x...............the x-coordinates of the data
%
%  y...............the y-coordinates of the data
%
%  Outputs:
%
%  poly.x..........the x-coordinates of the polygon
%
%  poly.y..........the y-coordinates of the polygon
%
%  Example:
%
%  polyBoxGomeliso=polygon(-100,200,-50,250,BoxGomeliso.x,BoxGomeliso.y);
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
figure
plot([xlower,xupper,xupper,xlower],[yupper,yupper,ylower,ylower],'.')
hold on
plot(x,y,'.')
[poly.x,poly.y]=drawpolygon;                    
    
function [X,Y]=drawpolygon
%
% [X,Y]=drawpolygon draws an polygon on a figure.
% The polygon is drawn by clicking the left mouse button.
% After clicking enter the polygon is automatically closed.
%
% The outputs are:
%           
%            X a column vector containing the x-coordinates of the polygon corners.
%      
%            Y a column vector containing the y-coordinates of the polygon corners.
%


flag = 1;
k = 0;
ish = ishold;
hold on
while flag == 1
  [x,y] = ginput(1);                        % put in the coordinates with the mouse 
  if ~isempty(x)
    k = k+1;
    plot(x,y,'or','linewidth',1,'MarkerSize',5)
    if k == 1
      X = x;
      Y = y;
    else
      X = [X; x];
      Y = [Y; y];
      plot(X(k-1:k),Y(k-1:k),'-r','linewidth',1) % draw polygon
    end
  else
    flag = 0;
  end
end

X = [X; X(1)];                                   % close the polygon
Y = [Y; Y(1)];                                   % close the polygon
plot(X(k:k+1),Y(k:k+1),'-r','linewidth',1)
axis equal
hold off
X=X(1:end-1,:)';
Y=Y(1:end-1,:)';