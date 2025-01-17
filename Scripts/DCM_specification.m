% Script used to specify all the DCMs made for our analysis
% They are 5 models x 4 TEs (multi-echo) x 74 participants = 1480 models

% First, definitions

% Scanner settings
TR = 2.375
TE1 = 0.009
TE2 = 0.0264
TE3 = 0.0306
TE4 = 0.0438
TE = [TE1, TE2, TE3, TE4]
n_TE = 4

% Experiment settings
n_participants = 74
n_regions = 3
n_conditions = 1 % since there is no task

% Index of each region
nuc_acc = 1
caudate = 2
putamen = 3

% Specification of matrices that do not change between models
% These matrices are more used when there is a task involved, which
% is not our case with resting state data (however, they must be passed
% to SPM)

B = zeros(n_regions, n_regions, n_conditions)
C = zeros(n_regions, n_conditions)
D = zeros(n_regions, n_regions, 0)

% Specification of model A1
A1 = zeros(n_regions, n_regions)
A1(caudate, nuc_acc) = 1
A1(putamen, caudate) = 1
A1(nuc_acc, nuc_acc) = 1
A1(caudate, caudate) = 1
A1(putamen, putamen) = 1

% Specification of model A2
A2 = zeros(n_regions, n_regions)
A2(caudate, nuc_acc) = 1
A2(nuc_acc, caudate) = 1
A2(putamen, caudate) = 1
A2(caudate, putamen) = 1
A2(nuc_acc, nuc_acc) = 1
A2(caudate, caudate) = 1
A2(putamen, putamen) = 1

% Specification of model A3
A3 = zeros(n_regions, n_regions)
A3(caudate, nuc_acc) = 1
A3(putamen, nuc_acc) = 1
A3(putamen, caudate) = 1
A3(nuc_acc, nuc_acc) = 1
A3(caudate, caudate) = 1
A3(putamen, putamen) = 1

% Specification of model A4
A4 = ones(n_regions, n_regions)

% Specification of model A5
A5 = zeros(n_regions, n_regions)
A5(caudate, nuc_acc) = 1
A5(putamen, nuc_acc) = 1
A5(nuc_acc, nuc_acc) = 1
A5(caudate, caudate) = 1
A5(putamen, putamen) = 1

A(:,:,1) = A1
A(:,:,2) = A2
A(:,:,3) = A3
A(:,:,4) = A4
A(:,:,5) = A5
n_models = 5

% Set directory variables
start_dir = pwd
glm_dir = '~/Analysis/GLM' 
roi_dir = '~/Analysis/Data/RoIs'
output_dir = '~/Analysis/Batches/DCM/'
%%
% Now we specify the DCMs
for participant = 1:n_participants
    for model = 1:n_models % Reset this after testing
        for te = 1:n_TE % Reset this after testing
            % Load SPM
            SPM = load(fullfile(glm_dir, "SPM.mat"))
            SPM = SPM.SPM

            % Load RoIs
            f = {fullfile(roi_dir, sprintf("VOI_Accumbens_%d.mat", participant))
                fullfile(roi_dir, sprintf("VOI_Caudate_%d.mat", participant))
                fullfile(roi_dir, sprintf("VOI_Putamen_%d.mat", participant))}
            for r = 1:length(f)
                XY = load(f{r})
                xY(r) = XY.xY
            end

            cd(output_dir)
            % Specify the DCM
            s = struct()
            s.name = sprintf('%d_A%d_TE%d', participant, model, te)
            s.u = [1] % Check if we actually want this
            s.delays = repmat(TR, 1, n_regions)
            s.TE = TE(te)
            s.nonlinear = false
            s.two_state = false
            s.stochastic = false
            s.centre = true
            s.induced = 1 % For resting state date
            s.a = A(:,:,model)
            s.b = B
            s.c = C
            s.d = D
            s.options.analysis = 'CSD' % For resting state data
            DCM = spm_dcm_specify(SPM, xY, s)

            cd(start_dir)
        end
    end
end