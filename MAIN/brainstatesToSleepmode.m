clear;clc;
load('MAIN\mask.mat','ans');
basic_motifs=zeros(171,171,20,14);
for i=1:14
    load("Results\basic motifs\basic_motif"+i+".mat");
    basic_motifs(:,:,:,i)=temp;
end
