function [signal_path, parameters_path] = Preprocess(dir_paths, mask_path, points_path, ifGSR, sampleNumber, initialized, changeOutput, varargin)
    % @requires
    % dir_paths--dir paths that point to the dirs store tiff track files, should be a cell(1*num of dirs)
    % mask_path--the path of a binary mask of the standard brain
    % points_path--the path of coordinates of two ends
    % gsr--wether do gsr or not
    % sampleNumber--the number of frames seen as the sample
    % initialized--if you already have mask, figs and angleStill
    % changeOutput--if change output path
    % varargin--the first is parameters_path, the second is output_path
    %
    % @returns
    % signal_path--the path of the signals after preprocess (size of each signal 200*200*frames)
    % parameter_path--the path of mask, figs and angleStill
    typename = '*.tif';
    load(points_path, 'point1', 'point2');
    load(mask_path, 'black_mask');
    mask_length = point2(2) - point1(2);
    if ~initialized
        tiffnum = 0;
        parameters_path = {};
        for i = 1:size(dir_paths, 2)
            pathname = dir_paths(1, i);
            pathname = pathname{1} + "\";
            pathname = char(pathname);
            dtPositive = dir([pathname typename]);
            namePositiveCell = {dtPositive.name};
            for k = 1:length(namePositiveCell)
                tiffnum = tiffnum + 1;
                % load tiff sample
                raw_data_r = loadTiff(pathname, namePositiveCell{k}, sampleNumber, false);
                % mask without deformation
                [mask_data_resize, mask, angleStill] = maskWithoutDeform(raw_data_r, mask_length, black_mask, point1, true);
                clc;
                % vasculature mask
                [~, figs] = vasculatureMask(mask_data_resize);
                clc;
                name = namePositiveCell{k};
                name = name(1:end - 8);
                mat_name = name + "_parameters.mat";
                mat_name = char(mat_name);
                parameters_path{tiffnum} = [pathname mat_name];
                save([pathname mat_name], 'figs', 'mask', 'angleStill');
            end
        end
        clear raw_data_r mask_data_resize mask figs name mat_name pathname dtPositive namePositiveCell angleStill;
    else
        parameters_path = varargin{1};
    end
    tiffnum = 0;
    signal_path = {};
    for i = 1:size(dir_paths, 2)
        pathname = dir_paths(1, i);
        pathname = pathname{1} + "\";
        pathname = char(pathname);
        dtPositive = dir([pathname typename]);
        namePositiveCell = {dtPositive.name};
        for k = 1:length(namePositiveCell)
            tiffnum = tiffnum + 1;
            load(parameters_path{tiffnum}, 'figs', 'mask', 'angleStill');
            % load tiff sample
            raw_data_r = loadTiff(pathname, namePositiveCell{k}, sampleNumber * 240, true);
            % mask without deformation
            [mask_data_resize, ~, ~] = maskWithoutDeform(raw_data_r, mask_length, black_mask, point1, false, mask, angleStill);
            clc;
            % vasculature mask
            data_vc = mask_data_resize .* figs.binary;
            % df/f0
            signal = dfDivideF0(data_vc);
            clc;
            % GSR
            if ifGSR
                signal = gsr(signal);
            end
            name = namePositiveCell{k};
            name = name(1:end - 8);
            mat_name = name + ".mat";
            mat_name = char(mat_name);
            % if exist([pathname mat_name])
            %     delete([pathname mat_name]);
            % end
            if changeOutput
                pathname = [varargin{2} '\'];
            end
            signal_path{tiffnum} = [pathname mat_name];
            save([pathname name], 'signal');
        end
    end
end
