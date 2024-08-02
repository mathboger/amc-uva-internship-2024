% Script that estimates all the DCMs specified

% Define paths and get model specifications
start_dir = pwd
dcm_dir = '~/Analysis/Batches/DCM/'
output_dir = '~/Analysis/Models/'

cd(dcm_dir)
specifications = spm_select('List', pwd, 'mat$')
n_models = size(specifications)
n_models = n_models(1)
len_filename = size(specifications)
len_filename = len_filename(2)

for i = 1:n_models
    GCM = cellstr(specifications(i,:))
    GCM = spm_dcm_load(GCM)
    GCM = spm_dcm_estimate(GCM{1,1})
    cd(output_dir)
    % Generate file name
    % This assumes that the files all start with "DCM_"
    % and finish with either ".mat" or ".mat " depending
    % on the number of the participant (following the
    % convention adopted in the specification script)
    outfile = strcat("GLM_", specifications(i,5:len_filename))
    save(outfile, "GCM")
    cd(dcm_dir)
end

cd(start_dir)