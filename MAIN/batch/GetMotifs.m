function paths = GetMotifs(filepaths, varargin)
    %% get motifs from big data
    % @requires
    % filepaths--paths that points to the mat file of signal
    % varargin--could mannually change parameters in parameters.m, ex: 'L',20
    %
    % @returns
    % paths--paths that points to dirs store the temp motifs
    gp = 'parameters';
    opts = loadobj(feval(gp));
    opts = ParseOptionalInputs(opts, varargin);
    paths = {};
    dirCounter = 0;
    %load data
    for i = 1:size(filepaths, 2)
        load(filepaths{i}, 'signal')
        parentFolderSplit = split(filepaths{i}, "\");
        parentFolder = join(parentFolderSplit(1:end - 1), "\");
        mkdir(parentFolder{1}, parentFolderSplit{end}(1:end - 4));
        for k = 1:size(signal, 3) / (2 * opts.w_chunk_dur * opts.fps)
            %nan out pixels with no variance
            dff = signal(:, :, 1 + (k - 1) * opts.w_chunk_dur * opts.fps * 2:k * opts.w_chunk_dur * opts.fps * 2);
            dff = reshape(dff, [200 * 200, size(dff, 3)]);
            dff(nanvar(dff, [], 2) <= eps, :) = NaN;
            dff = reshape(dff, [200, 200, size(dff, 2)]);
            % luric deconv & some other preprocess
            [~, nanpxs, data_train, ~] = ProcessAndSplitData(dff, [], gp);
            rng('default');
            lambda = 0.0077;
            %Fit Motifs To Training Data And Collect Statistics
            W_temp = cell(1, opts.repeat_fits);
            H_temp = cell(1, opts.repeat_fits);
            stats_train_temp = cell(1, opts.repeat_fits);
            for cur_fit = 1:opts.repeat_fits %fit multiple times due to random initialization. Each iteration takes ~5min
                if opts.verbose; fprintf('\nFitting Training Data Round %d of %d', cur_fit, opts.repeat_fits); end
                [W_temp{cur_fit}, H_temp{cur_fit}, stats_train_temp{cur_fit}] = ...
                    fpCNMF(data_train, 'L', opts.L, 'K', opts.K, 'non_penalized_iter', ...
                    opts.non_penalized_iter, 'penalized_iter', opts.penalized_iter, ...
                    'speed', opts.speed, 'verbose', opts.verbose, 'lambda', lambda, ...
                    'ortho_H', opts.ortho_H, 'w_update_iter', opts.w_update_iter, ...
                    'sparse_H', opts.sparse_H);
                %Remove Empty Motifs
                [W_temp{cur_fit}, H_temp{cur_fit}] = RemoveEmptyMotifs(W_temp{cur_fit}, H_temp{cur_fit});
            end
            %choose best fit
            idx = InternallyValidateWs(data_train, W_temp, H_temp, 'AIC', 0);
            W = W_temp{idx};
            %             H = H_temp{idx};
            stats_train = stats_train_temp{idx};
            %let's store the motifs.
            dirCounter = dirCounter + 1;
            paths{dirCounter} = char(parentFolder{1} + "\" + parentFolderSplit{end}(1:end - 4));
            for idx = 1:stats_train.n_motifs
                temp = conditionDffMat(squeeze(W(:, idx, :))', nanpxs);
                %smooth for visualization
                temp = SpatialGaussian(temp, [1 1], 'sigma');
                %save motifs
                save(parentFolder{1} + "\" + parentFolderSplit{end}(1:end - 4) + "\" ...
                    + parentFolderSplit{end}(1:end - 4) + "_temp" + k + "_" + idx + ".mat", 'temp');
                %pause(1); in between motifs
            end
            %make a video
            %     writerObj = VideoWriter('video.avi');
            %     open(writerObj);
            %     writeVideo(writerObj, F)
            %     close(writerObj);
        end
    end
end
