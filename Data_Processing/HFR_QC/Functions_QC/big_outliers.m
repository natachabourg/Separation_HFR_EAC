function [vr] = big_outliers(sta, grid, vr, lon, lat, std_thresh, grad_thresh)
% from Matt Archer 

if strcmp(sta, 'RHED')
    lon_ori = 151.7268;
    lat_ori = -33.0109167;
end

if strcmp(sta, 'SEAL')
    lon_ori = 152.5390833;
    lat_ori = -32.4414667;
end


if strcmp(sta, 'SEAL')
    lon_ori = 152.5390833;
    lat_ori = -32.4414667;
end


if strcmp(sta,'RRK')
    lon_ori = 153.231111;
    lat_ori = -29.983888;
end


%% Remove grid points with very large STDs - i.e. problematic gridpoints

stdR = std(vr,'',3,'omitnan');
mask = double(stdR < std_thresh);
mask(mask==0) = NaN;
vr = mask.*vr;

%% Remove Rings - using the gradient as a diagnostic tool
% add the distance 


% diff = NaN(size(lon));
% for i = 2:size(vr,1)-1
%     for j = 2:size(vr,2)-1
%         dlons = nanmean([abs(lon(i,j) - lon(i+1,j)),...
%             abs(lon(i,j) - lon(i-1,j)),...
%             abs(lon(i,j) - lon(i,j-1)),...
%             abs(lon(i,j) - lon(i,j+1))]);
%         dlats = nanmean([abs(lat(i,j) - lat(i+1,j)),...
%             abs(lat(i,j) - lat(i-1,j)),...
%             abs(lat(i,j) - lat(i,j-1)),...
%             abs(lat(i,j) - lat(i,j+1))]);
%         [dx,dy] = lonlat2km(0,0,dlons,dlats);
%         diff(i,j) = sqrt(dx.^2+dy.^2);
%     end
% end
% 
% 
% %%
% 
% diff = NaN(size(xr));
% for i = 2:size(xr,1)-1
%     for j = 2:size(xr,2)-1
%         dlons = nanmean([abs(xr(i,j) - xr(i+1,j)),...
%             abs(xr(i,j) - xr(i-1,j)),...
%             abs(xr(i,j) - xr(i,j-1)),...
%             abs(xr(i,j) - xr(i,j+1)),...
%             abs(xr(i,j) - xr(i-1,j-1)),...
%             abs(xr(i,j) - xr(i+1,j+1))]);
%         dlats = nanmean([abs(yr(i,j) - yr(i+1,j)),...
%             abs(yr(i,j) - yr(i-1,j)),...
%             abs(yr(i,j) - yr(i,j-1)),...
%             abs(yr(i,j) - yr(i,j+1)),...
%             abs(xr(i,j) - xr(i-1,j-1)),...
%             abs(xr(i,j) - xr(i+1, j+1))]);
%         diff(i,j) = sqrt(dlons.^2+dlats.^2);
%     end
% end



%%

xr = transpose(grid.xr);
yr = transpose(grid.yr);

diff_abs = nan(size(xr));
for i = 1:size(xr,1)
    for j = 1:size(xr,2)
        lon_pix = lon(i,j);
        lat_pix = lat(i,j);
        diff_lon = lon-lon_pix;
        diff_lat = lat-lat_pix;
        
        all = reshape(sqrt(diff_lon.^2+diff_lat.^2)*111,...
            size(xr,1)*size(xr,2),1);
        sorted_diff = sort(all,'ascend');
        diff_abs(i,j) = sorted_diff(2); % rough dlonlat to km 
        
    end
end

%%

grad_thresh_d = diff_abs.*grad_thresh;

for t = 1:size(vr,3)
    
    
    for i = 1:size(vr,1)
        for j = 1:size(vr,2)
            max_i = size(vr,1);
            max_j = size(vr,2);
            min_i = 1;
            min_j = 1;
            diff = get_diff(vr,i,j,t,min_i, min_j, max_i,max_j);
    
    
            if diff > grad_thresh_d(i,j)
                max_i = size(vr,1);
                max_j = size(vr,2);
                min_i = 1;
                min_j = 1;
                
    
                neigh_diff = check_neighbours(vr,i,j,t,...
                    min_i,min_j,max_i,max_j);
    
                if all(diff > neigh_diff)
                    vr(i,j,t)=NaN;
                end
    
            end
        end
    end




end



% 
% 
% %% 
% vr=vr_ori;
% t=80;
% grad_thresh = 0.15;
% figure; 
% hold on;
% title('before')
% pcolor(lon,lat,vr(:,:,t))
% shading flat;
% colorbar 
% caxis([-1.5 1.5])
% colormap(jet)
% hold off;
% 
% 
% for i = 1:size(vr,1)
%     for j = 1:size(vr,2)
%         max_i = size(vr,1);
%         max_j = size(vr,2);
%         min_i = 1;
%         min_j = 1;
%         diff = get_diff(vr,i,j,t,min_i, min_j, max_i,max_j);
% 
% 
%         if diff > grad_thresh_d(i,j)
%             max_i = size(vr,1);
%             max_j = size(vr,2);
%             min_i = 1;
%             min_j = 1;
%             
% 
%             neigh_diff = check_neighbours(vr,i,j,t,...
%                 min_i,min_j,max_i,max_j);
% 
%             if all(diff > neigh_diff)
%                 vr(i,j,t)=NaN;
%             end
% 
%         end
%     end
% end
% 
% 
% figure; pcolor(lon,lat,vr(:,:,t))
% shading flat;colorbar 
% caxis([-1.5 1.5])
% colormap(jet)
% 
end