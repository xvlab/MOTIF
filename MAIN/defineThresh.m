clear;clc;
load('D:\mokoghost\fpCNMF\Results\H_test.mat', 'H');
%test how many motifs will happen at one time
ratio = zeros(size(H, 1), size(H, 2));
for dim = 1:size(H, 1)
    for i = 1:size(H, 2)
        H_t = sort(H(:, i), 'descend');
        ratio(dim, i) = H_t(1) / H_t(dim);
    end
end
med_ratio = median(ratio, 2);
min_ratio = min(ratio, [], 2);
max_ratio = max(ratio, [], 2);
%it turns out that "1 motifs happens simultaneously" would be a plausible
%assumption and plus, the seqCNMF is event-based, so there should be only
%one motif happens at one time
amount = size(H, 2)/10;
threshs = 0:0.01:1;
counter = 0;
counter_last = 0;
for idx = 1:size(threshs,2)
    for i = 1:size(H, 2)
        for j = 1:size(H, 1)
            if H(j, i) > threshs(1,idx)
                counter = counter + 1;
            end
        end
    end
    if counter <= amount
        disp(threshs(idx - 1));
        disp(counter_last);
        break;
    end
    counter_last = counter;
    counter = 0;
end
%the threshold is 0.08