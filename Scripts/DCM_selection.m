% Script to compile information from the fitted models
% so a model can be chosen for further analysis
% Mainly compiling BIC and exporting to a csv so this
% information can be visualized and a combination of TE
% and model type can be chosen

% Path and constant variables declaration
start_dir = pwd
model_dir = '~/Analysis/Models/'
cd(model_dir)
models = spm_select('List', pwd, 'mat$')

n_participants = 74
n_TE = 4
n_models = 5
n_total = n_participants * n_TE * n_models
%%
% These variables are going to become columns in the final exported
% table

participant = []
te = []
model = []
bic = []

cd(model_dir)
for m = 1:n_total
    name = models(m,:)
    name = strsplit(name, ' ') % Remove blank spaces after the extension
    load(name{1}) 
    % Getting information from filename based on the convention established
    % in DCM_specification
    name = models(m,:)
    name = strsplit(name, '_')
    participant(m) = str2num(name{2})
    te(m) = str2num(name{4}(3))
    model(m) = str2num(name{3}(2))
    bic(m) = GCM.BIC % loaded from the model file
end
%%
% Make table to export to csv
T = table(transpose(participant), transpose(te), transpose(model), transpose(bic), 'VariableNames', {'Participant', 'TE', 'Model', 'BIC'})
writetable(T, 'BIC.csv')
cd(start_dir)

%%
% This section of the script is just used to load and rename the variable
% insde the fit model so that the PEB batch is able to reference it

chosen_TE = 2
chosen_model = 2

cd(model_dir)
for i = 1:n_participants
    filename = sprintf('GLM_%d_A%d_TE%d.mat', i, chosen_model, chosen_TE)
    load(filename)
    DCM = GCM
    save(filename, "DCM", "GCM")
end
cd(start_dir)