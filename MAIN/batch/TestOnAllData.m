function TestOnAllData(signal_path,resultpath)
    %test on whole dataset and make pev for
    %every motifs thourgh time
    %load data
    load(signal_path, 'signal');
    load([resultpath '\W_basis.mat'], 'W_basis');
    gp = 'genparamss';
    opts = loadobj(feval(gp));
    H = [];
    %make the size of W_basis coordinates with dff
    dff = signal(1:200, :, 1:opts.w_chunk_dur * opts.fps);
    dff = reshape(dff, [200 * 200, size(dff, 3)]);
    dff(nanvar(dff, [], 2) <= eps, :) = NaN;
    dff = reshape(dff, [200, 200, size(dff, 2)]);
    [~, nanpxs, ~] = ProcessButNotSplitData(dff, opts);

    W_basis(nanpxs, :, :) = [];

    for k = 1:size(signal, 3) / (opts.w_chunk_dur * opts.fps)
        %nan out pixels with no variance
        dff = signal(1:200, :, 1 + (k - 1) * opts.w_chunk_dur * opts.fps:k * opts.w_chunk_dur * opts.fps);
        dff = reshape(dff, [200 * 200, size(dff, 3)]);
        dff(nanvar(dff, [], 2) <= eps, :) = NaN;
        dff = reshape(dff, [200, 200, size(dff, 2)]);
        % luric deconv & some other preprocess
        [~, ~, data_test] = ProcessButNotSplitData(dff, opts);
        rng('default');
        lambda = 0.0077;
        %Fit Motifs To Training Data And Collect Statistics
        if opts.verbose; fprintf('\nFitting Testing Data'); end
        [~, H_temp, stats_test] = fpCNMF(data_test, 'non_penalized_iter', ...
            opts.non_penalized_iter, 'penalized_iter', 100, ...
            'speed', 'fast-gpu', 'verbose', 0, 'lambda', lambda, 'w_update_iter', 0, ...
            'ortho_H', opts.ortho_H, 'W', W_basis, 'sparse_H', opts.sparse_H);
        H = cat(2, H, H_temp);
    end
    save([resultpath '\H_test'], 'H');
    save([resultpath '\Stats_test'], 'stats_test');
    %Plot the motif temporal weightings. You'll see that some motifs occur multiple times, others just once.
    % In general, spontaneous activity is relatively sparse
    figure; hold on; plot(H'); legend; ylabel('Motif Activity'); set(gca, 'xticklabel', round(get(gca, 'xtick') / 10, 0)); xlabel('time (s)');
    
    imwrite(A,[resultpath '\Motif Activity.png']);
end
