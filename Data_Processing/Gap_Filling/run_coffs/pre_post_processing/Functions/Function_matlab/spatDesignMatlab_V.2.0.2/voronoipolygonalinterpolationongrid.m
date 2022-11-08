function prediction=voronoipolygonalinterpolationongrid(x,y,z,grid)
%
%  Copyright (C) 2010 Gunter Spöck, email: gunter.spoeck@uni-klu.ac.at
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
%  prediction=voronoipolygonalinterpolationongrid(x,y,z,grid)
%
%  interpolates by means of calculating the voronoi tesselation and
%  assuming within the voronoi polygons the prediction surface to be
%  constant.
%
%  Inputs:
%
%  x.................column vector containing the x-coordinates of the  data
%
%  y.................column vector containing the y-coordinates of the data
%
%  z.................column vector containing the concentrations 
%
%  Outputs:
%
%  prediction.prediction.............the predicted surface
%
%  prediction.grid...................the grid of coordinates
%                                    where prediction takes place
%
%  Example:
%  
%  grid2=generategrid2(-8,8,-8,8,61,61,polyPakistan);
%  prediction_hum_july_voronoipolygonal=voronoipolygonalinterpolationongrid(coordinates(:,1),coordinates(:,2),meanhum_july,grid2);
%  imgprediction_hum_july_voronoipolygonal=reshape(prediction_hum_july_voronoipolygonal.prediction,61,61);
%  figure()
%  imagesc(imgprediction_hum_july_voronoipolygonal(end:-1:1,:))
%  colorbar
%  title('prediction')
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

n=length(grid.x)
externaldrift={[x,y],z}

for i=1:n
    i
    if ~isnan(grid.x(i))
       rf=regressionfunctiontrend(externaldrift,grid.x(i),grid.y(i),1,1);
       pred(i)=rf(4);   
    else
       pred(i)=NaN;
    end   
end

prediction.prediction=pred;
prediction.grid=grid;

