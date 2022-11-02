This is version 2.0.2 of the Matlab based spatial sampling design 
toolbox SPATDESIGN. It is published under GPL-2. Read the file 
COPYING for licence agreements.

  The toolbox provides routines for spatial sampling design with the
linear Bayesian kriging predictor or the universal kriging predictor. 
Designs can be improved, design locations can be added or removed 
from available designs. 
  Furthermore Bayesian linear kriging and transformed-Gaussian kriging
together with routines for semivariogram- and transformation parameter 
estimation are implemented as interpolation routines . 
For details on the implemented algorithms we refer to the attached 
papers serra08_pilz_spoeck.pdf and serra09_spoeck_pilz.pdf.
  In future the toolbox will be extended with spatial sampling design 
algorithms for non-stationary random fields, for the estimation 
of the covariance function and for Bayesian copula based and 
transformed-Gaussian kriging. Furthermore it is planned to give efficiency
estimates that demonstrate how close the generated suboptimal designs are
to the unknown optimal designs.

  Copy the files to a directory, call Matlab, and add the path to this 
directory to your Matlab environment. It is best to start with one of the files
examplesessionGomel.m, examplesessionPakistan.m or examplesessiondriftPakistan.m,
where all the functionalities of the toolbox are 
explained in detail. The so-called Gomel data set is a data set of Caesium 137 
measurements in the region of Gomel, Belarus, 10 years after the Chernobyl accident.
The Pakistan data set comprises rainfall data from Pakistan. Variables like humidity,
elevation and wind may be considered as variables in external drift universal kriging
and sampling design. 

  The toolbox makes use of the Matlab Optimization Toolbox via the functions
optimset.m and fmincon.m, but basic design routines can be used also 
without this toolbox available (functions ending ....frompooladd.m).
I run the toolbox with Matlab 7.7.0 (R2008b) on a Linux system with 4GB RAM and 
a 2.333 GHz processor. Especially a lot of RAM is required because high 
dimensional matrices must be stored during computation.

Enjoy.
Gunter Spöck,                                        September 2009.


New in version 2.0.0 (April 2010):

i) Spatial sampling design, Bayesian linear universal kriging and generalized 
least squares estimation with an external drift have been added. 
See also examplesessiondriftPakistan.m.

ii) Wolfgang Nowak from the Institute of Hydraulic Engineering (IWS),
University of Stuttgart, Germany, has contributed a package for
FFT-Kriging to Version 2.0.0 of spatDesign. The speed of kriging 
in 1-, 2- and 3-D of his Kriging_FFT_Toolbox is really impressive. Please, 
read the README.txt file attached to his package for licence agreements.




CONTACT INFORMATION FOR THE KRIGING_FFT_TOOLBOX:

Dr.-Ing. Wolfgang Nowak, M.Sc.
Junior Professor
Institute of Hydraulic Engineering (IWS)
Chair for Hydraulics and Modelling of Hydrosystems (LH2)
University of Stuttgart
Pfaffenwaldring 7a
D-70569 Stuttgart, Germany

Mail: wolfgang.nowak@iws.uni-stuttgart.de
Phone: +49 (0)711 / 685 - 60113
Fax:   +49 (0)711 / 685 - 60430


CONTACT INFORMATION FOR THE SPATDESIGN TOOLBOX IN GENERAL:

Dr. Gunter Spöck
Assistant Professor
Department of Statistics
University of Klagenfurt
Universitaetsstraße 65-67
9020 Klagenfurt, Austria

Mail: gunter.spoeck@uni-klu.ac.at
Phone: +43 (0)650 2606166
       +43 (0)463 2700 3125
Fax:   +43 (0)463 2700 3199

