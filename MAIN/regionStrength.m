% clc; clear;
strength = readtable('\\192.168.3.146\public\ÁÙÊ±ÎÄ¼þ\xpy\Values.xlsx');
H = table2array(strength(:,2))';

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
x = 1:size(H_airpuff, 2);
plot(x, H_airpuff(1, :));
