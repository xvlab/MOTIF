load('preprocessed\thy1-gcamp6s-m2-0114-2_MMStack_Pos0.mat');
%%
load('Synchron\thy1-gcamp6s-m2-0114-2\air puff m2 14-2.mat', 'sync1', 'sync2');
figure;
for i = 4:size(sync2, 1)
    num_shift = round((sync2(i, 1) - sync1(1, 1)) / 0.1) ;
    nearest = 0;
    min = 1000;
    for j = num_shift- 200:num_shift + 200
        if abs(sync1(j, 1) - sync2(i, 1)) < min
            min = abs(sync1(j, 1) - sync2(i, 1));
            nearest = j;
        end
    end
    disp(nearest);
    for j = nearest - 15 :nearest - 1
         imshow(signal(:,:,j),[0 0.1]);title("frame "+num2str(j)+": before air puff");pause(0.01);
    end
    for j = nearest :nearest + 15  - 1
         imshow(signal(:,:,j),[0 0.1]);title("frame "+num2str(j)+": after air puff");pause(0.01);
    end
end