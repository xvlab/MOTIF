clear;clc;
load('D:\mokoghost\fpCNMF\Results\H_test.mat', 'H');
for i=1:size(H,1)
    subplot(5,3,i);
    data=squeeze(H(i,:));
    data=data(data>0.001);
    histogram(data);title("Motif"+i);
end
