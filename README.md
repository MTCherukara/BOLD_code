This repository contains currently- and recently-used code from my DPhil.

   C_FABBER/
Everything necessary for locally compiling and running FABBER with the qBOLD model (assuming an up-to-date installation of FSL). 

   C_FABBER/fabber_core/
The core of FABBER 4.0 (c) 2017 University of Oxford (Adrian Groves and Michael Chappell). This is basically unchanged  from the IBME working version on ibme-gitcvs.eng.ox.ac.uk.

   C_FABBER/fabber_models_qBOLD
A set of FABBER models (written by Matthew Cherukara, based on the template provided in fabber_core/) implementing the Yablonskiy Quantitative-BOLD model (static dephasing regime) with variations. 

      fwdmodel_qbold_T2.cc (and .h)
This is the most up-to-date and relevant model that should be used most of the time


- - - -


   Matlab_Bayesian_MCMC/
Contains MATLAB code (written by Matthew Cherukara) implementing Bayesian inference on simulated qBOLD (ASE) data, and a bunch of .mat files containing simulated data.

      MTC_qASE.m
This script is what generates an ASE signal with specified parameters and noise. It calls MTC_qASE_model.m, which does the work.

      MTC_qASE_model.m
This function takes a set of tau values, and a structure of parameters (PARAMS), and calculates the ASE signal based on the static dephasing (Yablonskiy) model.

      MTC_ASE_tissue.m / MTC_ASE_extra.m / MTC_ASE_blood.m
These functions evaluate the static dephasing model in the various compartments (see He & Yablonskiy, 2007)

      MTC_Asymmetric_Bayes.m
This script performs grid searches in 1 and 2 dimensions on particular parameters - it’s what was used to produce the classic OEF-DBV crescent plot

      MTC_ASE_MH.m
This script performs the Metropolis Hastings algorithm to infer on particular parameters. Right now (2017-08-07) it doesn’t work right.

      param_update.m
This function is used in MTC_Asymmetric_Bayes.m and MTC_ASE_MH.m in order to change parameter values with each iteration.

      Bayes_Analysis.m
This script can be used to plot the Metropolis-Hastings results

      MTC_smooth.m
This function applies a Gaussian smoothing kernel in 2D

      Other .m files
Other MATLAB scripts in this folder were created to do specific things and are mostly obsolete now…


- - - - 

   Matlab_VesselSim/
Contains MATLAB code (written mostly by Nicholas P Blockley, taken from GitHub.com/fmriphysiology/simple_vessel_sim) which uses Monte Carlo methods (based on Boxerman) to simulate dephasing of protons in an environment containing blood vessels. The subfolders (signalResults/, storedPhase/, and newStoredPhase/) contain various results.

      simrun.m
This script carries out the simulation and saves the results into newStoredPhase/

      gentemplate.m
This function is called by simrun.m and contains some standard values

      MTC_vesselsim.m
This function is a modified version of simplevesselsim.m, and does the heavy lifting of the Monte Carlo simulations. It has a bit of extra functionality that simplevesselsim.m lacks.

      calculateLength.m
This function works out the lengths of the various vessels. This is useful for a whole bunch of things.

      locateProton.m
This function figures out whether a given proton is inside or outside a vessel, enabling us to use the correct regime.

      simAnalyse.m
This function (which can be called on its own) is used to analyse and display the results of the simulation. It has a very neat GUI (if I may say so myself), and should be pretty self-explanatory.

      plotSignal.m
This function is called by simAnalyse.m and makes pretty pictures. It can be used separately too.

      Other .m files
Other MATLAB scripts in this folder were created to do specific things and are mostly obsolete now… 
