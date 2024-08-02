% This script loads the selected DCMs and exports into a CSV
% the connectivity parameters so they can be loaded in R
% for the correlation analysis

start_dir = pwd
model_dir = '~/Analysis/Models/'
out_dir = model_dir
chosen_TE = 2
chosen_model = 4
n_participants = 74
nuc_acc = 1
caudate = 2
putamen = 3

participant = []
nuc_acc_to_nuc_acc = []
nuc_acc_to_caudate = []
nuc_acc_to_putamen = []
caudate_to_nuc_acc = []
caudate_to_caudate = []
caudate_to_putamen = []
putamen_to_nuc_acc = []
putamen_to_caudate = []
putamen_to_putamen = []

cd(model_dir)
for i = 1:n_participants
    filename = sprintf('GLM_%d_A%d_TE%d.mat', i, chosen_model, chosen_TE)
    load(filename)
    participant(i) = i
    nuc_acc_to_nuc_acc(i) = GCM.Ep.A(nuc_acc, nuc_acc)
    nuc_acc_to_caudate(i) = GCM.Ep.A(caudate, nuc_acc)
    nuc_acc_to_putamen(i) = GCM.Ep.A(putamen, nuc_acc)
    caudate_to_nuc_acc(i) = GCM.Ep.A(nuc_acc, caudate)
    caudate_to_caudate(i) = GCM.Ep.A(caudate, caudate)
    caudate_to_putamen(i) = GCM.Ep.A(putamen, caudate)
    putamen_to_nuc_acc(i) = GCM.Ep.A(nuc_acc, putamen)
    putamen_to_caudate(i) = GCM.Ep.A(caudate, putamen)
    putamen_to_putamen(i) = GCM.Ep.A(putamen, putamen)
end

cd(out_dir)
T = table(transpose(participant), transpose(nuc_acc_to_nuc_acc), transpose(nuc_acc_to_caudate), transpose(nuc_acc_to_putamen), ...
    transpose(caudate_to_nuc_acc), transpose(caudate_to_caudate), transpose(caudate_to_putamen), ...
    transpose(putamen_to_nuc_acc), transpose(putamen_to_caudate), transpose(putamen_to_putamen), ...
    'VariableNames', {'participant', 'nuc_acc_to_nuc_acc', 'nuc_acc_to_caudate', 'nuc_acc_to_putamen', 'caudate_to_nuc_acc', 'caudate_to_caudate', 'caudate_to_putamen', 'putamen_to_nuc_acc', 'putamen_to_caudate', 'putamen_to_putamen'})
writetable(T, 'connectivities_chosen_model.csv')

cd(start_dir)