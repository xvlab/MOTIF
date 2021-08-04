function ClassifyMotifsAndGenerateBM(filepath)
    %classify motifs and generate basic motifs
    clear;clc;
    gp = 'parameters';
    files = dir([filepath, '*.mat']);
    folderCell = {files.folder};
    nameCell = {files.name};
    class_num = size(files, 1);
    opts = loadobj(feval(gp));
    W = zeros(opts.pixel_dim(1) * opts.pixel_dim(2), class_num, 10);
    counter = 0;
    for i = 1:class_num
        load([folderCell{i} nameCell{i}], 'temp');
        counter = counter + 1;
        temp_reshape = reshape(temp, [opts.pixel_dim(1) * opts.pixel_dim(2), size(temp, 3)]);
        W(:, counter, :) = temp_reshape;
    end
    [W_basis, kval, ovr_q, cluster_idx, idx_knn, tcorr_mat, handles, lag_mat, lags, nanpxs] = ClusterW(W, opts, []);
    save('W_basis.mat', 'W_basis');
    save('kval.mat', 'kval');
    save('ovr_q.mat', 'ovr_q');
    save('cluster_idx.mat', 'cluster_idx');
    save('idx_knn.mat', 'idx_knn');
    save('tcorr_mat.mat', 'tcorr_mat');
    save('similarity matrix', 'handles');
    save('lag_mat.mat', 'lag_mat');
    save('lags.mat', 'lags');
    save('nanpxs.mat', 'nanpxs');
end
