function signal = dfDivideF0(data_vc)
    % df/f0
    % @requires
    % data_vc--data after vasculature mask
    % @return
    % signal--data after df/f0
    f0 = mean(data_vc, 3);
    df = bsxfun(@minus, data_vc, f0);
    clear data_vc;
    signal = bsxfun(@rdivide, df, f0);
    clear df;
end
