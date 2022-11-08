02 nov. 2022
Natacha Bourg 

This folder contains all scripts needed to run DINEOF algorithm on Newcastle HFR data, from the pre-processing to the post processing. 

_______________________________________________________________________________

- QCed daily data from RHED and SEAL to fill are stored in 'original_data/' folder.

- Pre-processing : done with pre_post_processing/pre_processing.m. Actually not much is done, we create a mask of minimum temporal coverage over which DINEOF will be run (here coverage chosen is 30% for RHED and 50% for SEAL) and we put the HFR velocity file in the format needed for dineof. 

The temporal coverage is lower for RHED than for SEAL because there was less data in RHED. We think that it might be the reason why RHED tends to have more oftenly bad reconstruction than SEAL.
_______________________________________________________________________________

- Dineof run : all functions and program (fortran) needed are in 'dineof-3.0/' folder. Use run_dineof_2.sh to run, and choose input parameters. Parameters have been chosen after testing different combinations. Here, we ask a convergence of 0.1% (on cross-validation points, randomly sampled), 25 EOF modes have been computed and 0.98 of the variance of the initial matrix is found.

Outputs of the algorithm are in 'my_result_folder/' : Careful: RHED and SEAL filled files in this folder are not post processed, they only are before computing vectors. However currents_dineof_NEWC_Y2019M07_Y2021M12.nc has been post processed. Other files in there are outputs of the algorithm, mainly EOF computation outputs. 

- The outputs of DINEOF have been post processed and the vector reconstruction has been done using pre_post_processing/post_process_radials_map_vectors.m. We remove data where the two radials intersect at an angle < 30° or > 150° (Like Cosoli)
_______________________________________________________________________________

- The computed EOF modes seem ok and the reconstruction have smoothed a lot bad data still present after QC. In general, the filling of non-full maps is good. We observe some problems in the reconstruction, especially when both radials are entirely missing, and/or when long holes without one radial (see pre_post_processing/Check_Dineof_Newcastle_Decides_PostProcess.ipynb for more details). Bad reconstructions are therefore removed using pre_post_processing/post_process_radials_map_vectors.m. We also reconstruct cartesian velocities on a 6km grid resolution using this script.

- Basic plots on the filled dataset can be found in 'Recap_dineof_newcastle.ipynb'
