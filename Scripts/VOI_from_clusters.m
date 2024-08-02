% To run after the clustering to get data to feed the DCM from SPM
load("cluster_results.mat")
load("clusters_to_extract.mat")
%%
% Settings
n_participants = size(clusters_to_extract, 2)
total_clusters = size(clusters_to_extract, 1)
name_of_final_vois = ["VS" "DCN" "DAP"]
% VS = Ventral Striatum
% DCN = Dorsal Caudate Nucleus
% DAP = Dorsal-Anterior Putamen
%%
% VOI extraction
for participant = 1:n_participants
    participant_id = participants(participant)
    for i = 1:total_clusters
        % Get original data
        datafile = strcat("./Experimental/", participant_id, "/RestingState/striatum_voi/with_multiparticipant_glm/VOI_striatum_", int2str(participant), ".mat")
        load(datafile, "xY")
        [n_scans n_total_voxels] = size(xY.y)
    
        % Initialize new cluster VOI data
        cluster_n = clusters_to_extract(i, participant)
        n_voxels = sum(final_clusters(:,participant) == cluster_n)
        newxY = xY
        newxY.XYZmm = zeros(3, n_voxels)
        newxY.y = zeros(n_scans, n_voxels)
        newxY.u = zeros(n_scans, 1)
        newxY.v = zeros(n_voxels, 1)
        newxY.s = zeros(n_scans, 1)
        newxY.name = name_of_final_vois(i)
        % From what I gather, X0 is a statistical flag per participant that
        % comes from the original GLM, so no need to alter it (I hope OwO)
    
    
        % Copy relevant voxels to VOI
        voxel_counter = 1
        for v = 1:n_total_voxels
            if(final_clusters(v, participant) == cluster_n)
                newxY.XYZmm(:,voxel_counter) = xY.XYZmm(:,v)
                newxY.y(:,voxel_counter) = xY.y(:,v)
                voxel_counter = voxel_counter + 1
            end
        end
        newxY.xyz = transpose(mean(transpose(newxY.XYZmm)))
    
        % Calculate eigenvariates (this part is copied and modified from SPM
        % code itself)
        y = newxY.y
        if any(~isfinite(y(:)))
            error('Data contain NaN or Inf. Check the VOI definition.');
        end
        [m,n]   = size(y);
        if m > n
            [v,s,v] = svd(y'*y);
            s       = diag(s);
            v       = v(:,1);
            u       = y*v/sqrt(s(1));
        else
            [u,s,u] = svd(y*y');
            s       = diag(s);
            u       = u(:,1);
            v       = y'*u/sqrt(s(1));
        end
        d       = sign(sum(v));
        u       = u*d;
        v       = v*d;
        Y       = u*sqrt(s(1)/n);
         
        %-Set in structure
        %--------------------------------------------------------------------------
        newxY.y    = y;
        newxY.u    = Y;
        newxY.v    = v;
        newxY.s    = s;
        % End of copy/modification of SPM code
    
        % Save to file
        outfile = strcat("./Experimental/", participant_id, "/RestingState/striatum_voi/with_multiparticipant_glm/VOI_", name_of_final_vois(i),"_", int2str(participant), ".mat")
        xY = newxY
        Y = newxY.u
        save(outfile, "xY", "Y")
    end
end