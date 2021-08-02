%%
% get the pattern of motifs transforming through brain states during
% sleeping
clear;clc;
load('D:\mokoghost\fpCNMF\Results\thy1-gcamp6s-m2-0112-3\H_test.mat', 'H');
load('Synchron\thy1-gcamp6s-m2-0112-3\brainstates.mat', 'sync', 'brainState_01');
H_sync_brainstate = zeros(size(H, 1) + 1, size(H, 2));
for i = 1:size(H, 2)
    H_sync_brainstate(1:14, i) = H(:, i);
    H_sync_brainstate(15, i) = brainState_01(floor(sync(i) / 5) + 1);
end
save("H_sync_brainstate", 'H_sync_brainstate');
motif_threshold = 0.12;
H_states.wake_mean = zeros(14, 1); %the mean of h for each motif
H_states.NREM_mean = zeros(14, 1);
H_states.REM_mean = zeros(14, 1);
H_states.wake_frequency = zeros(14, 9);
H_states.NREM_frequency = zeros(14, 9);
H_states.REM_frequency = zeros(14, 9);
H_states.wake_frequency_thresh = zeros(14, 1);
H_states.NREM_frequency_thresh = zeros(14, 1);
H_states.REM_frequency_thresh = zeros(14, 1);
wake_counter = 0;
NREM_counter = 0;
REM_counter = 0;
%calculate the motifs for each state
for i = 1:size(H, 2)
    if H_sync_brainstate(15, i) == 1
        wake_counter = wake_counter + 1;
        H_states.wake_mean(:, 1) = H_states.wake_mean(:, 1) + H_sync_brainstate(1:14, i);
        [H_states.wake_frequency, H_states.wake_frequency_thresh] = calculateFrequency(motif_threshold, H_states.wake_frequency_thresh, H_states.wake_frequency, squeeze(H_sync_brainstate(1:14, i)));
    elseif H_sync_brainstate(15, i) == 0
        NREM_counter = NREM_counter + 1;
        H_states.NREM_mean(:, 1) = H_states.NREM_mean(:, 1) + H_sync_brainstate(1:14, i);
        [H_states.NREM_frequency, H_states.NREM_frequency_thresh] = calculateFrequency(motif_threshold, H_states.NREM_frequency_thresh, H_states.NREM_frequency, squeeze(H_sync_brainstate(1:14, i)));
    elseif H_sync_brainstate(15, i) == -1
        REM_counter = REM_counter + 1;
        H_states.REM_mean(:, 1) = H_states.REM_mean(:, 1) + H_sync_brainstate(1:14, i);
        [H_states.REM_frequency, H_states.REM_frequency_thresh] = calculateFrequency(motif_threshold, H_states.REM_frequency_thresh, H_states.REM_frequency, squeeze(H_sync_brainstate(1:14, i)));
    end
end
H_states.wake_mean(:, 1) = H_states.wake_mean(:, 1) / wake_counter;
H_states.NREM_mean(:, 1) = H_states.NREM_mean(:, 1) / NREM_counter;
H_states.REM_mean(:, 1) = H_states.REM_mean(:, 1) / REM_counter;
%%
%save data into xls and mat
motifName = strings(1, 14);
for i = 1:14
    motifName(i) = "motif" + i;
