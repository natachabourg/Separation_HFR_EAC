function [] = plot_diff(vr_ini, vr_out,lon,lat,gif_true,path,sta,yr,mth)

% some plots to see what the QC has done

%gif
%gif of variables
if gif_true
    set(gcf, 'Position', [10 10 1500 600]);

    gif([path 'comp_gif_' sta '_Y' yr 'M' mth '.gif'],'DelayTime',5,'LoopCount',5,'overwrite',true)
    for i=1:5:size(vr_ini,3)
        subplot(121)
        hold on;
        title('initial')
        hold off;
        pcolor(lon,lat,vr_ini(:,:,i)); 
        colormap(jet(30))
        colorbar
        caxis([-1.5 1.5])
        shading flat;
        
    
        subplot(122)
        pcolor(lon,lat,vr_out(:,:,i)); 
        colormap(jet(30))
        colorbar
        caxis([-1.5 1.5])
        shading flat;
    
        gif
    end
    
    %web('comp_gif.gif')

end


% histogram
fig_hist = figure('Position', [10 10 1500 600]);
h_ini=histogram(vr_ini, 'FaceColor','r');
hold on;
grid on;
h_out=histogram(vr_out, 'FaceColor','green');
title('Histogram of velocity values')
legend('before', 'after')
xlabel('Radial velocity [m/s]')
ylabel('Occurrence')
%saveas(fig_hist, [path 'hist_' sta '_Y' yr 'M' mth '.png'])

% standard deviation maps
fig_std = figure('Position', [10 10 1500 600]);
hold on;
sgtitle('STD Maps')
subplot(121);
hold on;
title('Before')
pcolor(lon,lat,std(vr_ini,'',3,'omitnan')); shading flat; colormap(jet(30));
colorbar;
caxis([0 1])
hold off;

subplot(122);
hold on;
title('After')
pcolor(lon,lat,std(vr_out,'',3,'omitnan')); shading flat; colormap(jet(30));
cb=colorbar;
caxis([0 1])
hold off;
%saveas(fig_std, [path 'std_' sta '_Y' yr 'M' mth '.png'])


%boxplot
rs_ini = reshape(squeeze(vr_ini(:,:,:)), size(vr_ini,1)*size(vr_ini,2), size(vr_ini,3));
rs_out = reshape(squeeze(vr_out(:,:,:)), size(vr_out,1)*size(vr_out,2), size(vr_out,3));

% fig_box=figure('Position', [10 10 1500 600]);
% hold on;
% 
% ax_ini = subplot(211);
% hold on;
% grid on;
% title('before')
% boxplot(rs_ini(:,1:7:end),'PlotStyle','compact');
% set(gca,'XTickLabel',{' '})
% hold off;
% 
% ax_out = subplot(212)
% hold on;
% grid on;
% boxplot(rs_out(:,1:7:end),'PlotStyle','compact');
% title('after')
% set(gca,'XTickLabel',{' '})
% hold off;
% 
% %linkaxes([ax_ini,ax_out],'xy')
% hold off;
% saveas(fig_box, [path 'box_' sta '_Y' yr 'M' mth '.png'])

% 
% 
% fig_box_zoom=figure('Position', [10 10 1500 600]);
% hold on;
% 
% ax_ini = subplot(211);
% hold on;
% grid on;
% title('before')
% boxplot(rs_ini(:,100:200),'PlotStyle','compact');
% set(gca,'XTickLabel',{' '})
% hold off;
% 
% ax_out = subplot(212)
% hold on;
% grid on;
% boxplot(rs_out(:,100:200),'PlotStyle','compact');
% title('after')
% set(gca,'XTickLabel',{' '})
% hold off;
% 
% linkaxes([ax_ini,ax_out],'xy')
% hold off;
% saveas(fig_box_zoom, [path 'box_zoom_' sta '_Y' yr 'M' mth '.png'])
% 



end