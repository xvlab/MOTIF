clear;clc;
dirname = uigetdirs('G:\temp\Mokoghost\data\', 'Select Source Dir');
% preprocess

load directory that holds all the track files
signal_path = Preprocess(dirname, 'MAIN\black_mask.mat', 'MAIN\points.mat', true, 10,0,0);

% getMotifs
close all;
paths = GetMotifs(signal_path, 'L', 20);

% classify motifs and generate basic motifs
ClassifyMotifsAndGenerateBM(char(paths{1}), 20);

clearvars

% %% thy1-gcamp6s-m2-0114-2 with gsr
% [signal_path, parameters_path] = Preprocess(dirname, 'MAIN\black_mask.mat', 'MAIN\points.mat', true, 10, false, true, '', 'G:\temp\Mokoghost\fpCNMF\Results\thy1-gcamp6s-m2-0114-2(gsr)');
% close all;
% %%
% paths = GetMotifs(signal_path, 'L', 10);
% %%
% ClassifyMotifsAndGenerateBM(char(paths{1}), 10);

% %% thy1-gcamp6s-m2-0114-2 with L=20
% [signal_path, ~] = Preprocess(dirname, 'MAIN\black_mask.mat', 'MAIN\points.mat', false, 10, true, true, parameters_path, 'G:\temp\Mokoghost\fpCNMF\Results\thy1-gcamp6s-m2-0114-2(motif-2s)');
% close all;
% paths = GetMotifs(signal_path, 'L', 20);
% ClassifyMotifsAndGenerateBM(char(paths{1}), 20);
% clearvars
