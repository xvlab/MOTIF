function PCA(signal_path)
    %% PCA
    load(signal_path, 'signal');
    %%
    fs = 10;
    df = signal;
    df_linear = reshape(df, size(df, 1) * size(df, 2), size(df, 3));
    %%
    [coeff,df_linear_tranformed] = pca(df_linear);

    try
        pcs = df(:, :, 1:100);
    catch
        pcs = zeros(200, 200, 100);
    end

    for i = 1:10
        for ii = 1:10
            n = (i - 1) * 10 + ii;
            pcs(:, :, n) = (reshape(df_linear_tranformed(:, n), size(pcs, 1), size(pcs, 2)));
        end
    end

    figure
    ff = 4;
    t = (0:1:length(coeff) - 1) / fs;
    for i = 1:ff
        subplot(ff, 1, i)
        plot(t, coeff(:, i)) %,hold on
        ylabel(i)
    end
    xlabel('time(s)')
    %%
    multiplot(pcs(:, :, 1:12)) %you need to download imdisp package

    coeff2 = coeff(:,1:12);
    parentFolderSplit = split(signal_path{i}, "\");
    parentFolder = join(parentFolderSplit(1:end - 1), "\");
    save([parentFolder '\pca.mat'], 'coeff2', '-append', '-v7.3')
end
