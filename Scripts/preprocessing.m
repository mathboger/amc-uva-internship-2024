% List of open inputs
% Realign: Estimate & Reslice: Session - cfg_files
nrun = X; % enter the number of runs here
jobfile = {'/data/mboger/Motion Control Test/scripts/Confidence/Preprocessing/Realignment Only/preprocessing_job.m'};
jobs = repmat(jobfile, 1, nrun);
inputs = cell(1, nrun);
for crun = 1:nrun
    inputs{1, crun} = MATLAB_CODE_TO_FILL_INPUT; % Realign: Estimate & Reslice: Session - cfg_files
end
spm('defaults', 'FMRI');
spm_jobman('run', jobs, inputs{:});
