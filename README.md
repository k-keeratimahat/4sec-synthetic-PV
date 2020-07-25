# 4sec-synthetic-PV
Generation of synthetic PV output time series at 4 seconds using hourly solar irradiance

PV plants notation: 277 - Nyngan, 295 - Broken Hill, 299 - Moree, 309 - Royalla.

`data - Generate reference data` contains parameters such as tilt angle, azimuth of the four reference plants.

#### Generate reference/training data
`code - Generate reference data` contains subfolders of steps in generating statistical distribution from the reference data

`3.1.2` contains codes to calculate 4-second clear sky PV output,
then arrange the 4-second clear sky output into hourly interval.

`3.1.3` contains code which sorts the hourly interval according to each pair of GHI and DNI. `BIN_INDEX.mat` contains the bin numbers that physically exist.

`3.1.4` contains code that fits q-exponential distribution to the measured (i.e. reference) distribution.

`3.1.5 & 3.1.6` contains the code which scale the distributions to the desired DC plant capacity.

#### Generate synthetic time series
`code-Synthetic time series` contatins 
* `model_4_sec.m` which generate 4-second time series with input of the hourly GHI, DNI and PV output of the plant to be modelled and the scaled distributions from the previous step.
* `prepare_for_validation.m` which calculate PV output variability from the generated 4-second time series and other statistical measures including RMSD, NMBD and KSI.

##### Sample outputs
Each folder contains some examples of output file of the code(s) within the same folder.

Where a reference plant and a test plant are paired, the file name can be read as follow:

`bin_dist_pool_(yyyy)_(reference plant)_(test plant).mat`

`Hourly_model_(yyyy)_(test plant)_(reference plant).mat`
