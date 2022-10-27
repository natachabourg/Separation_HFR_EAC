function [vr_return_final] = outliers_std_diff(lon,lat,vr,percent,codar)

    [dim_x, dim_y, dim_t] = size(vr);
    
    std_vr = nanstd(vr, [], 3);

    differ_x = NaN*ones(dim_x,dim_y);
    differ_y = NaN*ones(dim_x,dim_y);
    
    differ_x(1:end-1,:) = diff(std_vr,1,1);

    differ_y(:,1:end-1) = diff(std_vr,1,2);

    difference = abs(differ_x).*abs(differ_y);
    
%     [pdf, values] = hist(reshape(difference, dim_x*dim_y,1));
%     pdf_thresh = max(pdf)*percent/100;
% 
%     ind = find(pdf>=pdf_thresh, 1, 'last');
%     values_resolution = values(2)-values(1);
% 
%     threshold = values(ind) - values_resolution/2;
% 
% 
% % 
    figure;
    subplot(121)
    hold on
    pcolor(lon,lat,abs(differ_x));
    title('x');
    shading flat; 
    colorbar; 
    colormap("jet");
    shg; 

    subplot(122)
    hold on
    pcolor(lon,lat,abs(differ_y));
    title('y');
    shading flat; 
    colorbar; 
    colormap("jet");
    hold off;
    shg;    


%     threshold = input('entrez votre threshold ');
    threshold_x = 0.4;
    threshold_y = 0.4;
    close all;


    mask = double(abs(differ_x) < threshold_x);
    mask(mask==0) = NaN;
    
    mask_y = double(abs(differ_y) < threshold_y);
    mask_y(mask_y==0)=NaN;

    vr_return = vr.*mask;
    vr_return = vr_return.*mask_y;


    difference = NaN*ones(dim_x,dim_y);

    for i=1:dim_x
        for j=1:dim_y
            difference(i,j) = nanstd(diff(vr_return(i,j,:)));
        end
    end
    
    figure;
    pcolor(lon,lat,difference); shading flat; colorbar; colormap("jet");
    shg;
%     thresh_diff_min = input('entrez votre threshold bas ');
%     %close all;
%     thresh_diff_max = input('entrez votre threshold haut ')
% 
    
    thresh_diff_max = 0.7;
    
    mask_std = double(difference < thresh_diff_max);
    mask_std(mask_std==0) = NaN;
    
    vr_return_final = vr_return.*mask_std;

    for i=1:dim_x
        for j =1:dim_y
            difference(i,j) = abs(nanmean(diff(vr_return_final(i,j,:))));
        end
    end

    figure;
    pcolor(lon,lat,difference); shading flat; colorbar; colormap("jet");
    shg;
    thresh_diff = 0.6;
%     thresh_diff = input('entrez votre threshold ');
    %close all;

%   
    mask_std = double(difference < thresh_diff);
    mask_std(mask_std==0) = NaN;
    
    vr_return_final = vr_return_final.*mask_std;
    

    difference = NaN*ones(size(lon));
    difference(:,1:end-1) = (nanstd(diff(vr_return_final,1,2),[],3));
        
    difference2 = NaN*ones(size(lon));
    difference2(1:end-1,:) = (nanstd(diff(vr_return_final,1,1),[],3));
    

    figure;
    pcolor(lon,lat,difference); 
    shading flat; colorbar; colormap("jet");
    shg;
%     thresh_diff = input('entrez votre threshold ');
    
    thresh_diff = 0.17;
    
    figure;
    pcolor(lon,lat,difference2);
    shading flat; colorbar; colormap("jet");
    shg;

%     thresh_diff2 = input('entrez votre threshold ');

    thresh_diff2 = 0.17;

    mask_std = double(difference < thresh_diff);
    mask_std(difference2 > thresh_diff2) = 0;


    if codar
    
    
        for i = 1:dim_x
            for j = 1:dim_y
                plus1 = min([i+1, dim_x]);
                plus2 = min([i+2, dim_x]);
    
                moins1 = max([i-1, 1]);
                moins2 = max([i-2, 1]);
    
                plus1y = min([j+1, dim_y]);
                plus2y = min([j+2, dim_y]);
    
                moins1y = max([j-1, 1]);
                moins2y = max([j-2, 1]);
    
    
                mean_pix = nansum([mask_std(plus1,plus1y), mask_std(plus1,moins1y),...
                    mask_std(moins1,plus1y), mask_std(moins1,moins1y)]);
                if mean_pix < 3
                    mask_std(i,j) = 0;
                end
            end
        end
    else
    close all;

    mask_std(mask_std==0) = NaN;

    vr_return_final = vr_return_final.*mask_std;


end