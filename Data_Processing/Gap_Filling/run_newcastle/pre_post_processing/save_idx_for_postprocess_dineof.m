


clc; 
clear all;
close all;

addpath('/home/natachab/DINEOF/processing_dineof/Function_dineof/');
suffix = '07_09'

name_pey = ['/data/MIO/natachab/dineof_hourly_2021/my_result_folder/' suffix '/PEY_din_Y2021M' suffix '.nc'];
name_pob = ['/data/MIO/natachab/dineof_hourly_2021/my_result_folder/' suffix '/POB_din_Y2021M' suffix '.nc'];

vr1 = ncread(name_pey,'v');
vr2 = ncread(name_pob,'v');

%remove fill value
vr1(abs(vr1)>100)=NaN;
vr2(abs(vr2)>100)=NaN;

[all_false,vr1_ave,vr2_ave] = post_treatment_fill_after(vr1, vr2);
all_false = all_false(1:end-1);

name_idx = ['/data/MIO/natachab/dineof_hourly_2021/my_result_folder/idx_steps/idx_' suffix];
name_vr = ['/data/MIO/natachab/dineof_hourly_2021/my_result_folder/idx_steps/vr_ave_' suffix];

save(name_idx,'all_false');
save(name_vr,'vr1_ave','vr2_ave');
