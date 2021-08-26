function getROIIntens(signal, varargin)
    %getROIIntens 选取ROI，将其平均强度制成热力图
    %   varargin:可填入sync1，sync2和自己画的rois
    %%
    close all;
    opts.sync1 = [];
    opts.sync2 = [];
    opts.rois = {};
    opts = ParseOptionalInputs(opts, varargin);
    %%
    if size(opts.rois) == 0
        imshow(signal(:, :, 1), []);
        i = 0;
        while ~isempty(get(0, 'children'))
            i = i + 1;
            roi = drawrectangle;
            if isvalid(roi)
                position = roi.Position;
                space = zeros(round(position(3)) * round(position(4)), 2);
                for x = 1:round(position(3))
                    for y = 1:round(position(4))
                        space((x - 1) * round(position(4)) + y, 1) = round(position(1)) + x;
                        space((x - 1) * round(position(4)) + y, 2) = round(position(2)) + y;
                    end
                end
                opts.rois{i} = space;
            end
        end
    end
    intensity = zeros(size(opts.rois, 2), size(signal, 3));
    for i = 1:size(opts.rois,2)
        space = opts.rois{i};
        for j = 1:size(signal, 3)
            adder = 0;
            for index = 1:size(space, 1)
                if ~isnan(signal(space(index, 1), space(index, 2), j))
                    adder = adder + signal(space(index, 1), space(index, 2), j);
                end
            end
            avg = adder / size(space, 1);
            intensity(i, j) = avg;
        end
    end
    for counter = 1:size(intensity, 1)
        H = zeros(100, size(opts.sync2, 1) - 3);
        for i = 4:size(opts.sync2)
            index = round((opts.sync2(i) - opts.sync1(1)) * 10);
            min=1000;
            minIndex=index-100;
            for j=-200:200
                if abs(opts.sync1(index+j)-opts.sync2(i))<min
                    minIndex=index+j;
                    min=abs(opts.sync1(index+j)-opts.sync2(i));
                end
            end
            for j = -49:50
                H(j + 50, i-3) = intensity(counter, j + minIndex);
            end
        end
        figure; imagesc(H');
    end
end
