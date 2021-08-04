clear;clc;
%% preprocess

% load directory that holds all the track files
dirname = uigetdirs('G:\temp\Mokoghost\data\', 'Select Source Dir');
signal_path = Preprocess(dirname, 'MAIN\black_mask.mat', 'MAIN\points.mat', false, 10, 10);

%% getMotifs
GetMotifs();

%% classify motifs and generate basic motifs
ClassifyMotifsAndGenerateBM();

clearvars
