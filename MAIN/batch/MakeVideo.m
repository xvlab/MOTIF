function MakeVideo(resultpath)
    load([resultpath '\W_basis.mat'], 'W_basis');
    W = reshape(W_basis, [200, 200, size(W_basis, 2), size(W_basis, 3)]);
    filename = "basic motif.gif";
    mkdir(resultpath,'basic motifs');
    for i = 1:size(W, 3)
        filename = resultpath + "\basic motifs\basic motif" + i + ".gif";
        for j = 1:size(W, 4)
            cvals = prctile(W(:), 99.9);
            imagesc(W(:, :, i, j), [0 cvals]); title(sprintf('Motif %d Frame %d', i, j));

            I = frame2im(getframe);
            [I, map] = rgb2ind(I, 256);
            for k = 1:2
                if j == 1
                    imwrite(I, map, filename, 'gif', 'Loopcount', inf, 'DelayTime', 0.2);
                else
                    imwrite(I, map, filename, 'gif', 'WriteMode', 'append', 'DelayTime', 0.2);
                end
            end
        end
        temp = squeeze(W(:, :, i, :));
    end
end
