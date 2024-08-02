% This script generates a list of already fit DCMs
% to give as input to a PEB batch for specifying a group
% for sencond level analysis. Run after using DCM_selection
% to know which combination of TE and model is preferred

% Naming based on the convention established in DCM_estimation

% Change script accordingly to make different files for all
% participants, only gambling disorder patients (1 to 37) or
% only healthy controls (38 to 74)

n_participants = 74
chosen_TE = 2
chosen_model = 2

model_dir = '~/Analysis/Models/'
GCM = {}

for i = 1:n_participants
    filename = sprintf('GLM_%d_A%d_TE%d.mat', i, chosen_model, chosen_TE)
    filename = strcat(model_dir, filename)
    GCM{i,1} = filename
end

save("PEB_DCM_list_second_best_model.mat", "GCM")