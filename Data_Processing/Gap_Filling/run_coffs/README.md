08 nov. 2022
Natacha Bourg 

This folder contains all scripts needed to run DINEOF algorithm on Coffs Harbour HFR data, from the pre-processing to the post processing. 

_______________________________________________________________________________

- QCed daily data from RRK and NNB to fill are stored in 'original_data/' folder.

- Pre-processing : done with pre_post_processing/pre_processing.m. Actually not much is done, we create a mask of minimum temporal coverage over which DINEOF will be run (here coverage chosen is 40% for RRK and 70% for NNB) and we put the HFR velocity file in the format needed for dineof. 

The temporal coverage is lower for RRK than for NNB because there was less data in RRK.
_______________________________________________________________________________

- Dineof run : all functions and program (fortran) needed are in 'dineof-3.0/' folder. Use run_dineof_5.sh to run, and choose input parameters. Parameters have been chosen after testing different combinations. Here, we ask a convergence of 1% (on cross-validation points, randomly sampled), 25 EOF modes have been computed.

Outputs of the algorithm are in 'my_result_folder/' : Careful: RRK and NNB filled files in this folder are not post processed, they only are before computing vectors. However currents_dineof_COFFS_Y2019M07_Y2021M12.nc has been post processed. Other files in there are outputs of the algorithm, mainly EOF computation outputs. 

- The outputs of DINEOF have been post processed and the vector reconstruction has been done using pre_post_processing/post_process_radials_map_vectors.m. We remove data where the two radials intersect at an angle < 30° or > 150° (Like Cosoli)

_______________________________________________________________________________

- The computed EOF modes seem ok and the reconstruction have smoothed some of the remaining bad data/strong gradients still present after QC. In general, the filling of non-full maps is good. We observe some problems in the reconstruction, only when both radials are entirely missing (only 5 days, and at the end of the timeseries and forecast never work so it makes sense). Holes without one radial seem good (see pre_post_processing/Check_Dineof_CoffsHarbour_Decides_PostProcess.ipynb for more details). Bad reconstructions are therefore removed using pre_post_processing/post_process_radials_map_vectors.m. We also reconstruct cartesian velocities on a 1.5km grid resolution using this script.

- Basic plots on the filled dataset can be found in 'Recap_dineof_coffs_harbour.ipynb'
