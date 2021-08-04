function signal_path = Preprocess(dir_paths, mask_path, points_path, gsr, sampleNumber, fs)
    % @requires
    % dir_paths--dir paths that point to the dirs store tiff track files, should be a cell(1*num of dirs)
    % mask_path--the path of a binary mask of the standard brain
    % points_path--the path of coordinates of two ends
    % gsr--wether do gsr or not
    % sampleNumber--the number of frames seen as the sample
    % fs--frequency of sampling
    % @returns
    % signal_path--the path of the signals after preprocess (size of each signal 200*200*frames)
    load(points_path, 'point1', 'point2');
    load(mask_path, 'black_mask');
    typename = '*.tif';
    mask_length = point2(2) - point1(2);
    tiffnum = 0;
    for i = 1:size(dir_paths, 2)
        pathname = dir_paths(1, i);
        pathname = pathname{1} + "\";
        pathname = char(pathname);
        dtPositive = dir([pathname typename]);
        namePositiveCell = {dtPositive.name};
        for k = 1:length(namePositiveCell)
            tiffnum = tiffnum + 1;
            % load tiff sample
            raw_data_r = loadTiff(pathname, namePositiveCell{k}, fs, sampleNumber, false);
            % mask without deformation
            [mask_data_resize, mask] = maskWithoutDeform(raw_data_r, mask_length, black_mask, point1, true);
            % vasculature mask
            [~, fig] = vasculatureMask(mask_data_resize);
            name = namePositiveCell{k};
            name = name(1:end - 8);
            save([pathname name], 'fig', 'mask');
        end
    end
    signal_path = cell(1, tiffnum);
    tiffnum = 0;
    for i = 1:size(dir_paths, 2)
        pathname = dir_paths(1, i);
        pathname = pathname{1} + "\";
        pathname = char(pathname);
        dtPositive = dir([pathname typename]);
        namePositiveCell = {dtPositive.name};
        load([pathname name], 'fig', 'mask');
        for k = 1:length(namePositiveCell)
            tiffnum = tiffnum + 1;
            % load tiff sample
            raw_data_r = loadTiff(pathname, namePositiveCell{k}, fs, sampleNumber, true);
            % mask without deformation
            [mask_data_resize, mask] = maskWithoutDeform(raw_data_r, mask_length, black_mask, point1, true, mask);
            % vasculature mask
            data_vc = mask_data_resize .* figs.binary;
            % df/f0
            signal = dfDivideF0(data_vc);
            % GSR
            if gsr
                signal = gsr(signal);
            end
            name = namePositiveCell{k};
            name = name(1:end - 8);
            mat_name = name + ".mat";
            mat_name = char(mat_name);
            delete([pathname mat_name]);
            signal_path{tiffnum} = [pathname name];
            save([pathname name], 'signal');
        end
    end
end
