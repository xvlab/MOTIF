function raw_data_r = loadTiff(pathname, filename, number, ifAll)
    % load tiff sample
    % @requires
    % pathname--name of path
    % filename--name of file, typename shouldn't be excluded
    % number--frames to be take
    % ifAll--if take all frames of this tiff
    %
    % @returns
    % raw_data_r--rotate of raw data(vertical)
    fn = fullfile(pathname, filename);
    FileTif = fn;
    InfoImage = imfinfo(FileTif);
    mImage = InfoImage(1).Width;
    nImage = InfoImage(1).Height;
    if ifAll
        number = length(InfoImage);
    end
    FinalImage = zeros(nImage, mImage, number, 'uint16');
    TifLink = Tiff(FileTif, 'r');
    for i = 1:number
        TifLink.setDirectory(i);
        FinalImage(:, :, i) = TifLink.read();
    end
    TifLink.close();
    raw_data = double(FinalImage);
    raw_data_r = rot90(raw_data, 3);
end
