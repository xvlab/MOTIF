%% load tiff file
clear;clc;
load('points.mat');
load('black_mask.mat');
mask_length = point2(2) - point1(2);

% load track file
[filename, pathname] = uigetfile('*.tif', 'Select Source Movie');

if filename == 0
    return
end

fn = fullfile(pathname, filename);

FileTif = fn;
InfoImage = imfinfo(FileTif);
mImage = InfoImage(1).Width;
nImage = InfoImage(1).Height;
NumberImages = length(InfoImage); %全部load
%  NumberImages=1000;
FinalImage = zeros(nImage, mImage, NumberImages, 'uint16');
fs = 10; %采样频率10hz

TifLink = Tiff(FileTif, 'r');
for i = 1:NumberImages
    TifLink.setDirectory(i);
    FinalImage(:, :, i) = TifLink.read();
end
TifLink.close();
raw_data = double(FinalImage);
raw_data_r = rot90(raw_data, 3);
clear FinalImage;
clear raw_data;

%% mask without deformation
tif_img = squeeze(raw_data_r(:, :, 1)); figure;
imshow(tif_img, []);
mouse = imrect;
pos1 = getPosition(mouse);
mouse = imrect;
pos2 = getPosition(mouse);
pos1 = [round(pos1(1)) round(pos1(2))]; %[abscissa ordinate]
pos2 = [round(pos2(1)) round(pos2(2))];
fov_length = norm(pos1 - pos2);
% pos1 = [round((pos1(1) + pos2(1)) / 2) round(pos1(2))];
% pos2 = [pos1(1) round(pos2(2))];
% fov_length = pos2(2) - pos1(2);
mask = zeros(size(tif_img, 1), size(tif_img, 2));
for i = 1:size(tif_img, 1) %ordinate
    for j = 1:size(tif_img, 2) %abscissa
        x_distance = abs(det([pos2 - pos1; [j i] - pos1])) / norm(pos2 - pos1);
        y_distance = (norm([j i] - pos1)^2 - x_distance^2)^0.5;
        angle = getAngle([j i], pos1, pos2);
        stillPoint = [pos1(1), pos2(2)];
        angleStill = getAngle(stillPoint, pos1, pos2);
        if pos1(1) < pos2(1)
            angleStill = -angleStill;
        end
        if angle > 90
            y_distance = -y_distance;
        end
        side = judgeSide(pos1, pos2, [j i]);
        if side == "left"
            x_distance = -x_distance;
        end
        % ordinate = i - pos1(2);
        % abscissa = j - pos1(1);
        % if black_mask(point1(2) + round(ordinate * mask_length / fov_length), point1(1) + round(abscissa * mask_length / fov_length)) == 0
        if black_mask(point1(2) + round(y_distance * mask_length / fov_length), point1(1) + round(x_distance * mask_length / fov_length)) == 0
            tif_img(i, j) = 0;
            mask(i, j) = 1;
        end
    end
end
figure; imshow(tif_img, []);

mask_data = zeros(size(raw_data_r, 1), size(raw_data_r, 2), size(raw_data_r, 3));
for idx = 1:size(raw_data_r, 3)
    for i = 1:size(raw_data_r, 1) %ordinate
        for j = 1:size(raw_data_r, 2) %abscissa
            if mask(i, j) == 1
                mask_data(i, j, idx) = 0;
            else
                mask_data(i, j, idx) = raw_data_r(i, j, idx);
            end
        end
    end
end

%% rotate and resize
mask_data_ex = [zeros(10, size(mask_data, 2), size(mask_data, 3)); mask_data; zeros(10, size(mask_data, 2), size(mask_data, 3))];
mask_data_ex_ex = [zeros(size(mask_data_ex, 1), 10, size(mask_data, 3)) mask_data_ex zeros(size(mask_data_ex, 1), 10, size(mask_data, 3))];
clear mask_data_ex;
mask_data_rotate = zeros(size(mask_data_ex_ex));
for idx = 1:size(mask_data, 3)
    mask_data_rotate(:, :, idx) = imrotate(mask_data_ex_ex(:, :, idx), angleStill, 'crop');
end
clear mask_data_ex_ex;
allZeroCols = [];
allZeroRows = [];
mask_data_short = mask_data_rotate;
for i = 1:size(mask_data_rotate, 1) %ordinate
    if sum(mask_data_rotate(i, :, 1)) == 0
        allZeroRows = [allZeroRows i];
    end
end
mask_data_short(allZeroRows, :, :) = [];
for i = 1:size(mask_data_rotate, 2) %abscissa
    if sum(mask_data_rotate(:, i, 1)) == 0
        allZeroCols = [allZeroCols i];
    end
end
mask_data_short(:, allZeroCols, :) = [];
clear mask_data_rotate;
mask_data_resize = zeros(200, 200, size(mask_data_short, 3));
for idx = 1:size(mask_data_short, 3)
    mask_data_resize(:, :, idx) = imresize(squeeze(mask_data_short(:, :, idx)), [200, 200]);
end
clear mask_data_short;
figure; imshow(mask_data_resize(:, :, 1), []);

%% vasculature mask
filter_parm = [50 5];
filter_low = fspecial('average', filter_parm(1));
filter_high = fspecial('average', filter_parm(2));

figs.mean = double(mean(mask_data_resize, 3));
figs.smooth = figs.mean - imfilter(figs.mean, filter_low, 'replicate', 'same', 'conv');
figs.binary = imbinarize(figs.smooth, 'adaptive', 'ForegroundPolarity', 'dark', 'Sensitivity', 0.1);

h = figure;
draw_roi = true;
while draw_roi
    im_model = 3 * mask_data_resize(:, :, 1) + 500 * figs.binary(:, :, 1);
    figs.binary = ~figs.binary;
    imshow(im_model, [])
    roiMask = ~roipoly;
    figs.binary = figs.binary .* roiMask;
    hold on

    keep_roi = input('Keep ROI (y/n)?', 's');

    if strmatch(keep_roi, 'y')
        close(h);
        draw_roi = false;
    else

        hold off;
    end
    figs.binary = ~figs.binary;
end

figure;
subplot(2, 2, 1); imshow(figs.mean, []);
subplot(2, 2, 2); imshow(figs.smooth, []);
subplot(2, 2, 3); imshow(figs.binary);
% subplot(2,2,4); imshow(figs.close);
% imagesc(figs.skel*2);

data_vc = mask_data_resize .* figs.binary;
subplot(2, 2, 4); imshow(data_vc(:, :, 1), []);

%% df/f0
% I_base=black_mask;
f0 = mean(data_vc, 3);
df = bsxfun(@minus, data_vc, f0);
clear data_vc;
signal = bsxfun(@rdivide, df, f0);
clear df;
%% save signal
figure;imagesc(signal(:,:,1));
save(filename(1:size(filename,2) - 8), 'signal');
