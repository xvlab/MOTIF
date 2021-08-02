function [data_norm, nanpxs, data_test] = ProcessButNotSplitData(fn, opts)
    %Camden MacDowell - timeless
    %Modified by Mokoghost
    %filters, normalizes, and splits data in fn into training and test test
    %fn can be the full file path or a stack and opt structure.

    data = fn;

    %condition data and remove nan pxls
    [x, y, z] = size(data);
    [data, nanpxs] = conditionDffMat(data); %nanpxs are the same on each iteration so fine to overwrite
%     data=reshape(data,[size(data,1)*size(data,2),size(data,3)]);
%     data=data';
    %filter data
    switch opts.w_deconvolution
        case 'filter_thresh'
            fprintf('\n\tFiltering and thresholding data')
            data = filterstack(data, opts.fps, opts.w_filter_freq, opts.w_filter_type, 1, 0);
            %Remove negative component of signal and find bursts as in MacDowell 2020. Legacy. 
            %Deconvolution with non-negative output is preferred (maintains more data, comes with own assumptions).
            for px = 1:size(data, 2)
                temp = data(:, px);
                temp(temp <= nanmean(temp(:)) + opts.w_nstd * std(temp(:))) = 0;
                data(:, px) = temp;
            end

            data(data < (nanmean(data(:)) + opts.w_nstd * nanstd(data(:)))) = 0;
        case 'lucric'
            fprintf('\n\tPerforming a Lucy-Goosey Deconvolution (Lucy-Richardson)\n')
            for px = 1:size(data, 2)
                data(:, px) = lucric(data(:, px), opts.d_gamma, opts.d_smooth, opts.d_kernel);
            end
        case 'only_filter'
            fprintf('\n\tFiltering data')
            data = filterstack(data, opts.fps, opts.w_filter_freq, opts.w_filter_type, 1, 0);

        otherwise
            error('unknown w_deconvolution option. Check general parameters');
    end

    %Denoise with PCA (removed banded pixels)
    if opts.w_pca_denoise
        data = conditionDffMat(data, nanpxs, [], [x, y, z]);
        data = DenoisePCA(data);
        [data, ~] = conditionDffMat(data);
    end

    %normalize to 0 to 1
    fprintf('\n\tPerforming %s normalization to %d value', opts.w_normalization_method, opts.w_norm_val);
    switch opts.w_normalization_method
        case 'pixelwise' %each between x and xth pixel intensity
            data_norm = NaN(size(data));
            for px = 1:size(data, 2)
                data_norm(:, px) = (data(:, px)) / (prctile(data(:, px), opts.w_norm_val));
            end
        case 'full' %normalize using the percentile of the maximum
            data_norm = data / prctile(data(data > eps), opts.w_norm_val);
        case 'bounded'
            data_norm = (data) / (opts.w_norm_val(2)); %normalize between zero and the upper bound
        case 'none'
            data_norm = data;
        otherwise
            error('Unknown normalization method. Check general params')
    end

    %transpose (fpCNMF operates rowwise)
    data_test = data_norm';
end