end
save('H_states', 'H_states');
wake_mean = table(H_states.wake_mean, 'RowNames', motifName);
NREM_mean = table(H_states.NREM_mean, 'RowNames', motifName);
REM_mean = table(H_states.REM_mean, 'RowNames', motifName);
wake_frequency = table(H_states.wake_frequency, 'RowNames', motifName);
NREM_frequency = table(H_states.NREM_frequency, 'RowNames', motifName);
REM_frequency = table(H_states.REM_frequency, 'RowNames', motifName);
wake_frequency_thresh = table(H_states.wake_frequency_thresh, 'RowNames', motifName);
NREM_frequency_thresh = table(H_states.NREM_frequency_thresh, 'RowNames', motifName);
REM_frequency_thresh = table(H_states.REM_frequency_thresh, 'RowNames', motifName);
writetable(wake_mean, "wake_mean.xls", 'WriteRowNames', true);
writetable(NREM_mean, "NREM_mean.xls", 'WriteRowNames', true);
writetable(REM_mean, "REM_mean.xls", 'WriteRowNames', true);
writetable(wake_frequency, "wake_frequency.xls", 'WriteRowNames', true);
writetable(NREM_frequency, "NREM_frequency.xls", 'WriteRowNames', true);
writetable(REM_frequency, "REM_frequency.xls", 'WriteRowNames', true);
writetable(wake_frequency_thresh, "wake_frequency_thresh.xls", 'WriteRowNames', true);
writetable(NREM_frequency_thresh, "NREM_frequency_thresh.xls", 'WriteRowNames', true);
writetable(REM_frequency_thresh, "REM_frequency_thresh.xls", 'WriteRowNames', true);
%%
%calculate the motifs happened during state transformation
lastState = H_sync_brainstate(15, 1);
counter = 0;
for i = 1:size(brainState_01)
    if brainState_01(i, 1) ~= lastState
        lastState = brainState_01(i, 1);
        counter = counter + 1;
    end
end
H_transforming = zeros(counter, 55, 15);
counter = 0;
lastState = H_sync_brainstate(15, 1);
for i = 1:size(H, 2)
    if H_sync_brainstate(15, i) ~= lastState
        counter = counter + 1;
        for j = -49:5
            for k = 1:14
                if H_sync_brainstate(k, i + j) > motif_threshold
                    H_transforming(counter, j + 50, k) = H_sync_brainstate(k, i + j);
                else
                    H_transforming(counter, j + 50, k) = 0;
                end
            end
            if j < 0
                H_transforming(counter, j + 50, 15) = lastState;
            else
                H_transforming(counter, j + 50, 15) = H_sync_brainstate(15, i);
            end
        end
        lastState = H_sync_brainstate(15, i);
    end
end
%visualize the transformation
% pic_num = 2;
% map = squeeze(H_transforming(pic_num, :, 1:14))';
% if H_transforming(pic_num, 5, 15) == 0 && H_transforming(pic_num, 55, 15) == 1
%     label = "from NREM to wake";
% elseif H_transforming(pic_num, 5, 15) == 0 && H_transforming(pic_num, 55, 15) == -1
%     label = "from NREM to REM";
% elseif H_transforming(pic_num, 5, 15) == 1 && H_transforming(pic_num, 55, 15) == 0
%     label = "from wake to NREM";
% elseif H_transforming(pic_num, 5, 15) == 1 && H_transforming(pic_num, 55, 15) == -1
%     label = "from wake to REM";
% elseif H_transforming(pic_num, 5, 15) == -1 && H_transforming(pic_num, 55, 15) == 0
%     label = "from REM to NREM";
% elseif H_transforming(pic_num, 5, 15) == -1 && H_transforming(pic_num, 55, 15) == 1
%     label = "from REM to wake";
% end
% h = heatmap(map);
% h.Title = label;
% h.GridVisible = 'off';

maps.NREM_to_wake = zeros(14, 55);
maps.NREM_to_REM = zeros(14, 55);
maps.wake_to_NREM = zeros(14, 55);
% maps.wake_to_REM = zeros(14, 55);
% maps.REM_to_NREM = zeros(14, 55);
maps.REM_to_wake = zeros(14, 55);
for i = 1:size(H_transforming, 1)
    if H_transforming(i, 5, 15) == 0 && H_transforming(i, 55, 15) == 1
        maps.NREM_to_wake = maps.NREM_to_wake + squeeze(H_transforming(i, :, 1:14))';
    elseif H_transforming(i, 5, 15) == 0 && H_transforming(i, 55, 15) == -1
        maps.NREM_to_REM = maps.NREM_to_REM + squeeze(H_transforming(i, :, 1:14))';
    elseif H_transforming(i, 5, 15) == 1 && H_transforming(i, 55, 15) == 0
        maps.wake_to_NREM = maps.wake_to_NREM + squeeze(H_transforming(i, :, 1:14))';
