function [mask_data_resize, mask, angleStill] = maskWithoutDeform(raw_data_r, mask_length, black_mask, point1, initial, varargin)
    % mask without deformation
    % @requires
    % raw_data_r--rotate of raw data(vertical)
    % mask_length--the length between two ends of the mask
    % black_mask--the binary mask of the standard brain
    % point1--the upper point of the standard brain
    % initial--if initial is true, then run the point choosing code, else let mask be the
    % designated mask in varargin
    % @returns
    % mask_data_resize--data after mask without deformation but resize to 200*200 and
    % rotate to vertical

    % point choosing
    if initial
        tif_img = squeeze(raw_data_r(:, :, 1));
        h = figure;
        point = true;
        while point
            imshow(tif_img, []);
            mouse = imrect;
            pos1 = getPosition(mouse);
            mouse = imrect;
            pos2 = getPosition(mouse);
            pos1 = [round(pos1(1)) round(pos1(2))]; %[abscissa ordinate]
            pos2 = [round(pos2(1)) round(pos2(2))];
            fov_length = norm(pos1 - pos2);
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
                    if black_mask(point1(2) + round(y_distance * mask_length / fov_length), point1(1) + round(x_distance * mask_length / fov_length)) == 0
                        tif_img(i, j) = 0;
                        mask(i, j) = 1;
                    end
                end
            end
            res = figure; imshow(tif_img, []);
            set(res, 'WindowStyle', 'docked');
            hold on

            satisfied = input('Satisfied(y/n)?', 's');

            if strncmp(satisfied, 'y', 1)
                close(res);
                close(h);
                point = false;
            else
                tif_img = squeeze(raw_data_r(:, :, 1));
                close(res);
                hold off;
            end
        end
    else
        mask = varargin{1};
        angleStill = varargin{2};
    end

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

    % rotate and resize
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
end
