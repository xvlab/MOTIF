% clc; clear;
raw_data_r = loadTiff('G:\temp\Mokoghost\data\thy1-gcamp6s-m2-0114-2(airpuff)', 'thy1-gcamp6s-m2-0114-2_MMStack_Pos0.ome.tif', 150, false);
for i = 1:size(raw_data_r, 3)
    imshow(raw_data_r(:, :, i), []);
    F((i - 1) * 3 + 1) = getframe;
    F((i - 1) * 3 + 2) = getframe;
    F((i - 1) * 3 + 3) = getframe;
end

writerObj = VideoWriter('video.avi');
open(writerObj);
writeVideo(writerObj, F)
close(writerObj);
%%
% load('G:\temp\Mokoghost\fpCNMF\Results\thy1-gcamp6s-m2-0114-2(motif-2s)\thy1-gcamp6s-m2-0114-2_MMStack_Pos0.mat');
part = signal(:, :, 1:150);
figure;
pause(30);
for i = 1:size(part, 3)
    cvals = prctile(part(:), 99.9);
    imagesc([100 100],[300 300],part(:, :, i), [0 cvals]);
    frame = getframe;
%     frame.cdata = imresize(frame.cdata, [200 200]);
    F_signal((i - 1) * 3 + 1) = frame;
    F_signal((i - 1) * 3 + 2) = frame;
    F_signal((i - 1) * 3 + 3) = frame;
end
writerObj = VideoWriter('video_signal.avi');

open(writerObj);
writeVideo(writerObj, F_signal)
close(writerObj);
