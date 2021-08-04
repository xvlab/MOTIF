clear;clc;
%% preprocess

% load directory that holds all the track files
dirname = uigetdirs('G:\temp\Mokoghost\data\', 'Select Source Dir');
signal_path = Preprocess(dirname, 'MAIN\black_mask.mat', 'MAIN\points.mat', true, 10, 10);

%% getMotifs
GetMotifs(signal_path, 'L', 20);

%% classify motifs and generate basic motifs
ClassifyMotifsAndGenerateBM();

clearvars
