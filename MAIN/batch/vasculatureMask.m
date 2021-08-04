function [data_vc, figs] = vasculatureMask(mask_data_resize)
    %% vasculature mask
    % @requires
    % mask_data_resize--data after mask without deformation but resize to 200*200 and
    % rotate to vertical
    % @returns
    % data_vc--data after vasculature mask
    % fig--the vasculature mask

    filter_parm = [50 5];
    filter_low = fspecial('average', filter_parm(1));
    %     filter_high = fspecial('average', filter_parm(2));

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
        figs.before = figs.binary;
        figs.binary = figs.binary .* roiMask;
        hold on

        keep_roi = input('Keep ROI (y/n)?', 's');

        if strncmp(keep_roi, 'y', 1)
            figs.binary = figs.before;
            hold off;
        elseif strncmp(keep_roi, 'quit', 4)
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

    data_vc = mask_data_resize .* figs.binary;
    subplot(2, 2, 4); imshow(data_vc(:, :, 1), []);
end
