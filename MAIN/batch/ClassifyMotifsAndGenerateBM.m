function path = ClassifyMotifsAndGenerateBM(filepath, L)
    %% classify motifs and generate basic motifs
    % @requires
    % filepath--the path points to the dir stores motifs
    % L--L of each motif
    gp = 'parameters';
    filepath = [filepath '\'];
    files = dir([filepath, '*.mat']);
    folderCell = {files.folder};
    nameCell = {files.name};
    class_num = size(files, 1);
    opts = loadobj(feval(gp));
    W = zeros(opts.pixel_dim(1) * opts.pixel_dim(2), class_num, L);
    counter = 0;
    for i = 1:class_num
        load([folderCell{i} '\' nameCell{i}], 'temp');
        counter = counter + 1;
        temp_reshape = reshape(temp, [opts.pixel_dim(1) * opts.pixel_dim(2), size(temp, 3)]);
        W(:, counter, :) = temp_reshape;
    end
    [W_basis, kval, ovr_q, cluster_idx, idx_knn, tcorr_mat, handles, lag_mat, lags, nanpxs] = ClusterW(W, opts, []);
    mkdir(filepath, "results");
    path = filepath + "\results";
    save(filepath + "\results\" + "W_basis.mat", 'W_basis');
    save(filepath + "\results\" + "kval.mat", 'kval');
    save(filepath + "\results\" + "ovr_q.mat", 'ovr_q');
    save(filepath + "\results\" + "cluster_idx.mat", 'cluster_idx');
    save(filepath + "\results\" + "idx_knn.mat", 'idx_knn');
    save(filepath + "\results\" + "tcorr_mat.mat", 'tcorr_mat');
    savefig(handles, filepath + "\results\" + "similarity matrix");
    save(filepath + "\results\" + "lag_mat.mat", 'lag_mat');
    save(filepath + "\results\" + "lags.mat", 'lags');
    save(filepath + "\results\" + "nanpxs.mat", 'nanpxs');
end
