% List of open inputs
% Volume of Interest: Which session - cfg_entry
nrun = 74; % enter the number of runs here
jobfile = {'/data/mboger/Analysis/Scripts/caudate_voi_extraction_job.m'};
jobs = repmat(jobfile, 1, nrun);
inputs = cell(1, nrun);
for crun = 1:nrun
    inputs{1, crun} = crun; % Volume of Interest: Which session - cfg_entry
end
spm('defaults', 'FMRI');
spm_jobman('run', jobs, inputs{:});
