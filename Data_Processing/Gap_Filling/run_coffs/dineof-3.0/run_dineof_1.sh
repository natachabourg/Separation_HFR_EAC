_!/bin/sh 
# Author : Natacha Bourg
# Script to run DINEOF
# Script to place in the folder/dineof-3.0 (where there is the fortran executable)


# Create .init file

cat <<EOF >/home/natachab/Bureau/eac_chloro_hfr_analysis/hfr_data_processing/gap_filling/run_coffs/dineof-3.0/run_dineof_init_1.init &&

!  INPUT File for dineof 3.0 

data = ['/home/natachab/Bureau/eac_chloro_hfr_analysis/hfr_data_processing/gap_filling/run_coffs/pre_post_processing/daily_2019_2021_RRK_pre.nc#v','/home/natachab/Bureau/eac_chloro_hfr_analysis/hfr_data_processing/gap_filling/run_coffs/pre_post_processing/daily_2019_2021_NNB_pre.nc#v'] 

mask = ['/home/natachab/Bureau/eac_chloro_hfr_analysis/hfr_data_processing/gap_filling/run_coffs/pre_post_processing/mask_2019_2021_RRK.nc#mask','/home/natachab/Bureau/eac_chloro_hfr_analysis/hfr_data_processing/gap_filling/run_coffs/pre_post_processing/mask_2019_2021_NNB.nc#mask'] 

time = '/home/natachab/Bureau/eac_chloro_hfr_analysis/hfr_data_processing/gap_filling/run_coffs/pre_post_processing/daily_2019_2021_RRK_pre.nc#time' 

alpha = 0.5

numit =  3

nev =  150 

neini =   1 

ncv =  156

tol = 1.00e-08 

nitemax = 300

toliter = 1.00e-02

rec = 1 

eof = 1 

norm = 1 

Output = '/home/natachab/Bureau/eac_chloro_hfr_analysis/hfr_data_processing/gap_filling/run_coffs/my_result_folder' 

results = ['/home/natachab/Bureau/eac_chloro_hfr_analysis/hfr_data_processing/gap_filling/run_coffs/my_result_folder/daily_2019_2021_RRK_din.nc#v','/home/natachab/Bureau/eac_chloro_hfr_analysis/hfr_data_processing/gap_filling/run_coffs/my_result_folder/daily_2019_2021_NNB_din.nc#v'] 
seed = 243435 

! END OF PARAMETER FILE 

EOF
echo "init created"

# Execute DINEOF
time ./dineof /home/natachab/Bureau/eac_chloro_hfr_analysis/hfr_data_processing/gap_filling/run_coffs/dineof-3.0/run_dineof_init_1.init > /home/natachab/Bureau/eac_chloro_hfr_analysis/hfr_data_processing/gap_filling/run_coffs/dineof-3.0/run_dineof_log_1.log 2>&1 &&

echo "dineof : done"