%     elseif H_transforming(i, 5, 15) == 1 && H_transforming(i, 55, 15) == -1
%         maps.wake_to_REM = maps.wake_to_REM + squeeze(H_transforming(i, :, 1:14))';
%     elseif H_transforming(i, 5, 15) == -1 && H_transforming(i, 55, 15) == 0
%         maps.REM_to_NREM = maps.REM_to_NREM + squeeze(H_transforming(i, :, 1:14))';
    elseif H_transforming(i, 5, 15) == -1 && H_transforming(i, 55, 15) == 1
        maps.REM_to_wake = maps.REM_to_wake + squeeze(H_transforming(i, :, 1:14))';
    end
end
fields=fieldnames(maps);
for i=1:size(fields)
    subplot(2,2,i)
    k = fields(i);
    key = k{1};
    mapNow = maps.(key);
    h = heatmap(mapNow);
    h.Title =string(k{1}).replace('_',' ');
    h.GridVisible = 'off';
end
% for i = 1:size(H_transforming, 1)/2
%     map = squeeze(H_transforming(i, :, 1:14));
%     subplot(5, 5, i);
%     heatmap(map);
% end
%%
% longer time
lastState = H_sync_brainstate(15, 1);
counter = 0;
for i = 1:size(brainState_01)
    if brainState_01(i, 1) ~= lastState
        lastState = brainState_01(i, 1);
        counter = counter + 1;
    end
end
H_transforming_longer = zeros(counter, 200, 15);
counter = 0;
lastState = H_sync_brainstate(15, 1);
for i = 1:size(H, 2)
    if H_sync_brainstate(15, i) ~= lastState
        counter = counter + 1;
        for j = -99:100
            for k = 1:14
                if H_sync_brainstate(k, i + j) > motif_threshold
                    H_transforming_longer(counter, j + 100, k) = H_sync_brainstate(k, i + j);
                else
                    H_transforming_longer(counter, j + 100, k) = 0;
                end
            end
            if j < 0
                H_transforming_longer(counter, j + 100, 15) = lastState;
            else
                H_transforming_longer(counter, j + 100, 15) = H_sync_brainstate(15, i);
            end
        end
        lastState = H_sync_brainstate(15, i);
    end
end
maps.NREM_to_wake = zeros(14, 200);
maps.NREM_to_REM = zeros(14, 200);
maps.wake_to_NREM = zeros(14, 200);
maps.REM_to_wake = zeros(14, 200);
for i = 1:size(H_transforming_longer, 1)
    if H_transforming_longer(i, 5, 15) == 0 && H_transforming_longer(i, 150, 15) == 1
        maps.NREM_to_wake = maps.NREM_to_wake + squeeze(H_transforming_longer(i, :, 1:14))';
    elseif H_transforming_longer(i, 5, 15) == 0 && H_transforming_longer(i, 150, 15) == -1
        maps.NREM_to_REM = maps.NREM_to_REM + squeeze(H_transforming_longer(i, :, 1:14))';
    elseif H_transforming_longer(i, 5, 15) == 1 && H_transforming_longer(i, 150, 15) == 0
        maps.wake_to_NREM = maps.wake_to_NREM + squeeze(H_transforming_longer(i, :, 1:14))';
    elseif H_transforming_longer(i, 5, 15) == -1 && H_transforming_longer(i, 150, 15) == 1
        maps.REM_to_wake = maps.REM_to_wake + squeeze(H_transforming_longer(i, :, 1:14))';
    end
end
fields=fieldnames(maps);
for i=1:size(fields)
    subplot(2,2,i)
    k = fields(i);
    key = k{1};
    mapNow = maps.(key);
    h = heatmap(mapNow);
    h.Title =string(k{1}).replace('_',' ');
    h.GridVisible = 'off';
end
