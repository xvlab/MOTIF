clear;clc;
load('\\192.168.3.146\public\临时文件\xpy\Thy1-GCaMP6s-M4-K-airpuff-0706\datas.mat');
denoice_emg=emg1-emg2;
[S_eeg, F_eeg, T_eeg, P_eeg] = spectrogram(eeg, 4096, 2048, 4096, 1000);
[S_denoice_emg, F_denoice_emg, T_denoice_emg, P_denoice_emg] = spectrogram(denoice_emg, 4096, 2048, 4096, 1000);
% [S_emg2, F_emg2, T_emg2, P_emg2] = spectrogram(emg2, 4096, 2048, 4096, 1000);

figure;
subplot(2, 1, 1);
imagesc(T_eeg, F_eeg, 20 * log10((abs(S_eeg)))); xlabel('time'); ylabel('Freqency'); title('eeg');
subplot(2, 1, 2);
imagesc(T_denoice_emg, F_denoice_emg, 20 * log10((abs(S_denoice_emg)))); xlabel('time'); ylabel('Freqency'); title('emg');
% subplot(1, 3, 3);
% imagesc(T_emg2, F_emg2, 20 * log10((abs(S_emg2)))); xlabel('time'); ylabel('Freqency'); title('emg2');
colorbar;
