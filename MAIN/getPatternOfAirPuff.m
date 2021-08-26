%%
% get the pattern of motifs transforming through brain states during
% air puffing
clear;clc;
load('G:\temp\Mokoghost\fpCNMF\Results\thy1-gcamp6s-m2-0114-2\H_test.mat', 'H');
load('Synchron\thy1-gcamp6s-m2-0114-2\air puff m2 14-2.mat', 'sync1', 'sync2');
H_airpuff = zeros(size(H, 1), 30);
for i = 4:size(sync2, 1)
    num_shift = round((sync2(i, 1) - sync1(1, 1)) / 0.1);
    nearest = 0;
    min = 1000;
    for j = num_shift - 200:num_shift + 200
        if abs(sync1(j, 1) - sync2(i, 1)) < min
            min = abs(sync1(j, 1) - sync2(i, 1));
            nearest = j;
        end
    end
    disp(sync1(nearest));
    counter = 1;
    for j = nearest - 15:nearest + 14
        for k=1:size(H,1)
            if H(k,j)>0.04
                H_airpuff(k, counter)=H_airpuff(k, counter)+H(k,j);
            end
        end
        counter=counter+1;
    end
end
figure;
h = heatmap(H_airpuff);
h.Title ='airpuffÇ°ºó1.5ÃëµÄmotif activity';
h.GridVisible = 'off';