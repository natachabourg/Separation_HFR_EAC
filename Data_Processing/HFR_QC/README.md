27 oct. 2022
Natacha Bourg 

This folder contains Matlab scripts to QC radar data off Newcastle (CODAR) and Coffs Harbour (WERA). 

Matlab scripts to create a radial grid are in the 'Create_Radial_Grid' folder. It is later used in the QC to compute spatial gradients using xr and yr. 

All QC functions (from Dylan Dumas, Matthew Archer, Natacha Bourg) are in the 'Functions_QC' folder. And two main scripts : 'main_codar.m' and 'main_wera.m' have been run to process the data.

Data is later lowpass filtered (38hrs with pl66tn.m) and daily averaged in a new files using Matlab scripts in the 'Daily_Average' folder.

_______________________________________________________________________________

QC for CODAR radar off Newcastle (RHED and SEAL): 
 
Steps : 
- Mask Land
- Mask data further than 200 km
- Apply IMOS QC
- Remove outliers (detected with standard deviation and spatial gradient)
- Remove data below and over N_std = 3
- Remove poor temporal coverage pixels
- Removes outliers of Spatial/Temporal gradient (under 3% of gradient
histogram)
- Despike using acceleration, remove over 3 stds on a moving average
- Removes isolated points
- Linear interpolation of well-surrounded missing points

Thresholds have been chosen after sensitivity tests

_______________________________________________________________________________

QC for WERA radar off Coffs Harbour (RRK and NNB): 

 
Steps : 
- Mask Land
- Mask data further than 150 km
- Apply IMOS QC
- Remove outliers (detected with standard deviation and spatial gradient)
- Remove data below and over N_std = 3
- Remove poor temporal coverage pixels
- Removes outliers of Spatial/Temporal gradient (under 3% of gradient
histogram)
- Despike using acceleration, remove over 3 stds on a moving average
- Removes isolated points
- Linear interpolation of well-surrounded missing points

Thresholds have been chosen after sensitivity tests

