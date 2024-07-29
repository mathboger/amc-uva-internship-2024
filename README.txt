This folder contains the product of the internship by Matheus Boger from 01/2024 to 07/2024 under Ruth van Holst.

The pre-registration of the study can be found in:
osf.io/mc4jt

The final report can be found in:
<add link to GitHub>

In summary, the study aimed to evaluate if there is a difference in endogenous connectivity from the ventral to the dorsal striatum in patients with GD compared to HC. We make use of SPM to run DCM fitting and PEB analysis.

What can you find in the folders?
- Batches: MATLAB batches for GLM, VOI extraction and DCM/PEB models
- Data: the preprocessed participant scan data, motion parameters, demographics and extracted VOIs
- Figures: graphic output of SPM saved as png as well as some plots made with R for correlation analysis
- GLM: the batch specification of the initial GLM to extract VOIs from the participants and the resulting files from the fitting of that GLM
- Masks: all masks that were made in the process of the internship. The ones used for VOI extraction are saved under the subfolder 'Used Masks'
- Models: all fit DCM and PEB models
- Scripts: all scripts developed through the internship (R and MATLAB). See comments in the files for how to use them. The main scripts are 'demographics_control.R', 'restingState_master_preprocessing.m', and all the ones that begin with 'DCM'. The clustering scripts were developed but not used for the final result. Change the paths present in the scripts accordingly to the structure you have on your version.
