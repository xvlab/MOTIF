function AlignPCA(sync1, sync2, coeff, all)
    if all
        figure;
        for i = 1:4
            subplot(4, 1, i);
            plot(sync1, coeff(:, i));
            % disp(ylim);
            % ylim = get(gca, 'Ylim');
            hold on
            for j = 4:size(sync2)
                plot([sync2(j), sync2(j)], ylim, 'm:');
            end
        end
    else
        strength = readtable('\\192.168.3.146\public\临时文件\xpy\Values.xlsx');
        H_aug = table2array(strength(:, 2))';
        H = coeff';
        H = [H_aug; H];
        H_airpuff = zeros(size(H, 1), 200);
        for i = 4:size(sync2, 1)
            num_shift = round((sync2(i, 1) - sync1(1, 1)) / 0.1) - 10;
            nearest = 0;
            min = 1000;
            for j = num_shift:num_shift + 20
                if abs(sync1(j, 1) - sync2(i, 1)) < min
                    min = abs(sync1(j, 1) - sync2(i, 1));
                    nearest = j;
                end
            end
            counter = 1;
            for j = nearest - 100:nearest + 100 - 1
                for k = 1:size(H, 1)
                    H_airpuff(k, counter) = H_airpuff(k, counter) + H(k, j);
                end
                counter = counter + 1;
            end
        end
        H_airpuff=H_airpuff/size(sync2, 1);
        x = 1:size(H_airpuff, 2);
        subplot(7, 1, 1);
        plot(x, H_airpuff(1, :)); title('区域强度');
        for i = 2:7
            subplot(7, 1, i);
            plot(x, H_airpuff(i, :)); title("PC" + num2str(i-1));
        end
    end
end
