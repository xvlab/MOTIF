function ClassifyMotifsAndGenerateBM()
    %classify motifs and generate basic motifs
    clear;clc;
    filepath = '\\192.168.3.146\public\临时文件\xpy\fpCNMF\resultMotifs\'; %文件夹的路径
    gp = 'genparamss';
    files = dir([filepath, '*.mat']);
    class_num = size(files, 1);
    opts = loadobj(feval(gp));
    W = zeros(200 * 200, class_num, 10);
    counter = 0;
    for i = 1:16 %n是要读入的文件的个数
        for j = 1:opts.K
            if exist([filepath 'temp' num2str(i) '_' num2str(j) '.mat'], 'file')
                counter = counter + 1;
                load([filepath 'temp' num2str(i) '_' num2str(j) '.mat'], 'temp');
                %             disp(size(temp));
                temp_reshape = reshape(temp, [200 * 200, size(temp, 3)]);
                W(:, counter, :) = temp_reshape;
            end
        end
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
