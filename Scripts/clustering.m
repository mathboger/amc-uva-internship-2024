% K-clusters for striatal data based on Piray et al 2017

% List all the participants to be used
participants = string([1:74])
n_participants = size(participants, 2)
signal_data = struct % struct to save the data from all participants

for i = 1:n_participants
    % Load data from each participant
    datafile = strcat("../GLM/VOI/VOI_striatum_", int2str(i), ".mat")
    load(datafile, "xY")
    signal_data.(strcat("p", int2str(i))).data = xY.y
    signal_data.(strcat("p", int2str(i))).id = participants(i)

    % Calculate correlation
    signal_data.(strcat("p", int2str(i))).corr = corrcoef(xY.y)
    % Fisher transform
    signal_data.(strcat("p", int2str(i))).fcorr = atanh(corrcoef(xY.y))
end

n_voxels = size(signal_data.p1.corr, 1)

%% 

% Now we have the input for the K-clusters in the signal_data struct

% K-cluster settings (between parentheses is the standard from Piray et al)
K = 8 % The values of k to try (2:8)
replication_n = 20 % How many different random centroids per run should be tried (20)
% Group number manually implemented and fixed to 2 for now (later expand?)
% group_n = 2 % How many subdivisions of participants should be made to analyse stability (2)
subdivision_n = 100 % How many different subdivision should be created (100)
group_assignment = randi([1 2], subdivision_n, n_participants) % Assignment of participants to each subgroup

%% 
% Two ways to understand the group clustering and make it work:
% Apply Fisher transform for the average per group <- how Piray did, so how
% we implement
% Append matrices "to the right" instead of as a new page

% Prepare data for clustering implementing the appending to the right
% strategy
cluster_data = struct
for i = 1:subdivision_n
    name = strcat("d", int2str(i))
    m1 = zeros(n_voxels, n_voxels)
    m2 = zeros(n_voxels, n_voxels)
    counter1 = 0
    counter2 = 0
    for j = 1:n_participants
        if group_assignment(i, j) == 1
            m1 = m1 + signal_data.(strcat("p", int2str(j))).fcorr
            counter1 = counter1 + 1
        end
        if group_assignment(i, j) == 2
            m2 = m2 + signal_data.(strcat("p", int2str(j))).fcorr
            counter2 = counter2 + 1
        end
    end
    % Reverse Fisher to get corr matrix to run clustering on
    cluster_data.(name).m1 = tanh(m1/counter1)
    cluster_data.(name).m2 = tanh(m2/counter2)
end
%% 

save("clustering_preprocessed.mat")
%%
% Cluster
for i = 1:subdivision_n
    idx1 = zeros(n_voxels, 1)
    idx2 = zeros(n_voxels, 1)
    for k = 2:K
        idx1(:,k-1) = kmeans(cluster_data.(strcat("d", int2str(i))).m1, k, Distance='correlation', Replicates=replication_n)
        idx2(:,k-1) = kmeans(cluster_data.(strcat("d", int2str(i))).m2, k, Distance='correlation', Replicates=replication_n)
    end
end


%%

% Analyze stability to set an ideal k
% Nij/min(Ni,Nj)

stab_m = struct
for k = 2:K
    m = zeros(k, k)
    g1 = zeros(k,1)
    g2 = zeros(k,1)
    for i = 1:n_voxels
        m(idx1(i,k-1), idx2(i,k-1)) = m(idx1(i,k-1), idx2(i,k-1)) + 1
        g1(idx1(i,k-1)) = g1(idx1(i,k-1)) + 1
        g2(idx2(i,k-1)) = g2(idx2(i,k-1)) + 1
    end
    stability = zeros(k, k)
    for i = 1:k
        for j = 1:k
            stability(i, j) = m(i, j) / min(g1(i), g2(j))
        end
    end
    correspondence1 = zeros(k,1)
    correspondence2 = zeros(k,1)
    for i = 1:k
        [M I] = max(m(i,:))
        correspondence1(i) = I
        [M I] = max(m(:,i))
        correspondence2(i) = I
    end
    matching = (transpose(1:k) == correspondence2(correspondence1))
    stab_m.(strcat("k", int2str(k))).m = m
    stab_m.(strcat("k", int2str(k))).g1 = g1
    stab_m.(strcat("k", int2str(k))).g2 = g2
    stab_m.(strcat("k", int2str(k))).stability = stability
    stab_m.(strcat("k", int2str(k))).correspondence1 = correspondence1
    stab_m.(strcat("k", int2str(k))).correspondence2 = correspondence2
    stab_m.(strcat("k", int2str(k))).matching = matching
    stab_m.(strcat("k", int2str(k))).final_stab = sum(matching) / k
end

best_k = 2
cur_best_stab = stab_m.k2.final_stab
for k = 3:K
    if stab_m.(strcat("k", int2str(k))).final_stab > cur_best_stab
        best_k = k
        cur_best_stab = stab_m.(strcat("k", int2str(k))).final_stab
    end
end

%% 

% Leave-one-out clustering
final_clusters = zeros(n_voxels, n_participants)
final_centroids = zeros(best_k, n_voxels)
final_distances = zeros(n_voxels, best_k)
for i = 1:n_participants
    m_others = zeros(n_voxels, n_voxels)
    for j = 1:n_participants
        if j ~= i
            m_others = m_others + signal_data.(strcat("p", int2str(j))).fcorr
        end
    end
    m_others = tanh(m_others/(n_participants - 1))
    [idx C] = kmeans(m_others, best_k, Distance='correlation', Replicates=replication_n)
    [idx C sumd D] = kmeans(signal_data.(strcat("p", int2str(i))).corr, best_k, Distance='correlation', Replicates=replication_n, Start=repmat(C, [1 1 replication_n]))
    final_clusters(:,i) = idx
    final_centroids(:,:,i) = C
    final_distances(:,:,i) = D
end
%%
% Get brain coordinates from final centroids
% Getting the coordinates from the voxel closest to each centroid since the
% slight deviation won't matter when choosing which clusters to choose for
% the DCM (plotted to an image and chosen by looking which ones are closer
% to the typical 3 areas of the striatum)

final_xyz = zeros(best_k, 3)
for i = 1:n_participants
    % Load data from each participant
    datafile = strcat("../GLM/VOI/VOI_striatum_", int2str(i), ".mat")
    load(datafile, "xY")
    for k = 1:best_k
        c_voxel = find(final_distances(:,k,i) == min(final_distances(:,k,i)))
        final_xyz(k,:,i) = transpose(xY.XYZmm(:,c_voxel))
    end
end

%% 
% Saving the results from clustering
save("cluster_results.mat", "participants", "final_clusters", "final_centroids", "final_distances", "final_xyz")
%%
% Once classification per participant of which clusters should be used for
% the DCM, fill this matrix and save it so the VOI_from_clusters script can
% use it

% The first cluster should be VS, the second DCN and the third DAP
% VS = Ventral Striatum
% DCN = Dorsal Caudate Nucleus
% DAP = Dorsal-Anterior Putamen
clusters_to_extract = zeros(3, n_participants)
clusters_to_extract(:,1) = transpose([1 2 3])
clusters_to_extract(:,2) = transpose([1 2 3])
clusters_to_extract(:,3) = transpose([1 2 3])
save("clusters_to_extract.mat", "clusters_to_extract")