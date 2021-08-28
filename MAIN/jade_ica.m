%% jadeR-ica
data = signal(:, :, 1:10000);
data(isnan(data)) = 0;
df_linear = reshape(data, size(data, 1) * size(data, 2), size(data, 3));
numOfIC = 10;
B = jadeR(df_linear', numOfIC);
result = B * df_linear';
imdisp(reshape(result', size(data, 1), size(data, 2), numOfIC));

%% make the mask of significant points
mask = zeros(size(data, 1), size(data, 2), numOfIC);
for i = 1:numOfIC
    test0 = reshape(result(i, :), size(data, 1), size(data, 2));
    test1 = test0(:, 1:size(data, 2) / 2);
    test1 = test1(:);
    test1(abs(test1 - mean(test1)) < 1.3 * std(test1)) = 0;
    test1 = reshape(test1, size(data, 1), size(data, 2) / 2);
    test2 = test0(:, size(data, 2) / 2 + 1:size(data, 2));
    test2 = test2(:);
    test2(abs(test2 - mean(test2)) < 1.3 * std(test2)) = 0;
    test2 = reshape(test2, size(data, 1), size(data, 2) - size(data, 2) / 2);
    mask(:, :, i) = [test1 test2];
end
imdisp(mask);

%% get roi(mask and centroids)
roi = {};
roiCounter = 0;
for maskNum = 1:size(mask, 3)
    maskTemp = mask(:, :, maskNum);
    boundary = bwboundaries(maskTemp, 'noholes');
    size0 = length(boundary);
    counter = 1;
    i = 1;
    while i < size0
        if size(boundary{counter}, 1) < 50
            boundary(counter) = [];
        else
            counter = counter + 1;
        end
        i = i + 1;
    end
    figure
    imagesc(maskTemp);
    for ind = 1:numel(boundary)
        % Convert to x,y order.
        pos = boundary{ind};
        pos = fliplr(pos);
        % Create a freehand ROI.
        h = drawfreehand('Position', pos, 'Color', 'r');
        h.FaceAlpha = 1;
    end
    goon = input('Go on?(press any bottom to go on)', 's');

    % Convert edited ROI back to masks.
    hfhs = findobj(gca, 'Type', 'images.roi.Freehand');
    editedMask = false([size(mask(:, :, 2)) length(hfhs)]);

    for ind = 1:numel(hfhs)
        editedMask(:, :, ind) = hfhs(ind).createMask();
        boundaryLocation = hfhs(ind).Position;
    end
    for i = 1:size(editedMask, 3)
        close all;
        s = regionprops(editedMask(:, :, i), 'Centroid');
        centroids = cat(1, s.Centroid);
        em = imdisp(editedMask(:, :, i));
        hold on
        points = plot(centroids(:, 1), centroids(:, 2), 'b*');
        hold off
        deletePoint = input('How many centroids should be deleted?(input an integer)');
        % delete useless points
        while deletePoint > 0
            [xi, yi] = getpts;
            minDist = 10000;
            cIndex = 0;
            for c = 1:size(centroids, 1)
                nowDist = ((centroids(c, 1) - xi)^2 + (centroids(c, 2) - yi)^2)^0.5;
                if minDist > nowDist
                    minDist = nowDist;
                    cIndex = c;
                end
            end
            centroids(cIndex, :) = [];
            delete (points);
            em = imdisp(editedMask(:, :, i));
            hold on
            points = plot(centroids(:, 1), centroids(:, 2), 'b*');
            hold off
            deletePoint = deletePoint - 1;
        end
        roiCounter = roiCounter + 1;
        roi{roiCounter}.centroid = centroids;
        roi{roiCounter}.mask = editedMask(:, :, i);
    end
end
