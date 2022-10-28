_!/bin/sh 
# Author : Natacha Bourg
# Script to run DINEOF
# Script to place in the folder/dineof-3.0 (where there is the fortran executable)


# Create .init file

cat <<EOF >/home/natachab/Bureau/eac_chloro_hfr_analysis/hfr_data_processing/gap_filling/run_newcastle/dineof-3.0/run_dineof_init_2.init &&

!  INPUT File for dineof 3.0 

data = ['/home/natachab/Bureau/eac_chloro_hfr_analysis/hfr_data_processing/gap_filling/run_newcastle/pre_post_processing/daily_2019_2021_RHED_pre.nc#v','/home/natachab/Bureau/eac_chloro_hfr_analysis/hfr_data_processing/gap_filling/run_newcastle/pre_post_processing/daily_2019_2021_SEAL_pre.nc#v'] 

mask = ['/home/natachab/Bureau/eac_chloro_hfr_analysis/hfr_data_processing/gap_filling/run_newcastle/pre_post_processing/mask_2019_2021_RHED.nc#mask','/home/natachab/Bureau/eac_chloro_hfr_analysis/hfr_data_processing/gap_filling/run_newcastle/pre_post_processing/mask_2019_2021_SEAL.nc#mask'] 

time = '/home/natachab/Bureau/eac_chloro_hfr_analysis/hfr_data_processing/gap_filling/run_newcastle/pre_post_processing/daily_2019_2021_RHED_pre.nc#time' 

alpha = 0.5

numit =  3

nev =  25 

neini =   1 

ncv =  30

tol = 1.00e-08 

nitemax = 300

toliter = 1.00e-03

rec = 1 

eof = 1 

norm = 1 

Output = '/home/natachab/Bureau/eac_chloro_hfr_analysis/hfr_data_processing/gap_filling/run_newcastle/my_result_folder/log2' 

results = ['/home/natachab/Bureau/eac_chloro_hfr_analysis/hfr_data_processing/gap_filling/run_newcastle/my_result_folder/log2/daily_2019_2021_RHED_din.nc#v','/home/natachab/Bureau/eac_chloro_hfr_analysis/hfr_data_processing/gap_filling/run_newcastle/my_result_folder/log2/daily_2019_2021_SEAL_din.nc#v'] 
seed = 243435 

! END OF PARAMETER FILE 

EOF
echo "init created"

# Execute DINEOF
time ./dineof /home/natachab/Bureau/eac_chloro_hfr_analysis/hfr_data_processing/gap_filling/run_newcastle/dineof-3.0/run_dineof_init_2.init > /home/natachab/Bureau/eac_chloro_hfr_analysis/hfr_data_processing/gap_filling/run_newcastle/dineof-3.0/run_dineof_log_2.log 2>&1 &&

echo "dineof : done"
