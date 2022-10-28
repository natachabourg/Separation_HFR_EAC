mask_rrk = ncread('mask_2019_2021_RRK.nc','mask')';
mask_nnb = ncread('mask_2019_2021_NNB.nc','mask')';


rrk_file = 'daily_2019_2021_RRK_pre.nc';
nnb_file = 'daily_2019_2021_NNB_pre.nc';

rrk = ncread(rrk_file,'lon');
nnb = ncread(nnb_file,'lon');

lon_rrk = ncread(rrk_file,'lon');
lat_rrk = ncread(rrk_file,'lat');

lon_nnb = ncread(nnb_file,'lon');
lat_nnb = ncread(nnb_file,'lat');

size_rrk = length(rrk(find(mask_rrk==1)));
size_nnb = length(nnb(find(mask_nnb==1)));

left = load('/home/natachab/Bureau/eac_chloro_hfr_analysis/hfr_data_processing/gap_filling/run_coffs/my_result_folder/log5/outputEof.lftvec');

lft_rrk = left(1:size_rrk,:);
lft_nnb = left(size_rrk+1:end,:);

eof_rrk = nan(size(mask_rrk));
eof_nnb = nan(size(mask_nnb));
%%

figure;
subplot(421)

eof_rrk = nan(size(mask_rrk));
eof_nnb = nan(size(mask_nnb));

eof_rrk(find(mask_rrk==1))=lft_rrk(:,1);
pcolor(lon_rrk,lat_rrk,eof_rrk');
shading flat
subplot(422)
eof_rrk = nan(size(mask_rrk));
eof_nnb = nan(size(mask_nnb));

eof_nnb(find(mask_nnb==1))=lft_nnb(:,1);
pcolor(lon_nnb,lat_nnb,eof_nnb');
shading flat


subplot(423)

eof_rrk = nan(size(mask_rrk));
eof_nnb = nan(size(mask_nnb));

eof_rrk(find(mask_rrk==1))=lft_rrk(:,2);
pcolor(lon_rrk,lat_rrk,eof_rrk');
shading flat

subplot(424)
eof_rrk = nan(size(mask_rrk));
eof_nnb = nan(size(mask_nnb));

eof_nnb(find(mask_nnb==1))=lft_nnb(:,2);
pcolor(lon_nnb,lat_nnb,eof_nnb');
shading flat

subplot(425)

eof_rrk = nan(size(mask_rrk));
eof_nnb = nan(size(mask_nnb));

eof_rrk(find(mask_rrk==1))=lft_rrk(:,3);
pcolor(lon_rrk,lat_rrk,eof_rrk');
shading flat

subplot(426)
eof_rrk = nan(size(mask_rrk));
eof_nnb = nan(size(mask_nnb));

eof_nnb(find(mask_nnb==1))=lft_nnb(:,3);
pcolor(lon_nnb,lat_nnb,eof_nnb');
shading flat



subplot(427)

eof_rrk = nan(size(mask_rrk));
eof_nnb = nan(size(mask_nnb));

eof_rrk(find(mask_rrk==1))=lft_rrk(:,4);
pcolor(lon_rrk,lat_rrk,eof_rrk');
shading flat

subplot(428)
eof_rrk = nan(size(mask_rrk));
eof_nnb = nan(size(mask_nnb));

eof_nnb(find(mask_nnb==1))=lft_nnb(:,4);
pcolor(lon_nnb,lat_nnb,eof_nnb');
shading flat

















